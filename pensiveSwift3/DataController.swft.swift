//
//  DataController.swft.swift
//  pensiveSwift3
//
//  Created by Jack Borthwick on 8/23/17.
//  Copyright © 2017 Jack Borthwick. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    var days: [Day] = []
    var currentDay = Day()
    let formatter = DateFormatter()
    var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    var appDelegate = AppDelegate()
    
    init(managedObjectContext: NSManagedObjectContext, appDelegate: AppDelegate ) {
        self.appDelegate = appDelegate
        self.managedObjectContext = managedObjectContext
        self.formatter.dateFormat = "dd.MM.yyyy"
        self.fetchDays()
    }
    func createNote(managedObjectContext: NSManagedObjectContext, appDelegate: AppDelegate, noteString: String) -> Note{
        let date = Date()
        let entityDescription =
            NSEntityDescription.entity(forEntityName: "Note",
                                       in: managedObjectContext)!
        let note = NSManagedObject(entity: entityDescription, insertInto: managedObjectContext) as! Note
        note.date = self.formatter.string(from: date)
        note.note = noteString
        return note
    }
    
    func createDay(managedObjectContext: NSManagedObjectContext, appDelegate: AppDelegate, date: Date) -> Day {
        let entityDescription =
            NSEntityDescription.entity(forEntityName: "Day",
                                       in: managedObjectContext)!
        let day = NSManagedObject(entity: entityDescription, insertInto: managedObjectContext) as! Day
        print (date)
        day.setValue(self.formatter.string(from: date), forKey: "date")
        return day
    }
    
    func connectNoteToDay(note: Note, day: Day) {
        note.relationshipNotesDay = day
        note.order = Int16((day.relationshipDayNote?.count)!)
    }
    
    func saveContext(managedObjectContext: NSManagedObjectContext) {
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Can't save that my dude. Here's why --> \(error), \(error.userInfo)")
//            presentUnknownErrorAlert()
        }
        
    }
    
    func fetchDays (){
        do {
            days = try managedObjectContext.fetch(Day.fetchRequest())
            if days.count > 0 {
                self.currentDay = days[days.count - 1]
                
                
            }

            print ("fetched days")
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func checkDayExistence(managedObjectContext: NSManagedObjectContext, appDelegate: AppDelegate, date: Date) -> Bool {
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
    
    func saveAction(noteString: String, date: Date) {
        let note = self.createNote(managedObjectContext: managedObjectContext, appDelegate: appDelegate, noteString: noteString)
        if !(checkDayExistence(managedObjectContext: managedObjectContext, appDelegate: appDelegate, date: Date())) {//Create day and note
            let day = createDay(managedObjectContext: managedObjectContext, appDelegate: appDelegate, date: date)
            self.connectNoteToDay(note: note, day: day)
            currentDay = day
//            locationManager.startUpdatingLocation()
            saveContext(managedObjectContext: managedObjectContext)
            days.append(day)
        }
        else {//Add note to existing day
            connectNoteToDay(note: note, day: days[days.count - 1])
            saveContext(managedObjectContext: managedObjectContext)
            fetchDays()
            print ("day already exists")
        }
        
    }

}
