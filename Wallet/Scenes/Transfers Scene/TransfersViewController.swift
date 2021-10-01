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

    lazy var dataSource = buildDataSource()
    let viewModel = TransfersViewModel()

    override func viewDidLoad() {

        viewModel.stateListener = { [weak self] state in
            self?.handleStateUpdates(newState: state)
        }

        viewModel.resetStateMachine()
        tableView.dataSource = self.dataSource
    }

    func handleStateUpdates(newState: TransfersState) {
        switch newState {
        case let .error(message):
            break //TODO
        case let .loaded(transfers):
            var snapshot = NSDiffableDataSourceSnapshot<Section, TransferCellViewModel>()

            snapshot.appendSections([.transfers])
            snapshot.appendItems(transfers, toSection: .transfers)

            dataSource.apply(snapshot, animatingDifferences: true)
        case .loading:
            break //TODO
        }

        print(newState)
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
