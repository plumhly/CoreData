//
//  SegueHandler.swift
//  CoreData_Ex
//
//  Created by plum on 2019/3/6.
//  Copyright © 2019 Tima. All rights reserved.
//

import Foundation
import UIKit

protocol SegueHandler {
    associatedtype SegueIdentifier: RawRepresentable
}

extension SegueHandler where Self: UIViewController, SegueIdentifier.RawValue == String {
    func segueIdentifier(for segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let identifier = segue.identifier, let segueIdentifer = SegueIdentifier(rawValue: identifier) else {
            fatalError("Unnkown segue: \(segue)")
        }
        return segueIdentifer
    }
}
