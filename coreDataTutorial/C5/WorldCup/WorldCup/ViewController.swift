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
  fileprivate let teamCellIdentifier = "teamCellReuseIdentifier"
  var coreDataStack: CoreDataStack!

  // MARK: - IBOutlets
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var addButton: UIBarButtonItem!
  
  lazy var fetchController: NSFetchedResultsController<Team> = {
    let request = NSFetchRequest<Team>(entityName: "Team")
    let zoneDes = NSSortDescriptor(key: #keyPath(Team.qualifyingZone), ascending: true)
    let scoreDes = NSSortDescriptor(keyPath: \Team.wins, ascending: false)
    let nameDes = NSSortDescriptor(key: #keyPath(Team.teamName), ascending: true)
    request.sortDescriptors = [zoneDes, scoreDes, nameDes]
    let controler = NSFetchedResultsController(fetchRequest: request, managedObjectContext: coreDataStack.managedContext, sectionNameKeyPath:
      #keyPath(Team.qualifyingZone), cacheName: "plum")
    controler.delegate = self
    return controler
  }()

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    do {
      try self.fetchController.performFetch()
    } catch let error as NSError {
      print(error)
    }
  }
}

// MARK: - Internal
extension ViewController {

  func configure(cell: UITableViewCell, for indexPath: IndexPath) {

    guard let cell = cell as? TeamCell else {
      return
    }
    let team = fetchController.object(at: indexPath)
    
    cell.teamLabel.text = team.teamName
    cell.scoreLabel.text = "Wins: \(team.wins)"
    
    if let image = team.imageName {
      cell.imageView?.image = UIImage(named: image)
    } else {
      cell.imageView?.image = nil
    }
  }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return self.fetchController.sections?.count ?? 0
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let sectionInfo = self.fetchController.sections?[section] else {
      return 0
    }
    return sectionInfo.numberOfObjects
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: teamCellIdentifier, for: indexPath)
    configure(cell: cell, for: indexPath)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let sectionInfo = fetchController.sections?[section]
    return sectionInfo?.name
  }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let team = fetchController.object(at: indexPath)
    team.wins += 1
    coreDataStack.saveContext()
  }
}


extension ViewController: NSFetchedResultsControllerDelegate {
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }
  
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      tableView.insertRows(at: [indexPath!], with: .automatic)
      
    case .update:
      guard let cell = tableView.cellForRow(at: indexPath!) as? TeamCell else { return }
      configure(cell: cell, for: indexPath!)
      
    case .delete:
      tableView.deleteRows(at: [indexPath!], with: .automatic)
      
    case .move:
      tableView.deleteRows(at: [indexPath!], with: .automatic)
      tableView.insertRows(at: [newIndexPath!], with: .automatic)
    default:
      break
    }
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    let set = IndexSet(integer: sectionIndex)
    switch type {
    case .delete:
      tableView.deleteSections(set, with: .automatic)
      
    case .insert:
      tableView.insertSections(set, with: .automatic)
    default:
      break
    }
  }
}
