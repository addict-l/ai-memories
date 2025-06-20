import SwiftUI

// 回忆事件模型
struct MemoryEvent: Identifiable {
    let id = UUID()
    let personName: String
    let date: Date
    let content: String
    let title: String
}

struct TimeLineView: View {
    let selectedPerson: FamilyMember
    @Environment(\.dismiss) private var dismiss
    
    // 示例数据 - 实际应用中应该从数据存储中获取
    @State private var memoryEvents: [MemoryEvent] = []
    
    var sortedEvents: [MemoryEvent] {
        memoryEvents.sorted { $0.date > $1.date } // 越近的时间在越上面
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 248/255, green: 250/255, blue: 252/255),
                        Color(red: 241/255, green: 245/255, blue: 249/255)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 头部信息
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: selectedPerson.gender == .male ? "person.circle.fill" : "person.circle")
                                .resizable()
                                .frame(width: 48, height: 48)
                                .foregroundColor(selectedPerson.gender == .male ? .blue.opacity(0.7) : .pink.opacity(0.7))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(selectedPerson.name)的回忆录")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                
                                Text("共\(memoryEvents.count)个回忆")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    .padding(.bottom, 20)
                    .background(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    
                    // 时间轴内容
                    if sortedEvents.isEmpty {
                        VStack(spacing: 20) {
                            Spacer()
                            Image(systemName: "clock.badge.questionmark")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text("还没有回忆记录")
                                .font(.title3)
                                .foregroundColor(.gray)
                            
                            Text("开始记录\(selectedPerson.name)的美好时光吧")
                                .font(.subheadline)
                                .foregroundColor(.gray.opacity(0.8))
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        .padding(.horizontal, 40)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(Array(sortedEvents.enumerated()), id: \.element.id) { index, event in
                                    TimeLineEventView(event: event, isFirst: index == 0, isLast: index == sortedEvents.count - 1)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 20)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                            Text("返回")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
        }
        .onAppear {
            loadMemoryEvents()
        }
    }
    
    // 加载回忆事件数据
    private func loadMemoryEvents() {
        // 模拟数据 - 实际应用中应该从Core Data或其他数据源获取
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        memoryEvents = [
            MemoryEvent(
                personName: selectedPerson.name,
                date: formatter.date(from: "2024-12-25") ?? Date(),
                content: "今天是圣诞节，和家人一起装饰圣诞树，收到了很多礼物，特别开心。",
                title: "圣诞节的快乐时光"
            ),
            MemoryEvent(
                personName: selectedPerson.name,
                date: formatter.date(from: "2024-11-15") ?? Date(),
                content: "参加了学校的运动会，在100米跑比赛中获得了第一名，老师和同学们都为我鼓掌。",
                title: "运动会的胜利"
            ),
            MemoryEvent(
                personName: selectedPerson.name,
                date: formatter.date(from: "2024-10-01") ?? Date(),
                content: "国庆节和家人一起去海边玩，看到了美丽的日落，还捡了很多贝壳。",
                title: "海边的美好时光"
            )
        ]
    }
}

// 时间轴事件视图
struct TimeLineEventView: View {
    let event: MemoryEvent
    let isFirst: Bool
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // 时间轴线条和圆点
            VStack(spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2, height: 30)
                }
                
                Circle()
                    .fill(Color.blue)
                    .frame(width: 12, height: 12)
                    .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                
                if !isLast {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2, height: 30)
                }
            }
            .frame(width: 12)
            
            // 事件内容卡片
            VStack(alignment: .leading, spacing: 12) {
                // 日期
                Text(event.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                // 标题
                Text(event.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                // 内容
                Text(event.content)
                    .font(.body)
                    .foregroundColor(.black.opacity(0.8))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                // 底部装饰
                HStack {
                    Spacer()
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.red.opacity(0.6))
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    TimeLineView(selectedPerson: FamilyMember(name: "我", gender: .male, generation: 2, parentIds: [], childrenIds: []))
} 