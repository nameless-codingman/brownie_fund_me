from brownie import FundMe, accounts, config, MockV3Aggregator, network
from web3 import Web3

FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork"]
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"]
DECIMALS = 8
STARTING_PRICE = 200000000


def get_account():
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])


def deploy_mocks():
    print(f"the active network is {network.show_active()}")
    print("deploy mock ....")
    if len(MockV3Aggregator) <= 0:

        MockV3Aggregator.delopy(DECIMALS, Web3.toWei(
            STARTING_PRICE, "ether"), {"from": get_account()})
    print("mock! deploy!!!")
    price_feed_address = MockV3Aggregator[-1].address
