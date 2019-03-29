//
//  ManagedObjectObserver.swift
//  CoreData_Ex
//
//  Created by plum on 2019/3/7.
//  Copyright © 2019 Tima. All rights reserved.
//

import Foundation
import CoreData

final class ManagedObjectObserver {
    
    
    enum ChangeType {
        case delete
        case update
    }
    
    init?(objct: NSManagedObject, changeHandler: @escaping (ChangeType) -> ()) {
        guard let context = objct.managedObjectContext else {
            return nil
        }
        
        token = context.objectsDidChangeNotificationOberver { [weak self] noti in
            guard let type = self?.changeType(of: objct, in: noti) else {
                return
            }
            changeHandler(type)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(token)
    }
    
    // MARK: - Private
    fileprivate var token: NSObjectProtocol!
    
    fileprivate func changeType(of object: NSManagedObject, in note: ObjectsDidChangeNotification) -> ChangeType? {
        let deleted = note.deletedObjects.union(note.invalidatedObjects)
        if note.invalidatedAllObjects || deleted.containsObjectIdentical(to: object) {
            return .delete
        }
        
        let updates = note.updatedObjects.union(note.refreshedObjects)
        if updates.containsObjectIdentical(to: object) {
            return .update
        }
        return nil
    }
}
