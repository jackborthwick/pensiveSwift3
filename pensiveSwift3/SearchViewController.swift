//
//  SearchViewController.swift
//  pensiveSwift3
//
//  Created by Jack Borthwick on 8/26/17.
//  Copyright © 2017 Jack Borthwick. All rights reserved.
//

import UIKit
import CoreData
class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    var delegate: SearchViewControllerDelegate?

    
    @IBOutlet var tableView               :           UITableView!
    @IBOutlet var searchTextField         :           UITextField!
    
    var searchResultNotes = [Note]()
    var selectedNote = Note()
    lazy var dataController :DataController = self.initializeDataController()

    
    func initializeDataController() -> DataController {
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext =
            appDelegate.persistentContainer.viewContext
        let dataController = DataController(managedObjectContext: managedObjectContext, appDelegate: appDelegate)
        dataController.fetchDays()
        return dataController
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        print (textField.text)
        if textField.text == nil || textField.text == "" {
            searchResultNotes = [Note]()
            tableView.reloadData()
            return
        }
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Note")
        let resultPredicate = NSPredicate(format: "note contains[c] %@", textField.text!)
        fetchRequest.predicate = resultPredicate
        print (fetchRequest)
        do {
            let fetchResults = try self.dataController.managedObjectContext.fetch(fetchRequest) as? [Note]
            if fetchResults!.count > 0 {
                searchResultNotes = fetchResults!
                print (searchResultNotes)

                searchResultNotes = searchResultNotes.sorted(by: { $0.convertedTime.compare($1.convertedTime) == ComparisonResult.orderedDescending })
                print (searchResultNotes)
                tableView.reloadData()
                print ("We have notes with that content")
                
            }
            else {
                searchResultNotes = [Note]()
                tableView.reloadData()
            }
        }
        catch let error as NSError {
            print(error)
        }
    }
    
    
    
    var cellReuseIdentifier = "SearchCell"
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultNotes.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        // set the text from the data model
        cell.textLabel?.text = searchResultNotes[indexPath.row].note
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        self.delegate?.searchViewControllerResponse(dayPassedBack: searchResultNotes[indexPath.row].relationshipNotesDay!)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view.
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
protocol SearchViewControllerDelegate {
    func searchViewControllerResponse(dayPassedBack: Day)
}












