//
//  CalendarView.swift
//  TaskManagement
//
//  Created by Ryo on 2023/01/17.
//

import SwiftUI
import EventKit

struct CalendarView: View {
    @EnvironmentObject var eventManager: EventManager
    @Binding var date: Date
    // sheetのフラグ
    @State var isShowCreateEventView = false
    // 変更するイベント(nilの場合は新規追加)
    @State var event: EKEvent?
    @State var newEvent: Event?
    
    var body: some View {
        if let aEvent = eventManager.events {
            NavigationStack {
                List(aEvent, id: \.eventIdentifier) { event in
                    Button {
                        // 変更の場合は、CreateEventViewに変更したいイベントを送る
                        self.event = event
                        isShowCreateEventView = true
                    } label: {
//                        EventView(event: event)
                        Text(event.title)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button() {
                            // 変更の場合は、CreateEventViewに変更したいイベントを送る
                            self.event = event
                            isShowCreateEventView = true
                        } label: {
                            Label("編集", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            eventManager.deleteEvent(event: event)
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    }
                    // リストの区切り線を隠す
                    .listRowSeparator(.hidden)
                }
//                .listStyle(.plain)
                .onChange(of: date, perform: { newValue in
                    eventManager.day = date
                })
                .sheet(isPresented: $isShowCreateEventView) {
                    CreateEventView(event: $event, newEvent: $newEvent)
                        .presentationDetents([.medium])
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        DatePicker("", selection: $eventManager.day, displayedComponents: .date)
                            .labelsHidden()
                            .onChange(of: eventManager.day) { newValue in
                                eventManager.fetchEvent()
                            }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            // 追加の場合は、CreateEventViewにnilを送る
                            event = nil
                            isShowCreateEventView = true
                        } label: {
                            Label("追加", systemImage: "plus")
                        }
                    }
                }
            }
        } else {
            Text(eventManager.statusMessage)
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(date: .constant(Date()))
    }
}
