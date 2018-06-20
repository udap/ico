const UDAPCrowdsale = artifacts.require("UDAPCrowdsale");
const UPToken = artifacts.require("UPToken");
var BigNumber = require('bignumber.js');

contract('UDAPCrowdsale test', async (accounts) => {

    let buyerAccount = accounts[3];
    let receiveEthWallet;
    let crowdsale;
    let crowdsale_owner;
    let uptoken;

    before(async () => {
        crowdsale = await UDAPCrowdsale.deployed();
        uptoken = await UPToken.deployed();
        receiveEthWallet = await crowdsale.wallet.call();
        crowdsale_owner =  await crowdsale.owner.call();
    });

    it("UPToken should transfer token correctly", async () => {
        let amount = 100000000 * Math.pow(10,18);
        let  transaction = await uptoken.transfer(crowdsale.address,amount,{from: accounts[0]});
        let balance = await uptoken.balanceOf.call(crowdsale.address);
        assert.equal(balance, amount);
    });

    it("should register whitelist correctly", async () => {
        let  transaction = await crowdsale.addToWhitelist(buyerAccount,{from: crowdsale_owner});
        let whitelistIn = await crowdsale.whitelist.call(buyerAccount);
        assert.equal(whitelistIn, true);
    });

    it("should opened crowdsale ", async () => {
        let currentTime = parseInt(new Date().getTime()/1000);
        let openingTime = await crowdsale.openingTime.call();
        let closingTime = await crowdsale.closingTime.call();
        if(openingTime > currentTime){
            let sleepTime = (openingTime - currentTime)*1000;
            await new Promise(resolve => setTimeout(resolve,sleepTime));
        }
        currentTime = parseInt(new Date().getTime()/1000);
        assert.isAtLeast(currentTime, openingTime,"currentTime is greater or equal to openingTime");
        assert.isAtLeast(closingTime, currentTime,"closingTime is greater or equal to currentTime");
    });

    it("should buy token correctly ", async () => {
        //accounts[0] use 1 ether to buy tokens
        let etherAmount = web3.toWei(1, "ether");
        let balanceOfCrowdsale_old = await uptoken.balanceOf.call(crowdsale.address);

        let result = await crowdsale.sendTransaction({
            from :buyerAccount,
            to:crowdsale.address,
            value:etherAmount.toString(),
            gasPrice:web3.toWei(20, "gwei").toString()
        });
        let rate = await crowdsale.rate.call();
        let balanceOfBuyer = await uptoken.balanceOf.call(buyerAccount);
        assert.equal(balanceOfBuyer,rate*etherAmount,"buyer token balance equal to rate * etherAmount");


        let balanceOfCrowdsale = await uptoken.balanceOf.call(crowdsale.address);
        assert.isTrue(balanceOfCrowdsale_old.equals(balanceOfBuyer.plus(balanceOfCrowdsale)),"old balanceOfCrowdsale equal to balanceOfBuyer + balanceOfCrowdsale");

    });



   /* it("should call a function that depends on a linked library", async () => {
        let meta = await MetaCoin.deployed();
        let outCoinBalance = await meta.getBalance.call(accounts[0]);
        let metaCoinBalance = outCoinBalance.toNumber();
        let outCoinBalanceEth = await meta.getBalanceInEth.call(accounts[0]);
        let metaCoinEthBalance = outCoinBalanceEth.toNumber();
        assert.equal(metaCoinEthBalance, 2 * metaCoinBalance);

    });

    it("should send coin correctly", async () => {

        // Get initial balances of first and second account.
        let account_one = accounts[0];
        let account_two = accounts[1];

        let amount = 10;


        let instance = await MetaCoin.deployed();
        let meta = instance;

        let balance = await meta.getBalance.call(account_one);
        let account_one_starting_balance = balance.toNumber();

        balance = await meta.getBalance.call(account_two);
        let account_two_starting_balance = balance.toNumber();
        await meta.sendCoin(account_two, amount, {from: account_one});

        balance = await meta.getBalance.call(account_one);
        let account_one_ending_balance = balance.toNumber();

        balance = await meta.getBalance.call(account_two);
        let account_two_ending_balance = balance.toNumber();

        assert.equal(account_one_ending_balance, account_one_starting_balance - amount, "Amount wasn't correctly taken from the sender");
        assert.equal(account_two_ending_balance, account_two_starting_balance + amount, "Amount wasn't correctly sent to the receiver");
    });*/

});