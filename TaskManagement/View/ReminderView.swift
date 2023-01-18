//
//  ReminderView.swift
//  TaskManagement
//
//  Created by Ryo on 2023/01/17.
//

import SwiftUI
import EventKit

struct ReminderView: View {
    @EnvironmentObject var reminderManager: ReminderManager
    // sheetのフラグ
    @State var isShowCreateReminderView = false
    // 変更したいリマインダー(追加の場合はnil)
    @State var reminder: EKReminder?
    
    var body: some View {
        if let aReminder = reminderManager.reminders {
            NavigationStack {
                List(aReminder, id: \.calendarItemIdentifier) { reminder in
                    HStack {
                        Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(reminder.isCompleted ? Color.accentColor : Color.gray)
                        Button(reminder.title) {
                            // 変更したいイベントをCreateEventViewに送る
                            self.reminder = reminder
                            isShowCreateReminderView = true
                        }
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            reminderManager.deleteEvent(event: reminder)
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    }
                }
                .sheet(isPresented: $isShowCreateReminderView) {
//                    CreateReminderView(reminder: $reminder)
//                        .presentationDetents([.medium])
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        DatePicker("", selection: $reminderManager.day, displayedComponents: .date)
                            .labelsHidden()
                            .onChange(of: reminderManager.day) { newValue in
                                reminderManager.fetchReminder()
                            }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            // 追加したい場合は、CreateReminderViewにイベントを送らない(nilを送る)
                            reminder = nil
                            isShowCreateReminderView = true
                        } label: {
                            Label("追加", systemImage: "plus")
                        }
                    }
                }
            }
        } else {
            Text(reminderManager.statusMessage)
        }
    }
}

struct ReminderView_Previews: PreviewProvider {
    static var previews: some View {
        ReminderView()
    }
}
