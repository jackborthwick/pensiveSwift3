//
//  ViewController.swift
//  pensiveSwift3
//
//  Created by Jack Borthwick on 8/7/17.
//  Copyright © 2017 Jack Borthwick. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation
//class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UNUserNotificationCenterDelegate, CLLocationManagerDelegate, UITextViewDelegate, UITableViewDelegate,UITableViewDataSource, UIApplicationDelegate{
    
    @IBOutlet weak var tableView:               UITableView!
    @IBOutlet weak var collectionView:          UICollectionView!
    @IBOutlet weak var noteTextView:            UITextView!
    
    let noteSegueIdentifier = "noteSegueID"
    

    var selectedNote = Note()
    let reuseIdentifierCollectionView = "CVCell"
    let formatter = DateFormatter()
    var lastOffsetCapture = TimeInterval.abs(0)
    var previousOffset = CGPoint.init(x:0, y:0)
    let locationManager = CLLocationManager()
    lazy var dataController :DataController = self.initializeDataController()
    
    func initializeDataController() -> DataController {
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext =
            appDelegate.persistentContainer.viewContext
        let dataController = DataController(managedObjectContext: managedObjectContext, appDelegate: appDelegate)
        return dataController
    }
    
    //MARK: Force Touch Methos
    func application(_ application: UIApplication,
                              performActionFor shortcutItem: UIApplicationShortcutItem,
                              completionHandler: @escaping (Bool) -> Void) {
        print ("opened with force touch")
        print (shortcutItem)
        if shortcutItem.type == "com.app.newnote" {
            let newNote = self.dataController.createNote(noteString: "")
            self.dataController.connectNoteToDay(note: newNote, day: self.dataController.currentDay)
            self.selectedNote = newNote
            performSegue(withIdentifier: noteSegueIdentifier, sender: nil)
        }
    }
    //MARK: Segue Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == noteSegueIdentifier {
            let noteVC = segue.destination as? NoteViewController
            noteVC?.selectedNote = self.selectedNote
        }
    }
 
    
    //MARK: CollectionView/Slider Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataController.days.count + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Padding so all cells can reach the center of the screen
        if indexPath.row == 0 || indexPath.row == self.dataController.days.count + 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierCollectionView, for: indexPath as     IndexPath) as! DayCollectionViewCell
            cell.dayDateLabel.text = ""
            return cell        }
        else if self.dataController.days.count != 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierCollectionView, for: indexPath as     IndexPath) as! DayCollectionViewCell
            let day = self.dataController.days[indexPath.row - 1]
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
        print ("updating")
        let indexPath = collectionView.indexPathForItem(at: getSliderCenter())
        if ((indexPath != nil) && (indexPath!.row <= self.dataController.days.count - 1)) {
            noteTextView.text = String(describing: self.dataController.days[(indexPath?.row)!].relationshipDayNote!.allObjects.count)

            self.dataController.currentDay = self.dataController.days[(indexPath?.row)!]
            tableView.reloadData()

//            print(self.currentDay)
            if self.dataController.days[(indexPath?.row)!].value(forKey: "weather") != nil {
                noteTextView.text = self.dataController.days[(indexPath?.row)!].value(forKey: "weather") as! String
                noteTextView.text = (noteTextView.text + "\n" + "Latitude:" + (self.dataController.days[(indexPath?.row)!].value(forKey: "latitude") as! String))
                noteTextView.text = noteTextView.text + "\n" + "Longitude:" + (self.dataController.days[(indexPath?.row)!].value(forKey: "longitude") as! String)
                noteTextView.text = noteTextView.text + "\n" + String(self.dataController.days[(indexPath?.row)!].relationshipDayNote!.count)
            }
        }
    }
    
    func scrollToMostRecentDay() {
        let indexPath = NSIndexPath(item: self.dataController.days.count, section: 0) // 1
        self.collectionView.scrollToItem(at: indexPath as IndexPath, at: UICollectionViewScrollPosition.left, animated: true)
        updateTextViewFromScroll()
    }
    
    
//    //MARK: Table View Methods
//    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if self.dataController.days.count > 0 {
            return ((self.dataController.currentDay.relationshipDayNote?.count ?? 0) + 1)
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            if self.dataController.days.count > 0 {
                if indexPath.row == (self.dataController.currentDay.relationshipDayNote?.count) {
                    let cell =
                        tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                      for: indexPath)
                    cell.layoutMargins = UIEdgeInsets.zero
                    cell.textLabel?.text = "add a new note"
                    return cell
                }
                let descriptors = [NSSortDescriptor(key: "order", ascending: true)] as [NSSortDescriptor]
                let notes = self.dataController.currentDay.relationshipDayNote?.sortedArray(using: descriptors) as NSArray!
                let cell =
                    tableView.dequeueReusableCell(withIdentifier: "Cell",
                                              for: indexPath)
                cell.layoutMargins = UIEdgeInsets.zero
                cell.textLabel?.text = String(describing: (notes?[indexPath.row] as! Note).note!)
                cell.textLabel?.text = (cell.textLabel?.text)! + String(describing:(notes?[indexPath.row] as! Note).date!)
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let descriptors = [NSSortDescriptor(key: "order", ascending: true)] as [NSSortDescriptor]
        let notes = self.dataController.currentDay.relationshipDayNote?.sortedArray(using: descriptors) as! [Note]!
        if indexPath.row != notes?.count {
            self.selectedNote = (notes?[indexPath.row])!
        }
        else {
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            let managedObjectContext =
                appDelegate.persistentContainer.viewContext
            let newNote = self.dataController.createNote(noteString: "")
            self.dataController.connectNoteToDay(note: newNote, day: self.dataController.currentDay)
            self.selectedNote = newNote
        }
        performSegue(withIdentifier: noteSegueIdentifier, sender: nil)

    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let descriptors = [NSSortDescriptor(key: "order", ascending: true)] as [NSSortDescriptor]
        let notes = self.dataController.currentDay.relationshipDayNote?.sortedArray(using: descriptors) as! [Note]!
        if indexPath.row != notes?.count {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let descriptors = [NSSortDescriptor(key: "order", ascending: true)] as [NSSortDescriptor]
            let notes = self.dataController.currentDay.relationshipDayNote?.sortedArray(using: descriptors) as! [Note]!
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            print ("setting note")
            
            let managedObjectContext =
                appDelegate.persistentContainer.viewContext
            managedObjectContext.delete((notes?[indexPath.row])!)
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                print("Can't save that my dude. Here's why --> \(error), \(error.userInfo)")
            }
            updateTextViewFromScroll()
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
            if self.dataController.saveAction(noteString: (textResponse?.userText)!, date: Date()) {//if it'sa new day
                self.dataController.fetchDays()
                locationManager.startUpdatingLocation()
            }
            self.collectionView.reloadData()
            self.updateTextViewFromScroll()
            print("Tapped in notification")
        }
        else {
            let alert = UIAlertController(title: "Opps",
                                          message: "If you want to enter a note using a notification you must enter it in the text field.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Cancel",
                                             style: .default)
            alert.addAction(okAction)
            present(alert, animated: true)
        }

    }
    
    //MARK: Local Notification Scheduling Methods

    func createNotification(firingTime: String) {
        if #available(iOS 10.0, *) {
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
            
            self.dataController.saveAction(noteString: noteToSave, date: Date())
            self.collectionView.reloadData()
            self.updateTextViewFromScroll()
        }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    @IBAction func scheduleTestNotification(_sender: AnyObject) {
        createNotification(firingTime: "")
    }

    //MARK: - Location Methods
    func locationManager(_: CLLocationManager, didUpdateLocations: [CLLocation]){
        print ("LOCATION LOCATION LOCATION")
        print(didUpdateLocations[0].coordinate)
        
        if self.dataController.days[self.dataController.days.count - 1].value(forKey: "longitude") == nil {
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            let managedObjectContext =
                appDelegate.persistentContainer.viewContext
            self.dataController.days[self.dataController.days.count - 1].setValue(String(format: "%f", didUpdateLocations[0].coordinate.longitude), forKey: "longitude")
            self.dataController.days[self.dataController.days.count - 1].setValue(String(format: "%f", didUpdateLocations[0].coordinate.latitude), forKey: "latitude")
            self.dataController.days[self.dataController.days.count - 1].setValue(getWeather(lat: String(format: "%f", didUpdateLocations[0].coordinate.latitude), lon: String(format: "%f", didUpdateLocations[0].coordinate.longitude))[0] , forKey: "weather")
            do {
                try managedObjectContext.save()
                self.dataController.fetchDays()
                collectionView.reloadData()
                updateTextViewFromScroll()
            } catch let error as NSError {
                print("Can't save that my dude. Here's why --> \(error), \(error.userInfo)")
            }
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
    func presentUnknownErrorAlert() {
        let alert = UIAlertController(title: "An Unkown Error Occurred",
                                      message: "Sorry for the inconvenience.",
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okAction)
        present(alert,animated: true)
    }
    func catchNotification(notification:Notification) -> Void {
        print("Catch notification")
        print(UIApplication.topViewController())
        if (UIApplication.topViewController() is NoteViewController ) {
            print ("IT IS IT IS")
            self.dataController.appDelegate.makeNewNote = false
            let noteVC = UIApplication.topViewController() as! NoteViewController
            if noteVC.textView.text == "" || noteVC.textView.text == nil {
                dataController.managedObjectContext.delete(noteVC.selectedNote)
            }
            let newNote = self.dataController.createNote(noteString: "")
            self.dataController.connectNoteToDay(note: newNote, day: self.dataController.days[self.dataController.days.count - 1])
            noteVC.selectedNote = newNote
            noteVC.textView.text = newNote.note
        }
        else {
            if self.dataController.appDelegate.makeNewNote {
                let newNote = self.dataController.createNote(noteString: "")
                self.dataController.connectNoteToDay(note: newNote, day: self.dataController.days[self.dataController.days.count - 1])
                self.selectedNote = newNote
                performSegue(withIdentifier: noteSegueIdentifier, sender: nil)
                self.dataController.appDelegate.makeNewNote = false
            }
        }



        
    }
    //MARK: Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.reloadData()
        updateTextViewFromScroll()
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
//            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//            locationManager.startUpdatingLocation()
        }
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        print (dataController.appDelegate.launchedShortcutItem)
        let notificationName = Notification.Name("forceTouchNewNote")
        
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(catchNotification), name: notificationName, object: nil)
        
        // Post notification

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dataController.fetchDays()
        print ("appearded")
        collectionView.reloadData()
        scrollToMostRecentDay()
        updateTextViewFromScroll()
        print (self.dataController.appDelegate.makeNewNote)
        if (self.dataController.appDelegate.makeNewNote) {
            let newNote = self.dataController.createNote(noteString: "")
            self.dataController.connectNoteToDay(note: newNote, day: self.dataController.days[self.dataController.days.count - 1])
            self.selectedNote = newNote
            performSegue(withIdentifier: noteSegueIdentifier, sender: nil)
            self.dataController.appDelegate.makeNewNote = false
        }
        print ("appeared")
        if #available(iOS 9.0, *) {
            if (UIApplication.shared.shortcutItems?.filter({ $0.type == "com.app.newnote" }).first == nil) {
                UIApplication.shared.shortcutItems?.append(UIMutableApplicationShortcutItem(type: "com.app.newnote", localizedTitle: "New Note"))
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

