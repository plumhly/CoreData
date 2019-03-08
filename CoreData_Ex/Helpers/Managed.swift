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
    
   static func materializedObject(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
        for object in context.registeredObjects where !object.isFault {
            guard let result = object as? Self, predicate.evaluate(with: result) else { continue }
            return result
        }
        return nil
    }
    
   static func fetch(in context: NSManagedObjectContext, configurationBlock: (NSFetchRequest<Self>) -> () = { _ in }) -> [Self] {
        
        let request = NSFetchRequest<Self>(entityName: Self.entityName)
        configurationBlock(request)
        return try! context.fetch(request)
    }
    
   static func findOrFetch(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
    guard let object = materializedObject(in: context, matching: predicate) else {
        return fetch(in: context) { request in
            request.fetchLimit = 1
            request.predicate = predicate
            request.returnsObjectsAsFaults = false
        }.first
    }
    return object
    }
    
   static func findOrCreate(in context: NSManagedObjectContext, matching predicate: NSPredicate, configure: (Self) -> ()) -> Self {
        guard let object = findOrFetch(in: context, matching: predicate) else {
            let newObjc: Self = context.insert()
            configure(newObjc)
            return newObjc
    }
    return object
    }
}
