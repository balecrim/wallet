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

    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet private weak var walletBalanceLabel: UILabel!

    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.stateListener = { [weak self] state in
            DispatchQueue.main.async {
                self?.handleStateUpdates(newState: state)
            }
        }

        viewModel.resetStateMachine()
    }

    func handleStateUpdates(newState: BalanceState) {
        switch newState {
        case let .error(message):
            walletBalanceLabel.text = message

            activityIndicator.isHidden = true
            mainStackView.isHidden = false
        case let .loaded(balanceString):
            walletBalanceLabel.text = balanceString

            activityIndicator.isHidden = true
            mainStackView.isHidden = false
        case .loading:
            activityIndicator.startAnimating()

            activityIndicator.isHidden = false
            mainStackView.isHidden = true
        }
    }

    @IBAction func transferButtonPressed(_ sender: Any) {
        viewModel.initiateTransfer()
    }

}

