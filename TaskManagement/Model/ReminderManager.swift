//
//  ReminderManager.swift
//  TaskManagement
//
//  Created by Ryo on 2023/01/17.
//

import Foundation
import EventKit

class ReminderManager: ObservableObject {
    var store = EKEventStore()
    // リマインダーへの認証ステータスのメッセージ
    @Published var statusMessage = ""
    // 取得されたリマインダー
    @Published var reminders: [EKReminder]? = nil
    // 取得したいリマインダーの日付
    @Published var day = Date()
    
    init() {
        Task {
            do {
                // リマインダーへのアクセスを要求
                try await store.requestAccess(to: .reminder)
            } catch {
                print(error.localizedDescription)
            }
            // リマインダーへの認証ステータス
            let status = EKEventStore.authorizationStatus(for: .reminder)
            
            switch status {
            case .notDetermined:
                statusMessage = "リマインダーへのアクセスする\n権限が選択されていません。"
            case .restricted:
                statusMessage = "リマインダーへのアクセスする\n権限がありません。"
            case .denied:
                statusMessage = "リマインダーへのアクセスが\n明示的に拒否されています。"
            case .authorized:
                statusMessage = "リマインダーへのアクセスが\n許可されています。"
                fetchReminder()
                // カレンダーデータベースの変更を検出したらfetchReminder()を実行する
                NotificationCenter.default.addObserver(self, selector: #selector(fetchReminder), name: .EKEventStoreChanged, object: store)
            @unknown default:
                statusMessage = "@unknown default"
            }
        }
    }
    
    /// リマインダーの取得
    @objc func fetchReminder() {
        // 開始日コンポーネントの作成
        // 指定した前の日付の23:59:59
        let start = Calendar.current.date(byAdding: .second, value: -1, to: Calendar.current.startOfDay(for: day))
        // 終了日コンポーネントの作成
        // 指定した日付の23:59:0
        let end = Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: Calendar.current.startOfDay(for: day))
        // イベントストアのインスタンスメソッドから述語を作成
        var predicate: NSPredicate? = nil
        predicate = store.predicateForIncompleteReminders(withDueDateStarting: start, ending: end, calendars: nil)
        // 述語に一致する全てのリマインダーを取得
        if let predicate {
            store.fetchReminders(matching: predicate) { reminder in
                self.reminders = reminder
            }
        }
    }
    
    /// リマインダーの追加
    func createReminder(title: String, dueDate: Date){
        // 新規リマインダーの作成
        let reminder = EKReminder(eventStore: store)
        reminder.title = title
        reminder.dueDateComponents = Calendar.current.dateComponents([.calendar, .year, .month, .day, .hour, .minute], from: dueDate)
        // 保存するリマインダー
        // デフォルトリマインダー
        reminder.calendar = store.defaultCalendarForNewReminders()
        do {
            try store.save(reminder, commit: true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// リマインダーの変更
    func modifyEvent(reminder: EKReminder,title: String, dueDate: Date){
        // 削除したいリマインダーを取得
        reminder.title = title
        reminder.dueDateComponents = Calendar.current.dateComponents([.calendar, .year, .month, .day, .hour, .minute], from: dueDate)
        // 保存するリマインダー
        // デフォルトリマインダー
        reminder.calendar = store.defaultCalendarForNewReminders()
        do {
            try store.save(reminder, commit: true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// リマインダーの削除
    func deleteEvent(event: EKReminder){
        // 削除したいイベントを取得
        do {
            try store.remove(event,commit: true)
        } catch {
            print(error.localizedDescription)
        }
    }
}
