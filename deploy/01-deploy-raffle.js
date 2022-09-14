const { deployments, network, ethers } = require("hardhat")
const { developmentChains, networkConfig } = require("../helper-hardhat-config")

module.exports = async function ({ getNamedAccounts, deployements }) {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    let vrfCoordinatorV2Address
    if (developmentChains.includes(network.name)) {
        const VRFCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock")
        vrfCoordinatorV2Address = VRFCoordinatorV2Mock.address
    } else {
        vrfCoordinatorV2Address = networkConfig[chainId][vrfCoordinatorV2]
    }
    const args = []
    const raffle = await deploy("Raffle", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: network.config.blockConfirmattions || 1,
    })
}
