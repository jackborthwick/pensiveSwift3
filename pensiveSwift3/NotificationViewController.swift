//
//  NotificationViewController.swift
//  pensiveSwift3
//
//  Created by Jack Borthwick on 8/20/17.
//  Copyright © 2017 Jack Borthwick. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var notificationCountTextField:              UITextField!
    @IBOutlet weak var startDatePicker:                         UIDatePicker!
    @IBOutlet weak var endDatePicker:                           UIDatePicker!
    
    var startTime     =         Date()
    var endTime       =         Date()

    @IBAction func scheduleNotifications(_sender: AnyObject) {
        
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
