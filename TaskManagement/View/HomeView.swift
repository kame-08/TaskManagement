//
//  HomeView.swift
//  TaskManagement
//
//  Created by Ryo on 2023/01/17.
//

import SwiftUI

struct HomeView: View {
    var pages = Page.allCases
    @State var selectedPage: Category?
    @State var date = Date()
    
    var body: some View {
        NavigationSplitView {
            List {
                Button {
                    date = Date()
                } label: {
                    //                    Text("\(Date())")
                    Text("2023年2月1日")
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .buttonStyle(.plain)
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                //                ForEach(pages) { page in
                //                    //                    Text(page.localizedName)
                //                    NavigationLink {
                //                        page.view
                //                    } label: {
                //                        Text(page.localizedName)
                //                    }
                //                }
                NavigationLink {
                    CalendarView(date: $date)
                        .environmentObject(EventManager())
                        .environmentObject(ReminderManager())
                } label: {
                    Label("カレンダー", systemImage: "calendar")
                }
                NavigationLink {
                    ReminderView()
                        .environmentObject(ReminderManager())
                        .environmentObject(EventManager())
                } label: {
                    Label("リマインダー", systemImage: "checkmark.circle")
                }
                NavigationLink {
                    ClockView()
                } label: {
                    Label("時計", systemImage: "clock")
                }
                NavigationLink {
                    SettingsView()
                } label: {
                    Label("設定とサポート", systemImage: "gearshape")
                }
            }
        } detail: {
            
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
