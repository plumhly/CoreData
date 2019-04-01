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

class FilterViewController: UITableViewController {

  @IBOutlet weak var firstPriceCategoryLabel: UILabel!
  @IBOutlet weak var secondPriceCategoryLabel: UILabel!
  @IBOutlet weak var thirdPriceCategoryLabel: UILabel!
  @IBOutlet weak var numDealsLabel: UILabel!

  // MARK: - Price section
  @IBOutlet weak var cheapVenueCell: UITableViewCell!
  @IBOutlet weak var moderateVenueCell: UITableViewCell!
  @IBOutlet weak var expensiveVenueCell: UITableViewCell!

  // MARK: - Most popular section
  @IBOutlet weak var offeringDealCell: UITableViewCell!
  @IBOutlet weak var walkingDistanceCell: UITableViewCell!
  @IBOutlet weak var userTipsCell: UITableViewCell!
  
  // MARK: - Sort section
  @IBOutlet weak var nameAZSortCell: UITableViewCell!
  @IBOutlet weak var nameZASortCell: UITableViewCell!
  @IBOutlet weak var distanceSortCell: UITableViewCell!
  @IBOutlet weak var priceSortCell: UITableViewCell!

  
  var coreDataStack: CoreDataStack!
  
  weak var delegate: FilterViewControllerDelegate?
  var selectedSortDescriptor: NSSortDescriptor?
  var selectedPredicate: NSPredicate?
  
  lazy var cheapPricePredicate: NSPredicate = {
    return NSPredicate(format: "%K = %@", #keyPath(Venue.priceInfo.priceCategory), "$")
  }()
  
  lazy var moderatePredicate: NSPredicate = {
    return NSPredicate(format: "%K = %@", #keyPath(Venue.priceInfo.priceCategory), "$$")
  }()
  
  lazy var expensivePredicate: NSPredicate = {
    return NSPredicate(format: "%K = %@", #keyPath(Venue.priceInfo.priceCategory), "$$$")
  }()
  
  lazy var nameDescriptor = NSSortDescriptor(key: #keyPath(Venue.name), ascending: true, selector: #selector(NSString.localizedCompare(_:)))
  
  lazy var distanceDescriptor = NSSortDescriptor(key: #keyPath(Venue.location.distance), ascending: true)
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    populateCheapVenueCountLabel()
    populateModerateVenueCountLabel()
    
    populateDealsVenueCountLabel()
  }
}

// MARK: - IBActions
extension FilterViewController {

  @IBAction func search(_ sender: UIBarButtonItem) {
    self.delegate?.filterViewController(filter: self, didSelectPredicate: selectedPredicate, sortDescriptor: selectedSortDescriptor)
    dismiss(animated: true)
  }
}

// MARK - UITableViewDelegate
extension FilterViewController {

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else {
      return
    }
    
    switch cell {
    case cheapVenueCell:
      selectedPredicate = cheapPricePredicate
      
    case moderateVenueCell:
      selectedPredicate = moderatePredicate
      
    case expensiveVenueCell:
      selectedPredicate = expensivePredicate
      
      //
      
      //
    case nameAZSortCell:
      selectedSortDescriptor = nameDescriptor
      
    case distanceSortCell:
      selectedSortDescriptor = distanceDescriptor
    default:
      break
    }
    
    cell.accessoryType = .checkmark
  }
}
extension FilterViewController {
  func populateCheapVenueCountLabel() {
    firstPriceCategoryLabel.text = populateVenueStringWithPredicate(cheapPricePredicate)
  }
  
  func populateModerateVenueCountLabel() {
    secondPriceCategoryLabel.text = populateVenueStringWithPredicate(moderatePredicate)
  }
  
  func populateExpensiveVenueCountLabel() {
    let request: NSFetchRequest<Venue> = Venue.fetchRequest()
    request.predicate = expensivePredicate
    do {
      let count = try coreDataStack.managedContext.count(for: request)
      let pluralized = count == 1 ? "place" : "places"
      thirdPriceCategoryLabel.text = "\(count) bubble tea \(pluralized)"
    } catch let error as NSError {
      print(error)
    }
  }
  
  func populateDealsVenueCountLabel() {
    let request = NSFetchRequest<NSDictionary>(entityName: "Venue")
    request.resultType = .dictionaryResultType
    
    let sumExpressionDs = NSExpressionDescription()
    sumExpressionDs.name = "sumDeals"
    let specialEx = NSExpression(forKeyPath: \Venue.specialCount)
    sumExpressionDs.expression = NSExpression(forFunction: "sum:", arguments: [specialEx])
    sumExpressionDs.expressionResultType = .integer32AttributeType
  
    
    request.propertiesToFetch = [sumExpressionDs]
    
    do {
      let result = try coreDataStack.managedContext.fetch(request)
      let dic = result.first!
      let value = dic["sumDeals"] as! Int
      let pluralized = value == 1 ? "deal" : "deals"
      numDealsLabel.text = "\(String(describing: value))\(pluralized)"
    } catch let error as NSError {
      print(error)
    }
  }
  
  
  func populateVenueStringWithPredicate(_ predicate: NSPredicate) -> String? {
    let request = NSFetchRequest<NSNumber>(entityName: "Venue")
    request.resultType = .countResultType
    request.predicate = predicate
    
    do {
      let result = try coreDataStack.managedContext.fetch(request)
      let count = result.first!.intValue
      let pluralized = count == 1 ? "place" : "places"
      return "\(count) bubble tea \(pluralized)"
      
    } catch let error as NSError {
      print(error)
    }
    return nil
  }
}



protocol FilterViewControllerDelegate: class {
  func filterViewController(filter: FilterViewController, didSelectPredicate predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?)
}
