//
//  TableViewController.swift
//  PaymentsExample
//
//  Created by Neil Smith on 29/11/2019.
//  Copyright © 2019 Neil Smith. All rights reserved.
//

import UIKit

protocol TableViewControllerDataSource: AnyObject {
    func numberOfSections(_ tableViewController: TableViewController) -> Int
    func numberOfItems(in section: Int, tableViewController: TableViewController) -> Int
    func tableViewController(_ tableViewController: TableViewController, itemAt indexPath: IndexPath) -> TableViewItem?
}

protocol TableViewControllerDelegate: AnyObject {
    func tableViewController(_ tableViewController: TableViewController, didSelectItemAt indexPath: IndexPath)
}

struct TableViewItem {
    let title: String
    let detail: String
}

final class TableViewController: UIViewController {
    
    
    // MARK: Interface
    weak var dataSource: TableViewControllerDataSource?
    weak var delegate: TableViewControllerDelegate?
    
    func reload() {
        loadingIndicator.stopAnimating()
        tableView.reloadData()
    }

    
    // MARK: Subviews
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.dataSource = self
        tv.delegate = self
        tv.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.reuseID)
        tv.rowHeight = 56
        return tv
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .secondarySystemFill
        indicator.hidesWhenStopped = true
        return indicator
    }()


    // MARK:: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureLoadingIndicator()
    }
    
}


// MARK: - Setup
extension TableViewController {
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    private func configureLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        loadingIndicator.startAnimating()
    }
    
}


// MARK: - Table view data source
extension TableViewController: UITableViewDataSource, UITableViewDelegate {
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.numberOfSections(self) ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.numberOfItems(in: section, tableViewController: self) ?? 0
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.reuseID, for: indexPath)
        if let item = dataSource?.tableViewController(self, itemAt: indexPath) {
            cell.textLabel?.text = item.title
            cell.detailTextLabel?.text = item.detail
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.tableViewController(self, didSelectItemAt: indexPath)
    }

}


// MARK: - Table cell
final class TableViewCell: UITableViewCell {
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var reuseIdentifier: String? {
        TableViewCell.reuseID
    }
    
    static var reuseID: String {
        "TableViewCell"
    }
    
}
