//
//  Managed.swift
//  CoreData_Ex
//
//  Created by Plum on 2019/3/6.
//  Copyright © 2019 Tima. All rights reserved.
//

import Foundation
import CoreData


protocol Managed: class, NSFetchRequestResult {
    static var entityName: String { get }
    static var defaultDescriptors: [NSSortDescriptor] { get }
}


extension Managed {
    static var defaultDescriptors: [NSSortDescriptor] {
        return []
    }
    
    static var sortedFetchRequest: NSFetchRequest<Self> {
        let request = NSFetchRequest<Self>(entityName: entityName)
        request.sortDescriptors = defaultDescriptors
        return request
    }

}


extension Managed where Self: NSManagedObject {
    static var entityName: String {
       return entity().name!
    }
}
