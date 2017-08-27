//
//  NotificationViewController.swift
//  pensiveSwift3
//
//  Created by Jack Borthwick on 8/20/17.
//  Copyright © 2017 Jack Borthwick. All rights reserved.
//

import UIKit
import UserNotifications
class NotificationViewController: UIViewController {
    @IBOutlet weak var startDatePicker:                         UIDatePicker!
    @IBOutlet weak var endDatePicker:                           UIDatePicker!
    @IBOutlet weak var notificationStepper:                     UIStepper!
    @IBOutlet weak var notificationCountLabel:                  UILabel!
    
    var formatter     =         DateFormatter()
    var startTime     =         Date()
    var endTime       =         Date()

    @IBAction func pressedScheduleNotifications(_sender: AnyObject) {
        scheduleNotifications()
    }
    @IBAction func pressedDeleteNotifications(_sender: AnyObject) {
        let confirmationAlert = UIAlertController(title: "Notifications Deleted!",
                                                  message: "",
                                                  preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK",
                                     style: .default) {
                                        UIAlertAction in
                                        self.navigationController?.popViewController(animated: true)
        }
        confirmationAlert.addAction(okAction)
        present(confirmationAlert, animated: true)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    @IBAction func notificationStepperChanged (_sender: AnyObject){
        notificationCountLabel.text = String(Int(notificationStepper.value))
    }
    
    
    func scheduleNotifications() {
        let userCalendar = Calendar.current
        let requestedComponent: Set<Calendar.Component> = [.month,.day,.hour,.minute,.second]
        let elapsed = endDatePicker.date.timeIntervalSince(startDatePicker.date)
        if Int(elapsed) > 0 {
            let notificationInterval = Int(elapsed) / Int(notificationCountLabel.text!)!
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            var notificationTimes = [Date]()
            for i in 0 ..< Int(notificationCountLabel.text!)! {
                let date = userCalendar.date(byAdding: .second, value: (notificationInterval * i), to: startDatePicker.date)
//                createNotification(firingTime: date!)
                notificationTimes.append(date!)
            }
            UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
                print("Requests: \(notificationRequests)")
            }
            var notificationTimesToDisplay = [String]()
            var i = 1
            for time in notificationTimes {
                notificationTimesToDisplay.append(String(i) + ":        " + formatter.string(from: time))
                i += 1
            }
            let confirmationAlert = UIAlertController(title: "Notifications Scheduled!",
                                                      message: "",
                                                      preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK",
                                                          style: .default) {
                                                            UIAlertAction in
                                                            self.navigationController?.popViewController(animated: true)
            }
            confirmationAlert.addAction(okAction)
            let alert = UIAlertController(title: "Notifications to be scheduled",
                                          message: notificationTimesToDisplay.joined(separator: "\n"),
                                          preferredStyle: .alert)
            let scheduleNotificationsAction = UIAlertAction(title: "Schedule",
                                                            style: .default){
                                                                UIAlertAction in
                                                                for i in 0 ..< Int(self.notificationCountLabel.text!)! {
                                                                    let date = userCalendar.date(byAdding: .second, value: (notificationInterval * i), to: self.startDatePicker.date)
                                                                    self.createNotification(firingTime: date!, notifID: String(i))
                                                                }
                                                                self.present(confirmationAlert, animated: true)
            }

            let cancelNotificationsAction = UIAlertAction(title: "Cancel",
                                                          style: .default) {
                                                            UIAlertAction in
//                                                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            }
            alert.addAction(scheduleNotificationsAction)
            alert.addAction(cancelNotificationsAction)
            present(alert, animated: true)
        }
    }
    
    func createNotification(firingTime: Date, notifID: String) {
        if #available(iOS 10.0, *) {
            //            let commentAction = UNTextInputNotificationAction(identifier: "notificationId", title: "What's on your mind?", options: [], textInputButtonTitle: "Add", textInputPlaceholder: "")
            let content = UNMutableNotificationContent()
            content.title = "Hey?"
            content.body = "What's on your mind?"
            content.categoryIdentifier = "categoryId.category"
            content.badge = 1
            let dateCompenents = Calendar.current.dateComponents([.hour, .minute, .second], from: firingTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateCompenents, repeats: true)
            let request = UNNotificationRequest(identifier: notifID, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            print("added")
        }
    }
    

    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationCountLabel.text = String(Int(notificationStepper.value))
        self.title = "Notifications Settings"
        self.formatter.dateFormat = "HH:mm"
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

