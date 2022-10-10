const { ethers, network } = require("hardhat")
const fs = require("fs")
const FRONTEND_ADDRESS_FILE = "../next.js-lottery/constants/contractAddress.json"

const FRONTEND_ABI_FILE = "../next.js-lottery/constants/contractAbi.json"
module.exports = async function () {
    if (process.env.UPDATE_FRONTEND) {
        console.log("Updating Frontend")
        updtaeContractAddress()
        updateAbi()
    }
}
async function updateAbi() {
    const raffle = await ethers.getContract("Raffle")
    fs.writeFileSync(FRONTEND_ABI_FILE, raffle.interface.format(ethers.utils.FormatTypes.json))
}
async function updtaeContractAddress() {
    const raffle = await ethers.getContract("Raffle")
    const contractAddresses = JSON.parse(fs.readFileSync(FRONTEND_ADDRESS_FILE, "utf8"))
    console.log(`contract addresses file obj =${contractAddresses}`)
    if (network.config.chainId.toString() in contractAddresses) {
        if (!contractAddresses[network.config.chainId.toString()].includes(raffle.address))
            contractAddresses[network.config.chainId.toString()].push(raffle.address)
    } else {
        contractAddresses[network.config.chainId.toString()] = [raffle.address]
    }
    fs.writeFileSync(FRONTEND_ADDRESS_FILE, JSON.stringify(contractAddresses))
}
module.exports.tags = ["all", "frontend"]
