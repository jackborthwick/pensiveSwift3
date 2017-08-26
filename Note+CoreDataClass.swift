//
//  Note+CoreDataClass.swift
//  pensiveSwift3
//
//  Created by Jack Borthwick on 8/21/17.
//  Copyright © 2017 Jack Borthwick. All rights reserved.
//

import Foundation
import CoreData

@objc(Note)
public class Note: NSManagedObject {
    let formatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
}
