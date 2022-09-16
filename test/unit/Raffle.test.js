const { network, getNamedAccounts, deployments } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config")

!developmentChains.includes(network.name)
    ? describe.skip
    : describe(async function () {
          let raffle, vrfCoordinatorV2Mock

          beforeEach(async function () {
              const { deployer } = getNamedAccounts()
              await deployments.fixture(["all"])
          })
      })
