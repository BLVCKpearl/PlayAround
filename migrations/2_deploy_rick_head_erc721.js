// migrations/3_deploy_ERC721.js
const RickHeadERC721 = artifacts.require('RickHeadERC721');

module.exports = async function (deployer) {
  await deployer.deploy(RickHeadERC721);
};