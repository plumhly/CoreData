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
  private let filterViewControllerSegueIdentifier = "toFilterViewController"
  private let venueCellIdentifier = "VenueCell"

  var coreDataStack: CoreDataStack!

  // MARK: - IBOutlets
  @IBOutlet weak var tableView: UITableView!
  
  var fetchRequest: NSFetchRequest<Venue>?
  var venues: [Venue] = []
  
  var asynFetchRequest: NSAsynchronousFetchRequest<Venue>?

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let batchUpdateRequest = NSBatchUpdateRequest(entityName: "Venue")
    batchUpdateRequest.propertiesToUpdate = [#keyPath(Venue.favorite): true]
    batchUpdateRequest.resultType = .updatedObjectsCountResultType
    batchUpdateRequest.affectedStores = coreDataStack.managedContext.persistentStoreCoordinator!.persistentStores
    
    do {
       let result = try coreDataStack.managedContext.execute(batchUpdateRequest) as? NSBatchUpdateResult
      if let value = result?.result {
        print("update value: \(value)")
      }
    } catch let error as NSError {
      print(error)
    }
    
//    guard let managedObjectModel = coreDataStack.managedContext.persistentStoreCoordinator?.managedObjectModel, let request = managedObjectModel.fetchRequestTemplate(forName: "FetchRequest") as? NSFetchRequest<Venue> else { return }
    self.fetchRequest = Venue.fetchRequest()
    asynFetchRequest = NSAsynchronousFetchRequest<Venue>(fetchRequest: fetchRequest!) {[unowned self] result in
      guard let venues = result.finalResult else { return }
      self.venues = venues
      self.tableView.reloadData()
    }

    do {
      guard let asyncRequest = asynFetchRequest else { return }
      try coreDataStack.managedContext.execute(asyncRequest)
    } catch let error as NSError {
      print(error)
    }
  }
  
  

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == filterViewControllerSegueIdentifier, let nav = segue.destination as? UINavigationController, let filterVC = nav.topViewController as? FilterViewController {
      filterVC.coreDataStack = coreDataStack
      filterVC.delegate = self
    }
  }
}

// MARK: - IBActions
extension ViewController {

  @IBAction func unwindToVenueListViewController(_ segue: UIStoryboardSegue) {
  }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return venues.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: venueCellIdentifier, for: indexPath)
    let venue = venues[indexPath.row]
    cell.textLabel?.text = venue.name
    cell.detailTextLabel?.text = venue.priceInfo?.priceCategory
    return cell
  }
}

extension ViewController {
  func fetchAndReload() {
    guard let request = self.fetchRequest else { return }
    do {
      self.venues = try coreDataStack.managedContext.fetch(request)
      tableView.reloadData()
    } catch let error as NSError {
      print(error)
    }
  }
}


extension ViewController: FilterViewControllerDelegate {
  func filterViewController(filter: FilterViewController, didSelectPredicate predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?) {
    guard let request = fetchRequest else { return }
    request.predicate = nil
    request.sortDescriptors = nil
    request.predicate = predicate
    if let sort = sortDescriptor {
      request.sortDescriptors = [sort]
    }
    fetchAndReload()
  }
}
