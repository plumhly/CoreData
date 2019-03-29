//
//  TableViewDataSource.swift
//  CoreData_Ex
//
//  Created by Plum on 2019/3/6.
//  Copyright © 2019 Tima. All rights reserved.
//

import UIKit
import CoreData


class TableViewDataSource<Delegate: TableViewDataSourceDelegate>: NSObject, UITableViewDataSource,  NSFetchedResultsControllerDelegate {
    typealias Object = Delegate.Object
    typealias Cell = Delegate.Cell
    
    fileprivate let tableView: UITableView
    fileprivate let cellIdentifier: String
    fileprivate let fetchedResultsController: NSFetchedResultsController<Object>
    fileprivate weak var delegate: Delegate!
    
    var selecteObject: Object? {
        guard let index = tableView.indexPathForSelectedRow else {
            return nil
        }
        return objectAtIndexPath(index)
    }
    
    
    func objectAtIndexPath(_ indexPath: IndexPath ) -> Object? {
        return fetchedResultsController.object(at: indexPath)
    }
    
    init(tableView: UITableView, cellIdentifier: String, fetchedResultsController: NSFetchedResultsController<Object>, delegate: Delegate) {
        self.tableView = tableView
        self.cellIdentifier = cellIdentifier
        self.fetchedResultsController = fetchedResultsController
        self.delegate = delegate
        
        super.init()
        
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
//        tableView.dataSource = self
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        return section.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = fetchedResultsController.object(at: indexPath)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? Cell else { fatalError("Unknown cell typy at indexPath:\(indexPath)") }
        delegate.configure(cell, for: object)
        return cell
    }
}

