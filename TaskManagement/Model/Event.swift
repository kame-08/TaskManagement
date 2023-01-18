//
//  Event.swift
//  TaskManagement
//
//  Created by Ryo on 2023/01/17.
//

import Foundation
import EventKit

struct Event {
    var event: EKEvent?
    var reminder: EKReminder?
    
    init() {
        self.event = EKEvent()
    }
    
    init(_ event: EKEvent) {
        self.event = event
        self.reminder = nil
    }
    
    init(_ reminder: EKReminder){
        self.reminder = reminder
        self.event = nil
    }
}
