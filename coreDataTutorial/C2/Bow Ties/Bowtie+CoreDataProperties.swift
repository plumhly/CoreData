//
//  Bowtie+CoreDataProperties.swift
//  Bow Ties
//
//  Created by plum on 2019/3/27.
//  Copyright © 2019 Razeware. All rights reserved.
//
//

import Foundation
import CoreData


extension Bowtie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bowtie> {
        return NSFetchRequest<Bowtie>(entityName: "Bowtie")
    }

    @NSManaged public var name: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var lastWorn: NSDate?
    @NSManaged public var rating: Double
    @NSManaged public var searchKey: String?
    @NSManaged public var timesWorn: Int32
    @NSManaged public var id: UUID?
    @NSManaged public var url: URL?
    @NSManaged public var photoData: NSData?
    @NSManaged public var tintColor: NSObject?
  
  

}

extension NSManagedObject {
  func propertyVaidationForKey(key: String, description: String) -> NSError {
    let dic = [
      NSValidationObjectErrorKey: self,
      NSValidationKeyErrorKey: key as Any,
      NSLocalizedDescriptionKey: description as Any
    ]
    
    let domain = Bundle(for: type(of: self)).bundleIdentifier ?? "undefined"
    return NSError(domain: domain, code: NSManagedObjectValidationError, userInfo: dic)
  }
}

extension NSManagedObject {
  
}
