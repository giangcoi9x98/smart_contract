const DoMath = artifacts.require("DoMath")
const PeerToPPeerLendingContract = artifacts.require("PeerToPeerLendingContract")
const GCoin = artifacts.require("GCoin")


module.exports =  async function(deployer) {
  deployer.deploy(DoMath);
  deployer.link(DoMath, GCoin)
  deployer.deploy(GCoin)
  deployer.link(DoMath, PeerToPPeerLendingContract)
  deployer.link(GCoin,PeerToPPeerLendingContract)
  deployer.deploy(PeerToPPeerLendingContract,'0x298CB0fc302ba228AD21c4BAeF6a90B5f3d00F35')
};
