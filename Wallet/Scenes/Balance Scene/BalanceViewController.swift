//
//  BalanceViewController.swift
//  Wallet
//
//  Created by Bernardo Alecrim on 30/09/2021.
//

import UIKit
import web3

class ViewController: UIViewController {

    var viewModel = BalanceViewModel()

    @IBOutlet private weak var walletBalanceLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.stateListener = { [weak self] state in
            DispatchQueue.main.async {
                self?.handleStateUpdates(newState: state)
            }
        }

        viewModel.startStateMachine()
    }

    func handleStateUpdates(newState: BalanceState) {
        switch newState {
        case let .error(message):
            break //TODO
        case let .loaded(balanceString):
            walletBalanceLabel.text = balanceString
        case .loading:
            break //TODO
        }

        print(newState)
    }

}

