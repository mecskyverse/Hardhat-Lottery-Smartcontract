const { developementChains } = require("../helper-hardhat-config")
module.exports = async function ({ getNamedAcoounts, deployments }) {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAcoounts()
    const chainId = network.config.chainId
}
