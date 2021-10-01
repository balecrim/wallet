//
//  TransfersViewModel.swift
//  Wallet
//
//  Created by Bernardo Alecrim on 01/10/2021.
//

import BigInt
import Foundation
import web3

enum TransfersState {
    case loading
    case loaded(transfers: [TransferCellViewModel])
    case error(message: String)
}

class TransfersViewModel {

    private let proxy = URL(string: "https://ropsten.infura.io/v3/735489d9f846491faae7a31e1862d24b")!
    private lazy var client = EthereumClient(url: proxy)

    private var walletAddress: String

    private(set) var currentState = TransfersState.loading {
        didSet {
            stateListener?(currentState)
        }
    }

    var stateListener: ((TransfersState) -> Void)?

    init(walletAddress: String = Secrets.walletID) {
        self.walletAddress = walletAddress
    }

    func resetStateMachine() {
        currentState = .loading
        refreshTransferList(to: EthereumAddress(walletAddress))
    }

}

private extension TransfersViewModel {

    func refreshTransferList(to walletAddress: EthereumAddress) {
        let erc20 = ERC20(client: client)

        erc20.transferEventsTo(
            recipient: walletAddress,
            fromBlock: .Earliest,
            toBlock: .Latest,
            completion: { self.updateTransferList(error: $0, events: $1) })
    }

    func updateTransferList(error: Error?, events: [ERC20Events.Transfer]?) {
        if let error = error {
            self.currentState = .error(message: "Error: " + error.localizedDescription)
            return
        }

        guard let events = events else {
            self.currentState = .error(message: "Error: failed to unwrap transfer list")
            return
        }

        let mapped = events.enumerated().map { index, event in
            TransferCellViewModel(
                originAddress: event.from.value,
                amount: String(event.value) + " wei",
                transactionIndex: index
            )
        }

        self.currentState = .loaded(transfers: mapped)
    }

}
