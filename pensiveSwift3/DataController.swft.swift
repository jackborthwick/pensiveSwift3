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
    let formatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
    let noteFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy HH:mm"
        return formatter
    }()
    var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    var appDelegate = AppDelegate()
    
    init(managedObjectContext: NSManagedObjectContext, appDelegate: AppDelegate ) {
        self.appDelegate = appDelegate
        self.managedObjectContext = managedObjectContext
        self.fetchDays()
    }
    func createNote(noteString: String, date: Date) -> Note{
        let date = date
        let entityDescription =
            NSEntityDescription.entity(forEntityName: "Note",
                                       in: managedObjectContext)!
        let note = NSManagedObject(entity: entityDescription, insertInto: managedObjectContext) as! Note
        note.date = self.noteFormatter.string(from: date)
        note.note = noteString
        return note
    }
    
    func createDay(date: Date) -> Day {
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
    
    func saveContext() {
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Can't save that my dude. Here's why --> \(error), \(error.userInfo)")
//            presentUnknownErrorAlert()
        }
        
    }
    
    func fetchDays (){
        do {
            let calendar = NSCalendar.current

            days = try managedObjectContext.fetch(Day.fetchRequest())
            if days.count > 0 {
                if calendar.isDateInToday(formatter.date(from:days[days.count - 1].date!)!) {
                    self.currentDay = days[days.count - 1]
                }
                else {
                    let newDay = createDay(date: Date())
                    days.append(newDay)
                    self.currentDay = days[days.count - 1]
                }
            }
            else {
                let newDay = createDay(date: Date())
                days.append(newDay)
                self.currentDay = days[days.count - 1]
                addOnboardingDay()
            }

            print ("fetched days")
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func checkDayExistence(date: Date) -> Bool {
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
    
    func addOnboardingDay() {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())
        let onboardingDay = createDay(date: yesterday!)
        let note = createNote(noteString: "Hiya, this your first time here?", date: yesterday!)
        onboardingDay.addToRelationshipDayNote(note)
        saveContext()
    }
    
    func saveAction(noteString: String, date: Date) -> Bool {
        let note = self.createNote(noteString: noteString, date: Date())
        if !(checkDayExistence(date: Date())) {//Create day and note
            let day = createDay(date: date)
            self.connectNoteToDay(note: note, day: day)
            currentDay = day
//            locationManager.startUpdatingLocation()
            saveContext()
            days.append(day)
            return true
        }
        else {//Add note to existing day
            connectNoteToDay(note: note, day: days[days.count - 1])
            saveContext()
            fetchDays()
            print ("day already exists")
            return false
        }
        
    }

}
