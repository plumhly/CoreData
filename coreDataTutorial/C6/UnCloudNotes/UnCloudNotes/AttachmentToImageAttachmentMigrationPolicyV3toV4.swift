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
    guard let entityDescription = NSEntityDescription.entity(forEntityName: "ImageAttachment", in: manager.destinationContext) else { return }
    let newImageAttachment = ImageAttachment(entity: entityDescription, insertInto: manager.destinationContext)
    
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
        guard let express = propertyMapping.valueExpression,  let destinationValue = express.expressionValue(with: sInstance, context: nil) else { return }
        newImageAttachment.setValue(destinationValue, forKey: propertyName)
      }
      
      if let image = newImageAttachment.image {
        newImageAttachment.setValue(image.size.width, forKey: "width")
        newImageAttachment.setValue(image.size.height, forKey: "height")
      }
      
      let caption = newImageAttachment.note?.body as NSString? ?? ""
      newImageAttachment.setValue(caption, forKey: "caption")
      
      manager.associate(sourceInstance: sInstance, withDestinationInstance: newImageAttachment, for: mapping)
      
    }
  }
}
