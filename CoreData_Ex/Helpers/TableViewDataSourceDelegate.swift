//
//  TableViewDataSourceDelegate.swift
//  CoreData_Ex
//
//  Created by Plum on 2019/3/6.
//  Copyright © 2019 Tima. All rights reserved.
//

import Foundation
import CoreData

protocol TableViewDataSourceDelegate {
    associatedtype Object: NSFetchRequestResult
    associatedtype Cell
}
