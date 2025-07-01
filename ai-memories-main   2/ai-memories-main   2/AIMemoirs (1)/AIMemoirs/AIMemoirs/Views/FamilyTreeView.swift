import SwiftUI

// MARK: - 主视图：星空家族树
struct FamilyTreeView: View {
    let familyGraph: FamilyGraph
    @State private var selectedMember: FamilyMember?
    @State private var animationPhase: Double = 0
    @State private var orbitSpeed: Double = 1.0
    @State private var showOrbitPaths: Bool = true
    @State private var showMemberProfile: Bool = false // 控制资料卡显示
    @StateObject private var shootingStarManager = ShootingStarManager()
    @State private var isPaused: Bool = false // 控制动画暂停
    
    // 根据图片精确配置轨道 - 适配屏幕尺寸
    private let orbitRadii: [CGFloat] = [70, 110, 150]
    private let orbitColors: [Color] = [
        Color.green.opacity(0.7),  // 内轨道 - 第2代 (我、妹妹)
        Color.blue.opacity(0.7),   // 中轨道 - 第1代 (爸爸妈妈)
        Color.purple.opacity(0.7)  // 外轨道 - 第0代 (爷爷奶奶)
    ]
    
    init() {
        let graph = FamilyGraph()
        
        // 100%匹配图片中的家族成员、轨道、颜色、图标和回忆数
        let members = [
            // 外轨道 - 第0代
            FamilyMember(name: "爸爸", gender: .male, generation: 0, position: 0,
                         parentIds: [], childrenIds: [], profileImages: ["car.fill"],
                         memoryCount: 18, birthYear: 1962, description: "勤劳的父亲",
                         loveLevel: 4, specialTrait: "勤劳父亲", planetColor: Color.blue),
            FamilyMember(name: "姑姑", gender: .female, generation: 0, position: 1,
                         parentIds: [], childrenIds: [], profileImages: ["wand.and.stars.inverse"],
                         memoryCount: 15, birthYear: 1968, description: "时尚的姑姑",
                         loveLevel: 4, specialTrait: "时尚达人", planetColor: Color.pink),
            FamilyMember(name: "奶奶", gender: .female, generation: 0, position: 2,
                         parentIds: [], childrenIds: [], profileImages: ["circle.grid.2x1.fill"], // Placeholder
                         memoryCount: 30, birthYear: 1938, description: "慈祥的祖母",
                         loveLevel: 5, specialTrait: "慈祥祖母", planetColor: Color.pink),

            // 中轨道 - 第1代
            FamilyMember(name: "爷爷", gender: .male, generation: 1, position: 0,
                         parentIds: [], childrenIds: [], profileImages: ["bicycle"],
                         memoryCount: 10, birthYear: 1935, description: "智慧的家族长者",
                         loveLevel: 5, specialTrait: "家族长者", planetColor: Color.green),
            FamilyMember(name: "我", gender: .male, generation: 1, position: 1,
                         parentIds: [], childrenIds: [], profileImages: ["gamecontroller.fill"],
                         memoryCount: 8, birthYear: 1995, description: "年轻的自己",
                         loveLevel: 4, specialTrait: "年轻自己", planetColor: Color.green),
            FamilyMember(name: "表姐", gender: .female, generation: 1, position: 2,
                         parentIds: [], childrenIds: [], profileImages: ["leaf.fill"],
                         memoryCount: 5, birthYear: 1993, description: "亲密的表姐",
                         loveLevel: 4, specialTrait: "亲密伙伴", planetColor: Color.green),

            // 内轨道 - 第2代
            FamilyMember(name: "妹妹", gender: .female, generation: 2, position: 0,
                         parentIds: [], childrenIds: [], profileImages: ["leaf.fill"],
                         memoryCount: 22, birthYear: 1998, description: "可爱的妹妹",
                         loveLevel: 4, specialTrait: "可爱妹妹", planetColor: Color.cyan),
            FamilyMember(name: "妈妈", gender: .female, generation: 2, position: 1,
                         parentIds: [], childrenIds: [], profileImages: ["house.fill"],
                         memoryCount: 12, birthYear: 1965, description: "温暖的母亲",
                         loveLevel: 5, specialTrait: "温暖母亲", planetColor: Color.cyan)
        ]
        
        members.forEach { graph.addMember($0) }
        self.familyGraph = graph
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 渐变夜空背景
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.7), Color.black]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                // 流星动画 - 使用详细样式
                ShootingStarView(
                    x: shootingStarManager.shootingStarX, 
                    y: shootingStarManager.shootingStarY,
                    style: .detailed
                )
                .opacity(0.6)
                
                VStack(spacing: 0) {
                    // 顶部标题区域
                    topTitleSection
                        .frame(height: 120)
                    
                    // 中间家族成员区域
                    familyMembersView(geometry: geometry)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // 底部控制区域
                    bottomControlSection
                        .frame(height: 120)
                }
                
                // 轨道路径
                if showOrbitPaths {
                    orbitPathsView(geometry: geometry)
                }
                
                // 中心家图标 - 放置在最上层以确保居中
                centerHomeIcon(center: calculateCenter(geometry: geometry))
                
                // 成员资料卡覆盖层
                .overlay(
                    Group {
                        if showMemberProfile, let member = selectedMember {
                            MemberProfileCard(member: member, isShowing: $showMemberProfile)
                                .transition(.opacity.combined(with: .scale(scale: 0.8)))
                        }
                    }
                )
            }
        }
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            shootingStarManager.stopAnimation()
        }
    }
    
    // MARK: - 子视图组件
    
    // 星空背景
    var starfieldBackground: some View {
        ZStack {
            // 深空渐变背景 - 精确匹配图片色调
            RadialGradient(
                colors: [
                    Color(red: 0.15, green: 0.1, blue: 0.4),
                    Color(red: 0.1, green: 0.05, blue: 0.25),
                    Color(red: 0.05, green: 0.02, blue: 0.15),
                    Color.black
                ],
                center: .center,
                startRadius: 50,
                endRadius: 500
            )
            .ignoresSafeArea()
            
            // 星星效果
            ForEach(0..<80, id: \.self) { index in
                Circle()
                    .fill(.white)
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .opacity(0.3 + 0.7 * sin(animationPhase * 0.02 + Double(index)))
            }
            
            // 紫色星云效果
            ForEach(0..<3, id: \.self) { index in
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.purple.opacity(0.1),
                                Color.blue.opacity(0.08),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 200)
                    .rotationEffect(.degrees(animationPhase * 0.03 * Double(index + 1)))
                    .offset(
                        x: sin(animationPhase * 0.01 * Double(index + 1)) * 80,
                        y: cos(animationPhase * 0.008 * Double(index + 1)) * 60
                    )
                    .blur(radius: 25)
            }
        }
    }
    
    // 顶部标题区域
    var topTitleSection: some View {
        VStack(spacing: 12) {
            Spacer()
            
            // 星星图标和标题
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.yellow)
                    .shadow(color: .yellow.opacity(0.6), radius: 4)
                
                Text("星空家族树")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2)
            }
            
            // 副标题文案
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.yellow)
                
                Text("轻触星座成员，探索TA的回忆银河")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                
                Image(systemName: "star.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.yellow)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(.white.opacity(0.12))
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.25), lineWidth: 1)
                    )
            )
            
            Spacer()
        }
    }
    
    // 家族成员视图
    func familyMembersView(geometry: GeometryProxy) -> some View {
        let center = calculateCenter(geometry: geometry)
        
        // 动态计算轨道半径，基于可用空间
        let availableWidth = geometry.size.width - 40 // 留边距
        let availableHeight = geometry.size.height - 240 // 减去顶部和底部区域
        let homeRadius: CGFloat = 35 // home发光圈半径
        let memberRadius: CGFloat = 32.5 // 人物图标半径
        let minMargin: CGFloat = 10 // 额外间距
        let baseRadius = homeRadius + memberRadius + minMargin // 最小轨道半径
        let maxRadius = min(availableWidth, availableHeight) / 2.2
        let dynamicRadii = [
            baseRadius + (maxRadius - baseRadius) * 0.4,  // 内轨道
            baseRadius + (maxRadius - baseRadius) * 0.65, // 中轨道
            baseRadius + (maxRadius - baseRadius) * 0.9   // 外轨道
        ]
        
        return ZStack {
            // 家族成员 - 按精确位置排列
            ForEach(Array(familyGraph.members.values), id: \.id) { member in
                let position = calculatePrecisePosition(for: member, center: center, dynamicRadii: dynamicRadii)
                let isHighlighted = selectedMember?.id == member.id
                let isSelected = selectedMember?.id == member.id
                
                MemberPlanetView(
                    member: member, 
                    animationPhase: animationPhase,
                    isHighlighted: isHighlighted,
                    isSelected: isSelected
                )
                .position(position)
                .onTapGesture {
                    withAnimation(.spring()) {
                        selectedMember = member
                        showMemberProfile = true // 显示资料卡
                    }
                }
            }
        }
    }
    
    // 统一的中心点计算 - 确保在屏幕可视中心
    private func calculateCenter(geometry: GeometryProxy) -> CGPoint {
        // 考虑顶部和底部区域，将中心点放在可视区域的中心
        let availableHeight = geometry.size.height - 240 // 减去顶部120px和底部120px
        let centerY = 120 + availableHeight / 2 // 顶部区域高度 + 可用高度的一半
        
        return CGPoint(x: geometry.size.width / 2, y: centerY)
    }
    
    // 中心家图标
    func centerHomeIcon(center: CGPoint) -> some View {
        ZStack {
            // 外圈发光效果
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .orange.opacity(0.9), 
                            .orange.opacity(0.5), 
                            .orange.opacity(0.2),
                            .clear
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 35
                    )
                )
                .frame(width: 70, height: 70)
            
            // 家图标背景
            Circle()
                .fill(.orange)
                .frame(width: 45, height: 45)
                .shadow(color: .orange.opacity(0.8), radius: 12)
            
            // 家图标
            Image(systemName: "house.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 1)
        }
        .position(center)
    }
    
    // 轨道路径视图
    func orbitPathsView(geometry: GeometryProxy) -> some View {
        let center = calculateCenter(geometry: geometry)
        
        // 使用与主视图相同的动态半径计算
        let availableWidth = geometry.size.width - 40
        let availableHeight = geometry.size.height - 240
        let homeRadius: CGFloat = 35 // home发光圈半径
        let memberRadius: CGFloat = 32.5 // 人物图标半径
        let minMargin: CGFloat = 10 // 额外间距
        let baseRadius = homeRadius + memberRadius + minMargin // 最小轨道半径
        let maxRadius = min(availableWidth, availableHeight) / 2.2
        let dynamicRadii = [
            baseRadius + (maxRadius - baseRadius) * 0.4,  // 内轨道
            baseRadius + (maxRadius - baseRadius) * 0.65, // 中轨道
            baseRadius + (maxRadius - baseRadius) * 0.9   // 外轨道
        ]
        
        return ZStack {
            ForEach(0..<dynamicRadii.count, id: \.self) { index in
                // 轨道虚线圆圈
                Circle()
                    .stroke(
                        orbitColors[index],
                        style: StrokeStyle(lineWidth: 2.0, dash: [8, 4])
                    )
                    .frame(width: dynamicRadii[index] * 2, height: dynamicRadii[index] * 2)
                    .position(center)
                    .opacity(0.9)
                
                // 轨道发光效果
                Circle()
                    .stroke(
                        orbitColors[index].opacity(0.3),
                        style: StrokeStyle(lineWidth: 4.0)
                    )
                    .frame(width: dynamicRadii[index] * 2, height: dynamicRadii[index] * 2)
                    .position(center)
                    .opacity(0.5)
                    .blur(radius: 2)
            }
        }
        .allowsHitTesting(false)
    }
    
    // 底部控制区域
    var bottomControlSection: some View {
        HStack(spacing: 60) { // 减小按钮间距
            // 暂停按钮
            ControlButton(
                icon: isPaused ? "play.fill" : "pause.fill",
                title: isPaused ? "继续" : "暂停",
                isActive: isPaused
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isPaused.toggle()
                    if isPaused {
                        shootingStarManager.stopAnimation()
                    } else {
                        shootingStarManager.startAnimation(duration: 2.0, repeatCount: -1)
                    }
                }
            }
            
            // 随机按钮
            ControlButton(
                icon: "star.fill",
                title: "随机",
                isActive: false
            ) {
                // 随机选择一个家庭成员
                let allMembers = Array(familyGraph.members.values)
                if let randomMember = allMembers.randomElement() {
                    withAnimation(.spring()) {
                        selectedMember = randomMember
                        showMemberProfile = true
                    }
                }
            }
            
            // 中心按钮
            ControlButton(
                icon: "house.fill",
                title: "中心",
                isActive: false
            ) {
                withAnimation(.spring()) {
                    selectedMember = nil
                    showOrbitPaths = true
                    showMemberProfile = false
                }
            }
        }
        .padding(.bottom, 50)
    }
    
    // MARK: - 辅助方法
    
    // 精确计算成员位置 - 确保人物图标中心围绕home键中心旋转
    private func calculatePrecisePosition(for member: FamilyMember, center: CGPoint, dynamicRadii: [CGFloat]) -> CGPoint {
        // 正确映射generation到轨道索引
        // Generation 0 (爸爸、姑姑、奶奶) -> 最外层轨道 (index 2)
        // Generation 1 (爷爷、我、表姐) -> 中间轨道 (index 1)
        // Generation 2 (妹妹、妈妈) -> 最内层轨道 (index 0)
        let orbitIndex = 2 - member.generation
        
        // 防止轨道索引越界
        guard orbitIndex >= 0 && orbitIndex < dynamicRadii.count else {
            // 如果索引无效，返回中心点以防止崩溃
            return center
        }
        let radius = dynamicRadii[orbitIndex]
        
        // 根据图片精确调整每个成员的角度位置 (使用弧度)
        var baseAngle: CGFloat
        
        switch member.name {
        // --- 外轨道 ---
        case "爸爸":
            baseAngle = CGFloat.pi * 1.25  // 左侧偏下
        case "姑姑":
            baseAngle = CGFloat.pi * 0.2   // 右上角
        case "奶奶":
            baseAngle = CGFloat.pi * 1.85  // 右下角
            
        // --- 中轨道 ---
        case "爷爷":
            baseAngle = CGFloat.pi * 0.75  // 左上角
        case "我":
            baseAngle = CGFloat.pi * 0.0    // 右侧
        case "表姐":
            baseAngle = CGFloat.pi * 1.0    // 左侧
            
        // --- 内轨道 ---
        case "妹妹":
            baseAngle = CGFloat.pi * 1.65  // 偏右下方
        case "妈妈":
            baseAngle = CGFloat.pi * 1.35  // 偏左下方
            
        default:
            // 为其他未指定成员提供默认分布
            let membersInGeneration = familyGraph.members.values.filter { $0.generation == member.generation }.count
            baseAngle = (CGFloat(member.position) / CGFloat(membersInGeneration)) * 2 * CGFloat.pi
        }
        
        // 添加动画旋转 - 围绕home键中心进行圆周运动
        let animationAngle = isPaused ? 0 : CGFloat(animationPhase * orbitSpeed * 0.005)
        let finalAngle = baseAngle + animationAngle
        
        // 计算人物图标中心点位置
        let x = center.x + cos(finalAngle) * radius
        let y = center.y + sin(finalAngle) * radius
        
        return CGPoint(x: x, y: y)
    }
    
    // 启动动画
    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            if !isPaused {
                withAnimation(.linear(duration: 0.016)) {
                    animationPhase += 1
                }
            }
        }
        
        // 启动流星动画
        shootingStarManager.startAnimation(duration: 2.0, repeatCount: -1)
    }
}

#Preview {
    FamilyTreeView()
} 