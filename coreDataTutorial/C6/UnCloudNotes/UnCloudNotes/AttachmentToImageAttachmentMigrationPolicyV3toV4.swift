//
//  AttachmentToImageAttachmentMigrationPolicyV3toV4.swift
//  UnCloudNotes
//
//  Created by plum on 2019/4/2.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//

import UIKit
import CoreData

let errorDomain = "Migration"

class AttachmentToImageAttachmentMigrationPolicyV3toV4: NSEntityMigrationPolicy {
  override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
    let newImageAttachment = ImageAttachment(context: manager.destinationContext)
    
    func tranversePropertyMappings(block: (NSPropertyMapping, String) -> Void) throws {
      if let attributeMappings = mapping.attributeMappings {
        for porpertyMapping in attributeMappings {
          if let propertyName = porpertyMapping.name {
            block(porpertyMapping, propertyName)
          } else {
            let message = "Attribute destination not configured properly"
            let info = [NSLocalizedFailureReasonErrorKey: message]
            throw NSError(domain: errorDomain, code: 0, userInfo: info)
          }
        }
        
      } else {
        let message = "No Attribute Mappings found!"
        let info = [NSLocalizedFailureReasonErrorKey: message]
        throw NSError(domain: errorDomain, code: 0, userInfo: info)
      }
      
      try tranversePropertyMappings { propertyMapping, propertyName in
        guard let express = propertyMapping.valueExpression else { return }
        
//        express.expressionValue(with: <#T##Any?#>, context: <#T##NSMutableDictionary?#>)
      }
    }
  }
}
