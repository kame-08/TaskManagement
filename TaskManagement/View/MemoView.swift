//
//  MemoView.swift
//  TaskManagement
//
//  Created by Ryo on 2023/01/17.
//

import SwiftUI

struct MemoView: View {
    @State var selection = 1
    @State var text = ""
    var body: some View {
        TabView(selection: $selection) {
            TextEditor(text: $text)
                .tag(1)
            //TODO: - ここをマークダウンに変える
            Text(text)
                .tag(2)
        }
        .tabViewStyle(.page)
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .interactive))
    }
        
}

struct MemoView_Previews: PreviewProvider {
    static var previews: some View {
        MemoView()
    }
}
