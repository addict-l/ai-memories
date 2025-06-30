import SwiftUI

// 性别枚举
enum Gender {
    case male
    case female
}

// 家庭成员模型
struct FamilyMember: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let gender: Gender
    let generation: Int
    let position: Int // 在该轨道上的位置索引
    var spouseId: UUID?
    var parentIds: Set<UUID>
    var childrenIds: Set<UUID>
    var profileImages: [String]
    var memoryCount: Int
    var birthYear: Int?
    var description: String
    var loveLevel: Int
    var specialTrait: String
    var planetColor: Color // 行星颜色
    
    static func == (lhs: FamilyMember, rhs: FamilyMember) -> Bool {
        return lhs.id == rhs.id
    }
}

// 家族关系图
class FamilyGraph {
    var members: [UUID: FamilyMember]
    
    init() {
        self.members = [:]
    }
    
    func addMember(_ member: FamilyMember) {
        members[member.id] = member
    }
    
    func getSpouse(of memberId: UUID) -> FamilyMember? {
        guard let member = members[memberId],
              let spouseId = member.spouseId else { return nil }
        return members[spouseId]
    }
    
    func getChildren(of memberId: UUID) -> [FamilyMember] {
        guard let member = members[memberId] else { return [] }
        return member.childrenIds.compactMap { members[$0] }
    }
    
    func getParents(of memberId: UUID) -> [FamilyMember] {
        guard let member = members[memberId] else { return [] }
        return member.parentIds.compactMap { members[$0] }
    }
}

// 主视图：星空家族树
struct FamilyTreeView: View {
    let familyGraph: FamilyGraph
    @State private var selectedMember: FamilyMember?
    @State private var animationPhase: Double = 0
    @State private var orbitSpeed: Double = 1.0
    @State private var showOrbitPaths: Bool = true
    @State private var showMemberProfile: Bool = false // 控制资料卡显示
    @State private var shootingStarX: CGFloat = -100
    @State private var shootingStarY: CGFloat = 80
    @State private var animate = false
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
                
                // 流星动画
                ShootingStarView(x: shootingStarX, y: shootingStarY)
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
    }
    
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
        startShootingStarAnimation()
    }
    
    // 启动流星动画
    private func startShootingStarAnimation() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            if !isPaused {
                // 重置流星位置
                shootingStarX = -100
                shootingStarY = 80
                
                // 启动流星飞行动画
                withAnimation(Animation.linear(duration: 2.0)) {
                    shootingStarX = 500
                    shootingStarY = 400
                }
            }
        }
    }
}

// 成员行星视图
struct MemberPlanetView: View {
    let member: FamilyMember
    let animationPhase: Double
    let isHighlighted: Bool
    let isSelected: Bool
    
    @State private var particleOffset: [CGPoint] = []
    @State private var particleOpacity: [Double] = []
    @State private var haloScale: CGFloat = 1.0
    @State private var colorShiftPhase: Double = 0
    
    var body: some View {
        // The root view is now just the planet. Its center will be positioned on the orbit.
        ZStack {
            // 高级粒子特效 - 替代变大效果
            if isHighlighted {
                particleEffectsView
                haloRingsView
            }
            
            // 选中状态高级发光效果
            if isSelected {
                selectedGlowEffectsView
            }
            
            // 行星背景 - 使用成员自定义颜色，移除缩放效果
            planetBackgroundView
            
            // 成员图标 - 添加色彩变换效果
            memberIconView
            
            // 高级回忆数字标签
            memoryCountBadgeView
            
            // 能量波纹效果 - 仅在高亮时显示
            if isHighlighted {
                energyWaveEffectsView
            }
        }
        .frame(width: 65, height: 65)
        .overlay(alignment: .bottom) {
            memberNameTagView
        }
        .animation(.easeInOut(duration: 0.2), value: isHighlighted)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isSelected)
        .onChange(of: isHighlighted) { highlighted in
            if highlighted {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    haloScale = 1.2
                    colorShiftPhase = 1.0
                }
            } else {
                withAnimation(.easeOut(duration: 0.5)) {
                    haloScale = 1.0
                    colorShiftPhase = 0.0
                }
            }
        }
    }
    
    // 粒子特效视图
    private var particleEffectsView: some View {
        ForEach(0..<12, id: \.self) { index in
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .yellow.opacity(0.8),
                            .orange.opacity(0.6),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 8
                    )
                )
                .frame(width: 6, height: 6)
                .offset(
                    x: particleOffset.indices.contains(index) ? particleOffset[index].x : 0,
                    y: particleOffset.indices.contains(index) ? particleOffset[index].y : 0
                )
                .opacity(particleOpacity.indices.contains(index) ? particleOpacity[index] : 0)
                .blur(radius: 1)
        }
        .onAppear {
            startParticleAnimation()
        }
    }
    
    // 光环特效视图
    private var haloRingsView: some View {
        ForEach(0..<3, id: \.self) { ringIndex in
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            .yellow.opacity(0.8),
                            .orange.opacity(0.4),
                            .red.opacity(0.2),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .frame(width: 50 + CGFloat(ringIndex * 8), height: 50 + CGFloat(ringIndex * 8))
                .opacity(0.6 - Double(ringIndex) * 0.2)
                .rotationEffect(.degrees(animationPhase * (0.5 + Double(ringIndex) * 0.2)))
        }
    }
    
    // 选中发光效果视图
    private var selectedGlowEffectsView: some View {
        Group {
            // 内层能量光环
            Circle()
                .fill(
                    AngularGradient(
                        colors: [
                            .white.opacity(0.8),
                            .blue.opacity(0.6),
                            .purple.opacity(0.4),
                            .cyan.opacity(0.6),
                            .white.opacity(0.8)
                        ],
                        center: .center
                    )
                )
                .frame(width: 60, height: 60)
                .blur(radius: 6)
                .rotationEffect(.degrees(animationPhase * 0.3))
            
            // 外层脉冲光环
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.6),
                            .blue.opacity(0.3),
                            .clear
                        ],
                        startPoint: .center,
                        endPoint: .topTrailing
                    ),
                    lineWidth: 2
                )
                .frame(width: 65, height: 65)
                .opacity(0.5 + sin(animationPhase * 0.06) * 0.3)
        }
    }
    
    // 行星背景视图
    private var planetBackgroundView: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        .white.opacity(0.4),
                        getEnhancedColor().opacity(0.95),
                        getEnhancedColor().opacity(0.8)
                    ],
                    center: UnitPoint(x: 0.25, y: 0.25),
                    startRadius: 5,
                    endRadius: 40
                )
            )
            .shadow(color: getEnhancedColor().opacity(0.8), radius: 15)
            .overlay(
                Circle()
                    .stroke(
                        isHighlighted ? .yellow.opacity(0.8) : 
                        isSelected ? .white.opacity(0.6) : .white.opacity(0.3), 
                        lineWidth: isHighlighted || isSelected ? 2.0 : 1.5
                    )
            )
    }
    
    // 成员图标视图
    private var memberIconView: some View {
        Image(systemName: member.profileImages.first ?? "person.fill")
            .font(.system(size: 26, weight: .medium))
            .foregroundStyle(memberIconGradient)
            .shadow(color: .black.opacity(0.7), radius: 3)
    }
    
    // 成员图标渐变
    private var memberIconGradient: LinearGradient {
        if isHighlighted {
            return LinearGradient(
                colors: [.yellow, .orange, .red],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [.white, .white.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    // 回忆数字标签视图
    private var memoryCountBadgeView: some View {
        VStack {
            HStack {
                Spacer()
                ZStack {
                    // 背景光环
                    if isHighlighted {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        .yellow.opacity(0.6),
                                        .orange.opacity(0.3),
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 15
                                )
                            )
                            .frame(width: 30, height: 30)
                            .blur(radius: 4)
                    }
                    
                    Circle()
                        .fill(memoryBadgeGradient)
                        .frame(width: 22, height: 22)
                        .shadow(color: isHighlighted ? .yellow.opacity(0.8) : .red.opacity(0.8), radius: 6)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                        )
                    
                    Text("\(member.memoryCount)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(isHighlighted ? .black : .white)
                        .shadow(color: .black.opacity(0.5), radius: 1)
                }
                .offset(x: 4, y: -4)
            }
            Spacer()
        }
    }
    
    // 回忆标签渐变
    private var memoryBadgeGradient: AnyShapeStyle {
        if isHighlighted {
            return AnyShapeStyle(
                AngularGradient(
                    colors: [.yellow, .orange, .red, .yellow],
                    center: .center
                )
            )
        } else {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [.red, .red.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
    
    // 能量波纹效果视图
    private var energyWaveEffectsView: some View {
        ForEach(0..<2, id: \.self) { waveIndex in
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            .yellow.opacity(0.4),
                            .orange.opacity(0.2),
                            .clear
                        ],
                        startPoint: .center,
                        endPoint: .topTrailing
                    ),
                    lineWidth: 1
                )
                .frame(width: 55 + CGFloat(waveIndex * 8), height: 55 + CGFloat(waveIndex * 8))
                .opacity(0.8 - cos(animationPhase * 0.1 + Double(waveIndex) * .pi) * 0.4)
        }
    }
    
    // 成员名字标签视图
    private var memberNameTagView: some View {
        Text(member.name)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(nameTextGradient)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(nameTagBackgroundView)
            .shadow(color: .black.opacity(0.6), radius: 3)
            .padding(.top, 8)
            .offset(y: isHighlighted ? sin(animationPhase * 0.08) * 2 : 0)
    }
    
    // 名字文字渐变
    private var nameTextGradient: LinearGradient {
        if isHighlighted {
            return LinearGradient(
                colors: [.yellow, .orange],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                colors: [.white, .white.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    // 名字标签背景视图
    private var nameTagBackgroundView: some View {
        Capsule()
            .fill(nameTagBackgroundGradient)
            .overlay(
                Capsule()
                    .stroke(nameTagBorderGradient, lineWidth: isHighlighted ? 1.5 : 1)
            )
            .shadow(
                color: isHighlighted ? .yellow.opacity(0.4) : .black.opacity(0.3),
                radius: isHighlighted ? 8 : 3
            )
    }
    
    // 名字标签背景渐变
    private var nameTagBackgroundGradient: LinearGradient {
        if isHighlighted {
            return LinearGradient(
                colors: [.black.opacity(0.9), .black.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [.black.opacity(0.75), .black.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // 名字标签边框渐变
    private var nameTagBorderGradient: LinearGradient {
        if isHighlighted {
            return LinearGradient(
                colors: [.yellow.opacity(0.8), .orange.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [.white.opacity(0.35), .white.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // 获取增强的颜色效果
    private func getEnhancedColor() -> Color {
        if isHighlighted {
            // 高亮时使用动态色彩变换
            let hue = (sin(animationPhase * 0.02) + 1) / 2 // 0-1范围
            return Color(hue: hue * 0.3, saturation: 0.8, brightness: 0.9) // 暖色调范围
        }
        return member.planetColor
    }
    
    // 粒子动画
    private func startParticleAnimation() {
        // 初始化粒子位置和透明度
        particleOffset = (0..<12).map { index in
            let angle = Double(index) * (2 * .pi / 12)
            let radius = CGFloat.random(in: 15...25)
            return CGPoint(
                x: cos(angle) * radius,
                y: sin(angle) * radius
            )
        }
        
        particleOpacity = Array(repeating: 0.0, count: 12)
        
        // 启动循环动画
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            guard isHighlighted else {
                timer.invalidate()
                return
            }
            
            withAnimation(.easeInOut(duration: 0.8)) {
                for i in 0..<12 {
                    // 粒子向外扩散 - 限制在图标范围内
                    let angle = Double(i) * (2 * .pi / 12)
                    let maxRadius = CGFloat.random(in: 25...30)
                    particleOffset[i] = CGPoint(
                        x: cos(angle) * maxRadius,
                        y: sin(angle) * maxRadius
                    )
                    
                    // 透明度变化
                    particleOpacity[i] = Double.random(in: 0.3...0.8)
                }
            }
            
            // 延迟重置
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeOut(duration: 0.4)) {
                    for i in 0..<12 {
                        particleOpacity[i] = 0.0
                    }
                }
            }
        }
    }
}

// 控制按钮 - 精致质感版本
struct ControlButton: View {
    let icon: String
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    // 外层发光效果
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: isActive ? [
                                    .yellow.opacity(0.6),
                                    .yellow.opacity(0.2),
                                    .clear
                                ] : [
                                    .white.opacity(0.15),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 35
                            )
                        )
                        .frame(width: 60, height: 60)
                        .blur(radius: isActive ? 8 : 4)
                    
                    // 主按钮背景 - 玻璃质感
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.25),
                                    .white.opacity(0.1),
                                    .black.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 55, height: 55)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.4),
                                            .white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.2
                                )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                    
                    // 内层高光
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    .white.opacity(0.3),
                                    .clear
                                ],
                                center: UnitPoint(x: 0.3, y: 0.3),
                                startRadius: 5,
                                endRadius: 20
                            )
                        )
                        .frame(width: 55, height: 55)
                        .blendMode(.softLight)
                    
                    // 图标
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: isActive ? [
                                    .yellow,
                                    .orange
                                ] : [
                                    .white,
                                    .white.opacity(0.8)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: isActive ? .yellow.opacity(0.5) : .black.opacity(0.3), radius: 2)
                }
                .scaleEffect(isActive ? 1.05 : 1.0)
                
                // 标题文字
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.9),
                                .white.opacity(0.7)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isActive)
        .scaleEffect(isActive ? 1.02 : 1.0)
    }
}

// 温馨家庭成员资料卡
struct MemberProfileCard: View {
    let member: FamilyMember
    @Binding var isShowing: Bool
    @State private var animationOffset: CGFloat = 50
    @State private var showMemoryGallery: Bool = false
    @State private var showAddMemorySheet: Bool = false
    @State private var newMemoryTitle: String = ""
    @State private var newMemoryDescription: String = ""
    @State private var showSuccessMessage: Bool = false
    
    var body: some View {
        ZStack {
            // 背景遮罩
            Rectangle()
                .fill(.black.opacity(0.7))
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring()) {
                        isShowing = false
                    }
                }
            
            // 资料卡主体
            VStack(spacing: 0) {
                // 卡片头部 - 头像区域
                cardHeaderView
                
                // 卡片内容区域
                cardContentView
                
                // 卡片底部 - 操作按钮
                cardFooterView
            }
            .frame(width: 320, height: 480)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.95),
                                .white.opacity(0.88)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.8),
                                        .white.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
            )
            .offset(y: animationOffset)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animationOffset = 0
                }
            }
            
            // 成功消息提示
            if showSuccessMessage {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("回忆添加成功！")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(.black.opacity(0.8))
                    )
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showMemoryGallery) {
            MemoryGalleryView(member: member, isShowing: $showMemoryGallery)
        }
        .sheet(isPresented: $showAddMemorySheet) {
            AddMemoryView(
                member: member,
                isShowing: $showAddMemorySheet,
                onMemoryAdded: {
                    showSuccessMessage = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSuccessMessage = false
                    }
                }
            )
        }
    }
    
    // 卡片头部
    private var cardHeaderView: some View {
        VStack(spacing: 16) {
            // 关闭按钮
            HStack {
                Spacer()
                Button {
                    withAnimation(.spring()) {
                        isShowing = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray.opacity(0.6))
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 20)
            
            // 大头像
            ZStack {
                // 头像背景光环
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                member.planetColor.opacity(0.3),
                                member.planetColor.opacity(0.1),
                                .clear
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 80
                        )
                    )
                    .frame(width: 120, height: 120)
                
                // 头像主体
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .white.opacity(0.4),
                                member.planetColor.opacity(0.9),
                                member.planetColor.opacity(0.7)
                            ],
                            center: UnitPoint(x: 0.3, y: 0.3),
                            startRadius: 10,
                            endRadius: 50
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.6), lineWidth: 3)
                    )
                    .shadow(color: member.planetColor.opacity(0.5), radius: 15)
                
                // 头像图标
                Image(systemName: member.profileImages.first ?? "person.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2)
            }
            
            // 姓名和称谓
            VStack(spacing: 4) {
                Text(member.name)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.black.opacity(0.8))
                
                Text(getRoleDescription(for: member))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(member.planetColor.opacity(0.2))
                    )
            }
        }
        .padding(.bottom, 20)
    }
    
    // 卡片内容
    private var cardContentView: some View {
        VStack(spacing: 20) {
            // 基本信息行
            infoRowView
            
            // 特色标签
            specialTraitView
            
            // 温馨描述
            descriptionView
            
            // 回忆统计
            memoryStatsView
        }
        .padding(.horizontal, 24)
    }
    
    // 基本信息行
    private var infoRowView: some View {
        HStack(spacing: 20) {
            // 年龄信息
            VStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.system(size: 16))
                    .foregroundColor(member.planetColor)
                
                if let birthYear = member.birthYear {
                    let age = Calendar.current.component(.year, from: Date()) - birthYear
                    Text("\(age)岁")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black.opacity(0.7))
                    
                    Text("\(birthYear)年生")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                } else {
                    Text("年龄未知")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.gray.opacity(0.1))
            )
            
            // 亲密度
            VStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.red.opacity(0.8))
                
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: index < member.loveLevel ? "heart.fill" : "heart")
                            .font(.system(size: 8))
                            .foregroundColor(index < member.loveLevel ? .red.opacity(0.8) : .gray.opacity(0.3))
                    }
                }
                
                Text("亲密度")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.red.opacity(0.05))
            )
        }
    }
    
    // 特色标签
    private var specialTraitView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.yellow.opacity(0.8))
                
                Text("特色标签")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black.opacity(0.7))
                
                Spacer()
            }
            
            Text(member.specialTrait)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(member.planetColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(member.planetColor.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(member.planetColor.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // 温馨描述
    private var descriptionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.blue.opacity(0.6))
                
                Text("温馨印象")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black.opacity(0.7))
                
                Spacer()
            }
            
            Text(getWarmDescription(for: member))
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.black.opacity(0.6))
                .lineLimit(3)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.blue.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.blue.opacity(0.1), lineWidth: 1)
                        )
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // 回忆统计
    private var memoryStatsView: some View {
        HStack {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 16))
                .foregroundColor(member.planetColor)
            
            Text("珍贵回忆")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black.opacity(0.7))
            
            Spacer()
            
            Text("\(member.memoryCount)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(member.planetColor)
            
            Text("个")
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(member.planetColor.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(member.planetColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // 卡片底部
    private var cardFooterView: some View {
        VStack(spacing: 16) {
            // 操作按钮
            HStack(spacing: 16) {
                // 查看回忆按钮
                Button {
                    showMemoryGallery = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 14))
                        
                        Text("查看回忆")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [
                                member.planetColor,
                                member.planetColor.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: member.planetColor.opacity(0.4), radius: 4, x: 0, y: 2)
                }
                
                // 添加回忆按钮
                Button {
                    showAddMemorySheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 14))
                        
                        Text("添加回忆")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(member.planetColor)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(member.planetColor, lineWidth: 1.5)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.white)
                            )
                    )
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }
    
    // 获取角色描述
    private func getRoleDescription(for member: FamilyMember) -> String {
        switch member.name {
        case "爷爷": return "家族的智慧长者 👴"
        case "奶奶": return "慈祥的家庭守护者 👵"
        case "爸爸": return "家庭的顶梁柱 👨‍💼"
        case "妈妈": return "温暖的家庭港湾 👩‍❤️"
        case "姑姑": return "时尚的家族明星 ✨"
        case "我": return "家庭的未来希望 🌟"
        case "妹妹": return "家里的开心果 😊"
        case "表姐": return "贴心的好伙伴 👭"
        default: return "珍贵的家庭成员 💝"
        }
    }
    
    // 获取温馨描述
    private func getWarmDescription(for member: FamilyMember) -> String {
        switch member.name {
        case "爷爷": return "总是在门口等我回家的人，会给我讲很多有趣的老故事，手里永远有好吃的糖果。"
        case "奶奶": return "世界上最温柔的人，做的饭菜是世界上最香的，总是担心我吃不饱穿不暖。"
        case "爸爸": return "虽然平时严肃，但总是默默为家庭付出一切，是我最坚强的依靠。"
        case "妈妈": return "无论什么时候都会给我最温暖的拥抱，是世界上最了解我的人。"
        case "姑姑": return "总是带来最新奇的礼物和故事，让我的童年充满了惊喜和欢乐。"
        case "我": return "正在努力成长的小家伙，希望能够让家人为我感到骄傲。"
        case "妹妹": return "家里最可爱的小天使，总能用她的笑容治愈所有的不开心。"
        case "表姐": return "最好的玩伴和倾听者，一起分享过无数秘密和快乐时光。"
        default: return "每一个家庭成员都是独一无二的珍宝，承载着无数美好的回忆。"
        }
    }
}

// 回忆画廊视图
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

// 回忆项目数据模型
struct MemoryItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let date: String
    let images: [String]
    let emotion: MemoryEmotion
}

enum MemoryEmotion {
    case happy, peaceful, warm, excited, nostalgic
    
    var color: Color {
        switch self {
        case .happy: return .yellow
        case .peaceful: return .green
        case .warm: return .orange
        case .excited: return .red
        case .nostalgic: return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .happy: return "face.smiling"
        case .peaceful: return "leaf.fill"
        case .warm: return "heart.fill"
        case .excited: return "star.fill"
        case .nostalgic: return "clock.fill"
        }
    }
}

// 回忆卡片视图
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

// 添加回忆视图
struct AddMemoryView: View {
    let member: FamilyMember
    @Binding var isShowing: Bool
    let onMemoryAdded: () -> Void
    
    @State private var memoryTitle: String = ""
    @State private var memoryDescription: String = ""
    @State private var selectedEmotion: MemoryEmotion = .happy
    @State private var selectedDate = Date()
    @State private var showingImagePicker = false
    
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 成员信息
                        memberInfoSection
                        
                        // 回忆标题
                        titleInputSection
                        
                        // 回忆描述
                        descriptionInputSection
                        
                        // 情感选择
                        emotionSelectionSection
                        
                        // 日期选择
                        dateSelectionSection
                        
                        // 图片选择
                        imageSelectionSection
                        
                        // 添加按钮
                        addMemoryButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("添加回忆")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        isShowing = false
                    }
                    .foregroundColor(member.planetColor)
                }
            }
        }
    }
    
    // 成员信息区域
    private var memberInfoSection: some View {
        HStack(spacing: 16) {
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
                Text("为 \(member.name) 添加新回忆")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black.opacity(0.8))
                
                Text("记录与TA的美好时光")
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
    
    // 标题输入区域
    private var titleInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("回忆标题", systemImage: "text.cursor")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black.opacity(0.8))
            
            TextField("输入回忆标题...", text: $memoryTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.system(size: 16))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    // 描述输入区域
    private var descriptionInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("回忆描述", systemImage: "doc.text")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black.opacity(0.8))
            
            TextField("描述这个美好的回忆...", text: $memoryDescription, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.system(size: 16))
                .lineLimit(3...6)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    // 情感选择区域
    private var emotionSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("回忆情感", systemImage: "heart")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black.opacity(0.8))
            
            HStack(spacing: 12) {
                ForEach([MemoryEmotion.happy, .peaceful, .warm, .excited, .nostalgic], id: \.self) { emotion in
                    EmotionButton(
                        emotion: emotion,
                        isSelected: selectedEmotion == emotion
                    ) {
                        selectedEmotion = emotion
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    // 日期选择区域
    private var dateSelectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("回忆日期", systemImage: "calendar")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black.opacity(0.8))
            
            DatePicker("选择日期", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .accentColor(member.planetColor)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    // 图片选择区域
    private var imageSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("添加图片", systemImage: "photo")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black.opacity(0.8))
            
            Button {
                showingImagePicker = true
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 30))
                        .foregroundColor(member.planetColor)
                    
                    Text("点击添加图片")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(member.planetColor)
                }
                .frame(height: 80)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(member.planetColor, style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    // 添加回忆按钮
    private var addMemoryButton: some View {
        Button {
            // 模拟添加回忆
            withAnimation(.spring()) {
                onMemoryAdded()
                isShowing = false
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16))
                
                Text("添加回忆")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [
                        member.planetColor,
                        member.planetColor.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: member.planetColor.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .disabled(memoryTitle.isEmpty || memoryDescription.isEmpty)
        .opacity(memoryTitle.isEmpty || memoryDescription.isEmpty ? 0.6 : 1.0)
    }
}

// 情感按钮组件
struct EmotionButton: View {
    let emotion: MemoryEmotion
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: emotion.icon)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? .white : emotion.color)
                
                Text(emotionText)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? .white : emotion.color)
            }
            .frame(width: 50, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? emotion.color : emotion.color.opacity(0.15))
            )
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
    
    private var emotionText: String {
        switch emotion {
        case .happy: return "开心"
        case .peaceful: return "宁静"
        case .warm: return "温暖"
        case .excited: return "兴奋"
        case .nostalgic: return "怀念"
        }
    }
}

#Preview {
    FamilyTreeView()
} 