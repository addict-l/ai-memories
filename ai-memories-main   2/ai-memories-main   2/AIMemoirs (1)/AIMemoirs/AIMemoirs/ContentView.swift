//
//  ContentView.swift
//  AIMemoirs
//
//  Created by 贝贝 on 2025/6/19.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var isShowingNewMemory = false
    
    init() {
        // 设置未选中项为浅金色
        UITabBar.appearance().unselectedItemTintColor = UIColor(red: 255/255, green: 215/255, blue: 150/255, alpha: 0.8)
        // 完全移除TabBar背景，确保透明
        UITabBar.appearance().backgroundColor = UIColor.clear
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().isTranslucent = true
        // 移除顶部分割线
        UITabBar.appearance().clipsToBounds = true
    }
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("首页")
                }
                .tag(0)
            NewMemoryView(isShowingNewMemory: $isShowingNewMemory)
                .tabItem {
                    Image(systemName: "square.grid.2x2.fill")
                    Text("新的回忆")
                }
                .tag(1)
            FamilyTreeView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "tree.fill")
                    Text("家族树")
                }
                .tag(2)
            ProfileView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("我的")
                }
                .tag(3)
        }
        .tint(.blue) // 选中项改回蓝色
    }
}

#Preview {
    ContentView()
}
