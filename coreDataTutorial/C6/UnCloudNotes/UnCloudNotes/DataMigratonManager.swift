//
//  DataMigratonManager.swift
//  UnCloudNotes
//
//  Created by plum on 2019/4/3.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//

import Foundation
import CoreData

class DataMigrationManager {
  fileprivate let enableMigrations: Bool
  fileprivate let modelName: String
  let storeName = "UnCloudNotesDataModel"
  var stack: CoreDataStack {
    guard enableMigrations, !store(at: storeURL, isCompatible: currentModel) else {
      return CoreDataStack(modelName: modelName)
    }
    performMigration()
    return CoreDataStack(modelName: modelName)
  }
  
  private var applicationSupportURL: URL = {
    let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
    return URL(fileURLWithPath: path)
  }()
  
  private lazy var storeURL: URL = {
    return URL(fileURLWithPath: "\(self.storeName).sqlite", relativeTo: self.applicationSupportURL)
  }()
  
  private var storeModel: NSManagedObjectModel? {
    return NSManagedObjectModel.modelVersions(for: self.modelName).filter {
      self.store(at: storeURL, isCompatible: $0)
    }.first
  }
  
  lazy var currentModel = NSManagedObjectModel.model(name: self.modelName)
  
  init(modelName: String, enableMigrations: Bool = false) {
    self.modelName = modelName
    self.enableMigrations = enableMigrations
  }
  
  private func store(at url: URL, isCompatible model: NSManagedObjectModel) -> Bool {
    let meta = metaDataForStore(url)
    return model.isConfiguration(withName: nil, compatibleWithStoreMetadata:meta)
  }
  
  func metaDataForStore(_ storeURL: URL) -> [String: Any] {
    var meta: [String: Any]
    do {
      meta = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL, options: nil)
    } catch {
      meta = [:]
      print("Error retrieving metadata for store at URL:\(storeURL) \n error: \(error)")
    }
    return meta
  }
  
  func performMigration() {
    guard currentModel.isVersion4 else {
      fatalError()
    }
    guard let store = storeModel else { return }
    
    if store.isVersion1 {
      let destination = NSManagedObjectModel.version2
      migrateStoreAt(storeURL, form: store, to: destination)
      performMigration()
    } else if(store.isVersion2) {
      let destination = NSManagedObjectModel.version3
      let mapping = NSMappingModel(from: nil, forSourceModel: store, destinationModel: destination)
      migrateStoreAt(storeURL, form: store, to: destination, with: mapping)
      performMigration()
    } else if(store.isVersion3) {
      let destination = NSManagedObjectModel.version4
      let mapping = NSMappingModel(from: nil, forSourceModel: store, destinationModel: destination)
      migrateStoreAt(storeURL, form: store, to: destination, with: mapping)
    }

  }
  
  func migrateStoreAt(_ url: URL, form sourceModel: NSManagedObjectModel, to destinationModel: NSManagedObjectModel, with mappingModel: NSMappingModel? = nil) {
    let manager = NSMigrationManager(sourceModel: sourceModel, destinationModel: destinationModel)
    
  
    var mModel: NSMappingModel
    if let mapping = mappingModel {
      mModel = mapping
    } else {
      mModel =  try! NSMappingModel.inferredMappingModel(forSourceModel: sourceModel, destinationModel: destinationModel)
    }
    
    let destinationFileName = url.lastPathComponent + "~1"
    let destinationFolder = url.deletingLastPathComponent()
    let destinationURL = destinationFolder.appendingPathComponent(destinationFileName)
    
    print("From Model: \(sourceModel.entityVersionHashesByName)")
    print("To Model: \(destinationModel.entityVersionHashesByName)")
    print("Migrating store \(url) to \(destinationURL)")
    print("Mapping model: \(String(describing: mModel))")
    
    var success: Bool = false
    do {
      try manager.migrateStore(from: url, sourceType: NSSQLiteStoreType, options: nil, with: mModel, toDestinationURL: destinationURL, destinationType: NSSQLiteStoreType, destinationOptions: nil)
      success = true
    } catch {
      print("migrate Failed error:\(error)")
    }
    
    if success {
      print("migrate success")
      let fileManager = FileManager.default
      do {
        try fileManager.removeItem(at: url)
        try fileManager.moveItem(at: destinationURL, to: url)
      } catch {
        print("Error migration:\(error)")
      }
    }
  }
}

extension NSManagedObjectModel {
 private class func urls(in modelFolder: String) -> [URL] {
    return Bundle.main.urls(forResourcesWithExtension: "mom", subdirectory: "\(modelFolder).momd") ?? []
  }
  
  class func modelVersions(for modelName: String) -> [NSManagedObjectModel] {
    return urls(in: modelName).compactMap(NSManagedObjectModel.init)
  }
  
  class func unCloudNoteModel(_ modelName: String) -> NSManagedObjectModel {
    return urls(in: "UnCloudNotesDataModel").filter { $0.lastPathComponent == "\(modelName).mom" }.compactMap(NSManagedObjectModel.init).first ?? NSManagedObjectModel()
  }
  
  class func model(name modelName: String, fromBundle bundle: Bundle = .main) -> NSManagedObjectModel {
    return bundle.url(forResource: modelName, withExtension: "momd").flatMap(NSManagedObjectModel.init) ?? NSManagedObjectModel()
  }
  
  class var version1: NSManagedObjectModel {
    return unCloudNoteModel("UnCloudNotesDataModel")
  }
  
  var isVersion1: Bool {
    return self == type(of: self).version1
  }
  
  class var version2: NSManagedObjectModel {
    return unCloudNoteModel("UnCloudNotesDataModel v2")
  }
  
  var isVersion2: Bool {
    return self == type(of: self).version2
  }
  
  class var version3: NSManagedObjectModel {
    return unCloudNoteModel("UnCloudNotesDataModel v3")
  }
  
  var isVersion3: Bool {
    return self == type(of: self).version3
  }
  
  class var version4: NSManagedObjectModel {
    return unCloudNoteModel("UnCloudNotesDataModel v4")
  }
  
  var isVersion4: Bool {
    return self == type(of: self).version4
  }
  
  
}


func == (lhs: NSManagedObjectModel, rhs: NSManagedObjectModel) -> Bool {
  return lhs.entitiesByName == rhs.entitiesByName
}
