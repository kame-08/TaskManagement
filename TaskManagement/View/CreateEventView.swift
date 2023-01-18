//
//  CreatEventView.swift
//  TaskManagement
//
//  Created by Ryo on 2023/01/17.
//

import SwiftUI
import EventKit

struct CreateEventView: View {
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var reminderManager: ReminderManager
    // ContentViewのsheetのフラグ
    @Environment(\.dismiss) var dismiss
    // 変更したいイベント(nilの場合は新規追加)
    @Binding var event: EKEvent?
    @Binding var newEvent: Event?
    
    // eventのタイトル
    @State var title = ""
    // eventの開始日時
    @State var start = Date()
    // eventの終了日時
    @State var end = Date()
    // eventの終日のフラグ
    @State var allDay = false
    // eventのURL
    @State var URLText = ""
    // eventのメモ
    @State var note = ""
    
    @State var num = 0
    @State var type = eventType.event
    enum eventType {
        case event
        case reminder
    }
    
    
    var body: some View {
        NavigationStack{
            VStack {
                Picker("Flavor", selection: $type) {
                    Label("イベント", systemImage: "calendar")
                        .labelStyle(.titleAndIcon)
                        .tag(eventType.event)
                    Label("リマインダー", systemImage: "checkmark")
                        .labelStyle(.titleAndIcon)
                        .tag(eventType.reminder)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                List {

                    TextField("タイトル", text: $title, axis: .vertical)
                    .onChange(of: title) { newValue in
                        num = title.split(whereSeparator: \.isNewline).count
                    }
                    Toggle("終日", isOn: $allDay)
                    DatePicker("開始", selection: $start, displayedComponents: allDay ? [.date] : [.date, .hourAndMinute])
                    if type == .event {
                        //in: start...はstartより前を選択できないようにするため
                        DatePicker("終了", selection: $end, in: start..., displayedComponents: allDay ? [.date] : [.date, .hourAndMinute])
                            .onChange(of: start) { newValue in
                                // in: start...では、すでに代入済みの値は変更しないため
                                if start > end {
                                    end = start
                                }
                            }
                        TextField("ノート", text: $note, axis: .vertical)
                            .lineLimit(10)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル", role: .destructive) {
                        // sheetを閉じる
                        dismiss()
                    }
                    .buttonStyle(.borderless)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        if type == .event {
                            eventManager.addEvent(event: event, title: title, startDate: start, endDate: end, isAllDay: allDay, url: nil, notes: note)
                            
                        } else {
                            reminderManager.createReminder(title: title, dueDate: start)
                        }
                        // sheetを閉じる
                        dismiss()
                    }
                    .disabled(num == 0 ? true : false)
                }
            }
            .navigationBarTitle("\(num)個の" + String(type == eventType.event ? "イベント" : "リマインダー"), displayMode: .inline)
        }
        .task {
            if let event {
                // eventが渡されたら既存の値をセットする(変更の場合)
                self.title = event.title
                self.start = event.startDate
                self.end = event.endDate
                self.allDay = event.isAllDay
                if let url = event.url {
                    self.URLText = url.absoluteString
                }
                if let notes = event.notes {
                    self.note = notes
                }
            }
        }
    }
}

struct CreatEventeView_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventView(event: .constant(EKEvent()), newEvent: .constant(Event()))
    }
}
