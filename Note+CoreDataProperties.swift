//
//  Note+CoreDataProperties.swift
//  pensiveSwift3
//
//  Created by Jack Borthwick on 8/21/17.
//  Copyright © 2017 Jack Borthwick. All rights reserved.
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var date: String?
    @NSManaged public var note: String?
    @NSManaged public var order: Int16
    @NSManaged public var relationshipNotesDay: Day?

}
