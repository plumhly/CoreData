//
//  ValueTransformer.swift
//  CoreData_Ex
//
//  Created by Plum on 2019/3/10.
//  Copyright © 2019 Tima. All rights reserved.
//

import UIKit

class ClosureValueTransformer<A: AnyObject, B: AnyObject>: ValueTransformer {
    
    typealias Transform = (A?) -> B?
    typealias ReverseTransform = (B?) -> A?
    
    fileprivate let transform: Transform
    fileprivate let reverseTransform: ReverseTransform
    
    init(transform: @escaping Transform, reverseTransform: @escaping ReverseTransform) {
        self.transform = transform
        self.reverseTransform = reverseTransform
        super.init()
    }
    
    static func registerTransformer(withName name: String, transform: @escaping Transform, reverseTransform: @escaping ReverseTransform) {
        let vt = ClosureValueTransformer(transform: transform, reverseTransform: reverseTransform)
        Foundation.ValueTransformer.setValueTransformer(vt, forName: NSValueTransformerName(name))
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override class func transformedValueClass() -> AnyClass {
        return B.self
    }

    override func transformedValue(_ value: Any?) -> Any? {
       return transform(value as? A)
    }
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        return reverseTransform(value as? B)
    }
    
    
}
