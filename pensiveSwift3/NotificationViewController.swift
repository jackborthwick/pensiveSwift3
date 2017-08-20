//
//  NotificationViewController.swift
//  pensiveSwift3
//
//  Created by Jack Borthwick on 8/20/17.
//  Copyright © 2017 Jack Borthwick. All rights reserved.
//

import UIKit
import UserNotifications
class NotificationViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var notificationCountTextField:              UITextField!
    @IBOutlet weak var startDatePicker:                         UIDatePicker!
    @IBOutlet weak var endDatePicker:                           UIDatePicker!
    
    var startTime     =         Date()
    var endTime       =         Date()

    @IBAction func pressedScheduleNotifications(_sender: AnyObject) {
        scheduleNotifications()

    }
    
    func scheduleNotifications() {
        let userCalendar = Calendar.current
        let requestedComponent: Set<Calendar.Component> = [.month,.day,.hour,.minute,.second]
        let elapsed = endDatePicker.date.timeIntervalSince(startDatePicker.date)
        if Int(elapsed) > 0 {
            let notificationInterval = Int(elapsed) / Int(notificationCountTextField.text!)!
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            for i in 0 ..< Int(notificationCountTextField.text!)! {
                let date = userCalendar.date(byAdding: .second, value: (notificationInterval * i), to: startDatePicker.date)
                createNotification(firingTime: date!)
            }
            UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
                print("Requests: \(notificationRequests)")
            }
        }
    }
    
    func createNotification(firingTime: Date) {
        if #available(iOS 10.0, *) {
            //            let commentAction = UNTextInputNotificationAction(identifier: "notificationId", title: "What's on your mind?", options: [], textInputButtonTitle: "Add", textInputPlaceholder: "")
            let content = UNMutableNotificationContent()
            content.title = "Hey?"
            content.body = "What's on your mind?"
            content.categoryIdentifier = "categoryId.category"
            content.badge = 1
            let dateCompenents = Calendar.current.dateComponents([.hour, .minute, .second], from: firingTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateCompenents, repeats: true)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            print("added")
        }
    }
    
    func printTime() {

    }

    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

