//
//  Day+CoreDataProperties.swift
//  pensiveSwift3
//
//  Created by Jack Borthwick on 8/21/17.
//  Copyright © 2017 Jack Borthwick. All rights reserved.
//

import Foundation
import CoreData


extension Day {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Day> {
        return NSFetchRequest<Day>(entityName: "Day")
    }

    @NSManaged public var date: String?
    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var weather: String?
    @NSManaged public var relationshipDayNote: NSSet?

}

// MARK: Generated accessors for relationshipDayNote
extension Day {

    @objc(addRelationshipDayNoteObject:)
    @NSManaged public func addToRelationshipDayNote(_ value: Note)

    @objc(removeRelationshipDayNoteObject:)
    @NSManaged public func removeFromRelationshipDayNote(_ value: Note)

    @objc(addRelationshipDayNote:)
    @NSManaged public func addToRelationshipDayNote(_ values: NSSet)

    @objc(removeRelationshipDayNote:)
    @NSManaged public func removeFromRelationshipDayNote(_ values: NSSet)

}
