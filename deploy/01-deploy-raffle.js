const { deployments, network } = require("hardhat")

module.exports = async function ({ getNamedAccounts, deployements }) {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const raffe = await deploy("Raffle", {
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: network.config.blockConfirmattions || 1,
    })
}
