//
//  ViewController.swift
//  HitList
//
//  Created by plum on 2019/3/26.
//  Copyright © 2019 Tima. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var people: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "The List"
        loadData()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func loadData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "Person")
        do {
            self.people = try context.fetch(request)
        } catch let error as NSError {
            print("load Data failed, error: \(error)")
        }
        
    }

    @IBAction func addName(_ sender: Any) {
        let alert = UIAlertController(title: "New Name", message: "add new name", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
            guard let textfield = alert.textFields?.first, let saveName = textfield.text else { return }
            
            self.save(saveName)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func save(_ name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
//        NSEntityDescription.insertNewObject(forEntityName: "person", into: context)
        let entityDescription = NSEntityDescription.entity(forEntityName: "Person", in: context)
        let person = NSManagedObject(entity: entityDescription!, insertInto: context)
        person.setValue(name, forKey: "name")
        
        do {
            try context.save()
            people.append(person)
        } catch let error as NSError {
            print("Cant save data error: \(error)")
        }
    }

}


extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let person = people[indexPath.row]
        cell.textLabel?.text = person.value(forKey: "name") as? String
        return cell
    }
    
}
