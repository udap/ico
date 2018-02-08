var UPToken = artifacts.require("UPToken");
contract('UPToken', function(accounts) {
  it("should have a cap 500,000,000", function() {
    var token;
    return UPToken.deployed().then(function(instance) {
      token = instance;
      return token.cap();
    }).then(function(cap){
      assert.equal(cap.toNumber(),500000000);
    })
  });
  it("should mint tokens", function() {
    var _to = accounts[1];
    var token;
    return UPToken.deployed().then(function(instance){
      token = instance;
      token.mint(_to, 10000);
      return token.balanceOf(accounts[1]);
    }).then(function(result){
      assert.equal(result.toNumber(),10000,"mint 10000 tokens was not in account2" );
    }).catch(function(e){
      console.log(e,'error');
    })
  });
});
