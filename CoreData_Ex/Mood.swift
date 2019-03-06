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

final class Mood: NSManagedObject {
    @NSManaged fileprivate(set) var date: Date
    @NSManaged fileprivate(set) var colors: [UIColor]
}


extension Mood: Managed {
    static var defaultDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(date), ascending: false)]
    }
}
