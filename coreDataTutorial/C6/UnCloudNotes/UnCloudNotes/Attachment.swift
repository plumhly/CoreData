//
//  Attachment.swift
//  UnCloudNotes
//
//  Created by Plum on 2019/4/1.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Attachment: NSManagedObject {
  @NSManaged var date: Date
  @NSManaged var note: Note?
}
