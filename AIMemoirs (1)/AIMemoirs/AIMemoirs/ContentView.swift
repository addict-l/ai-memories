//
//  ContentView.swift
//  AIMemoirs
//
//  Created by 贝贝 on 2025/6/19.
//

import SwiftUI
import CoreData

struct ContentView: View {
    init() {
        // 设置未选中项为浅金色
        UITabBar.appearance().unselectedItemTintColor = UIColor(red: 255/255, green: 215/255, blue: 150/255, alpha: 0.8)
        // 移除白色背景，保持透明
        UITabBar.appearance().backgroundColor = nil
    }
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("首页")
                }
            NewMemoryView()
                .tabItem {
                    Image(systemName: "square.grid.2x2.fill")
                    Text("新的回忆")
                }
            FamilyTreeView()
                .tabItem {
                    Image(systemName: "tree.fill")
                    Text("家族树")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("我的")
                }
        }
        .tint(.blue) // 选中项改回蓝色
    }
}

#Preview {
    ContentView()
}
