//
//  Mood.swift
//  CoreData_Ex
//
//  Created by plum on 2019/3/6.
//  Copyright © 2019 Tima. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import CoreLocation

final class Mood: NSManagedObject {
    @NSManaged fileprivate(set) var date: Date
    @NSManaged fileprivate(set) var colors: [UIColor]
    @NSManaged fileprivate var longtitude: NSNumber?
    @NSManaged fileprivate var latitude: NSNumber?
    
    static func insert(into context: NSManagedObjectContext, image: UIImage) -> Mood {
        let mood: Mood = context.insert()
        mood.colors = []
        mood.date = Date()
        return mood
    }
    
    public var location: CLLocation? {
        guard let longitude = longtitude?.doubleValue, let latitude = latitude?.doubleValue else {
            return nil
        }
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}


extension Mood: Managed {
    static var defaultDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(date), ascending: false)]
    }
}
