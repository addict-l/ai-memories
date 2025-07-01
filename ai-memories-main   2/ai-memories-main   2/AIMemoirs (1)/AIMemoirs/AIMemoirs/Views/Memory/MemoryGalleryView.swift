 import SwiftUI

// MARK: - 回忆画廊视图
struct MemoryGalleryView: View {
    let member: FamilyMember
    @Binding var isShowing: Bool
    @State private var selectedMemoryIndex: Int = 0
    
    // 模拟回忆数据
    private var mockMemories: [MemoryItem] {
        let baseMemories = [
            MemoryItem(
                title: "生日聚会",
                description: "和\(member.name)一起度过的温馨生日时光",
                date: "2024年3月15日",
                images: ["birthday_cake", "family_photo", "gifts"],
                emotion: .happy
            ),
            MemoryItem(
                title: "周末郊游",
                description: "阳光明媚的一天，我们一起去公园散步",
                date: "2024年2月28日",
                images: ["park_walk", "sunshine", "picnic"],
                emotion: .peaceful
            ),
            MemoryItem(
                title: "家庭聚餐",
                description: "全家人围坐在一起享用美食的温暖时刻",
                date: "2024年1月20日",
                images: ["dinner_table", "delicious_food", "family_chat"],
                emotion: .warm
            )
        ]
        return Array(baseMemories.prefix(min(member.memoryCount, baseMemories.count)))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 渐变背景
                LinearGradient(
                    colors: [
                        member.planetColor.opacity(0.1),
                        member.planetColor.opacity(0.05),
                        .white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 顶部成员信息
                    memberInfoHeader
                    
                    // 回忆列表
                    if mockMemories.isEmpty {
                        emptyMemoriesView
                    } else {
                        memoryListView
                    }
                }
            }
            .navigationTitle("回忆画廊")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        isShowing = false
                    }
                    .foregroundColor(member.planetColor)
                }
            }
        }
    }
    
    // MARK: - 子视图组件
    
    // 成员信息头部
    private var memberInfoHeader: some View {
        HStack(spacing: 16) {
            // 成员头像
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .white.opacity(0.4),
                                member.planetColor.opacity(0.9),
                                member.planetColor.opacity(0.7)
                            ],
                            center: UnitPoint(x: 0.3, y: 0.3),
                            startRadius: 5,
                            endRadius: 25
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: member.profileImages.first ?? "person.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(member.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black.opacity(0.8))
                
                Text("共有 \(mockMemories.count) 个珍贵回忆")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    // 空回忆视图
    private var emptyMemoriesView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("还没有回忆")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)
            
            Text("点击添加按钮创建第一个回忆吧")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.8))
            
            Spacer()
        }
    }
    
    // 回忆列表视图
    private var memoryListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(mockMemories.enumerated()), id: \.offset) { index, memory in
                    MemoryCardView(memory: memory, memberColor: member.planetColor)
                        .onTapGesture {
                            selectedMemoryIndex = index
                        }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
}

// MARK: - 回忆卡片视图
struct MemoryCardView: View {
    let memory: MemoryItem
    let memberColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 回忆标题和情感
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(memory.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black.opacity(0.8))
                    
                    Text(memory.date)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // 情感标签
                HStack(spacing: 4) {
                    Image(systemName: memory.emotion.icon)
                        .font(.system(size: 12))
                        .foregroundColor(memory.emotion.color)
                    
                    Text(emotionText(for: memory.emotion))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(memory.emotion.color)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(memory.emotion.color.opacity(0.15))
                )
            }
            
            // 回忆描述
            Text(memory.description)
                .font(.system(size: 14))
                .foregroundColor(.black.opacity(0.7))
                .lineLimit(2)
            
            // 图片预览
            HStack(spacing: 8) {
                ForEach(0..<min(3, memory.images.count), id: \.self) { index in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(memberColor.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: getImageIcon(for: memory.images[index]))
                                .font(.system(size: 20))
                                .foregroundColor(memberColor)
                        )
                }
                
                if memory.images.count > 3 {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Text("+\(memory.images.count - 3)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.gray)
                        )
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - 辅助方法
    
    private func emotionText(for emotion: MemoryEmotion) -> String {
        switch emotion {
        case .happy: return "开心"
        case .peaceful: return "宁静"
        case .warm: return "温暖"
        case .excited: return "兴奋"
        case .nostalgic: return "怀念"
        }
    }
    
    private func getImageIcon(for imageName: String) -> String {
        switch imageName {
        case "birthday_cake": return "birthday.cake"
        case "family_photo": return "photo"
        case "gifts": return "gift"
        case "park_walk": return "figure.walk"
        case "sunshine": return "sun.max"
        case "picnic": return "basket"
        case "dinner_table": return "fork.knife"
        case "delicious_food": return "takeoutbag.and.cup.and.straw"
        case "family_chat": return "bubble.left.and.bubble.right"
        default: return "photo"
        }
    }
}