//
//  MoodDetailViewController.swift
//  CoreData_Ex
//
//  Created by plum on 2019/3/7.
//  Copyright © 2019 Tima. All rights reserved.
//

import UIKit
import CoreData

class MoodDetailViewController: UIViewController {
    
    var mood: Mood! {
        didSet {
            observer = ManagedObjectObserver(objct: mood) { [weak self] type in
                guard type == .delete else {
                    return
                }
                self?.navigationController?.popViewController(animated: true)
            }
            updateView()
        }
    }
    
    fileprivate var observer: ManagedObjectObserver?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    fileprivate func updateView() {
        
    }
    
    
    // MARK: - Response
    @IBAction func deleteMood(_ sender: Any?) {
        mood.managedObjectContext?.performChange {
            self.mood.managedObjectContext?.delete(self.mood)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
