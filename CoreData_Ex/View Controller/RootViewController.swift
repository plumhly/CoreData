//
//  ViewController.swift
//  CoreData_Ex
//
//  Created by plum on 2019/3/6.
//  Copyright © 2019 Tima. All rights reserved.
//

import UIKit
import CoreData

class RootViewController: UIViewController, SegueHandler {
    
    enum SegueIdentifier: String {
        case embedNavigation = "embedNavigationController"
        case embedCamera = "embedCamera"
    }
    
    var managedContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .embedNavigation:
            guard let nv = segue.destination as? UINavigationController, let vc = nv.viewControllers.first as? MoodsTableViewController else {
                fatalError("wrong view controller type")
            }
            vc.managedContext = managedContext
        default:
            ""
        }
    }
    
    // MARK: - 私有方法
    func didCaptureImage(image: UIImage) {
        managedContext.performChange {
            _ = Mood.insert(into: self.managedContext, image: image)
        }
    }


}

