//
//  BalanceViewModel.swift
//  Wallet
//
//  Created by Bernardo Alecrim on 30/09/2021.
//

import Foundation
import web3
import BigInt

enum BalanceState {
    case loading
    case loaded(balance: String)
    case error(message: String)
}

class BalanceViewModel {

    private let proxy = URL(string: "https://ropsten.infura.io/v3/735489d9f846491faae7a31e1862d24b")!
    private lazy var client = EthereumClient(url: proxy)

    private var walletAddress: String
    private var walletPrivateKey: String

    private(set) var currentState = BalanceState.loading {
        didSet {
            stateListener?(currentState)
        }
    }

    var stateListener: ((BalanceState) -> Void)?

    init(walletAddress: String = Secrets.walletID, walletPrivateKey: String = Secrets.walletPrivateKey) {
        self.walletAddress = walletAddress
        self.walletPrivateKey = walletPrivateKey
    }

    func resetStateMachine() {
        currentState = .loading
        refreshWalletState(for: EthereumAddress(walletAddress), using: client)
    }

    func initiateTransfer() {
        executeTransfer()
    }

}

private extension BalanceViewModel {

    func buildNumberFormatter() -> NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2

        return numberFormatter
    }

    func getEthereumValue(from wei: BigUInt) -> Decimal? {
        let stringNumber = String(wei)

        guard let decimalWei = Decimal(string: stringNumber) else {
            return nil
        }

        return decimalWei / 1_000_000_000_000_000_000
    }

    func refreshWalletState(for address: EthereumAddress, using client: EthereumClient) {

        client.eth_getBalance(address: address, block: .Latest) { error, balance in

            if let error = error {
                self.currentState = .error(message: "Error: " + error.localizedDescription)
                return
            }

            guard let balance = balance, let ethBalance = self.getEthereumValue(from: balance) else {
                self.currentState = .error(message: "Error: failed to unwrap balance")
                return
            }

            let numberFormatter = self.buildNumberFormatter()
            let formatted = numberFormatter.string(from: ethBalance as NSDecimalNumber)

            self.currentState = .loaded(balance: formatted! + " ETH")

        }

    }

    func executeTransfer() {

        let transfer = TransferManager(
            _wallet: EthereumAddress(Secrets.walletID),
            _token: EthereumAddress("0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"),
            _to: EthereumAddress(Secrets.recipientWallet),
            _amount: 10000000000000000,
            _data: Data()
        )

        let gasPrice: BigUInt = 12 * (1_000_000_000)
        let gasLimit: BigUInt = 250_000

        guard let transaction = try? transfer.transaction(gasPrice: gasPrice, gasLimit: gasLimit) else {
            self.currentState = .error(message: "Error: failed to generate transaction")
            return
        }

        let keyStorage = EthereumKeyLocalStorage()
        try? keyStorage.storePrivateKey(key: Secrets.walletPrivateKey.web3.hexData!)

        guard let account = try? EthereumAccount(keyStorage: keyStorage) else {
            self.currentState = .error(message: "Error: failed to generate account")
            return
        }

        client.eth_sendRawTransaction(transaction, withAccount: account) { error, result in
            if let error = error {
                self.currentState = .error(message: "Error: " + error.localizedDescription)
                return
            }

            guard let result = result else {
                self.currentState = .error(message: "Error: failed to unwrap transaction result")
                print(result)
                return
            }

            self.currentState = .loading
            self.resetStateMachine()
        }

    }

}
