//
//  Page.swift
//  TaskManagement
//
//  Created by Ryo on 2023/01/17.
//

import Foundation
import SwiftUI

enum Page: Int, Hashable, CaseIterable, Identifiable, Codable {
    case calendar
    case reminder
    case timer
    
    var id: Int { rawValue }
    
    var localizedName: LocalizedStringKey {
        switch self {
        case .calendar:
            return "カレンダー"
        case .reminder:
            return "リマインダー"
        case .timer:
            return "タイマー"
        }
    }
    
//    var view: AnyView {
//        switch self {
//        case .calendar:
//            return AnyView(CalendarView())
//        case .reminder:
//            return AnyView(CalendarView())
//        case .timer:
//            return AnyView(CalendarView())
//        }
//    }

}
