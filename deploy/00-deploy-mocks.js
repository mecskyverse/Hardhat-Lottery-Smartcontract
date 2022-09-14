const { ethers } = require("hardhat")

const { developementChains } = require("../helper-hardhat-config")
module.exports = async function ({ getNamedAcoounts, deployments }) {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAcoounts()
    const chainId = network.config.chainId

    const BASE_FEE = ethers.utils.parseEther("0.25")
    const GAS_PRICE_LINK = 1e9 //calculated value based on the gas price of the chain

    const args = [BASE_FEE, GAS_PRICE_LINK]

    if (developementChains.includes(network.name)) {
        log("Local Network Detected! Deploying Mocks.....")
        await deploy("VRFCoordinatorV2Mock", {
            from: deployer,
            log: true,
            args: args,
        })
    }
}
