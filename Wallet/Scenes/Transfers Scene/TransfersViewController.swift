//
//  TransfersViewController.swift
//  Wallet
//
//  Created by Bernardo Alecrim on 01/10/2021.
//

import UIKit

enum Section {
    case transfers
}

struct TransferCellViewModel: Equatable, Hashable {
    let originAddress: String
    let amount: String
    let transactionIndex: Int
}

class TransfersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!

    lazy var dataSource = buildDataSource()
    let viewModel = TransfersViewModel()

    override func viewDidLoad() {

        viewModel.stateListener = { [weak self] state in
            DispatchQueue.main.async {
                self?.handleStateUpdates(newState: state)
            }
        }

        viewModel.resetStateMachine()
        tableView.dataSource = self.dataSource
    }

    func handleStateUpdates(newState: TransfersState) {

        var tableViewHidden = true
        var activityIndicatorHidden = true
        var errorLabelHidden = true

        switch newState {
        case let .error(message):
            errorLabel.text = message
            errorLabelHidden = false
        case let .loaded(transfers):
            var snapshot = NSDiffableDataSourceSnapshot<Section, TransferCellViewModel>()

            snapshot.appendSections([.transfers])
            snapshot.appendItems(transfers, toSection: .transfers)

            dataSource.apply(snapshot, animatingDifferences: true)
            tableViewHidden = false
        case .loading:
            activityIndicator.startAnimating()
            activityIndicatorHidden = false
        }

        self.tableView.isHidden = tableViewHidden
        self.activityIndicator.isHidden = activityIndicatorHidden
        self.errorLabel.isHidden = errorLabelHidden

    }

    func buildDataSource() -> UITableViewDiffableDataSource<Section, TransferCellViewModel> {

        return UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: {  tableView, indexPath, transferViewModel in
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "transferCell",
                    for: indexPath
                )

                cell.textLabel?.text = transferViewModel.amount
                cell.detailTextLabel?.text = transferViewModel.originAddress

                return cell
            }
        )
    }

}
