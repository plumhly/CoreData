//
//  Utilities.swift
//  CoreData_Ex
//
//  Created by plum on 2019/3/7.
//  Copyright © 2019 Tima. All rights reserved.
//

import Foundation

extension Collection where Iterator.Element: AnyObject {
    func containsObjectIdentical(to object: AnyObject) -> Bool {
        return contains { $0 === object }
    }
}



extension Array {
    
    func slice(size: Int) -> [[Iterator.Element]] {
        var result: [[Iterator.Element]] = []
        
        for index in stride(from: startIndex, to: endIndex, by: size) {
            let end = Swift.min(index + size, endIndex)
            result.append(Array(self[index..<end]))
        }
        return result
    }
}
