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
        selectedNote.note = textView.text
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let vc = self.presentingViewController as! ViewController
//        vc.dataController.appDelegate.makeNewNote = false
        textView.text = selectedNote.note
        textView.delegate = self
        textView.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            print("appearing")
        self.title = selectedNote.date
    }
    

    
    override func viewWillDisappear(_ animated: Bool) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }

        let managedObjectContext =
            appDelegate.persistentContainer.viewContext
        if selectedNote.note == nil || selectedNote.note == "" {
            managedObjectContext.delete(selectedNote)
            print ("deleted")
        }
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
