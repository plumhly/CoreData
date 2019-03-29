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
    
    @NSManaged fileprivate(set) var moods: Set<Mood>
    @NSManaged fileprivate(set) var continent: Continent?
    fileprivate var mutableMoods: NSMutableSet {
        return mutableSetValue(forKeyPath: #keyPath(moods))
    }
    
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
    
    static func findOrCreate(for isoCountry: ISO3166.Country, in context: NSManagedObjectContext) -> Country {
        let predicate = NSPredicate(format: "%K == %d", #keyPath(numericISO3166Code), isoCountry.rawValue)
        let country = findOrCreate(in: context, matching: predicate) {
            $0.iso3166Code = isoCountry
            $0.continent = Continent.findOrCeateContinent(for: isoCountry, in: context)
            $0.updateAt = Date()
        }
        return country
    }
    
    override func prepareForDeletion() {
        guard let c = continent else { return }
        if c.coutries.filter({ !$0.isDeleted }).isEmpty {
            managedObjectContext?.delete(c)

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
