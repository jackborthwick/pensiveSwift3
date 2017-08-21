//
//  ViewController.swift
//  pensiveSwift3
//
//  Created by Jack Borthwick on 8/7/17.
//  Copyright © 2017 Jack Borthwick. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import CoreLocation
//class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UNUserNotificationCenterDelegate, CLLocationManagerDelegate, UITextViewDelegate, UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var tableView:               UITableView!
    @IBOutlet weak var collectionView:          UICollectionView!
    @IBOutlet weak var noteTextView:            UITextView!

    
    var days: [Day] = []
    var currentDay = Day()
    let reuseIdentifierCollectionView = "CVCell"
    let formatter = DateFormatter()
    var lastOffsetCapture = TimeInterval.abs(0)
    var previousOffset = CGPoint.init(x:0, y:0)
    let locationManager = CLLocationManager()

    
 
    
    //MARK: CollectionView/Slider Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.days.count + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Padding so all cells can reach the center of the screen
        if indexPath.row == 0 || indexPath.row == self.days.count + 1 {
            var cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierCollectionView, for: indexPath as     IndexPath) as! DayCollectionViewCell
            cell.dayDateLabel.text = ""
            return cell        }
        else if days.count != 0 {
            var cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierCollectionView, for: indexPath as     IndexPath) as! DayCollectionViewCell
            let day = days[indexPath.row - 1]
            cell.dayDateLabel.text = day.value(forKey: "date") as? String
            return cell

        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierCollectionView, for: indexPath as     IndexPath) as! DayCollectionViewCell
            cell.dayDateLabel?.text = "no days"
            return cell

        }
        
    }
    
    func getSliderCenter() -> CGPoint {
        return CGPoint(x: (self.collectionView.frame.size.width / 2 + collectionView.contentOffset.x - (self.view.frame.width / 2.9)) + 8, y: self.collectionView.frame.size.height / 2 + collectionView.contentOffset.y)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            updateTextViewFromScroll()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
//            let indexPath = memorySliderCollectionView.indexPathForItemAtPoint(getSliderCenter())
//            if ((indexPath != nil) && (indexPath!.row <= memoryArray.count - 1)) {
//                currentMemory = memoryArray[(indexPath?.row)!]
//                let dateFormatter  = NSDateFormatter()
//                dateFormatter.dateFormat = "EEEE MMM d"
//                if currentMemory.memoryTempHigh == 0 {
//                    currentTemp.hidden = true
//                }
//                else if currentMemory.memoryTempHigh != nil {
//                    currentTemp.text = String(currentMemory.memoryTempHigh!)
//                    currentTemp.hidden = false
//                }
//                else {
//                    //                    currentTemp.hidden = true
//                }
//                //                navigationItem.title = dateFormatter.stringFromDate(currentMemory.memoryDate!)
//            }
            let currentOffset = scrollView.contentOffset
            let currentTime = NSDate.timeIntervalSinceReferenceDate
            let timeDiff = currentTime - lastOffsetCapture
            if(timeDiff > 0.1) {
                let distance = (currentOffset.x - previousOffset.x)
                let scrollSpeed = fabsf(Float((distance * 10) / 1000))
                if scrollSpeed > 0.2 {
                    self.collectionView.decelerationRate = UIScrollViewDecelerationRateNormal
                }
                else {
                    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast
                }
            }
            previousOffset = currentOffset
            lastOffsetCapture = currentTime
        }
    }
    
    func updateTextViewFromScroll () {
        let indexPath = collectionView.indexPathForItem(at: getSliderCenter())
        if ((indexPath != nil) && (indexPath!.row <= days.count - 1)) {
            noteTextView.text = String(describing: days[(indexPath?.row)!].relationshipDayNote!.allObjects.count)

            currentDay = days[(indexPath?.row)!]
            if days[(indexPath?.row)!].value(forKey: "weather") != nil {
                noteTextView.text = days[(indexPath?.row)!].value(forKey: "weather") as! String
                noteTextView.text = (noteTextView.text + "\n" + "Latitude:" + (days[(indexPath?.row)!].value(forKey: "latitude") as! String))
                noteTextView.text = noteTextView.text + "\n" + "Longitude:" + (days[(indexPath?.row)!].value(forKey: "longitude") as! String)
                noteTextView.text = noteTextView.text + "\n" + String(days[(indexPath?.row)!].relationshipDayNote!.count)
                tableView.reloadData()
            }
        }
    }
    
    func scrollToMostRecentDay() {
        let indexPath = NSIndexPath(item: days.count, section: 0) // 1
        self.collectionView.scrollToItem(at: indexPath as IndexPath, at: UICollectionViewScrollPosition.left, animated: true)
        updateTextViewFromScroll()
    }
    
    
//    //MARK: Table View Methods
//    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return self.currentDay.relationshipDayNote!.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            if days.count != 0 {
                let descriptors = [NSSortDescriptor(key: "date", ascending: true)] as [NSSortDescriptor]
                let notes = currentDay.relationshipDayNote?.sortedArray(using: descriptors) as NSArray!
//                let day = days[indexPath.row]
                let cell =
                    tableView.dequeueReusableCell(withIdentifier: "Cell",
                                              for: indexPath)
                cell.layoutMargins = UIEdgeInsets.zero
                cell.textLabel?.text = String(describing: (notes?[indexPath.row] as! Note).note)

                
                return cell
            }
            else {
                let cell =
                    tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                  for: indexPath)
                cell.textLabel?.text = "No days"
                return cell
            }
    }
//
    //MARK: Note CoreData Methods
    
    func saveDay(noteString: String, date: Date) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        print ("setting note")

        let managedObjectContext =
            appDelegate.persistentContainer.viewContext
        
        let entityDescription =
            NSEntityDescription.entity(forEntityName: "Note",
                                       in: managedObjectContext)!
        let note = NSManagedObject(entity: entityDescription, insertInto: managedObjectContext) as! Note
        print ("setting note")

        note.note = noteString
        print ("set note")
        if !(checkDayExistence(date: Date())) {
            
            let entityDescription =
                NSEntityDescription.entity(forEntityName: "Day",
                                           in: managedObjectContext)!
            let day = NSManagedObject(entity: entityDescription, insertInto: managedObjectContext) as! Day
            print (date)
            let date = Date()
            day.setValue(self.formatter.string(from: date), forKey: "date")
            print ("set date")
            note.relationshipNotesDay = day
            print ("set relationship")
            currentDay = day
            locationManager.startUpdatingLocation()
            print ("set relationship")
            do {
                try managedObjectContext.save()
                days.append(day)
                print ("set relationship")
            } catch let error as NSError {
                print("Can't save that my dude. Here's why --> \(error), \(error.userInfo)")
            }
        }
        else {
//            days[days.count - 1].setValue((days[days.count - 1].value(forKey: "note") as! String) + "\n" + noteString, forKey: "note")
            note.relationshipNotesDay = days[days.count - 1]
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                print("Can't save that my dude. Here's why --> \(error), \(error.userInfo)")
            }
            //appending info
            fetchDays()
            print ("day already exists")
        }

    }
    func fetchDays (){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedObjectContext =
            appDelegate.persistentContainer.viewContext
        do {
            days = try managedObjectContext.fetch(Day.fetchRequest())
            collectionView.reloadData()
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    func checkDayExistence(date: Date) -> Bool {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return false
        }
        let managedObjectContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Day")
        let predicate = NSPredicate(format: "date = %@", self.formatter.string(from: date))
        fetchRequest.predicate = predicate
        do {
            let fetchResults = try managedObjectContext.fetch(fetchRequest) as? [Day]
            if fetchResults!.count > 0 {
                print ("already have that day")
                return true
            }
            else {
                return false
            }
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return true
            
        }

    }
    
    //MARK: Local Notification Delegate Methods
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.actionIdentifier
        let textResponse = response as? UNTextInputNotificationResponse
        if (textResponse?.userText) != nil {
            self.saveDay(noteString: (textResponse?.userText)!, date: Date())
            //            self.tableView.reloadData()
            self.collectionView.reloadData()
            self.updateTextViewFromScroll()
            print("Tapped in notification")
        }

    }
    
    //MARK: Local Notification Scheduling Methods

    func createNotification(firingTime: String) {
        if #available(iOS 10.0, *) {
//            let commentAction = UNTextInputNotificationAction(identifier: "notificationId", title: "What's on your mind?", options: [], textInputButtonTitle: "Add", textInputPlaceholder: "")
            let content = UNMutableNotificationContent()
            content.title = "Hey?"
            content.body = "What's on your mind?"
            content.categoryIdentifier = "categoryId.category"
            content.badge = 1
            let date = Date(timeIntervalSinceNow: 3)
            var dateCompenents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateCompenents, repeats: false)
            let request = UNNotificationRequest(identifier: "notificationId", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
        
    }
    

    

    //MARK: Interactivity Methods
    
    @IBAction func makeDay(_sender: AnyObject) {
        let alert = UIAlertController(title: "New Day",
                                      message: "Make a note",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            
            guard let textField = alert.textFields?.first,
                let noteToSave = textField.text else {
                    return
            }
            
            self.saveDay(noteString: noteToSave, date: Date())
//            self.tableView.reloadData()
            self.collectionView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    @IBAction func scheduleTestNotification(_sender: AnyObject) {
        print ("pressed make notification")
        createNotification(firingTime: "")
    }

    //MARK: - Location Methods
    func locationManager(_: CLLocationManager, didUpdateLocations: [CLLocation]){
        print ("LOCATION LOCATION LOCATION")
        print(didUpdateLocations[0].coordinate)

        if currentDay.value(forKey: "longitude") == nil {
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            let managedObjectContext =
                appDelegate.persistentContainer.viewContext
            currentDay.setValue(String(format: "%f", didUpdateLocations[0].coordinate.longitude), forKey: "longitude")
            currentDay.setValue(String(format: "%f", didUpdateLocations[0].coordinate.latitude), forKey: "latitude")
            currentDay.setValue(getWeather(lat: String(format: "%f", didUpdateLocations[0].coordinate.latitude), lon: String(format: "%f", didUpdateLocations[0].coordinate.longitude))[0] as! String, forKey: "weather")
            do {
                try managedObjectContext.save()
                fetchDays()
//                days.append(day)
            } catch let error as NSError {
                print("Can't save that my dude. Here's why --> \(error), \(error.userInfo)")
            }//            getWeather(String(didUpdateLocations[0].coordinate.latitude), lon: String(didUpdateLocations[0].coordinate.longitude))
        }
        locationManager.stopUpdatingLocation()
    }
    
    @objc func locationManager(_: CLLocationManager, didFailWithError: Error) {
        print (didFailWithError)
    }
    //MARK: Weather Methods
    func getWeather(lat:String, lon:String) -> [String] {
        if let url = NSURL(string: "https://api.forecast.io/forecast/d3250bf407f0579c8355cd39cdd4f9e1/"+lat+","+lon) {
            if let data = NSData(contentsOf: url as URL){
                do {
                    let parsed = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.allowFragments)
                    print (parsed)
                    let newDict = parsed as? NSDictionary
                    print((newDict!["currently"]! as? NSDictionary)?["summary"])
//                    self.weatherArray = ["\(newDict!["currently"]!["temperature"]!!.intValue)°",newDict!["currently"]!["icon"]!! as! String]
//                    NSNotificationCenter.defaultCenter().postNotificationName("gotWeather", object: nil)
                    return ["\(((newDict!["currently"]! as? NSDictionary)?["temperature"]!))°",(newDict!["currently"]! as? NSDictionary)?["icon"]! as! String]
                }
                catch let error {
                    print("A JSON parsithng error occurred, here are the details:\n \(error)")
                    return ["fuuuck"]
                }
            }
        }
        return ["suck"]
    }
    
    //MARK: Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.formatter.dateFormat = "dd.MM.yyyy"
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: {didAllow,Error in })
        UNUserNotificationCenter.current().delegate = self
        

        let textAction = UNTextInputNotificationAction(identifier: "textActionId", title: "Enter Memory", options: [], textInputButtonTitle: "Add", textInputPlaceholder: "")
        let category = UNNotificationCategory(
            identifier: "categoryId.category",
            actions: [textAction],
            intentIdentifiers: [],
            options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        if (CLLocationManager.locationServicesEnabled()) {
            print ("LOCATION SERVICES ENABLED")
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//            locationManager.startUpdatingLocation()
        }
//        let settings = UNNotificationSetting(forTypes: [.Alert, .Badge, .Sound], categories: categories)
//        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        // Do any additional setup after loading the view, typically from a nib.
//
//        tableView.register(UITableViewCell.self,
//                           forCellReuseIdentifier: "Cell")
//        tableView.layoutMargins = UIEdgeInsets.zero
//        tableView.separatorInset = UIEdgeInsets.zero
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchDays()
        scrollToMostRecentDay()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

