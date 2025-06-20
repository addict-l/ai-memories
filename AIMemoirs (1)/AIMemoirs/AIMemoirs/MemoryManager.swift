import SwiftUI
import Foundation

// 回忆事件模型
struct MemoryEvent: Identifiable, Codable {
    let id = UUID()
    let personName: String
    let date: Date
    let content: String
    let title: String
    let createdAt: Date
    
    init(personName: String, date: Date, content: String, title: String) {
        self.personName = personName
        self.date = date
        self.content = content
        self.title = title
        self.createdAt = Date()
    }
}

// 回忆数据管理类
class MemoryManager: ObservableObject {
    static let shared = MemoryManager()
    
    @Published var memoryEvents: [MemoryEvent] = []
    
    private let userDefaults = UserDefaults.standard
    private let memoryEventsKey = "MemoryEvents"
    
    private init() {
        loadMemoryEvents()
    }
    
    // 添加新的回忆事件
    func addMemoryEvent(_ event: MemoryEvent) {
        memoryEvents.append(event)
        saveMemoryEvents()
    }
    
    // 获取特定人物的回忆事件
    func getMemoryEvents(for personName: String) -> [MemoryEvent] {
        return memoryEvents
            .filter { $0.personName == personName }
            .sorted { $0.date > $1.date } // 越近的时间在越上面
    }
    
    // 获取所有回忆事件
    func getAllMemoryEvents() -> [MemoryEvent] {
        return memoryEvents.sorted { $0.date > $1.date }
    }
    
    // 删除回忆事件
    func deleteMemoryEvent(_ event: MemoryEvent) {
        memoryEvents.removeAll { $0.id == event.id }
        saveMemoryEvents()
    }
    
    // 更新回忆事件
    func updateMemoryEvent(_ event: MemoryEvent) {
        if let index = memoryEvents.firstIndex(where: { $0.id == event.id }) {
            memoryEvents[index] = event
            saveMemoryEvents()
        }
    }
    
    // 保存到本地存储
    private func saveMemoryEvents() {
        do {
            let data = try JSONEncoder().encode(memoryEvents)
            userDefaults.set(data, forKey: memoryEventsKey)
        } catch {
            print("保存回忆事件失败: \(error)")
        }
    }
    
    // 从本地存储加载
    private func loadMemoryEvents() {
        guard let data = userDefaults.data(forKey: memoryEventsKey) else {
            // 如果没有保存的数据，加载示例数据
            loadSampleData()
            return
        }
        
        do {
            memoryEvents = try JSONDecoder().decode([MemoryEvent].self, from: data)
        } catch {
            print("加载回忆事件失败: \(error)")
            loadSampleData()
        }
    }
    
    // 加载示例数据
    private func loadSampleData() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        memoryEvents = [
            MemoryEvent(
                personName: "我",
                date: formatter.date(from: "2024-12-25") ?? Date(),
                content: "今天是圣诞节，和家人一起装饰圣诞树，收到了很多礼物，特别开心。",
                title: "圣诞节的快乐时光"
            ),
            MemoryEvent(
                personName: "我",
                date: formatter.date(from: "2024-11-15") ?? Date(),
                content: "参加了学校的运动会，在100米跑比赛中获得了第一名，老师和同学们都为我鼓掌。",
                title: "运动会的胜利"
            ),
            MemoryEvent(
                personName: "我",
                date: formatter.date(from: "2024-10-01") ?? Date(),
                content: "国庆节和家人一起去海边玩，看到了美丽的日落，还捡了很多贝壳。",
                title: "海边的美好时光"
            ),
            MemoryEvent(
                personName: "爸爸",
                date: formatter.date(from: "2024-12-20") ?? Date(),
                content: "爸爸教我骑自行车，虽然摔了几次，但最终学会了，很有成就感。",
                title: "学会骑自行车"
            ),
            MemoryEvent(
                personName: "妈妈",
                date: formatter.date(from: "2024-11-30") ?? Date(),
                content: "妈妈做的红烧肉特别好吃，今天又做了一次，全家人都赞不绝口。",
                title: "妈妈的红烧肉"
            )
        ]
        
        saveMemoryEvents()
    }
    
    // 清空所有数据（用于测试）
    func clearAllData() {
        memoryEvents.removeAll()
        userDefaults.removeObject(forKey: memoryEventsKey)
    }
} 