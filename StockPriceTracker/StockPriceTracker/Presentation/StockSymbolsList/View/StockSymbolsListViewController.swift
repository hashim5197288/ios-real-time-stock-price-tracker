//
//  StockSymbolsListViewController.swift
//  StockPriceTracker
//
//  Created by M.Hashim on 01/04/2026.
//

import UIKit

final class StockSymbolsListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var priceFeedSwitch: UISwitch!
    
    private var viewModel: StockSymbolListViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - Setup -

    private func setup() {
        let stockManager = StockManager()
        viewModel = StockSymbolListViewModel(stockManager: stockManager)
        viewModel.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        
        viewModel.loadStocks()
    }

    // MARK: - Actions
    @IBAction func priceFeedSwitchAction(_ sender: UISwitch) {
        sender.isOn ? viewModel.startFeed() :  viewModel.stopFeed()
    }
    
    @IBAction func sortListButton(_ sender: UIButton) {
        showSortingOptions()
    }

    private func sortPriceTapped() {
        viewModel.sortByPrice()
    }

    private func sortChangeTapped() {
        viewModel.sortByChange()
    }
    
    private func showSortingOptions() {
        let alert = UIAlertController(title: "Choose sorting option", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "by Price", style: .default, handler: {[weak self] UIAlertAction in
            guard let self = self else { return }
            sortPriceTapped()
        }))
        alert.addAction(UIAlertAction(title: "by Price Change", style: .default, handler: {[weak self]  UIAlertAction in
            guard let self = self else { return }
            sortChangeTapped()
        }))
        present(alert, animated: true)
    }
}

// MARK: - TableView -

extension StockSymbolsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        viewModel.stocks.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: StockSymbolsListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "StockCell") as! StockSymbolsListTableViewCell
        
        cell.configureCell(viewModel.stocks[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        let stock = viewModel.stocks[indexPath.row]
        
        let vc: StockSymbolDetailViewController = UIStoryboard(name: "StockSymbolDetail", bundle: nil).instantiateViewController(withIdentifier: "StockSymbolDetailViewController") as! StockSymbolDetailViewController
        vc.configure(symbol: stock.symbol, stockManager: viewModel.stockManager)
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - StockSymbolListViewModel Delegate
extension StockSymbolsListViewController: StockSymbolListViewModelDelegate {
    
    func didReload() {
        DispatchQueue.main.async {[weak self] in
            guard let self = self else { return }
            tableView.reloadData()
        }
    }
    
    func didUpdateConnection(_ isConnected: Bool) {
        DispatchQueue.main.async {[weak self] in
            guard let self = self else { return }
            statusLabel.text = isConnected ? "Connected" : "Disconnected"
            priceFeedSwitch.isOn = isConnected
        }
    }
}
