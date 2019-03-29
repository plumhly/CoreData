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

  // MARK: - IBOutlets
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var ratingLabel: UILabel!
  @IBOutlet weak var timesWornLabel: UILabel!
  @IBOutlet weak var lastWornLabel: UILabel!
  @IBOutlet weak var favoriteLabel: UILabel!
  
  var currentTie: Bowtie?

  var managerContext: NSManagedObjectContext!
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    insertSampleData()
    
    let fetchRequest: NSFetchRequest<Bowtie> = Bowtie.fetchRequest()
    let firstTitle = segmentedControl.titleForSegment(at: 0)
    fetchRequest.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(Bowtie.searchKey), firstTitle!])
    do {
      let result = try managerContext.fetch(fetchRequest)
      currentTie = result.first
      populate(bowtie: currentTie!)
    } catch let error as NSError {
      print("error: \(error)")
    }
    
    
  }
  
  func insertSampleData() {
    let fetchRequest: NSFetchRequest<Bowtie> = Bowtie.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "searchKey != nil")
    let count = try! managerContext.count(for: fetchRequest)
    if count > 0 {
      return
    }
    
    let path = Bundle.main.path(forResource: "SampleData", ofType: "plist")
    let dataArray = NSArray(contentsOfFile: path!)!
    
    for dict in dataArray {
      let entity = NSEntityDescription.entity( forEntityName: "Bowtie", in: managerContext)!
      
      let bowtie = Bowtie(entity: entity, insertInto: managerContext)
      let btDict = dict as! [String: Any]
      
      bowtie.id = UUID(uuidString: btDict["id"] as! String)
      bowtie.name = btDict["name"] as? String
      bowtie.searchKey = btDict["searchKey"] as? String
      bowtie.rating = btDict["rating"] as! Double
      let colorDict = btDict["tintColor"] as! [String: Any]
      bowtie.tintColor = UIColor.color(dic: colorDict)
      
      let imageName = btDict["imageName"] as? String
      let image = UIImage(named: imageName!)
      
      let photoData = UIImagePNGRepresentation(image!)!
      bowtie.photoData = NSData(data: photoData)
      bowtie.lastWorn = btDict["lastWorn"] as? NSDate
      
      let timesNumber = btDict["timesWorn"] as! NSNumber
      bowtie.timesWorn = timesNumber.int32Value
      bowtie.isFavorite = btDict["isFavorite"] as! Bool
      bowtie.url = URL(string: btDict["url"] as! String)
    }
    try! managerContext.save()
    
  }
  
  func populate(bowtie: Bowtie) {
    guard let imageData = bowtie.photoData as Data?,
      let lastWorn = bowtie.lastWorn as Date?,
      let tintColor = bowtie.tintColor as? UIColor
    else {
      return
    }
    
    imageView.image = UIImage(data: imageData)
    nameLabel.text = bowtie.name
    ratingLabel.text = "Rating: \(bowtie.rating)/5"
    timesWornLabel.text = "# times worn: \(bowtie.timesWorn)"
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none
    
    lastWornLabel.text = "last worn: " + dateFormatter.string(from: lastWorn)
    
    favoriteLabel.isHidden = !bowtie.isFavorite
    view.tintColor = tintColor
  }

  // MARK: - IBActions
  @IBAction func segmentedControl(_ sender: Any) {
    guard let segment = sender as? UISegmentedControl,
    let title = segment.titleForSegment(at: segment.selectedSegmentIndex) else { return }
    
    let request: NSFetchRequest<Bowtie> = Bowtie.fetchRequest()
    request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(Bowtie.searchKey), title])
    do {
      let result = try managerContext.fetch(request)
      currentTie = result.first
      populate(bowtie: currentTie!)
    } catch let error as NSError {
      print(error)
    }
    
  }

  @IBAction func wear(_ sender: Any) {
    let times = currentTie?.timesWorn
    currentTie?.timesWorn = times! + 1
    currentTie?.lastWorn = NSDate()
    
    do {
      try managerContext.save()
      populate(bowtie: currentTie!)
    } catch let error as NSError {
      print(error)
    }
  }
  
  @IBAction func rate(_ sender: Any) {
    let alert = UIAlertController(title: "New Rating", message: "Rate this bow tie", preferredStyle: .alert)
    alert.addTextField { textfield in
      textfield.keyboardType = .decimalPad
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
      guard let textfield = alert.textFields?.first else {
        return
      }
      self.update(textfield.text!)
    }
    alert.addAction(cancelAction)
    alert.addAction(saveAction)
    present(alert, animated: true)
  }
  
  func update(_ string: String) {
    guard let rating = Double(string) else { return }
    currentTie?.rating = rating
    do {
      try managerContext.save()
      populate(bowtie: currentTie!)
    } catch let error as NSError {
      if error.domain == NSCocoaErrorDomain && (error.code == NSValidationNumberTooLargeError || error.code == NSValidationNumberTooSmallError) {
        rate(currentTie!)
      } else {
        print(error)
      }
    }
  }
}


extension UIColor {
  static func color(dic: [String: Any]) -> UIColor? {
    guard let red = dic["red"] as? NSNumber,
    let green = dic["green"] as? NSNumber,
    let blue = dic["blue"] as? NSNumber else {
      return nil
    }
    return UIColor(red: CGFloat(truncating: red) / 255.0, green: CGFloat(truncating: green) / 255.0, blue: CGFloat(truncating: blue) / 255.0, alpha: 1.0)
  }
}


