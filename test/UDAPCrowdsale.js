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

    it("should pause crowdsalea correctly", async () => {
        let paused = await crowdsale.paused.call();
        assert.isFalse(paused,"original paused is false");

        let transaction = await crowdsale.pause({from: crowdsale_owner});

        paused = await crowdsale.paused.call();
        assert.isTrue(paused,"after calling the pause() method, paused is true");

        //should can't buy tokens when paused
        let fn;
        crowdsale.sendTransaction({
            from :buyerAccount,
            to:crowdsale.address,
            value:web3.toWei(1, "ether"),
            gasPrice:web3.toWei(20, "gwei")
        }).catch(e => {
            fn = () => {throw e};
        }).finally(()=> {
            assert.throw(fn,Error,"VM Exception while processing transaction: revert");
        });
    });

    it("should unpause crowdsalea correctly", async () => {

        let transaction = await crowdsale.unpause({from: crowdsale_owner});

        let paused = await crowdsale.paused.call();
        assert.isFalse(paused,"after calling the unpause() method, paused is false");
    });

    it("should goal reached  correctly", async () => {

        let goalReached = await crowdsale.goalReached.call();
        assert.isFalse(goalReached,"at the beginning goalReached is false");

        let goal = await crowdsale.goal.call();

        let weiRaised = await crowdsale.weiRaised.call();

        //buy tokens
        let result = await crowdsale.sendTransaction({
            from :buyerAccount,
            to:crowdsale.address,
            value:goal.minus(weiRaised),
            gasPrice:web3.toWei(20, "gwei").toString()
        });

        goalReached = await crowdsale.goalReached.call();
        assert.isTrue(goalReached,"goalReached is true");
    });

    it("should cap reached  correctly", async () => {

        let capReached = await crowdsale.capReached.call();
        assert.isFalse(capReached,"at the beginning capReached is false");

        let cap = await crowdsale.cap.call();

        let weiRaised = await crowdsale.weiRaised.call();

        //buy tokens
        let result = await crowdsale.sendTransaction({
            from :buyerAccount,
            to:crowdsale.address,
            value:cap.minus(weiRaised),
            gasPrice:web3.toWei(20, "gwei").toString()
        });

        capReached = await crowdsale.capReached.call();
        assert.isTrue(capReached,"capReached is true");

        //should can't buy tokens when capReached
        let fn;
        crowdsale.sendTransaction({
            from :buyerAccount,
            to:crowdsale.address,
            value:web3.toWei(1, "ether"),
            gasPrice:web3.toWei(20, "gwei")
        }).catch(e => {
            fn = () => {throw e};
        }).finally(()=> {
            assert.throw(fn,Error,"VM Exception while processing transaction: revert");
        });

    });

    it("Waiting for crowdsale to close", async () => {
        let currentTime = parseInt(new Date().getTime()/1000);
        let closingTime = await crowdsale.closingTime.call();
        if(closingTime > currentTime){
            let sleepTime = (closingTime - currentTime)*1000;
            await new Promise(resolve => setTimeout(resolve,sleepTime));
        }
        let hasClosed = await crowdsale.hasClosed.call();
        assert.isTrue(hasClosed,"hasClosed is true");
    });











   /*

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