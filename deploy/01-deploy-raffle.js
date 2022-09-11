const { deployments } = require("hardhat")

module.exports = async function ({ getNamedAccounts, deployements }) {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts
}
