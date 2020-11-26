const { expect } = require('chai');
const ethers = require('ethers');
const bre = require('@nomiclabs/buidler');
const { gray, green } = require('chalk');

describe('Test', function() {
  let test;

  describe('when simulating the data to be sent', () => {
    let timestamps;
    let amounts;
    let packedData;

    function ensureEvenHex(hex) {
      if (hex.length % 2 === 0) {
        return hex;
      } else {
        return `0${hex}`
      }
    }

    function lenToBytes(len) {
      return ensureEvenHex((len / 2).toString(16));
    }

    function simulateData() {
      timestamps = [];
      amounts = [];
      packedData = '0x';

      const abiCoder = new ethers.utils.AbiCoder();

      for (let i = 0; i < 52; i++) {
        const timestamp = Math.floor(Date.now() / 1000) + i;
        timestamps.push(timestamp);

        const amount = Math.floor(5000 * Math.random());
        amounts.push(amount);

        const timestampHex = ensureEvenHex(timestamp.toString(16));
        const amountHex = ensureEvenHex(amount.toString(16));

        const timestampHexLen = lenToBytes(timestampHex.length);
        const amountHexLen = lenToBytes(amountHex.length);

        const timestampPacked =  `${timestampHexLen}${timestampHex}`;
        const amountPacked = `${amountHexLen}${amountHex}`;

        packedData += timestampPacked;
        packedData += amountPacked;
      }

      const data = abiCoder.encode(['uint64[]', 'uint256[]'], [timestamps, amounts]);
      console.log(gray(`> raw data (${data.length} bytes): ${data}`));

      console.log(gray(`> packed data (${packedData.length} bytes): ${packedData}`));
    }

    function showGasUsed({ ctx, receipt }) {
      ctx._runnable.title = `${ctx._runnable.title} (${green(receipt.gasUsed)}${gray(' gas)')}`;
    }

    before('simulate data', async () => {
      simulateData();
    });

    describe('when storing the data directly', () => {
      before('deploy Test contract', async () => {
        const Test = await bre.ethers.getContractFactory('Test');
        test = await Test.deploy();
      });

      // This would normally be a 'before', but using an 'it'
      // so that we can print gas used in the title
      it('stores the data', async function() {
        const tx = await test.setDataRaw(timestamps, amounts);
        const receipt = await tx.wait();

        showGasUsed({ ctx: this, receipt });
      });

      it('should have registered timestamps', async () => {
        const retrievedTimestamps = await test.getTimestamps();

        for (let i = 0; i < timestamps.length; i++) {
          const timestamp = timestamps[i];
          const retrievedTimestamp = retrievedTimestamps[i];

          expect(timestamp).to.equal(retrievedTimestamp);
        }
      });

      it('should have registered amounts', async () => {
        const retrievedAmounts = await test.getAmounts();

        for (let i = 0; i < amounts.length; i++) {
          const amount = amounts[i];
          const retrievedAmount = retrievedAmounts[i];

          expect(amount).to.equal(retrievedAmount);
        }
      });
    });

    describe('when storing the data packed', () => {
      before('deploy Test contract', async () => {
        const Test = await bre.ethers.getContractFactory('Test');
        test = await Test.deploy();
      });

      // This would normally be a 'before', but using an 'it'
      // so that we can print gas used in the title
      it('stores the data', async function() {
        const tx = await test.setDataPacked(packedData);
        const receipt = await tx.wait();

        showGasUsed({ ctx: this, receipt });
      });

      describe('when unpacking the data', () => {
        // This would normally be a 'before', but using an 'it'
        // so that we can print gas used in the title
        it('unpack the data', async function() {
          const tx = await test.unpackData();
          const receipt = await tx.wait();

          showGasUsed({ ctx: this, receipt });
        });

        it('should have registered timestamps', async () => {
          const retrievedTimestamps = await test.getTimestamps();

          for (let i = 0; i < timestamps.length; i++) {
            const timestamp = timestamps[i];
            const retrievedTimestamp = retrievedTimestamps[i];

            expect(timestamp).to.equal(retrievedTimestamp);
          }
        });

        it('should have registered amounts', async () => {
          const retrievedAmounts = await test.getAmounts();

          for (let i = 0; i < amounts.length; i++) {
            const amount = amounts[i];
            const retrievedAmount = retrievedAmounts[i];

            expect(amount).to.equal(retrievedAmount);
          }
        });
      });
    });
  });
});
