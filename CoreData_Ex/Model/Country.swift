//
//  Country.swift
//  CoreData_Ex
//
//  Created by plum on 2019/3/7.
//  Copyright © 2019 Tima. All rights reserved.
//

import UIKit
import CoreData




final class Country: NSManagedObject {

    @NSManaged var updateAt: Date
    @NSManaged fileprivate var numericISO3166Code: Int16
    
    fileprivate(set) var iso3166Code: ISO3166.Country {
        get {
            guard let c = ISO3166.Country(rawValue: numericISO3166Code) else {
                fatalError("Unknown country code")
            }
            return c
        }
        
        set {
            numericISO3166Code = newValue.rawValue
        }
    }
}


extension Country: Managed {
    static var defaultDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(updateAt), ascending: false)]
    }
}

extension Country: LocalizedStringConvertible {
    var localizeDescription: String {
        return iso3166Code.localizeDescription
    }
}
