//
//  NoteViewController.swift
//  pensiveSwift3
//
//  Created by Jack Borthwick on 8/21/17.
//  Copyright © 2017 Jack Borthwick. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView          : UITextView!
    var selectedNote = Note()
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        print(textView.text); //the textView parameter is the textView where text was changed
        selectedNote.note = textView.text
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = selectedNote.note
        textView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        print ("setting note")
        
        let managedObjectContext =
            appDelegate.persistentContainer.viewContext
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Can't save that my dude. Here's why --> \(error), \(error.userInfo)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
