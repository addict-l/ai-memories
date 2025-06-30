import SwiftUI
import PhotosUI

struct TimeLineView: View {
    let selectedPerson: FamilyMember
    @Environment(\.dismiss) private var dismiss
    @StateObject private var memoryManager = MemoryManager.shared
    @State private var selectedEventIndex: Int = 0
    @State private var showingImageDetail = false
    @State private var selectedImage: UIImage? = nil
    
    var sortedEvents: [MemoryEvent] {
        memoryManager.getMemoryEvents(for: selectedPerson.name)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 动态背景渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 245/255, green: 248/255, blue: 255/255),
                        Color(red: 255/255, green: 250/255, blue: 245/255),
                        Color(red: 240/255, green: 255/255, blue: 248/255)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 头部信息卡片
                    HeaderCardView(selectedPerson: selectedPerson, eventsCount: sortedEvents.count)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    
                    if sortedEvents.isEmpty {
                        EmptyStateView(selectedPerson: selectedPerson)
                    } else {
                        // 时间线内容
                        ScrollView {
                            LazyVStack(spacing: 24) {
                                ForEach(Array(sortedEvents.enumerated()), id: \.element.id) { index, event in
                                    EnhancedTimeLineEventView(
                                        event: event,
                                        index: index,
                                        isFirst: index == 0,
                                        isLast: index == sortedEvents.count - 1,
                                        onImageTapped: { image in
                                            selectedImage = image
                                            showingImageDetail = true
                                        }
                                    )
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .leading).combined(with: .opacity),
                                        removal: .move(edge: .trailing).combined(with: .opacity)
                                    ))
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 30)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    ShareButton(events: sortedEvents, personName: selectedPerson.name)
                }
            }
        }
        .sheet(isPresented: $showingImageDetail) {
            if let image = selectedImage {
                ImageDetailView(image: image)
            }
        }
    }
}

// MARK: - 头部卡片视图
struct HeaderCardView: View {
    let selectedPerson: FamilyMember
    let eventsCount: Int
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // 头像和光环效果
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: selectedPerson.gender == .male ?
                                [Color.blue.opacity(0.2), Color.blue.opacity(0.1)] :
                                [Color.pink.opacity(0.2), Color.pink.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .shadow(color: .blue.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: selectedPerson.gender == .male ? "person.circle.fill" : "person.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(
                            LinearGradient(
                                colors: selectedPerson.gender == .male ?
                                [Color.blue, Color.blue.opacity(0.7)] :
                                [Color.pink, Color.pink.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(selectedPerson.name)的回忆时光")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.primary, Color.primary.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.red.opacity(0.7))
                        
                        Text("共收录 \(eventsCount) 段美好回忆")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if eventsCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                                .foregroundColor(.blue.opacity(0.7))
                            
                            Text("时光荏苒，记忆永恒")
                                .font(.caption)
                                .foregroundColor(.secondary.opacity(0.8))
                                .italic()
                        }
                    }
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 5)
        )
    }
}

// MARK: - 空状态视图
struct EmptyStateView: View {
    let selectedPerson: FamilyMember
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // 动画图标
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "clock.badge.questionmark")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 12) {
                Text("暂无回忆记录")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("开始记录\(selectedPerson.name)的美好时光吧\n每一个瞬间都值得被珍藏")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - 增强的时间线事件视图
struct EnhancedTimeLineEventView: View {
    let event: MemoryEvent
    let index: Int
    let isFirst: Bool
    let isLast: Bool
    let onImageTapped: (UIImage) -> Void
    
    @StateObject private var memoryManager = MemoryManager.shared
    @State private var currentImageIndex = 0
    @State private var isExpanded = false
    
    // 收集所有可用的图片
    private var availableImages: [ImageSource] {
        var images: [ImageSource] = []
        
        // 添加本地图片
        if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
            images.append(.localImage(uiImage))
        }
        
        // 添加系统图标
        if let imageName = event.imageName, !imageName.isEmpty {
            images.append(.systemIcon(imageName))
        }
        
        return images.isEmpty ? [.systemIcon("photo")] : images
    }
    
    enum ImageSource {
        case localImage(UIImage)
        case systemIcon(String)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            // 时间轴线条和节点
            TimeLineConnector(isFirst: isFirst, isLast: isLast, index: index)
            
            // 事件内容卡片
            VStack(spacing: 0) {
                EventContentCard(
                    event: event,
                    availableImages: availableImages,
                    currentImageIndex: $currentImageIndex,
                    isExpanded: $isExpanded,
                    onImageTapped: onImageTapped
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 时间轴连接器
struct TimeLineConnector: View {
    let isFirst: Bool
    let isLast: Bool
    let index: Int
    
    private var nodeColor: Color {
        switch index % 4 {
        case 0: return .blue
        case 1: return .purple
        case 2: return .green
        default: return .orange
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if !isFirst {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [nodeColor.opacity(0.3), nodeColor.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 3, height: 40)
            }
            
            ZStack {
                Circle()
                    .fill(nodeColor.opacity(0.2))
                    .frame(width: 20, height: 20)
                
                Circle()
                    .fill(nodeColor)
                    .frame(width: 12, height: 12)
                    .shadow(color: nodeColor.opacity(0.4), radius: 4, x: 0, y: 2)
            }
            
            if !isLast {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [nodeColor.opacity(0.1), nodeColor.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 3, height: 40)
            }
        }
        .frame(width: 20)
    }
}

// MARK: - 事件内容卡片
struct EventContentCard: View {
    let event: MemoryEvent
    let availableImages: [EnhancedTimeLineEventView.ImageSource]
    @Binding var currentImageIndex: Int
    @Binding var isExpanded: Bool
    let onImageTapped: (UIImage) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 日期标签
            EventDateLabel(date: event.date)
            
            // 标题
            EventTitle(title: event.title)
            
            // 图片轮播区域
            if !availableImages.isEmpty {
                ImageCarouselView(
                    images: availableImages,
                    currentIndex: $currentImageIndex,
                    onImageTapped: onImageTapped
                )
            }
            
            // 内容描述
            EventContentView(content: event.content, isExpanded: $isExpanded)
            
            // 底部装饰
            EventFooter()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - 图片轮播视图
struct ImageCarouselView: View {
    let images: [EnhancedTimeLineEventView.ImageSource]
    @Binding var currentIndex: Int
    let onImageTapped: (UIImage) -> Void
    
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 12) {
            // 轮播图主体
            TabView(selection: $currentIndex) {
                ForEach(Array(images.enumerated()), id: \.offset) { index, imageSource in
                    CarouselImageView(imageSource: imageSource, onTapped: onImageTapped)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 200)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            // 自定义页面指示器
            if images.count > 1 {
                HStack(spacing: 8) {
                    ForEach(0..<images.count, id: \.self) { index in
                        Circle()
                            .fill(currentIndex == index ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentIndex == index ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3), value: currentIndex)
                    }
                }
            }
        }
    }
}

// MARK: - 轮播图片视图
struct CarouselImageView: View {
    let imageSource: EnhancedTimeLineEventView.ImageSource
    let onTapped: (UIImage) -> Void
    
    var body: some View {
        Button(action: {
            if case .localImage(let image) = imageSource {
                onTapped(image)
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                switch imageSource {
                case .localImage(let image):
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                colors: [Color.clear, Color.black.opacity(0.2)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                case .systemIcon(let iconName):
                    VStack(spacing: 12) {
                        Image(systemName: getSystemIconName(iconName))
                            .font(.system(size: 40))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text(getImageDisplayName(iconName))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 其他组件视图
struct EventDateLabel: View {
    let date: Date
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "calendar")
                .font(.system(size: 12))
                .foregroundColor(.blue.opacity(0.7))
            
            Text(date, style: .date)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.blue.opacity(0.8))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.blue.opacity(0.1))
        )
    }
}

struct EventTitle: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.primary, Color.primary.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .lineLimit(2)
    }
}

struct EventContentView: View {
    let content: String
    @Binding var isExpanded: Bool
    
    private var displayContent: String {
        if isExpanded || content.count <= 100 {
            return content
        } else {
            return String(content.prefix(100)) + "..."
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(displayContent)
                .font(.body)
                .foregroundColor(.primary.opacity(0.8))
                .lineSpacing(2)
                .multilineTextAlignment(.leading)
            
            if content.count > 100 {
                Button(action: { isExpanded.toggle() }) {
                    HStack(spacing: 4) {
                        Text(isExpanded ? "收起" : "展开")
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

struct EventFooter: View {
    var body: some View {
        HStack {
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.red.opacity(0.6))
                Text("珍贵回忆")
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.7))
            }
        }
    }
}

// MARK: - 工具栏按钮
struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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

struct ShareButton: View {
    let events: [MemoryEvent]
    let personName: String
    
    var body: some View {
        Button(action: {
            // 分享功能
        }) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
        }
    }
}

// MARK: - 图片详情视图
struct ImageDetailView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = value
                            }
                            .onEnded { _ in
                                withAnimation(.spring()) {
                                    if scale < 1 {
                                        scale = 1
                                        offset = .zero
                                    } else if scale > 3 {
                                        scale = 3
                                    }
                                }
                            }
                            .simultaneously(with:
                                DragGesture()
                                    .onChanged { value in
                                        offset = value.translation
                                    }
                                    .onEnded { _ in
                                        withAnimation(.spring()) {
                                            offset = .zero
                                        }
                                    }
                            )
                    )
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - 工具函数
func getSystemIconName(_ imageName: String) -> String {
    switch imageName {
    case "christmas_tree": return "tree.fill"
    case "sports_medal": return "medal.fill"
    case "beach_sunset": return "sun.max.fill"
    case "bicycle_learning": return "bicycle"
    case "home_cooking": return "fork.knife"
    case "birthday": return "gift.fill"
    case "book": return "book.fill"
    case "home": return "house.fill"
    case "friends": return "person.2.fill"
    case "travel": return "airplane"
    case "sports": return "sportscourt.fill"
    case "music": return "music.note"
    case "art": return "paintbrush.fill"
    case "food": return "fork.knife"
    case "happy": return "face.smiling"
    case "growth": return "arrow.up.circle.fill"
    case "calm": return "leaf.fill"
    case "memory": return "heart.fill"
    default: return "photo"
    }
}

func getImageDisplayName(_ imageName: String) -> String {
    switch imageName {
    case "christmas_tree": return "圣诞树"
    case "sports_medal": return "运动奖牌"
    case "beach_sunset": return "海边日落"
    case "bicycle_learning": return "学自行车"
    case "home_cooking": return "家常菜"
    case "birthday": return "生日庆祝"
    case "book": return "学习时光"
    case "home": return "温馨家庭"
    case "friends": return "友谊岁月"
    case "travel": return "旅行回忆"
    case "sports": return "运动时刻"
    case "music": return "音乐时光"
    case "art": return "艺术创作"
    case "food": return "美食回忆"
    case "happy": return "快乐时光"
    case "growth": return "成长历程"
    case "calm": return "平静时刻"
    case "memory": return "珍贵回忆"
    default: return "美好时光"
    }
}

#Preview {
    TimeLineView(selectedPerson: FamilyMember(name: "我", gender: .male, generation: 2, position: 0, parentIds: [], childrenIds: [], profileImages: ["person.crop.circle.fill", "gamecontroller.fill", "laptopcomputer"], memoryCount: 0, birthYear: 1995, description: "年轻一代，热爱科技和游戏", loveLevel: 4, specialTrait: "科技达人", planetColor: Color.green))
} 