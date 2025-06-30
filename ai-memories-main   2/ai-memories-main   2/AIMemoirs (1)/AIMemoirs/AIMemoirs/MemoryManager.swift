import SwiftUI
import Foundation

// 回忆事件模型
struct MemoryEvent: Identifiable, Codable {
    let id: UUID
    let personName: String
    let date: Date
    let content: String
    let title: String
    let imageName: String? // 图片名称，可选
    let imageData: Data? // 本地图片数据，可选
    let createdAt: Date
    
    init(personName: String, date: Date, content: String, title: String, imageName: String? = nil, imageData: Data? = nil) {
        self.id = UUID()
        self.personName = personName
        self.date = date
        self.content = content
        self.title = title
        self.imageName = imageName
        self.imageData = imageData
        self.createdAt = Date()
    }
    
    // 复制方法，用于更新
    func copy(imageData: Data?) -> MemoryEvent {
        return MemoryEvent(
            id: self.id,
            personName: self.personName,
            date: self.date,
            content: self.content,
            title: self.title,
            imageName: self.imageName,
            imageData: imageData,
            createdAt: self.createdAt
        )
    }
    
    // 私有初始化方法，用于复制
    private init(id: UUID, personName: String, date: Date, content: String, title: String, imageName: String?, imageData: Data?, createdAt: Date) {
        self.id = id
        self.personName = personName
        self.date = date
        self.content = content
        self.title = title
        self.imageName = imageName
        self.imageData = imageData
        self.createdAt = createdAt
    }
    
    // 自定义编码方法
    enum CodingKeys: String, CodingKey {
        case id, personName, date, content, title, imageName, imageData, createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        personName = try container.decode(String.self, forKey: .personName)
        date = try container.decode(Date.self, forKey: .date)
        content = try container.decode(String.self, forKey: .content)
        title = try container.decode(String.self, forKey: .title)
        imageName = try container.decodeIfPresent(String.self, forKey: .imageName)
        imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(personName, forKey: .personName)
        try container.encode(date, forKey: .date)
        try container.encode(content, forKey: .content)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(imageName, forKey: .imageName)
        try container.encodeIfPresent(imageData, forKey: .imageData)
        try container.encode(createdAt, forKey: .createdAt)
    }
}

// 回忆数据管理类
class MemoryManager: ObservableObject {
    static let shared = MemoryManager()
    
    @Published var memoryEvents: [MemoryEvent] = []
    
    private let userDefaults = UserDefaults.standard
    private let memoryEventsKey = "MemoryEvents"
    private var isLoading = false
    private var isSaving = false
    
    // 添加缓存机制
    private var eventsCache: [String: [MemoryEvent]] = [:]
    private var lastCacheUpdate: Date?
    private let cacheExpirationTime: TimeInterval = 300 // 5分钟
    
    private init() {
        loadMemoryEvents()
    }
    
    // 添加新的回忆事件 - 优化版本
    func addMemoryEvent(_ event: MemoryEvent) {
        memoryEvents.append(event)
        invalidateCache()
        saveMemoryEventsAsync()
    }
    
    // 异步保存，避免阻塞UI
    private func saveMemoryEventsAsync() {
        guard !isSaving else { return }
        isSaving = true
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.saveMemoryEvents()
            DispatchQueue.main.async {
                self?.isSaving = false
            }
        }
    }
    
    // 获取特定人物的回忆事件 - 优化版本
    func getMemoryEvents(for personName: String) -> [MemoryEvent] {
        // 检查缓存
        if let cachedEvents = getCachedEvents(for: personName) {
            return cachedEvents
        }
        
        let events = memoryEvents
            .filter { $0.personName == personName }
            .sorted { $0.date > $1.date }
        
        // 更新缓存
        updateCache(for: personName, events: events)
        return events
    }
    
    // 获取所有回忆事件 - 优化版本
    func getAllMemoryEvents() -> [MemoryEvent] {
        return memoryEvents.sorted { $0.date > $1.date }
    }
    
    // 删除回忆事件
    func deleteMemoryEvent(_ event: MemoryEvent) {
        memoryEvents.removeAll { $0.id == event.id }
        invalidateCache()
        saveMemoryEventsAsync()
    }
    
    // 更新回忆事件
    func updateMemoryEvent(_ event: MemoryEvent) {
        if let index = memoryEvents.firstIndex(where: { $0.id == event.id }) {
            memoryEvents[index] = event
            invalidateCache()
            saveMemoryEventsAsync()
        }
    }
    
    // 缓存管理方法
    private func getCachedEvents(for personName: String) -> [MemoryEvent]? {
        guard let lastUpdate = lastCacheUpdate,
              Date().timeIntervalSince(lastUpdate) < cacheExpirationTime else {
            return nil
        }
        return eventsCache[personName]
    }
    
    private func updateCache(for personName: String, events: [MemoryEvent]) {
        eventsCache[personName] = events
        lastCacheUpdate = Date()
    }
    
    private func invalidateCache() {
        eventsCache.removeAll()
        lastCacheUpdate = nil
    }
    
    // 保存到本地存储 - 优化版本
    private func saveMemoryEvents() {
        do {
            let data = try JSONEncoder().encode(memoryEvents)
            userDefaults.set(data, forKey: memoryEventsKey)
        } catch {
            #if DEBUG
            print("MemoryManager: 保存回忆事件失败: \(error)")
            #endif
        }
    }
    
    // 从本地存储加载
    private func loadMemoryEvents() {
        guard !isLoading else { return }
        isLoading = true
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            guard let data = self.userDefaults.data(forKey: self.memoryEventsKey) else {
                // 如果没有保存的数据，加载示例数据
                DispatchQueue.main.async {
                    self.loadSampleData()
                    self.isLoading = false
                }
                return
            }
            
            do {
                let events = try JSONDecoder().decode([MemoryEvent].self, from: data)
                DispatchQueue.main.async {
                    self.memoryEvents = events
                    self.isLoading = false
                }
            } catch {
                #if DEBUG
                print("MemoryManager: 加载回忆事件失败: \(error)")
                #endif
                // 如果解码失败，也加载示例数据
                DispatchQueue.main.async {
                    self.loadSampleData()
                    self.isLoading = false
                }
            }
        }
    }
    
    // 批量操作方法
    func addMemoryEvents(_ events: [MemoryEvent]) {
        memoryEvents.append(contentsOf: events)
        invalidateCache()
        saveMemoryEventsAsync()
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
                title: "圣诞节的快乐时光",
                imageName: "christmas_tree",
                imageData: nil
            ),
            MemoryEvent(
                personName: "我",
                date: formatter.date(from: "2024-11-15") ?? Date(),
                content: "参加了学校的运动会，在100米跑比赛中获得了第一名，老师和同学们都为我鼓掌。",
                title: "运动会的胜利",
                imageName: "sports_medal",
                imageData: nil
            ),
            MemoryEvent(
                personName: "我",
                date: formatter.date(from: "2024-10-01") ?? Date(),
                content: "国庆节和家人一起去海边玩，看到了美丽的日落，还捡了很多贝壳。",
                title: "海边的美好时光",
                imageName: "cat",
                imageData: nil
            ),
            MemoryEvent(
                personName: "爸爸",
                date: formatter.date(from: "2024-12-20") ?? Date(),
                content: "爸爸教我骑自行车，虽然摔了几次，但最终学会了，很有成就感。",
                title: "学会骑自行车",
                imageName: "bicycle_learning",
                imageData: nil
            ),
            MemoryEvent(
                personName: "妈妈",
                date: formatter.date(from: "2024-11-30") ?? Date(),
                content: "妈妈做的红烧肉特别好吃，今天又做了一次，全家人都赞不绝口。",
                title: "妈妈的红烧肉",
                imageName: "home_cooking",
                imageData: nil
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