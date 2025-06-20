import SwiftUI

struct TimeLineView: View {
    let selectedPerson: FamilyMember
    @Environment(\.dismiss) private var dismiss
    @StateObject private var memoryManager = MemoryManager.shared
    
    var sortedEvents: [MemoryEvent] {
        memoryManager.getMemoryEvents(for: selectedPerson.name)
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
                                
                                Text("共\(memoryManager.getMemoryEvents(for: selectedPerson.name).count)个回忆")
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
            // 数据现在由MemoryManager管理，不需要在这里加载
        }
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