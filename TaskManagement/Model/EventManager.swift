//
//  EventManager.swift
//  TaskManagement
//
//  Created by Ryo on 2023/01/17.
//

import Foundation
import EventKit

class EventManager: ObservableObject {
    var store = EKEventStore()
    // イベントへの認証ステータスのメッセージ
    @Published var statusMessage = ""
    // 取得されたevents
    @Published var events: [EKEvent]? = nil
    // 取得したいイベントの日付
    @Published var day = Date()
    
    init() {
        Task {
            do {
                // カレンダーへのアクセスを要求する
                try await store.requestAccess(to: .event)
            } catch {
                print(error.localizedDescription)
            }
            // イベントへの認証ステータス
            let status = EKEventStore.authorizationStatus(for: .event)
            
            switch status {
            case .notDetermined:
                statusMessage = "カレンダーへのアクセスする\n権限が選択されていません。"
            case .restricted:
                statusMessage = "カレンダーへのアクセスする\n権限がありません。"
            case .denied:
                statusMessage = "カレンダーへのアクセスが\n明示的に拒否されています。"
            case .authorized:
                statusMessage = "カレンダーへのアクセスが\n許可されています。"
                fetchEvent()
                // カレンダーデータベースの変更を検出したらfetchEvent()を実行する
                NotificationCenter.default.addObserver(self, selector: #selector(fetchEvent), name: .EKEventStoreChanged, object: store)
            @unknown default:
                statusMessage = "@unknown default"
            }
        }
    }
    
    /// イベントの取得
    @objc func fetchEvent() {
        // 開始日コンポーネントの作成
        // 指定した日付の0:00
        let start = Calendar.current.startOfDay(for: day)
        // 終了日コンポーネントの作成
        // 指定した日付の23:59:1
        let end = Calendar.current.date(bySettingHour: 23, minute: 59, second: 1, of: start)
        // イベントストアのインスタンスメソッドから述語を作成
        var predicate: NSPredicate? = nil
        if let end {
            predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        }
        // 述語に一致する全てのイベントを取得
        if let predicate {
            events = store.events(matching: predicate)
        }
    }
    
    /// イベントの追加
    func createEvent(title: String, startDate: Date, endDate: Date, isAllDay: Bool, url: URL?, notes :String?){
        // 新規イベントの作成
        let event = EKEvent(eventStore: store)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.isAllDay = isAllDay
        event.url = url
        event.notes = notes
        // 保存するカレンダー
        // デフォルトカレンダー
        event.calendar = store.defaultCalendarForNewEvents
        do {
            try store.save(event, span: .thisEvent, commit: true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// イベントの変更
    func modifyEvent(event: EKEvent,title: String, startDate: Date, endDate: Date, isAllDay: Bool, url: URL?){
        // 変更したいイベントを取得
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.isAllDay = isAllDay
        event.url = url
        // 保存するカレンダー
        // デフォルトカレンダー
        event.calendar = store.defaultCalendarForNewEvents
        do {
            try store.save(event, span: .thisEvent, commit: true)
        } catch {
            print(error.localizedDescription)
        }
    }

    /// イベントの追加・変更
    func addEvent(event: EKEvent?,title: String, startDate: Date, endDate: Date, isAllDay: Bool, url: URL?, notes :String){
        // イベントを受け取ったら受け取ったイベントを使用して、nilだったら新規イベントを作成
        let eventTemp: EKEvent = event ?? EKEvent(eventStore: store)
        
        // 変更したいイベントを取得
        eventTemp.title = title
        eventTemp.startDate = startDate
        eventTemp.endDate = endDate
        eventTemp.isAllDay = isAllDay
        eventTemp.url = url
        
        if notes.trimmingCharacters(in: .whitespaces) == "" {
            // 空文字orSpaces
            eventTemp.notes = nil
        } else {
            eventTemp.notes = notes
        }
        
        // 保存するカレンダー
        // デフォルトカレンダー
        eventTemp.calendar = store.defaultCalendarForNewEvents
        do {
            try store.save(eventTemp, span: .thisEvent, commit: true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// イベントの削除
    func deleteEvent(event: EKEvent){
        // 削除したいイベントを取得
        do {
            try store.remove(event, span: .thisEvent, commit: true)
        } catch {
            print(error.localizedDescription)
        }
    }
}

