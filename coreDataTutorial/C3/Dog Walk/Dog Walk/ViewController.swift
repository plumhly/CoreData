/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import CoreData

class ViewController: UIViewController {

  // MARK: - Properties
  lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
  }()
  
  var managerContext: NSManagedObjectContext!
  

  var walks: [Date] = []
  var currentDog: Dog!

  // MARK: - IBOutlets
  @IBOutlet var tableView: UITableView!

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    let name = "Fido"
    let request: NSFetchRequest<Dog> = Dog.fetchRequest()
    request.predicate = NSPredicate(format: "%K = %@", #keyPath(Dog.name), name)
    
    do {
      let result = try managerContext.fetch(request)
      if result.count > 0 {
        currentDog = result.first
      } else {
        let dog = Dog(context: managerContext)
        dog.name = name
        currentDog = dog
        try managerContext.save()
      }
    } catch let errror as NSError {
      print(errror)
    }
    

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
  }
}

// MARK: - IBActions
extension ViewController {

  @IBAction func add(_ sender: UIBarButtonItem) {
    let walk = Walk(context: managerContext)
    walk.date = NSDate()
    currentDog.addToWalks(walk)
//    if let walks = currentDog.walks?.mutableCopy() as? NSMutableOrderedSet {
//      walks.add(walk)
//      currentDog.walks = walks
//    }
    
    do {
      try managerContext.save()
    } catch let error as NSError {
      print(error)
    }
    
    tableView.reloadData()
  }
}

// MARK: UITableViewDataSource
extension ViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return currentDog.walks?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    guard let walk = currentDog.walks?[indexPath.row] as? Walk, let date = walk.date as Date? else { return cell }
    cell.textLabel?.text = dateFormatter.string(from: date)
    return cell
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "List of Walks"
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    guard editingStyle == .delete, let removeWalk = currentDog.walks?[indexPath.row] as? Walk else { return }
    managerContext.delete(removeWalk)
    
    do {
      try managerContext.save()
      tableView.deleteRows(at: [indexPath], with: .automatic)
    } catch let error as NSError {
      print(error)
    }
  }
}
