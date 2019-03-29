//
//  NSManagedObjectContext + Extension.swift
//  CoreData_Ex
//
//  Created by plum on 2019/3/7.
//  Copyright © 2019 Tima. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    func insert<A: NSManagedObject>() -> A where A: Managed {
        guard let model = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A  else {
            fatalError("Unknown type")
        }
        return model
    }
    

    public func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }
    
    public func performChange(block: @escaping ()->()) {
        perform {
            block()
            _ = self.saveOrRollback()
        }
    }
}
