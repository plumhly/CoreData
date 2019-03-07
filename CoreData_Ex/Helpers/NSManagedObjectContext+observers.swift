//
//  NSManagedObjectContext+observers.swift
//  CoreData_Ex
//
//  Created by plum on 2019/3/7.
//  Copyright © 2019 Tima. All rights reserved.
//

import Foundation
import CoreData

struct ObjectsDidChangeNotification {
    init(noti: Notification) {
        assert(noti.name == Notification.Name.NSManagedObjectContextObjectsDidChange)
        notification = noti
        
    }
    
    var insertedObjects: Set<NSManagedObject> {
        return objects(forKey: NSInsertedObjectsKey)
    }
    
    var updatedObjects: Set<NSManagedObject> {
        return objects(forKey: NSUpdatedObjectsKey)
    }
    
    var deletedObjects: Set<NSManagedObject> {
        return objects(forKey: NSDeletedObjectsKey)
    }
    
    var refreshedObjects: Set<NSManagedObject> {
        return objects(forKey: NSRefreshedObjectsKey)
    }
    
    var invalidatedObjects: Set<NSManagedObject> {
        return objects(forKey: NSInvalidatedObjectsKey)
    }
    
    var invalidatedAllObjects: Bool {
        return (notification as NSNotification).userInfo?[NSInvalidatedAllObjectsKey] != nil
    }
    
    var managedObjectContext: NSManagedObjectContext {
        guard let c = notification.object as? NSManagedObjectContext else {
            fatalError("Invalid notification object")
        }
        return c
    }
    
    // MARK: - Private
    fileprivate let notification: Notification
    fileprivate func objects(forKey key: String) -> Set<NSManagedObject> {
        return (notification as NSNotification).userInfo?[key] as? Set<NSManagedObject> ?? Set()
    }
}


extension NSManagedObjectContext {
    
    func objectsDidChangeNotificationOberver(handler: @escaping (ObjectsDidChangeNotification) -> ()) -> NSObjectProtocol {
        let c = NotificationCenter.default
        return c.addObserver(forName: Notification.Name.NSManagedObjectContextObjectsDidChange, object: self, queue: nil) { noti in
            let wrapperNoti = ObjectsDidChangeNotification(noti: noti)
            handler(wrapperNoti)
        }
    }
}
