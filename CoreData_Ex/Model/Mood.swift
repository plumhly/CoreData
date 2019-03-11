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
import CoreLocation

final class Mood: NSManagedObject {
    @NSManaged fileprivate(set) var date: Date
    @objc public fileprivate(set) var colors: [UIColor] {
        get {
            willAccessValue(forKey: #keyPath(colors))
            var c = primitiveColors
            didAccessValue(forKey: #keyPath(colors))
            if c == nil {
                c = colorStorage.moodColor ?? []
                primitiveColors = c
            }
            return c!
        }
        
        set {
            willChangeValue(forKey: #keyPath(colors))
            primitiveColors = newValue
            didChangeValue(forKey: #keyPath(colors))
            colorStorage = newValue.moodData
        }
    }
    @NSManaged fileprivate var longtitude: NSNumber?
    @NSManaged fileprivate var latitude: NSNumber?
    
    @NSManaged public fileprivate(set) var country: Country
    
    
    @NSManaged fileprivate var colorStorage: Data
    @NSManaged fileprivate var primitiveColors: [UIColor]?
    
    
    static func insert(into context: NSManagedObjectContext, image: UIImage, localtion: CLLocation?, placeMark: CLPlacemark?) -> Mood {
        let mood: Mood = context.insert()
        mood.colors = []
        mood.date = Date()
        
        if let local = localtion?.coordinate {
            mood.latitude = NSNumber(value: local.latitude)
            mood.longtitude = NSNumber(value: local.longitude)
        }
        
        let isoCode = placeMark?.isoCountryCode ?? ""
        let isoCountry = ISO3166.Country.fromISO3166(isoCode)
        let country = Country.findOrCreate(for: isoCountry, in: context)
        mood.country = country
        return mood
    }
    
    public var location: CLLocation? {
        guard let longitude = longtitude?.doubleValue, let latitude = latitude?.doubleValue else {
            return nil
        }
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    override func prepareForDeletion() {
        if country.moods.filter({ !$0.isDeleted }).isEmpty {
            managedObjectContext?.delete(country)
        }
    }
}


extension Mood: Managed {
    static var defaultDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(date), ascending: false)]
    }
}

private let ColorsTransformerName = "ColorsTransformer"

extension Mood {
    static func resiterValueTransformers() {
        _ = self.__registerOnce
    }

    fileprivate static let __registerOnce: () = {
        ClosureValueTransformer.registerTransformer(withName: ColorsTransformerName, transform: { (colors: NSArray?) -> NSData? in
            guard let colors = colors as? [UIColor] else { return nil }
            return colors.moodData as NSData
        }, reverseTransform: { (data: NSData?) -> NSArray? in
            return data
                .flatMap { ($0 as Data).moodColor }
                .map { $0 as NSArray }
        })
    }()
}


extension Collection where Iterator.Element: UIColor {
    var moodData: Data {
        let value = flatMap { $0.rgb }
        return value.withUnsafeBufferPointer {
            return Data(bytes: UnsafePointer<UInt8>($0.baseAddress!), count: $0.count)
        }
    }
}


extension UIColor {
    fileprivate var rgb: [UInt8] {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: nil)
        return [UInt8(red * 255), UInt8(green * 255), UInt8(blue * 255)]
    }
    
    fileprivate convenience init?(rawData: [UInt8]) {
        guard rawData.count == 3 else { return nil }
        let red = CGFloat(rawData[0]) / 255
        let green = CGFloat(rawData[1]) / 255
        let blue = CGFloat(rawData[2]) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}


extension Data {
    var moodColor: [UIColor]? {
        guard count > 0 && count % 3 == 0 else { return nil }
        var rgbValues = Array(repeating: UInt8(), count: count)
        rgbValues.withUnsafeMutableBufferPointer {
            buffer in
            let voidPoint = UnsafeMutableRawPointer(buffer.baseAddress)
            let _ = withUnsafeBytes {
                bytes in
                memcpy(voidPoint, bytes, count)
            }
        }
        let rgbSlices = rgbValues.slice(size: 3)
        return rgbSlices.map { slice in
            guard let color = UIColor(rawData: slice) else {
                fatalError("cannot fail since we know tuple is of length 3")
            }
            return color
        }
        
    }
}


