//
//  Event.swift
//  Calendar
//
//  Created by Max Reuter on 19/11/15.
//  Copyright © 2015 reuterm. All rights reserved.
//

import Foundation

class Event {
    // MARK: Properties
    var id: String?
    var title: String
    var description: String
    var start: NSDate
    var end: NSDate
    var venue: String
    
    // MARK: Initialisation
    init(id: String?, title: String, description: String, start: NSDate, end: NSDate, venue: String) {
        self.id = id
        self.title = title
        self.description = description
        self.start = start
        self.end = end
        self.venue = venue
    }
}