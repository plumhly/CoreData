//
//  TableViewDataSource.swift
//  CoreData_Ex
//
//  Created by Plum on 2019/3/6.
//  Copyright © 2019 Tima. All rights reserved.
//

import UIKit
import CoreData

class TableViewDataSource<Delegate: TableViewDataSourceDelegate>: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    typealias Object = Delegate.Object
    typealias Cell = Delegate.Cell
    
    let tableView: UITableView
    let cellIdentifier: String
    let fetchedResultsController: NSFetchedResultsController<Object>
    weak var delegate: Delegate?
    
    init(tableView: UITableView, cellIdentifier: String, fetchedResultsController: NSFetchedResultsController<Object>, delegate: Delegate) {
        
    }
}
