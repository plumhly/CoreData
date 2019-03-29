//
//  CoreDataStack..swift
//  Dog Walk
//
//  Created by plum on 2019/3/29.
//  Copyright © 2019 Razeware. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
  private let modelName: String
  
  lazy var context = self.container.viewContext
  
  init(_ name: String) {
    self.modelName = name
  }
  
  private lazy var container: NSPersistentContainer = {
    let container = NSPersistentContainer(name: self.modelName)
    container.loadPersistentStores { _, error in
      if let e = error as NSError? {
        print(e)
      }
    }
    return container
  }()
  
  func saveContext() {
    guard self.context.hasChanges else {
      return
    }
    
    do {
      try self.context.save()
    } catch let error as NSError {
      print(error)
    }
  }
  
}
