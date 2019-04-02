//
//  ImageAttachment.swift
//  UnCloudNotes
//
//  Created by plum on 2019/4/2.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ImageAttachment: Attachment {
  @NSManaged var width: Float
  @NSManaged var height: Float
  @NSManaged var caption: String
  @NSManaged var image: UIImage?
}
