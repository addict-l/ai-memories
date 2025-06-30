import SwiftUI
import PhotosUI

struct ProfileView: View {
    @State private var animationPhase: Double = 0
    @State private var showEditProfile: Bool = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showAvatarDetail: Bool = false
    @State private var showMemoryStats: Bool = false
    @State private var showFavoriteMembers: Bool = false
    @State private var selectedStatistic: StatisticType?
    @State private var shootingStarX: CGFloat = -100
    @State private var shootingStarY: CGFloat = 80
    @State private var animate = false
    
    // 新增状态变量
    @State private var showAddMemory: Bool = false
    @State private var showInviteFamily: Bool = false
    @State private var showShareTree: Bool = false
    @State private var showBackupData: Bool = false
    @State private var showNotificationSettings: Bool = false
    @State private var showPrivacySettings: Bool = false
    @State private var showHelpSupport: Bool = false
    @State private var showAboutApp: Bool = false
    
    enum StatisticType {
        case favoriteMembers
        case newMemories
        case highlights
        case totalMemories
    }
    
    // 示例用户数据
    @State private var userProfile = UserProfile(
        name: "张小明",
        nickname: "小明",
        avatar: "person.circle.fill",
        customAvatar: nil,
        birthYear: 1995,
        location: "北京市",
        familyRole: "家庭记录者",
        totalMemories: 156,
        favoriteMembers: ["妈妈", "爷爷", "妹妹"],
        joinDate: "2024年1月",
        motto: "用心记录每一个温暖瞬间",
        planetColor: .blue
    )
    
    // 初始化时设置TabBar样式
    init() {
        // 确保TabBar背景完全透明
        UITabBar.appearance().backgroundColor = UIColor.clear
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().isTranslucent = true
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
                    .onAppear {
                        withAnimation(Animation.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                            shootingStarX = 500
                            shootingStarY = 400
                        }
                    }
                
                // 主内容区域
                ScrollViewReader { scrollProxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0, pinnedViews: []) {
                            // 顶部安全区域占位 - 增加额外空间避免灵动岛遮挡
                            Color.clear
                                .frame(height: max(geometry.safeAreaInsets.top + 20, 70))
                                .id("top")
                            
                            VStack(spacing: 0) {
                                // 个人信息卡片 - 增加顶部边距
                                profileCardView
                                    .padding(.top, 40)
                                    .padding(.horizontal, 20)
                                
                                // 统计信息
                                statisticsView
                                    .padding(.horizontal, 20)
                                    .padding(.top, 32)
                                
                                // 底部安全区域 + 导航栏高度 - 增加高度确保完全覆盖
                                Color.clear
                                    .frame(height: geometry.safeAreaInsets.bottom + 200)
                            }
                            .background(
                                GeometryReader { scrollGeometry in
                                    Color.clear
                                        .preference(key: ScrollOffsetPreferenceKey.self, 
                                                    value: scrollGeometry.frame(in: .named("scroll")).minY)
                                }
                            )
                        }
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        scrollOffset = value
                    }
                }
                
                // 顶部导航栏区域
                topNavigationOverlay(geometry: geometry)
                
                // 增强的底部融合遮罩 - 确保完美覆盖TabBar
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.black.opacity(0.05),
                                    Color.black.opacity(0.15),
                                    Color.black.opacity(0.3),
                                    Color.black.opacity(0.5),
                                    Color.black.opacity(0.7),
                                    Color.black.opacity(0.85),
                                    Color.black.opacity(0.95),
                                    Color.black,
                                    Color.black
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: geometry.safeAreaInsets.bottom + 220) // 增加高度确保完全覆盖
                        .allowsHitTesting(false)
                }
                .ignoresSafeArea(.all)
            }
        }
        .ignoresSafeArea(.all) // 改为忽略所有边缘
        .onAppear {
            startAnimation()
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(profile: $userProfile)
        }
        .sheet(isPresented: $showAvatarDetail) {
            AvatarDetailView(profile: userProfile)
        }
        .sheet(isPresented: $showMemoryStats) {
            MemoryStatisticsDetailView(
                statType: selectedStatistic ?? .totalMemories,
                profile: userProfile
            )
        }
        .sheet(isPresented: $showAddMemory) {
            AddMemoryView()
        }
        .sheet(isPresented: $showInviteFamily) {
            InviteFamilyView()
        }
        .sheet(isPresented: $showShareTree) {
            ShareTreeView(profile: userProfile)
        }
        .sheet(isPresented: $showBackupData) {
            BackupDataView()
        }
        .sheet(isPresented: $showNotificationSettings) {
            NotificationSettingsView()
        }
        .sheet(isPresented: $showPrivacySettings) {
            PrivacySettingsView()
        }
        .sheet(isPresented: $showHelpSupport) {
            HelpSupportView()
        }
        .sheet(isPresented: $showAboutApp) {
            AboutAppView()
        }
    }
    
    // 星空背景
    var starfieldBackground: some View {
        ZStack {
            // 深空渐变背景
            deepSpaceGradient
            
            // 动态星云效果
            nebulaEffects
            
            // 星星效果 - 分层处理
            starFieldEffects
            
            // 流星效果 - 增强版
            meteorEffects
        }
    }
    
    // 深空渐变背景
    var deepSpaceGradient: some View {
        RadialGradient(
            colors: [
                Color(red: 0.15, green: 0.1, blue: 0.4),
                Color(red: 0.1, green: 0.05, blue: 0.25),
                Color(red: 0.05, green: 0.02, blue: 0.15),
                Color.black
            ],
            center: .center,
            startRadius: 50,
            endRadius: 600
        )
        .ignoresSafeArea()
    }
    
    // 动态星云效果
    var nebulaEffects: some View {
        ForEach(0..<5, id: \.self) { index in
            singleNebulaCloud(index: index)
        }
    }
    
    // 单个星云
    func singleNebulaCloud(index: Int) -> some View {
        Circle()
            .fill(nebulaGradient)
            .frame(width: 400, height: 400)
            .offset(
                x: sin(animationPhase * 0.002 + Double(index)) * 100,
                y: cos(animationPhase * 0.003 + Double(index) * 2) * 80
            )
            .opacity(0.3 + 0.2 * sin(animationPhase * 0.005 + Double(index)))
    }
    
    // 星云渐变
    var nebulaGradient: RadialGradient {
        RadialGradient(
            colors: [
                Color.purple.opacity(0.1),
                Color.blue.opacity(0.05),
                .clear
            ],
            center: .center,
            startRadius: 50,
            endRadius: 200
        )
    }
    
    // 星星效果
    var starFieldEffects: some View {
        ForEach(0..<80, id: \.self) { index in
            singleStar(index: index)
        }
    }
    
    // 单颗星星
    func singleStar(index: Int) -> some View {
        Circle()
            .fill(.white)
            .frame(width: CGFloat.random(in: 1...3))
            .position(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: 0...UIScreen.main.bounds.height * 1.5)
            )
            .opacity(0.2 + 0.8 * sin(animationPhase * (0.01 + Double(index) * 0.001) + Double(index)))
            .scaleEffect(0.5 + 0.5 * sin(animationPhase * 0.02 + Double(index)))
    }
    
    // 流星效果
    var meteorEffects: some View {
        ForEach(0..<3, id: \.self) { index in
            singleMeteor(index: index)
        }
    }
    
    // 单颗流星
    func singleMeteor(index: Int) -> some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(meteorGradient)
            .frame(width: 100, height: 3)
            .rotationEffect(.degrees(30))
            .offset(x: meteorXOffset(index: index), y: meteorYOffset(index: index))
            .opacity(meteorOpacity(index: index))
    }
    
    // 流星X偏移量
    private func meteorXOffset(index: Int) -> CGFloat {
        sin(animationPhase * (0.006 + Double(index) * 0.002) + Double(index) * 3.14) * 300
    }
    
    // 流星Y偏移量
    private func meteorYOffset(index: Int) -> CGFloat {
        cos(animationPhase * (0.004 + Double(index) * 0.001) + Double(index) * 2.1) * 200
    }
    
    // 流星透明度
    private func meteorOpacity(index: Int) -> Double {
        0.3 + 0.7 * sin(animationPhase * 0.008 + Double(index))
    }
    
    // 流星渐变
    var meteorGradient: LinearGradient {
        LinearGradient(
            colors: [
                .white.opacity(0.9),
                .blue.opacity(0.6),
                .purple.opacity(0.3),
                .clear
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // 个人信息卡片
    var profileCardView: some View {
        VStack(spacing: 28) {
            // 标题区域 - 增强设计，增加垂直间距
            HStack {
                profileTitleSection
                
                Spacer()
                
                // 编辑按钮放在标题右侧
                Button {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showEditProfile = true
                    }
                } label: {
                    glassEditButton
                }
                .scaleEffect(showEditProfile ? 0.95 : 1.0)
                .animation(.spring(response: 0.3), value: showEditProfile)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16) // 增加顶部内边距
            
            // 主要个人信息 - 增强设计
            VStack(spacing: 28) {
                // 头像和基本信息
                profileHeaderView
                
                // 详细信息
                profileDetailsView
            }
            .padding(28)
            .background(profileCardBackground)
        }
    }
    
    // 个人信息头部
    var profileHeaderView: some View {
        VStack(spacing: 20) {
            // 大头像 - 增强设计
            avatarSection
            
            // 姓名和标签区域 - 重新设计
            nameAndTagsSection
        }
    }
    
    // 资料卡标题区域
    var profileTitleSection: some View {
        HStack(spacing: 16) {
            profileTitleIcon
            
            VStack(alignment: .leading, spacing: 4) {
                Text("我的星空档案")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2)
                
                Text("Personal Starfield Profile")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .italic()
            }
        }
    }
    
    // 标题图标
    var profileTitleIcon: some View {
        ZStack {
            // 图标背景光环
            Circle()
                .fill(titleIconGradient)
                .frame(width: 50, height: 50)
                .scaleEffect(1.0 + sin(animationPhase * 0.03) * 0.05)
            
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.yellow)
                .shadow(color: .yellow.opacity(0.8), radius: 6)
                .shadow(color: .yellow.opacity(0.4), radius: 12)
        }
    }
    
    // 标题图标渐变
    var titleIconGradient: RadialGradient {
        RadialGradient(
            colors: [
                .yellow.opacity(0.3),
                .yellow.opacity(0.1),
                .clear
            ],
            center: .center,
            startRadius: 15,
            endRadius: 30
        )
    }
    
    // 资料卡背景
    var profileCardBackground: some View {
        ZStack {
            // 主背景
            cardMainBackground
            
            // 边框渐变
            cardBorderGradient
            
            // 内部光效
            cardInnerGlow
        }
    }
    
    // 卡片主背景
    var cardMainBackground: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(
                LinearGradient(
                    colors: [
                        .white.opacity(0.18),
                        .white.opacity(0.12),
                        .white.opacity(0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
    
    // 卡片边框渐变
    var cardBorderGradient: some View {
        RoundedRectangle(cornerRadius: 24)
            .stroke(
                LinearGradient(
                    colors: [
                        .white.opacity(0.4),
                        .white.opacity(0.2),
                        .white.opacity(0.1),
                        .clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.5
            )
    }
    
    // 卡片内部光效
    var cardInnerGlow: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(
                RadialGradient(
                    colors: [
                        userProfile.planetColor.opacity(0.1),
                        .clear
                    ],
                    center: .topLeading,
                    startRadius: 50,
                    endRadius: 200
                )
            )
    }
    
    // 头像区域
    var avatarSection: some View {
        Button {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showAvatarDetail = true
            }
        } label: {
            ZStack {
                // 外层光环 - 更大更柔和
                outerAvatarHalo
                
                // 中层光环
                middleAvatarHalo
                
                // 头像主体 - 更立体
                mainAvatarBody
                
                // 头像图标或自定义图片
                avatarContent
            }
        }
        .scaleEffect(showAvatarDetail ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: showAvatarDetail)
    }
    
    // 头像内容（图标或自定义图片）
    var avatarContent: some View {
        Group {
            if let customAvatar = userProfile.customAvatar,
               let uiImage = UIImage(contentsOfFile: customAvatar) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.3), lineWidth: 2)
                    )
            } else {
                avatarIcon
            }
        }
    }
    
    // 外层头像光环
    var outerAvatarHalo: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        userProfile.planetColor.opacity(0.4),
                        userProfile.planetColor.opacity(0.2),
                        userProfile.planetColor.opacity(0.1),
                        .clear
                    ],
                    center: .center,
                    startRadius: 60,
                    endRadius: 120
                )
            )
            .frame(width: 160, height: 160)
            .scaleEffect(1.0 + sin(animationPhase * 0.025) * 0.08)
    }
    
    // 中层头像光环
    var middleAvatarHalo: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        userProfile.planetColor.opacity(0.3),
                        userProfile.planetColor.opacity(0.15),
                        .clear
                    ],
                    center: .center,
                    startRadius: 50,
                    endRadius: 85
                )
            )
            .frame(width: 130, height: 130)
            .scaleEffect(1.0 + sin(animationPhase * 0.035) * 0.06)
    }
    
    // 主头像体
    var mainAvatarBody: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        .white.opacity(0.5),
                        userProfile.planetColor.opacity(0.95),
                        userProfile.planetColor.opacity(0.8),
                        userProfile.planetColor.opacity(0.6)
                    ],
                    center: UnitPoint(x: 0.3, y: 0.3),
                    startRadius: 15,
                    endRadius: 50
                )
            )
            .frame(width: 100, height: 100)
            .overlay(avatarBorder)
            .shadow(color: userProfile.planetColor.opacity(0.8), radius: 25, x: 0, y: 5)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 2)
    }
    
    // 头像边框
    var avatarBorder: some View {
        Circle()
            .stroke(
                LinearGradient(
                    colors: [
                        .white.opacity(0.8),
                        .white.opacity(0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 3
            )
    }
    
    // 头像图标
    var avatarIcon: some View {
        Image(systemName: userProfile.avatar)
            .font(.system(size: 42, weight: .medium))
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.4), radius: 3)
            .shadow(color: .white.opacity(0.3), radius: 1)
    }
    
    // 姓名和标签区域
    var nameAndTagsSection: some View {
        VStack(spacing: 12) {
            Text(userProfile.name)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.4), radius: 3)
                .shadow(color: userProfile.planetColor.opacity(0.6), radius: 8)
            
            HStack(spacing: 12) {
                if !userProfile.nickname.isEmpty && userProfile.nickname != userProfile.name {
                    nicknameTag
                }
                
                familyRoleTag
            }
        }
    }
    
    // 昵称标签
    var nicknameTag: some View {
        Text("「\(userProfile.nickname)」")
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white.opacity(0.9))
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(userProfile.planetColor.opacity(0.25))
                    .overlay(
                        Capsule()
                            .stroke(userProfile.planetColor.opacity(0.5), lineWidth: 1)
                    )
            )
    }
    
    // 家庭角色标签
    var familyRoleTag: some View {
        Text(userProfile.familyRole)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.black.opacity(0.8))
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                .yellow.opacity(0.9),
                                .orange.opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .yellow.opacity(0.5), radius: 6)
            )
    }
    
    // 个人详细信息
    var profileDetailsView: some View {
        VStack(spacing: 16) {
            // 座右铭
            mottoSection
            
            // 基本信息网格
            basicInfoGrid
        }
    }
    
    // 座右铭部分
    var mottoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            mottoHeader
            mottoContent
        }
    }
    
    // 座右铭标题
    var mottoHeader: some View {
        HStack {
            Image(systemName: "quote.bubble.fill")
                .font(.system(size: 12))
                .foregroundColor(.blue.opacity(0.8))
            
            Text("我的座右铭")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
    }
    
    // 座右铭内容
    var mottoContent: some View {
        Text(userProfile.motto)
            .font(.system(size: 16, design: .rounded))
            .foregroundColor(.white.opacity(0.8))
            .italic()
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(mottoBackground)
    }
    
    // 座右铭背景
    var mottoBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.blue.opacity(0.15))
    }
    
    // 基本信息网格
    var basicInfoGrid: some View {
        LazyVGrid(columns: basicInfoColumns, spacing: 12) {
            ageInfoItem
            locationInfoItem
            joinDateInfoItem
            memoriesInfoItem
        }
    }
    
    // 基本信息网格列
    var basicInfoColumns: [GridItem] {
        [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    }
    
    // 年龄信息项
    var ageInfoItem: some View {
        infoItemView(icon: "calendar", title: "年龄", value: "\(currentAge)岁")
    }
    
    // 位置信息项
    var locationInfoItem: some View {
        infoItemView(icon: "location", title: "位置", value: userProfile.location)
    }
    
    // 加入时间信息项
    var joinDateInfoItem: some View {
        infoItemView(icon: "calendar.badge.plus", title: "加入时间", value: userProfile.joinDate)
    }
    
    // 记忆信息项
    var memoriesInfoItem: some View {
        infoItemView(icon: "photo.on.rectangle", title: "记录回忆", value: "\(userProfile.totalMemories)个")
    }
    
    // 信息项视图
    func infoItemView(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(userProfile.planetColor)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.1))
        )
    }
    
    // 统计信息区域
    var statisticsView: some View {
        VStack(spacing: 20) {
            // 记忆统计卡片
            memoryStatisticsCards
            
            // 快捷功能区域
            quickFunctionsArea
            
            // 设置选项区域
            settingsOptionsArea
        }
        .padding(.horizontal, 20)
    }
    
    // 记忆统计卡片
    var memoryStatisticsCards: some View {
        VStack(spacing: 15) {
            statisticsTitle
            statisticsGrid
        }
    }
    
    // 统计标题
    var statisticsTitle: some View {
        HStack {
            Image(systemName: "chart.bar.xaxis")
                .foregroundColor(.yellow)
                .font(.title2)
            
            Text("记忆统计")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
    
    // 统计网格
    var statisticsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
            favoriteStatCard
            newMemoryStatCard
            highlightStatCard
            totalMemoryStatCard
        }
    }
    
    // 最爱成员统计卡
    var favoriteStatCard: some View {
        Button {
            selectedStatistic = .favoriteMembers
            showMemoryStats = true
        } label: {
            statisticCard(
                icon: "heart.fill",
                color: .pink,
                title: "最爱成员",
                value: "3位",
                subtitle: "妈妈"
            )
        }
    }
    
    // 新增记忆统计卡
    var newMemoryStatCard: some View {
        Button {
            selectedStatistic = .newMemories
            showMemoryStats = true
        } label: {
            statisticCard(
                icon: "plus.circle.fill",
                color: .green,
                title: "新增记忆",
                value: "12条",
                subtitle: "本月"
            )
        }
    }
    
    // 精彩记忆统计卡
    var highlightStatCard: some View {
        Button {
            selectedStatistic = .highlights
            showMemoryStats = true
        } label: {
            statisticCard(
                icon: "star.fill",
                color: .yellow,
                title: "精彩记忆",
                value: "38条",
                subtitle: "总计"
            )
        }
    }
    
    // 总记忆统计卡
    var totalMemoryStatCard: some View {
        Button {
            selectedStatistic = .totalMemories
            showMemoryStats = true
        } label: {
            statisticCard(
                icon: "photo.fill",
                color: .blue,
                title: "记忆总数",
                value: "156条",
                subtitle: "累计"
            )
        }
    }
    
    // 统计卡片通用组件
    func statisticCard(icon: String, color: Color, title: String, value: String, subtitle: String) -> some View {
        VStack(spacing: 12) {
            // 顶部图标和数值区域
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .stroke(color.opacity(0.4), lineWidth: 1)
                        )
                    
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 16, weight: .semibold))
                        .scaleEffect(1.0 + sin(animationPhase * 0.02) * 0.05)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(value)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: color.opacity(0.3), radius: 2)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            // 底部标题区域
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            color.opacity(0.08),
                            color.opacity(0.04),
                            .black.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    color.opacity(0.3),
                                    .white.opacity(0.1),
                                    .clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: animationPhase)
    }
    
    // 快捷功能区域
    var quickFunctionsArea: some View {
        VStack(spacing: 15) {
            quickFunctionsTitle
            quickFunctionsGrid
        }
    }
    
    // 快捷功能标题
    var quickFunctionsTitle: some View {
        HStack {
            Image(systemName: "bolt.fill")
                .foregroundColor(.yellow)
                .font(.title2)
            
            Text("快捷功能")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
    
    // 快捷功能网格
    var quickFunctionsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
            addMemoryButton
            inviteFamilyButton
            shareTreeButton
            backupDataButton
        }
    }
    
    // 添加记忆按钮
    var addMemoryButton: some View {
        quickFunctionButton(
            icon: "plus.circle",
            title: "添加记忆",
            description: "记录美好时光",
            color: .green
        )
    }
    
    // 邀请家人按钮
    var inviteFamilyButton: some View {
        quickFunctionButton(
            icon: "person.badge.plus",
            title: "邀请家人",
            description: "共建家族树",
            color: .blue
        )
    }
    
    // 分享家族树按钮
    var shareTreeButton: some View {
        quickFunctionButton(
            icon: "square.and.arrow.up",
            title: "分享家族树",
            description: "传承家族记忆",
            color: .orange
        )
    }
    
    // 备份数据按钮
    var backupDataButton: some View {
        quickFunctionButton(
            icon: "icloud.and.arrow.up",
            title: "备份数据",
            description: "保护珍贵回忆",
            color: .purple
        )
    }
    
    // 快捷功能按钮通用组件
    func quickFunctionButton(icon: String, title: String, description: String, color: Color) -> some View {
        Button(action: {
            // 添加触觉反馈
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // 根据不同功能执行不同操作
            switch title {
            case "添加记忆":
                showAddMemory = true
            case "邀请家人":
                showInviteFamily = true
            case "分享家族树":
                showShareTree = true
            case "备份数据":
                showBackupData = true
            default:
                break
            }
        }) {
            VStack(spacing: 12) {
                // 图标区域
                ZStack {
                    // 背景光晕
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    color.opacity(0.3),
                                    color.opacity(0.1),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 5,
                                endRadius: 25
                            )
                        )
                        .frame(width: 50, height: 50)
                        .scaleEffect(1.0 + sin(animationPhase * 0.02) * 0.1)
                    
                    // 主图标背景
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    color.opacity(0.2),
                                    color.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(color.opacity(0.4), lineWidth: 1)
                        )
                    
                    // 图标
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 18, weight: .semibold))
                        .scaleEffect(1.0 + sin(animationPhase * 0.03) * 0.05)
                        .shadow(color: color.opacity(0.5), radius: 4)
                }
                
                // 文字区域
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(description)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(height: 90)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                color.opacity(0.06),
                                color.opacity(0.03),
                                .black.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        color.opacity(0.3),
                                        .white.opacity(0.1),
                                        .clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: color.opacity(0.15), radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(EnhancedScaleButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: animationPhase)
    }
    
    // 设置选项区域
    var settingsOptionsArea: some View {
        VStack(spacing: 15) {
            settingsTitle
            settingsOptionsList
        }
    }
    
    // 设置标题
    var settingsTitle: some View {
        HStack {
            Image(systemName: "gearshape.fill")
                .foregroundColor(.yellow)
                .font(.title2)
            
            Text("设置选项")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
    
    // 设置选项列表
    var settingsOptionsList: some View {
        VStack(spacing: 12) {
            notificationSettingRow
            privacySettingRow
            helpSupportRow
            aboutAppRow
        }
    }
    
    // 通知设置行
    var notificationSettingRow: some View {
        settingRow(
            icon: "bell.fill",
            title: "通知设置",
            subtitle: "管理消息提醒",
            color: .orange
        )
    }
    
    // 隐私设置行
    var privacySettingRow: some View {
        settingRow(
            icon: "lock.fill",
            title: "隐私设置",
            subtitle: "保护个人信息",
            color: .blue
        )
    }
    
    // 帮助支持行
    var helpSupportRow: some View {
        settingRow(
            icon: "questionmark.circle.fill",
            title: "帮助与支持",
            subtitle: "获取使用帮助",
            color: .green
        )
    }
    
    // 关于应用行
    var aboutAppRow: some View {
        settingRow(
            icon: "info.circle.fill",
            title: "关于应用",
            subtitle: "版本信息",
            color: .purple
        )
    }
    
    // 设置行通用组件
    func settingRow(icon: String, title: String, subtitle: String, color: Color) -> some View {
        Button(action: {
            // 添加触觉反馈
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            // 根据不同设置项显示对应界面
            switch title {
            case "通知设置":
                showNotificationSettings = true
            case "隐私设置":
                showPrivacySettings = true
            case "帮助与支持":
                showHelpSupport = true
            case "关于应用":
                showAboutApp = true
            default:
                break
            }
        }) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    // 计算当前年龄
    var currentAge: Int {
        Calendar.current.component(.year, from: Date()) - userProfile.birthYear
    }
    
    // 启动动画
    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            withAnimation(.linear(duration: 0.016)) {
                animationPhase += 1
            }
        }
    }
    
    // 顶部导航栏覆盖层
    func topNavigationOverlay(geometry: GeometryProxy) -> some View {
        VStack {
            // 状态栏背景
            Rectangle()
                .fill(topNavigationGradient)
                .frame(height: geometry.safeAreaInsets.top + 60)
                .opacity(min(1.0, max(0.0, -scrollOffset / 100)))
            
            Spacer()
        }
        .ignoresSafeArea(edges: .top)
    }
    
    // 顶部导航渐变
    var topNavigationGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.black.opacity(0.8),
                Color.black.opacity(0.6),
                Color.clear
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // 玻璃效果编辑按钮
    var glassEditButton: some View {
        ZStack {
            // 光环效果
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.15),
                            .white.opacity(0.08),
                            .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 22
                    )
                )
                .frame(width: 44, height: 44)
                .scaleEffect(1.0 + sin(animationPhase * 0.04) * 0.06)
            
            // 按钮主体
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.25),
                            .white.opacity(0.15),
                            .white.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 38, height: 38)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.4),
                                    .white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .overlay(
                    // 高光效果
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    .white.opacity(0.3),
                                    .clear
                                ],
                                center: UnitPoint(x: 0.3, y: 0.3),
                                startRadius: 2,
                                endRadius: 12
                            )
                        )
                        .frame(width: 38, height: 38)
                )
            
            // 编辑图标
            Image(systemName: "pencil")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                .scaleEffect(1.0 + sin(animationPhase * 0.05) * 0.03)
        }
    }
    
    // 滚动偏移量监听
    struct ScrollOffsetPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
    
    // 用户资料数据模型
    struct UserProfile {
        var name: String
        var nickname: String
        var avatar: String
        var customAvatar: String?
        var birthYear: Int
        var location: String
        var familyRole: String
        var totalMemories: Int
        var favoriteMembers: [String]
        var joinDate: String
        var motto: String
        var planetColor: Color
    }
    
    // 编辑资料视图
    struct EditProfileView: View {
        @Binding var profile: UserProfile
        @Environment(\.presentationMode) var presentationMode
        
        @State private var editedProfile: UserProfile
        @State private var showingColorPicker = false
        @State private var showingAvatarPicker = false
        @State private var animationPhase: Double = 0
        @State private var selectedPhotoItem: PhotosPickerItem?
        @State private var selectedPhotoData: Data?
        @State private var showingPhotoPicker = false
        
        // 可选择的头像图标
        private let avatarOptions = [
            "person.circle.fill",
            "person.crop.circle.fill",
            "face.smiling.fill",
            "heart.circle.fill",
            "star.circle.fill",
            "moon.circle.fill",
            "sun.max.circle.fill",
            "leaf.circle.fill"
        ]
        
        // 可选择的星球颜色
        private let colorOptions: [Color] = [
            .blue, .purple, .pink, .red, .orange, .yellow, .green, .mint, .cyan, .indigo
        ]
        
        init(profile: Binding<UserProfile>) {
            self._profile = profile
            self._editedProfile = State(initialValue: profile.wrappedValue)
        }
        
        var body: some View {
            NavigationView {
                GeometryReader { geometry in
                    ZStack {
                        // 星空背景
                        starfieldBackground
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 24) {
                                // 头像编辑区域 - 增加顶部间距避免灵动岛遮挡
                                avatarEditSection
                                    .padding(.top, 60)
                                
                                // 基本信息编辑
                                basicInfoEditSection
                                
                                // 个人设置编辑
                                personalSettingsEditSection
                                
                                // 颜色主题选择
                                colorThemeEditSection
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 100)
                        }
                    }
                }
                .navigationTitle("编辑个人资料")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    },
                    trailing: Button("保存") {
                        saveProfile()
                    }
                        .foregroundColor(.yellow)
                        .fontWeight(.semibold)
                )
                .onAppear {
                    startAnimation()
                }
                .onChange(of: selectedPhotoItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            selectedPhotoData = data
                            // 保存照片到本地
                            savePhotoToLocal(data: data)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAvatarPicker) {
                avatarPickerView
            }
            .sheet(isPresented: $showingColorPicker) {
                colorPickerView
            }
        }
        
        // 星空背景
        var starfieldBackground: some View {
            ZStack {
                // 深空渐变背景
                deepSpaceGradient
                
                // 动态星云效果
                nebulaEffects
                
                // 星星效果 - 分层处理
                starFieldEffects
                
                // 流星效果 - 增强版
                meteorEffects
            }
        }
        
        // 深空渐变背景
        var deepSpaceGradient: some View {
            RadialGradient(
                colors: [
                    Color(red: 0.15, green: 0.1, blue: 0.4),
                    Color(red: 0.1, green: 0.05, blue: 0.25),
                    Color(red: 0.05, green: 0.02, blue: 0.15),
                    Color.black
                ],
                center: .center,
                startRadius: 50,
                endRadius: 600
            )
            .ignoresSafeArea()
        }
        
        // 动态星云效果
        var nebulaEffects: some View {
            ForEach(0..<5, id: \.self) { index in
                singleNebulaCloud(index: index)
            }
        }
        
        // 单个星云
        func singleNebulaCloud(index: Int) -> some View {
            Circle()
                .fill(nebulaGradient)
                .frame(width: 400, height: 400)
                .offset(
                    x: sin(animationPhase * 0.002 + Double(index)) * 100,
                    y: cos(animationPhase * 0.003 + Double(index) * 2) * 80
                )
                .opacity(0.3 + 0.2 * sin(animationPhase * 0.005 + Double(index)))
        }
        
        // 星云渐变
        var nebulaGradient: RadialGradient {
            RadialGradient(
                colors: [
                    Color.purple.opacity(0.1),
                    Color.blue.opacity(0.05),
                    .clear
                ],
                center: .center,
                startRadius: 50,
                endRadius: 200
            )
        }
        
        // 星星效果
        var starFieldEffects: some View {
            ForEach(0..<80, id: \.self) { index in
                singleStar(index: index)
            }
        }
        
        // 单颗星星
        func singleStar(index: Int) -> some View {
            Circle()
                .fill(.white)
                .frame(width: CGFloat.random(in: 1...3))
                .position(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height * 1.5)
                )
                .opacity(0.2 + 0.8 * sin(animationPhase * (0.01 + Double(index) * 0.001) + Double(index)))
                .scaleEffect(0.5 + 0.5 * sin(animationPhase * 0.02 + Double(index)))
        }
        
        // 流星效果
        var meteorEffects: some View {
            ForEach(0..<3, id: \.self) { index in
                singleMeteor(index: index)
            }
        }
        
        // 单颗流星
        func singleMeteor(index: Int) -> some View {
            RoundedRectangle(cornerRadius: 3)
                .fill(meteorGradient)
                .frame(width: 100, height: 3)
                .rotationEffect(.degrees(30))
                .offset(x: meteorXOffset(index: index), y: meteorYOffset(index: index))
                .opacity(meteorOpacity(index: index))
        }
        
        // 流星X偏移量
        private func meteorXOffset(index: Int) -> CGFloat {
            sin(animationPhase * (0.006 + Double(index) * 0.002) + Double(index) * 3.14) * 300
        }
        
        // 流星Y偏移量
        private func meteorYOffset(index: Int) -> CGFloat {
            cos(animationPhase * (0.004 + Double(index) * 0.001) + Double(index) * 2.1) * 200
        }
        
        // 流星透明度
        private func meteorOpacity(index: Int) -> Double {
            0.3 + 0.7 * sin(animationPhase * 0.008 + Double(index))
        }
        
        // 流星渐变
        var meteorGradient: LinearGradient {
            LinearGradient(
                colors: [
                    .white.opacity(0.9),
                    .blue.opacity(0.6),
                    .purple.opacity(0.3),
                    .clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        
        // 头像编辑区域
        var avatarEditSection: some View {
            VStack(spacing: 20) {
                avatarEditPreview
                avatarEditPrompt
                avatarEditOptions
            }
            .padding(20)
            .background(avatarEditBackground)
        }
        
        // 头像编辑预览
        var avatarEditPreview: some View {
            ZStack {
                avatarEditHalo
                avatarEditBody
                avatarEditContent
                avatarEditPencilIndicator
            }
        }
        
        // 头像编辑内容（图标或自定义图片）
        var avatarEditContent: some View {
            Group {
                if let photoData = selectedPhotoData,
                   let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.3), lineWidth: 2)
                        )
                } else if let customAvatar = editedProfile.customAvatar,
                          let uiImage = UIImage(contentsOfFile: customAvatar) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.3), lineWidth: 2)
                        )
                } else {
                    avatarEditIcon
                }
            }
        }
        
        // 头像编辑提示
        var avatarEditPrompt: some View {
            Text("选择头像")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
        
        // 头像编辑选项
        var avatarEditOptions: some View {
            HStack(spacing: 16) {
                // 从相册选择
                PhotosPicker(
                    selection: $selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text("相册")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(width: 60, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.blue.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.blue.opacity(0.5), lineWidth: 1)
                            )
                    )
                }
                
                // 选择图标
                Button {
                    showingAvatarPicker = true
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle")
                            .font(.title2)
                            .foregroundColor(.purple)
                        
                        Text("图标")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(width: 60, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.purple.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.purple.opacity(0.5), lineWidth: 1)
                            )
                    )
                }
                
                // 删除当前头像
                Button {
                    selectedPhotoData = nil
                    editedProfile.customAvatar = nil
                    editedProfile.avatar = "person.circle.fill"
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "trash")
                            .font(.title2)
                            .foregroundColor(.red)
                        
                        Text("删除")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(width: 60, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.red.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.red.opacity(0.5), lineWidth: 1)
                            )
                    )
                }
            }
        }
        
        // 头像编辑主体
        var avatarEditBody: some View {
            Circle()
                .fill(avatarEditMainGradient)
                .frame(width: 80, height: 80)
                .overlay(avatarEditBorder)
                .shadow(color: editedProfile.planetColor.opacity(0.6), radius: 15)
        }
        
        // 头像编辑铅笔指示器
        var avatarEditPencilIndicator: some View {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    avatarEditPencil
                }
            }
            .frame(width: 80, height: 80)
        }
        
        // 头像编辑光环
        var avatarEditHalo: some View {
            Circle()
                .fill(avatarEditHaloGradient)
                .frame(width: 120, height: 120)
                .scaleEffect(1.0 + sin(animationPhase * 0.04) * 0.03)
        }
        
        // 头像编辑光环渐变
        var avatarEditHaloGradient: RadialGradient {
            RadialGradient(
                colors: [
                    editedProfile.planetColor.opacity(0.4),
                    editedProfile.planetColor.opacity(0.2),
                    .clear
                ],
                center: .center,
                startRadius: 40,
                endRadius: 80
            )
        }
        
        // 头像编辑主体渐变
        var avatarEditMainGradient: RadialGradient {
            RadialGradient(
                colors: [
                    .white.opacity(0.4),
                    editedProfile.planetColor.opacity(0.9),
                    editedProfile.planetColor.opacity(0.7)
                ],
                center: UnitPoint(x: 0.3, y: 0.3),
                startRadius: 10,
                endRadius: 40
            )
        }
        
        // 头像编辑边框
        var avatarEditBorder: some View {
            Circle()
                .stroke(.white.opacity(0.6), lineWidth: 2)
        }
        
        // 头像编辑图标
        var avatarEditIcon: some View {
            Image(systemName: editedProfile.avatar)
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2)
        }
        
        // 头像编辑铅笔图标
        var avatarEditPencil: some View {
            Circle()
                .fill(.yellow)
                .frame(width: 24, height: 24)
                .overlay(
                    Image(systemName: "pencil")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black)
                )
                .offset(x: -5, y: -5)
        }
        
        // 头像编辑背景
        var avatarEditBackground: some View {
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        }
        
        // 基本信息编辑
        var basicInfoEditSection: some View {
            VStack(spacing: 16) {
                // 标题
                HStack {
                    Image(systemName: "person.text.rectangle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                    
                    Text("基本信息")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                VStack(spacing: 16) {
                    // 姓名
                    editFieldView(
                        title: "姓名",
                        icon: "person.fill",
                        text: $editedProfile.name,
                        placeholder: "请输入姓名"
                    )
                    
                    // 昵称
                    editFieldView(
                        title: "昵称",
                        icon: "heart.fill",
                        text: $editedProfile.nickname,
                        placeholder: "请输入昵称"
                    )
                    
                    // 出生年份
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.system(size: 14))
                                .foregroundColor(.orange)
                                .frame(width: 20)
                            
                            Text("出生年份")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Spacer()
                        }
                        
                        HStack {
                            Stepper(
                                value: $editedProfile.birthYear,
                                in: 1920...2024,
                                step: 1
                            ) {
                                Text("\(editedProfile.birthYear)年")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            }
                            .accentColor(.orange)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.white.opacity(0.1))
                        )
                    }
                    
                    // 位置
                    editFieldView(
                        title: "位置",
                        icon: "location.fill",
                        text: $editedProfile.location,
                        placeholder: "请输入所在城市"
                    )
                    
                    // 家庭角色
                    editFieldView(
                        title: "家庭角色",
                        icon: "house.fill",
                        text: $editedProfile.familyRole,
                        placeholder: "请输入家庭角色"
                    )
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        
        // 个人设置编辑
        var personalSettingsEditSection: some View {
            VStack(spacing: 16) {
                // 标题
                HStack {
                    Image(systemName: "quote.bubble.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.purple)
                    
                    Text("个人设置")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                VStack(spacing: 16) {
                    // 座右铭
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "quote.opening")
                                .font(.system(size: 14))
                                .foregroundColor(.purple)
                                .frame(width: 20)
                            
                            Text("座右铭")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Spacer()
                        }
                        
                        TextEditor(text: $editedProfile.motto)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .frame(minHeight: 80)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.white.opacity(0.9))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        
        // 颜色主题编辑
        var colorThemeEditSection: some View {
            VStack(spacing: 16) {
                // 标题
                HStack {
                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.yellow)
                    
                    Text("个人主题色")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                // 颜色选择网格
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(colorOptions, id: \.self) { color in
                        Button {
                            editedProfile.planetColor = color
                        } label: {
                            Circle()
                                .fill(color)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(.white, lineWidth: editedProfile.planetColor == color ? 3 : 0)
                                )
                                .scaleEffect(editedProfile.planetColor == color ? 1.1 : 1.0)
                                .shadow(color: color.opacity(0.6), radius: editedProfile.planetColor == color ? 8 : 4)
                        }
                        .animation(.spring(response: 0.3), value: editedProfile.planetColor)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        
        // 编辑字段视图
        func editFieldView(title: String, icon: String, text: Binding<String>, placeholder: String) -> some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                        .frame(width: 20)
                    
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                }
                
                TextField(placeholder, text: text)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            }
        }
        
        // 头像选择器
        var avatarPickerView: some View {
            NavigationView {
                VStack(spacing: 20) {
                    Text("选择头像")
                        .font(.system(size: 24, weight: .bold))
                        .padding(.top, 20)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(avatarOptions, id: \.self) { avatar in
                            Button {
                                editedProfile.avatar = avatar
                                showingAvatarPicker = false
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [
                                                    .white.opacity(0.4),
                                                    editedProfile.planetColor.opacity(0.9),
                                                    editedProfile.planetColor.opacity(0.7)
                                                ],
                                                center: UnitPoint(x: 0.3, y: 0.3),
                                                startRadius: 10,
                                                endRadius: 30
                                            )
                                        )
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Circle()
                                                .stroke(.white.opacity(0.6), lineWidth: 2)
                                        )
                                        .scaleEffect(editedProfile.avatar == avatar ? 1.1 : 1.0)
                                    
                                    Image(systemName: avatar)
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.3), radius: 2)
                                    
                                    if editedProfile.avatar == avatar {
                                        Circle()
                                            .stroke(.yellow, lineWidth: 3)
                                            .frame(width: 60, height: 60)
                                    }
                                }
                            }
                            .animation(.spring(response: 0.3), value: editedProfile.avatar)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
                .navigationBarItems(
                    trailing: Button("完成") {
                        showingAvatarPicker = false
                    }
                )
            }
        }
        
        // 颜色选择器
        var colorPickerView: some View {
            NavigationView {
                VStack(spacing: 30) {
                    Text("选择主题色")
                        .font(.system(size: 24, weight: .bold))
                        .padding(.top, 20)
                    
                    // 预览效果
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        .white.opacity(0.4),
                                        editedProfile.planetColor.opacity(0.9),
                                        editedProfile.planetColor.opacity(0.7)
                                    ],
                                    center: UnitPoint(x: 0.3, y: 0.3),
                                    startRadius: 20,
                                    endRadius: 60
                                )
                            )
                            .frame(width: 120, height: 120)
                            .overlay(
                                Circle()
                                    .stroke(.white.opacity(0.6), lineWidth: 3)
                            )
                            .shadow(color: editedProfile.planetColor.opacity(0.6), radius: 20)
                        
                        Image(systemName: editedProfile.avatar)
                            .font(.system(size: 40, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2)
                    }
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(colorOptions, id: \.self) { color in
                            Button {
                                editedProfile.planetColor = color
                            } label: {
                                Circle()
                                    .fill(color)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(.white, lineWidth: editedProfile.planetColor == color ? 3 : 0)
                                    )
                                    .scaleEffect(editedProfile.planetColor == color ? 1.2 : 1.0)
                                    .shadow(color: color.opacity(0.6), radius: editedProfile.planetColor == color ? 10 : 6)
                            }
                            .animation(.spring(response: 0.3), value: editedProfile.planetColor)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .navigationBarItems(
                    trailing: Button("完成") {
                        showingColorPicker = false
                    }
                )
            }
        }
        
        // 保存照片到本地
        private func savePhotoToLocal(data: Data) {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = "avatar_\(UUID().uuidString).jpg"
            let fileURL = documentsPath.appendingPathComponent(fileName)
            
            do {
                try data.write(to: fileURL)
                editedProfile.customAvatar = fileURL.path
            } catch {
                print("保存照片失败: \(error)")
            }
        }
        
        // 保存资料
        private func saveProfile() {
            // 如果有新选择的照片，使用新照片
            if selectedPhotoData != nil {
                // 照片已经在savePhotoToLocal中保存了
            }
            
            withAnimation(.spring()) {
                profile = editedProfile
            }
            presentationMode.wrappedValue.dismiss()
        }
        
        // 启动动画
        private func startAnimation() {
            Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
                withAnimation(.linear(duration: 0.016)) {
                    animationPhase += 1
                }
            }
        }
    }
    
    // 自定义按钮样式
    struct ScaleButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }
    
    // 头像详情弹窗
    struct AvatarDetailView: View {
        let profile: UserProfile
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
            NavigationView {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    VStack(spacing: 30) {
                        Spacer()
                        
                        // 大头像显示
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            profile.planetColor.opacity(0.3),
                                            profile.planetColor.opacity(0.1),
                                            .clear
                                        ],
                                        center: .center,
                                        startRadius: 100,
                                        endRadius: 200
                                    )
                                )
                                .frame(width: 300, height: 300)
                            
                            if let customAvatar = profile.customAvatar,
                               let uiImage = UIImage(contentsOfFile: customAvatar) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 200, height: 200)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(.white.opacity(0.3), lineWidth: 3)
                                    )
                            } else {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                .white.opacity(0.5),
                                                profile.planetColor.opacity(0.95),
                                                profile.planetColor.opacity(0.8)
                                            ],
                                            center: UnitPoint(x: 0.3, y: 0.3),
                                            startRadius: 30,
                                            endRadius: 100
                                        )
                                    )
                                    .frame(width: 200, height: 200)
                                    .overlay(
                                        Circle()
                                            .stroke(.white.opacity(0.8), lineWidth: 3)
                                    )
                                    .overlay(
                                        Image(systemName: profile.avatar)
                                            .font(.system(size: 80, weight: .medium))
                                            .foregroundColor(.white)
                                            .shadow(color: .black.opacity(0.4), radius: 5)
                                    )
                            }
                        }
                        
                        // 用户信息
                        VStack(spacing: 12) {
                            Text(profile.name)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            if !profile.nickname.isEmpty && profile.nickname != profile.name {
                                Text("「\(profile.nickname)」")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Text(profile.familyRole)
                                .font(.system(size: 16))
                                .foregroundColor(profile.planetColor)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(profile.planetColor.opacity(0.2))
                                )
                        }
                        
                        Spacer()
                    }
                }
                .navigationTitle("个人头像")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    trailing: Button("关闭") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                )
            }
        }
    }
    
    // 记忆统计详情弹窗
    struct MemoryStatisticsDetailView: View {
        let statType: StatisticType
        let profile: UserProfile
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
            NavigationView {
                ZStack {
                    // 星空背景
                    RadialGradient(
                        colors: [
                            Color(red: 0.15, green: 0.1, blue: 0.4),
                            Color(red: 0.1, green: 0.05, blue: 0.25),
                            Color.black
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 600
                    )
                    .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // 统计图标和标题
                            VStack(spacing: 16) {
                                Image(systemName: statisticIcon)
                                    .font(.system(size: 60))
                                    .foregroundColor(statisticColor)
                                
                                Text(statisticTitle)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text(statisticSubtitle)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.top, 40)
                            
                            // 详细数据
                            statisticDetailContent
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
                .navigationTitle(statisticTitle)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    trailing: Button("关闭") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                )
            }
        }
        
        var statisticIcon: String {
            switch statType {
            case .favoriteMembers: return "heart.fill"
            case .newMemories: return "plus.circle.fill"
            case .highlights: return "star.fill"
            case .totalMemories: return "photo.fill"
            }
        }
        
        var statisticColor: Color {
            switch statType {
            case .favoriteMembers: return .pink
            case .newMemories: return .green
            case .highlights: return .yellow
            case .totalMemories: return .blue
            }
        }
        
        var statisticTitle: String {
            switch statType {
            case .favoriteMembers: return "最爱成员"
            case .newMemories: return "新增记忆"
            case .highlights: return "精彩记忆"
            case .totalMemories: return "记忆总数"
            }
        }
        
        var statisticSubtitle: String {
            switch statType {
            case .favoriteMembers: return "记录最多的家庭成员"
            case .newMemories: return "最近添加的美好回忆"
            case .highlights: return "被标记为精彩的特殊时刻"
            case .totalMemories: return "累计记录的所有珍贵回忆"
            }
        }
        
        var statisticDetailContent: some View {
            VStack(spacing: 20) {
                switch statType {
                case .favoriteMembers:
                    ForEach(profile.favoriteMembers, id: \.self) { member in
                        memberDetailCard(name: member)
                    }
                case .newMemories:
                    // 新增记忆假数据
                    ForEach(newMemoriesData, id: \.id) { memory in
                        newMemoryCard(memory: memory)
                    }
                case .highlights:
                    // 精彩记忆假数据
                    ForEach(highlightMemoriesData, id: \.id) { memory in
                        highlightMemoryCard(memory: memory)
                    }
                case .totalMemories:
                    Text("累计记录 \(profile.totalMemories) 条珍贵回忆")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white.opacity(0.1))
                        )
                }
            }
        }
        
        // 新增记忆假数据
        private var newMemoriesData: [MockMemory] {
            [
                MockMemory(
                    id: 1,
                    title: "妈妈的生日派对",
                    content: "今天是妈妈的生日，全家人一起为她庆祝，妈妈很开心",
                    date: "今天",
                    mood: "😊",
                    participants: ["妈妈", "爸爸", "我"],
                    location: "家里",
                    images: ["birthday_cake", "family_celebration", "mom_smile"]
                ),
                MockMemory(
                    id: 2,
                    title: "周末郊游",
                    content: "和家人一起去公园野餐，天气很好，大家都很开心",
                    date: "昨天",
                    mood: "🤩",
                    participants: ["全家人"],
                    location: "中山公园",
                    images: ["park_picnic", "family_outdoor", "sunny_day", "picnic_basket"]
                ),
                MockMemory(
                    id: 3,
                    title: "爷爷讲故事",
                    content: "爷爷给我们讲了他小时候的故事，很有趣很温馨",
                    date: "3天前",
                    mood: "🥰",
                    participants: ["爷爷", "我", "妹妹"],
                    location: "客厅",
                    images: ["grandpa_story", "children_listening"]
                ),
                MockMemory(
                    id: 4,
                    title: "家庭电影夜",
                    content: "全家人一起看电影，吃爆米花，很温馨的夜晚",
                    date: "1周前",
                    mood: "😌",
                    participants: ["全家人"],
                    location: "客厅",
                    images: ["movie_night", "popcorn", "family_cozy", "living_room"]
                ),
                MockMemory(
                    id: 5,
                    title: "奶奶的拿手菜",
                    content: "奶奶做了她的拿手菜红烧肉，全家人都赞不绝口",
                    date: "1周前",
                    mood: "🙏",
                    participants: ["奶奶", "全家人"],
                    location: "餐厅",
                    images: ["cooking_grandma", "delicious_food", "family_dinner"]
                )
            ]
        }
        
        // 精彩记忆假数据
        private var highlightMemoriesData: [MockMemory] {
            [
                MockMemory(
                    id: 11,
                    title: "爸爸的升职庆祝",
                    content: "爸爸升职了，全家人一起庆祝这个重要时刻",
                    date: "2周前",
                    mood: "😎",
                    participants: ["爸爸", "全家人"],
                    location: "高级餐厅",
                    images: ["promotion_celebration", "fancy_restaurant", "dad_proud", "family_toast"]
                ),
                MockMemory(
                    id: 12,
                    title: "妹妹第一次骑自行车",
                    content: "妹妹学会了骑自行车，我们在公园里欢呼庆祝",
                    date: "1个月前",
                    mood: "🤩",
                    participants: ["妹妹", "爸爸", "我"],
                    location: "社区公园",
                    images: ["first_bike_ride", "sister_cycling", "park_celebration", "proud_moment", "bike_learning"]
                ),
                MockMemory(
                    id: 13,
                    title: "全家旅游",
                    content: "暑假全家一起去海边旅游，看日出日落，留下美好回忆",
                    date: "3个月前",
                    mood: "😊",
                    participants: ["全家人"],
                    location: "三亚",
                    images: ["beach_sunset", "family_beach", "ocean_view", "vacation_fun", "seaside_walk", "beach_photo"]
                ),
                MockMemory(
                    id: 14,
                    title: "爷爷奶奶金婚纪念",
                    content: "爷爷奶奶结婚50周年，全家人聚在一起庆祝",
                    date: "6个月前",
                    mood: "🥰",
                    participants: ["全家人", "亲戚"],
                    location: "老家",
                    images: ["golden_anniversary", "grandparents_love", "family_gathering", "celebration_moment"]
                ),
                MockMemory(
                    id: 15,
                    title: "新年团圆饭",
                    content: "除夕夜全家人一起包饺子，吃团圆饭，看春晚",
                    date: "1年前",
                    mood: "🙏",
                    participants: ["全家人"],
                    location: "老家",
                    images: ["new_year_dinner", "making_dumplings", "spring_festival", "family_reunion", "festive_table"]
                )
            ]
        }
        
        // 新增记忆卡片
        func newMemoryCard(memory: MockMemory) -> some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(memory.mood)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(memory.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(memory.date)
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                }
                
                Text(memory.content)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
                
                // 瀑布流图片展示
                if !memory.images.isEmpty {
                    WaterfallImageGrid(images: memory.images, accentColor: .green)
                }
                
                HStack {
                    Label(memory.location, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                    
                    Text(memory.participants.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(1)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.green.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        
        // 精彩记忆卡片
        func highlightMemoryCard(memory: MockMemory) -> some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(memory.mood)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(memory.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(memory.date)
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.title3)
                }
                
                Text(memory.content)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
                
                // 瀑布流图片展示
                if !memory.images.isEmpty {
                    WaterfallImageGrid(images: memory.images, accentColor: .yellow)
                }
                
                HStack {
                    Label(memory.location, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                    
                    Text(memory.participants.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(1)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.yellow.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        
        // 瀑布流图片网格组件
        struct WaterfallImageGrid: View {
            let images: [String]
            let accentColor: Color
            
            @State private var currentIndices: [Int] = []
            @State private var timer: Timer?
            
            var body: some View {
                VStack(spacing: 12) {
                    if images.count == 1 {
                        // 单张图片轮播 - 居中显示
                        HStack {
                            Spacer()
                            CarouselImageView(
                                images: images,
                                accentColor: accentColor,
                                height: 140,
                                cornerRadius: 12,
                                fontSize: 28
                            )
                            .frame(maxWidth: 280)
                            Spacer()
                        }
                    } else if images.count == 2 {
                        // 两张图片优雅横向排列
                        HStack(spacing: 10) {
                            CarouselImageView(
                                images: [images[0]],
                                accentColor: accentColor,
                                height: 100,
                                cornerRadius: 10,
                                fontSize: 20
                            )
                            .frame(maxWidth: .infinity)
                            
                            CarouselImageView(
                                images: [images[1]],
                                accentColor: accentColor,
                                height: 100,
                                cornerRadius: 10,
                                fontSize: 20
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 4)
                    } else if images.count == 3 {
                        // 三张图片，优化布局比例
                        HStack(spacing: 10) {
                            // 主图片 - 占据更多空间
                            CarouselImageView(
                                images: [images[0]],
                                accentColor: accentColor,
                                height: 140,
                                cornerRadius: 12,
                                fontSize: 24
                            )
                            .frame(maxWidth: .infinity, maxHeight: 140)
                            
                            // 副图片垂直排列
                            VStack(spacing: 8) {
                                CarouselImageView(
                                    images: [images[1]],
                                    accentColor: accentColor,
                                    height: 66,
                                    cornerRadius: 10,
                                    fontSize: 18
                                )
                                
                                CarouselImageView(
                                    images: [images[2]],
                                    accentColor: accentColor,
                                    height: 66,
                                    cornerRadius: 10,
                                    fontSize: 18
                                )
                            }
                            .frame(maxWidth: .infinity * 0.75)
                        }
                        .padding(.horizontal, 4)
                    } else if images.count == 4 {
                        // 四张图片，2x2对称网格
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                CarouselImageView(
                                    images: [images[0]],
                                    accentColor: accentColor,
                                    height: 85,
                                    cornerRadius: 10,
                                    fontSize: 18
                                )
                                .frame(maxWidth: .infinity)
                                
                                CarouselImageView(
                                    images: [images[1]],
                                    accentColor: accentColor,
                                    height: 85,
                                    cornerRadius: 10,
                                    fontSize: 18
                                )
                                .frame(maxWidth: .infinity)
                            }
                            
                            HStack(spacing: 8) {
                                CarouselImageView(
                                    images: [images[2]],
                                    accentColor: accentColor,
                                    height: 85,
                                    cornerRadius: 10,
                                    fontSize: 18
                                )
                                .frame(maxWidth: .infinity)
                                
                                CarouselImageView(
                                    images: [images[3]],
                                    accentColor: accentColor,
                                    height: 85,
                                    cornerRadius: 10,
                                    fontSize: 18
                                )
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 4)
                    } else {
                        // 五张及以上，优化瀑布流布局
                        VStack(spacing: 10) {
                            // 第一行：两张主图
                            HStack(spacing: 8) {
                                CarouselImageView(
                                    images: Array(images.prefix(2)),
                                    accentColor: accentColor,
                                    height: 90,
                                    cornerRadius: 10,
                                    fontSize: 20
                                )
                                .frame(maxWidth: .infinity)
                                
                                CarouselImageView(
                                    images: Array(images.dropFirst(2).prefix(2)),
                                    accentColor: accentColor,
                                    height: 90,
                                    cornerRadius: 10,
                                    fontSize: 20
                                )
                                .frame(maxWidth: .infinity)
                            }
                            
                            // 第二行：一张中图和两张小图
                            HStack(spacing: 8) {
                                CarouselImageView(
                                    images: Array(images.dropFirst(4).prefix(2)),
                                    accentColor: accentColor,
                                    height: 75,
                                    cornerRadius: 10,
                                    fontSize: 18
                                )
                                .frame(maxWidth: .infinity)
                                
                                VStack(spacing: 6) {
                                    if images.count > 6 {
                                        CarouselImageView(
                                            images: Array(images.dropFirst(6).prefix(3)),
                                            accentColor: accentColor,
                                            height: 34,
                                            cornerRadius: 8,
                                            fontSize: 14
                                        )
                                    }
                                    
                                    if images.count > 9 {
                                        CarouselImageView(
                                            images: Array(images.dropFirst(9)),
                                            accentColor: accentColor,
                                            height: 35,
                                            cornerRadius: 8,
                                            fontSize: 14,
                                            showCounter: true,
                                            totalCount: max(0, images.count - 9)
                                        )
                                    } else if images.count > 6 {
                                        CarouselImageView(
                                            images: Array(images.dropFirst(6)),
                                            accentColor: accentColor,
                                            height: 35,
                                            cornerRadius: 8,
                                            fontSize: 14
                                        )
                                    }
                                }
                                .frame(maxWidth: .infinity * 0.7)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
            }
        }
        
        // 轮播图片视图组件 - 立体相框效果
        struct CarouselImageView: View {
            let images: [String]
            let accentColor: Color
            let height: CGFloat
            let cornerRadius: CGFloat
            let fontSize: CGFloat
            let showCounter: Bool
            let totalCount: Int
            
            @State private var currentIndex: Int = 0
            @State private var timer: Timer?
            
            init(images: [String], accentColor: Color, height: CGFloat, cornerRadius: CGFloat, fontSize: CGFloat, showCounter: Bool = false, totalCount: Int = 0) {
                self.images = images.filter { !$0.isEmpty }
                self.accentColor = accentColor
                self.height = height
                self.cornerRadius = cornerRadius
                self.fontSize = fontSize
                self.showCounter = showCounter
                self.totalCount = totalCount
            }
            
            var body: some View {
                ZStack {
                    if !images.isEmpty {
                        // 立体相框背景层
                        RoundedRectangle(cornerRadius: cornerRadius + 2)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.15),
                                        Color.black.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(
                                color: accentColor.opacity(0.3),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                            .overlay(
                                // 内阴影效果
                                RoundedRectangle(cornerRadius: cornerRadius + 2)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.4),
                                                Color.clear,
                                                Color.black.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                        
                        // 主要图片内容区域
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        accentColor.opacity(0.25),
                                        accentColor.opacity(0.1),
                                        accentColor.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                // 图片内容
                                VStack(spacing: height > 80 ? 10 : 4) {
                                    // 图标
                                    Image(systemName: getSystemIcon(for: currentImage))
                                        .font(.system(size: fontSize, weight: .medium))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [accentColor, accentColor.opacity(0.7)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                                        .animation(.easeInOut(duration: 0.3), value: currentIndex)
                                    
                                    // 文字标题
                                    if height > 80 {
                                        Text(getImageTitle(for: currentImage))
                                            .font(.system(size: max(10, fontSize * 0.4), weight: .medium))
                                            .foregroundColor(.white.opacity(0.9))
                                            .multilineTextAlignment(.center)
                                            .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                                            .animation(.easeInOut(duration: 0.3), value: currentIndex)
                                    } else if height > 40 {
                                        Text(getImageTitle(for: currentImage))
                                            .font(.system(size: max(8, fontSize * 0.35), weight: .medium))
                                            .foregroundColor(.white.opacity(0.8))
                                            .lineLimit(2)
                                            .multilineTextAlignment(.center)
                                            .shadow(color: .black.opacity(0.4), radius: 1, x: 0, y: 1)
                                            .animation(.easeInOut(duration: 0.3), value: currentIndex)
                                    }
                                }
                                .padding(height > 80 ? 12 : 6)
                            )
                            .overlay(
                                // 内边框
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                accentColor.opacity(0.6),
                                                accentColor.opacity(0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .padding(2) // 为外层相框留出空间
                        
                        // 数量指示器
                        if images.count > 1 || showCounter {
                            VStack {
                                HStack {
                                    Spacer()
                                    Text(showCounter ? "+\(totalCount)" : "\(currentIndex + 1)/\(images.count)")
                                        .font(.system(size: max(8, height * 0.12), weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(
                                            Capsule()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [
                                                            .black.opacity(0.8),
                                                            .black.opacity(0.6)
                                                        ],
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                                )
                                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                        )
                                        .padding(.top, 6)
                                        .padding(.trailing, 8)
                                }
                                Spacer()
                            }
                        }
                        
                        // 光泽效果
                        if height > 60 {
                            VStack {
                                HStack {
                                    RoundedRectangle(cornerRadius: cornerRadius / 2)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    .white.opacity(0.3),
                                                    .clear
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: min(60, height * 0.8), height: 2)
                                        .padding(.leading, 8)
                                        .padding(.top, 8)
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                        
                    } else {
                        // 空状态
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.gray.opacity(0.1))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                                    .font(.system(size: fontSize))
                            )
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                }
                .frame(height: height)
                .onAppear {
                    startCarousel()
                }
                .onDisappear {
                    stopCarousel()
                }
            }
            
            private var currentImage: String {
                guard !images.isEmpty else { return "" }
                return images[currentIndex % images.count]
            }
            
            private func startCarousel() {
                guard images.count > 1 else { return }
                
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentIndex = (currentIndex + 1) % images.count
                    }
                }
            }
            
            private func stopCarousel() {
                timer?.invalidate()
                timer = nil
            }
            
            private func getSystemIcon(for imageName: String) -> String {
                switch imageName {
                case "birthday_cake": return "birthday.cake"
                case "family_celebration": return "party.popper"
                case "mom_smile": return "heart.circle"
                case "park_picnic": return "leaf"
                case "family_outdoor": return "figure.walk"
                case "sunny_day": return "sun.max"
                case "picnic_basket": return "basket"
                case "grandpa_story": return "book"
                case "children_listening": return "ear"
                case "movie_night": return "tv"
                case "popcorn": return "popcorn"
                case "family_cozy": return "house"
                case "living_room": return "sofa"
                case "cooking_grandma": return "frying.pan"
                case "delicious_food": return "fork.knife"
                case "family_dinner": return "table.furniture"
                case "promotion_celebration": return "trophy"
                case "fancy_restaurant": return "wineglass"
                case "dad_proud": return "medal"
                case "family_toast": return "cup.and.saucer"
                case "first_bike_ride": return "bicycle"
                case "sister_cycling": return "figure.cycling"
                case "park_celebration": return "hands.clap"
                case "proud_moment": return "star.circle"
                case "bike_learning": return "graduationcap"
                case "beach_sunset": return "sunset"
                case "family_beach": return "beach.umbrella"
                case "ocean_view": return "water.waves"
                case "vacation_fun": return "airplane"
                case "seaside_walk": return "figure.walk.circle"
                case "beach_photo": return "camera"
                case "golden_anniversary": return "heart.circle.fill"
                case "grandparents_love": return "hands.and.sparkles"
                case "family_gathering": return "person.3"
                case "celebration_moment": return "sparkles"
                case "new_year_dinner": return "tray.and.arrow.down"
                case "making_dumplings": return "hands.and.sparkles"
                case "spring_festival": return "fireworks"
                case "family_reunion": return "house.and.flag"
                case "festive_table": return "table.furniture.fill"
                default: return "photo"
                }
            }
            
            private func getImageTitle(for imageName: String) -> String {
                switch imageName {
                case "birthday_cake": return "生日蛋糕"
                case "family_celebration": return "家庭庆祝"
                case "mom_smile": return "妈妈笑容"
                case "park_picnic": return "公园野餐"
                case "family_outdoor": return "户外活动"
                case "sunny_day": return "阳光明媚"
                case "picnic_basket": return "野餐篮"
                case "grandpa_story": return "爷爷讲故事"
                case "children_listening": return "认真聆听"
                case "movie_night": return "电影之夜"
                case "popcorn": return "爆米花"
                case "family_cozy": return "温馨时光"
                case "living_room": return "客厅"
                case "cooking_grandma": return "奶奶下厨"
                case "delicious_food": return "美味佳肴"
                case "family_dinner": return "家庭聚餐"
                case "promotion_celebration": return "升职庆祝"
                case "fancy_restaurant": return "高档餐厅"
                case "dad_proud": return "爸爸自豪"
                case "family_toast": return "家人干杯"
                case "first_bike_ride": return "首次骑车"
                case "sister_cycling": return "妹妹骑车"
                case "park_celebration": return "公园庆祝"
                case "proud_moment": return "骄傲时刻"
                case "bike_learning": return "学习骑车"
                case "beach_sunset": return "海滩日落"
                case "family_beach": return "海滩全家福"
                case "ocean_view": return "海景"
                case "vacation_fun": return "度假乐趣"
                case "seaside_walk": return "海边漫步"
                case "beach_photo": return "海滩合影"
                case "golden_anniversary": return "金婚纪念"
                case "grandparents_love": return "爷爷奶奶"
                case "family_gathering": return "家庭聚会"
                case "celebration_moment": return "庆祝时刻"
                case "new_year_dinner": return "年夜饭"
                case "making_dumplings": return "包饺子"
                case "spring_festival": return "春节庆祝"
                case "family_reunion": return "家庭团聚"
                case "festive_table": return "节日餐桌"
                default: return "图片"
                }
            }
        }
        
        // 模拟记忆数据结构
        struct MockMemory {
            let id: Int
            let title: String
            let content: String
            let date: String
            let mood: String
            let participants: [String]
            let location: String
            let images: [String] // 添加图片数组
        }
        
        func memberDetailCard(name: String) -> some View {
            HStack(spacing: 16) {
                Circle()
                    .fill(statisticColor.opacity(0.8))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.title2)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("记录了 \(Int.random(in: 15...45)) 条相关回忆")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    // 添加记忆视图 - 升级版
    struct AddMemoryView: View {
        @Environment(\.presentationMode) var presentationMode
        @State private var memoryTitle = ""
        @State private var memoryContent = ""
        @State private var selectedMembers: Set<String> = []
        @State private var selectedDate = Date()
        @State private var selectedPhotos: [PhotosPickerItem] = []
        @State private var selectedImages: [UIImage] = []
        @State private var showPhotoPicker = false
        @State private var showCamera = false
        @State private var animationPhase: Double = 0
        @State private var showSaveAnimation = false
        @State private var memoryLocation = ""
        @State private var memoryMood: MoodType = .happy
        @State private var isRecording = false
        @State private var showLocationPicker = false
        
        // AI语音输入相关状态
        @State private var isAIReady = true
        @State private var isProcessingVoice = false
        @State private var voiceTranscription = ""
        @State private var aiOptimizedContent = ""
        @State private var aiSuggestions: [String] = []
        @State private var recordingDuration: TimeInterval = 0
        @State private var isPaused = false
        @State private var recordingTimer: Timer?
        
        enum MoodType: String, CaseIterable {
            case happy = "😊"
            case excited = "🤩" 
            case peaceful = "😌"
            case nostalgic = "🥰"
            case proud = "😎"
            case surprised = "😲"
            case grateful = "🙏"
            case thoughtful = "🤔"
            
            var name: String {
                switch self {
                case .happy: return "开心"
                case .excited: return "兴奋"
                case .peaceful: return "平静"
                case .nostalgic: return "怀念"
                case .proud: return "自豪"
                case .surprised: return "惊喜"
                case .grateful: return "感激"
                case .thoughtful: return "深思"
                }
            }
            
            var color: Color {
                switch self {
                case .happy: return .yellow
                case .excited: return .orange
                case .peaceful: return .blue
                case .nostalgic: return .pink
                case .proud: return .purple
                case .surprised: return .red
                case .grateful: return .green
                case .thoughtful: return .indigo
                }
            }
        }
        
        private let familyMembers = ["妈妈", "爸爸", "爷爷", "奶奶", "妹妹", "弟弟"]
        
        var body: some View {
            NavigationView {
                ZStack {
                    // 增强星空背景
                    enhancedStarfieldBackground
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 32) {
                            // 顶部装饰
                            topDecorationView
                            
                            // 标题输入区域
                            modernTitleSection
                            
                            // 图片上传区域
                            photoUploadSection
                            
                            // 内容输入区域
                            modernContentSection
                            
                            // AI语音输入区域
                            aiVoiceInputSection
                            
                            // 心情选择
                            moodSelectionSection
                            
                            // 地点输入
                            locationSection
                            
                            // 家庭成员选择
                            modernMemberSection
                            
                            // 日期选择
                            modernDateSection
                            
                            // 底部安全间距
                            Color.clear.frame(height: 60)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    
                    // 保存动画覆盖层
                    if showSaveAnimation {
                        saveAnimationOverlay
                    }
                }
                .navigationTitle("记录美好时光")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                presentationMode.wrappedValue.dismiss()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                Text("取消")
                                    .font(.body)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.3))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                showSaveAnimation = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                saveMemory()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "heart.fill")
                                    .font(.title3)
                                Text("保存")
                                    .font(.body.weight(.semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.pink, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: .pink.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                        }
                        .disabled(memoryTitle.isEmpty)
                        .opacity(memoryTitle.isEmpty ? 0.5 : 1.0)
                    }
                }
            }
            .onAppear {
                startAnimations()
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotos, maxSelectionCount: 10, matching: .images)
            .onChange(of: selectedPhotos) { newItems in
                loadSelectedImages(from: newItems)
            }
        }
        
        // 顶部装饰视图
        var topDecorationView: some View {
            VStack(spacing: 16) {
                // 动态图标
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.pink.opacity(0.6), .purple.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 50
                            )
                        )
                        .frame(width: 100, height: 100)
                        .scaleEffect(1.0 + sin(animationPhase) * 0.1)
                    
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .pink.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .rotation3DEffect(
                            .degrees(sin(animationPhase * 0.5) * 10),
                            axis: (x: 1, y: 1, z: 0)
                        )
                }
                
                Text("分享这个特别的时刻")
                    .font(.title3.weight(.medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
        }
        
        // 现代化标题输入区域
        var modernTitleSection: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.title3)
                    Text("记忆标题")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                    Spacer()
                }
                
                TextField("输入这段记忆的标题", text: $memoryTitle)
                    .font(.body)
                    .padding(16)
                    .background(titleFieldBackground)
                    .foregroundColor(.primary)
            }
        }
        
        // 标题字段背景
        private var titleFieldBackground: some View {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(titleFieldStroke)
        }
        
        // 标题字段边框
        private var titleFieldStroke: some View {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.3), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        
        // 图片上传区域
        var photoUploadSection: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "photo.stack.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                    Text("添加照片")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(selectedImages.count)/10")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                // 图片网格
                if selectedImages.isEmpty {
                    emptyPhotoState
                } else {
                    photoGridView
                }
            }
        }
        
        // 空状态视图
        private var emptyPhotoState: some View {
            Button {
                showPhotoPicker = true
            } label: {
                VStack(spacing: 12) {
                    emptyPhotoPlaceholder
                }
            }
        }
        
        // 空状态占位符
        private var emptyPhotoPlaceholder: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .frame(height: 120)
                    .overlay(emptyPhotoStroke)
                
                VStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                    Text("添加照片")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        
        // 空状态边框
        private var emptyPhotoStroke: some View {
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [.blue.opacity(0.5), .purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                )
        }
        
        // 图片网格视图
        private var photoGridView: some View {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                    photoGridItem(image: image, index: index)
                }
                
                // 添加更多按钮
                if selectedImages.count < 10 {
                    addMorePhotosButton
                }
            }
        }
        
        // 图片网格项
        private func photoGridItem(image: UIImage, index: Int) -> some View {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 80)
                    .clipped()
                    .cornerRadius(12)
                    .overlay(photoItemStroke)
                
                // 删除按钮
                photoDeleteButton(index: index)
            }
        }
        
        // 图片项边框
        private var photoItemStroke: some View {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        }
        
        // 删除按钮
        private func photoDeleteButton(index: Int) -> some View {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    selectedImages.remove(at: index)
                    selectedPhotos.remove(at: index)
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.red)
                    .background(Color.white, in: Circle())
            }
            .offset(x: 6, y: -6)
        }
        
        // 添加更多照片按钮
        private var addMorePhotosButton: some View {
            Button {
                showPhotoPicker = true
            } label: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .frame(height: 80)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.blue)
                    )
                    .overlay(addMorePhotosStroke)
            }
        }
        
        // 添加更多照片按钮边框
        private var addMorePhotosStroke: some View {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4, 2]))
        }
        
        // 现代化内容输入区域
        var modernContentSection: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "text.quote")
                        .foregroundColor(.green)
                        .font(.title3)
                    Text("记忆内容")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                    Spacer()
                }
                
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .frame(minHeight: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.3), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                    
                    TextEditor(text: $memoryContent)
                        .font(.body)
                        .padding(16)
                        .background(Color.clear)
                        .foregroundColor(.primary)
                        .scrollContentBackground(.hidden)
                    
                    if memoryContent.isEmpty {
                        Text("记录下这个美好的时刻...")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(16)
                            .allowsHitTesting(false)
                    }
                }
            }
        }
        
        // AI语音输入区域
        var aiVoiceInputSection: some View {
            VStack(alignment: .leading, spacing: 20) {
                // 标题区域
                aiVoiceHeaderView
                
                // 主要语音输入界面
                aiVoiceMainInterface
                
                // AI处理状态和建议
                if isProcessingVoice || !voiceTranscription.isEmpty {
                    aiProcessingStatusView
                }
                
                // 智能建议区域
                if !aiSuggestions.isEmpty {
                    aiSuggestionsView
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.1, green: 0.05, blue: 0.2).opacity(0.8),
                                Color(red: 0.05, green: 0.02, blue: 0.15).opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .pink.opacity(0.6),
                                        .purple.opacity(0.4),
                                        .blue.opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: .pink.opacity(0.3), radius: 12, x: 0, y: 6)
            )
        }
        
        // AI语音标题区域
        var aiVoiceHeaderView: some View {
            HStack(spacing: 12) {
                // 动态AI图标
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    .pink.opacity(0.6),
                                    .purple.opacity(0.4),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 5,
                                endRadius: 20
                            )
                        )
                        .frame(width: 40, height: 40)
                        .scaleEffect(1.0 + sin(animationPhase * 2) * 0.1)
                    
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))
                        .scaleEffect(1.0 + sin(animationPhase * 1.5) * 0.05)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI智能语音助手")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("说出你的回忆，AI帮你记录美好")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // AI状态指示器
                aiStatusIndicator
            }
        }
        
        // AI状态指示器
        var aiStatusIndicator: some View {
            HStack(spacing: 6) {
                Circle()
                    .fill(isAIReady ? .green : .orange)
                    .frame(width: 8, height: 8)
                    .scaleEffect(isAIReady ? 1.0 + sin(animationPhase * 3) * 0.3 : 1.0)
                
                Text(isAIReady ? "就绪" : "准备中")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        
        // 主要语音输入界面
        var aiVoiceMainInterface: some View {
            VStack(spacing: 20) {
                // 语音波形可视化
                voiceWaveformView
                
                // 录音控制按钮
                voiceRecordingControls
                
                // 录音时长和状态
                if isRecording || recordingDuration > 0 {
                    recordingStatusView
                }
            }
        }
        
        // 语音波形可视化
        var voiceWaveformView: some View {
            VStack(spacing: 12) {
                // 波形显示
                HStack(spacing: 3) {
                    ForEach(0..<20, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                LinearGradient(
                                    colors: [.pink, .purple, .blue],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(width: 4)
                            .frame(height: isRecording ? 
                                CGFloat.random(in: 8...40) * (1.0 + sin(animationPhase * 5 + Double(index)) * 0.5) : 8
                            )
                            .animation(.easeInOut(duration: 0.1).repeatForever(), value: isRecording)
                    }
                }
                .frame(height: 50)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.white.opacity(0.1), lineWidth: 1)
                        )
                )
                
                // 波形说明文字
                Text(isRecording ? "正在聆听你的声音..." : "点击开始录制你的回忆")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        
        // 录音控制按钮
        var voiceRecordingControls: some View {
            HStack(spacing: 20) {
                // 开始/停止录音按钮
                Button {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        if isRecording {
                            stopRecording()
                        } else {
                            startRecording()
                        }
                    }
                } label: {
                    ZStack {
                        // 外圈动画
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.pink, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                            .frame(width: 80, height: 80)
                            .scaleEffect(isRecording ? 1.2 : 1.0)
                            .opacity(isRecording ? 0.6 : 1.0)
                        
                        // 主按钮
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: isRecording ? [.red, .orange] : [.pink, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                            .overlay(
                                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                    .scaleEffect(isRecording ? 0.8 : 1.0)
                            )
                            .shadow(color: isRecording ? .red.opacity(0.4) : .pink.opacity(0.4), radius: 12, x: 0, y: 6)
                        
                        // 录音时的脉冲效果
                        if isRecording {
                            Circle()
                                .stroke(.white.opacity(0.3), lineWidth: 2)
                                .frame(width: 90, height: 90)
                                .scaleEffect(1.0 + sin(animationPhase * 4) * 0.2)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // 辅助控制按钮
                VStack(spacing: 12) {
                    // 暂停/继续按钮
                    if isRecording {
                        Button {
                            pauseRecording()
                        } label: {
                            Image(systemName: isPaused ? "play.fill" : "pause.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(Color.blue.opacity(0.8))
                                        .shadow(color: .blue.opacity(0.3), radius: 6, x: 0, y: 3)
                                )
                        }
                    }
                    
                    // 删除录音按钮
                    if recordingDuration > 0 && !isRecording {
                        Button {
                            clearRecording()
                        } label: {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(Color.red.opacity(0.8))
                                        .shadow(color: .red.opacity(0.3), radius: 6, x: 0, y: 3)
                                )
                        }
                    }
                }
            }
        }
        
        // 录音状态视图
        var recordingStatusView: some View {
            VStack(spacing: 8) {
                // 录音时长
                Text(formatRecordingDuration(recordingDuration))
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                // 状态文字
                Text(isRecording ? "正在录制..." : "录制完成")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                // 进度条
                if isRecording {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .pink))
                        .scaleEffect(0.8)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        
        // AI处理状态视图
        var aiProcessingStatusView: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.cyan)
                        .font(.title3)
                    
                    Text("AI正在处理")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if isProcessingVoice {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                            .scaleEffect(0.7)
                    }
                }
                
                // 转录文本
                if !voiceTranscription.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("语音转录:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.cyan)
                        
                        Text(voiceTranscription)
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.3))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.cyan.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
                
                // AI优化建议
                if !aiOptimizedContent.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("AI优化建议:")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.green)
                            
                            Spacer()
                            
                            Button("采用") {
                                applyAIOptimization()
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(.green)
                                    .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)
                            )
                        }
                        
                        Text(aiOptimizedContent)
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.3))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.green.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        
        // AI智能建议视图
        var aiSuggestionsView: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                        .font(.title3)
                    
                    Text("智能建议")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                LazyVStack(spacing: 8) {
                    ForEach(aiSuggestions, id: \.self) { suggestion in
                        Button {
                            applySuggestion(suggestion)
                        } label: {
                            HStack {
                                Text(suggestion)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 16))
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.3))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.yellow.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        
        // 心情选择区域
        var moodSelectionSection: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.pink)
                        .font(.title3)
                    Text("当时的心情")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                    Spacer()
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                    ForEach(MoodType.allCases, id: \.self) { mood in
                        moodButton(for: mood)
                    }
                }
            }
        }
        
        // 心情按钮
        private func moodButton(for mood: MoodType) -> some View {
            let isSelected = memoryMood == mood
            
            return Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    memoryMood = mood
                }
            } label: {
                VStack(spacing: 6) {
                    Text(mood.rawValue)
                        .font(.title2)
                    Text(mood.name)
                        .font(.caption.weight(.medium))
                        .foregroundColor(.white)
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(moodButtonBackground(for: mood, isSelected: isSelected))
                .scaleEffect(isSelected ? 1.05 : 1.0)
            }
        }
        
        // 心情按钮背景
        private func moodButtonBackground(for mood: MoodType, isSelected: Bool) -> some View {
            if isSelected {
                return AnyView(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(mood.color.opacity(0.3))
                        .overlay(moodButtonStroke(for: mood, isSelected: isSelected))
                )
            } else {
                return AnyView(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(moodButtonStroke(for: mood, isSelected: isSelected))
                )
            }
        }
        
        // 心情按钮边框
        private func moodButtonStroke(for mood: MoodType, isSelected: Bool) -> some View {
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isSelected ? mood.color : Color.white.opacity(0.2),
                    lineWidth: isSelected ? 2 : 1
                )
        }
        
        // 地点输入区域
        var locationSection: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                    Text("地点")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                    Spacer()
                }
                
                TextField("记录发生的地点", text: $memoryLocation)
                    .font(.body)
                    .padding(16)
                    .background(locationFieldBackground)
                    .foregroundColor(.primary)
            }
        }
        
        // 地点字段背景
        private var locationFieldBackground: some View {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(locationFieldStroke)
        }
        
        // 地点字段边框
        private var locationFieldStroke: some View {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.3), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        
        // 现代化成员选择区域
        var modernMemberSection: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.orange)
                        .font(.title3)
                    Text("相关成员")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(selectedMembers.count)人")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(familyMembers, id: \.self) { member in
                        modernMemberCard(member: member)
                    }
                }
            }
        }
        
        // 现代化日期选择区域
        var modernDateSection: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "calendar.circle.fill")
                        .foregroundColor(.purple)
                        .font(.title3)
                    Text("记忆日期")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                    Spacer()
                }
                
                DatePicker("选择日期", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .accentColor(.purple)
                    .padding(16)
                    .background(datePickerBackground)
            }
        }
        
        // 日期选择器背景
        private var datePickerBackground: some View {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(datePickerStroke)
        }
        
        // 日期选择器边框
        private var datePickerStroke: some View {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.3), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        
        // 现代化成员卡片
        func modernMemberCard(member: String) -> some View {
            let isSelected = selectedMembers.contains(member)
            
            return Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    if selectedMembers.contains(member) {
                        selectedMembers.remove(member)
                    } else {
                        selectedMembers.insert(member)
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    // 头像
                    memberAvatarView(for: member, isSelected: isSelected)
                    
                    Text(member)
                        .font(.body.weight(.medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // 选中指示器
                    if isSelected {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundColor(.pink)
                    }
                }
                .padding(16)
                .background(memberCardBackground(isSelected: isSelected))
                .scaleEffect(isSelected ? 1.02 : 1.0)
            }
        }
        
        // 成员头像视图
        private func memberAvatarView(for member: String, isSelected: Bool) -> some View {
            Circle()
                .fill(memberAvatarGradient(isSelected: isSelected))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: isSelected ? "checkmark" : "person.fill")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)
                )
        }
        
        // 成员头像渐变
        private func memberAvatarGradient(isSelected: Bool) -> LinearGradient {
            LinearGradient(
                colors: isSelected 
                ? [.blue, .purple] 
                : [.gray.opacity(0.3), .gray.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        // 成员卡片背景
        private func memberCardBackground(isSelected: Bool) -> some View {
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? .ultraThickMaterial : .ultraThinMaterial)
                .overlay(memberCardStroke(isSelected: isSelected))
        }
        
        // 成员卡片边框
        private func memberCardStroke(isSelected: Bool) -> some View {
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isSelected 
                    ? LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [.white.opacity(0.2)], startPoint: .leading, endPoint: .trailing),
                    lineWidth: isSelected ? 2 : 1
                )
        }
        
        // 增强星空背景
        var enhancedStarfieldBackground: some View {
            ZStack {
                baseGradientBackground
                dynamicStarsEffect
            }
            .ignoresSafeArea()
        }
        
        // 基础渐变背景
        private var baseGradientBackground: some View {
            RadialGradient(
                colors: [
                    Color(red: 0.15, green: 0.1, blue: 0.4),
                    Color(red: 0.1, green: 0.05, blue: 0.25),
                    Color(red: 0.05, green: 0.02, blue: 0.15),
                    Color.black
                ],
                center: .center,
                startRadius: 50,
                endRadius: 800
            )
        }
        
        // 动态星光效果
        private var dynamicStarsEffect: some View {
            ForEach(0..<50, id: \.self) { i in
                singleStar(index: i)
            }
        }
        
        // 单个星星
        private func singleStar(index: Int) -> some View {
            Circle()
                .fill(Color.white.opacity(Double.random(in: 0.1...0.8)))
                .frame(width: Double.random(in: 1...3))
                .position(
                    x: Double.random(in: 0...400),
                    y: Double.random(in: 0...800)
                )
                .opacity(0.5 + 0.5 * sin(animationPhase + Double(index) * 0.1))
        }
        
        // 保存动画覆盖层
        var saveAnimationOverlay: some View {
            ZStack {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // 脉冲心形
                    ZStack {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: "heart.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.pink)
                                .scaleEffect(1.0 + Double(i) * 0.3)
                                .opacity(1.0 - Double(i) * 0.3)
                                .animation(
                                    .easeInOut(duration: 1.0)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(i) * 0.2),
                                    value: showSaveAnimation
                                )
                        }
                    }
                    
                    Text("保存中...")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.white)
                    
                    Text("正在将美好记忆珍藏✨")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        
        // 启动动画
        private func startAnimations() {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                animationPhase = .pi * 2
            }
        }
        
        // 加载选中的图片
        private func loadSelectedImages(from items: [PhotosPickerItem]) {
            selectedImages.removeAll()
            
            for item in items {
                item.loadTransferable(type: Data.self) { result in
                    switch result {
                    case .success(let data):
                        if let data = data, let uiImage = UIImage(data: data) {
                            DispatchQueue.main.async {
                                selectedImages.append(uiImage)
                            }
                        }
                    case .failure(let error):
                        print("Error loading image: \(error)")
                    }
                }
            }
        }
        
        // 保存记忆
        private func saveMemory() {
            // 这里添加保存逻辑
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showSaveAnimation = false
                presentationMode.wrappedValue.dismiss()
            }
        }
        
        // AI语音输入方法实现
        
        // 开始录音
        private func startRecording() {
            isRecording = true
            recordingDuration = 0
            isPaused = false
            
            // 启动录音计时器
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if !isPaused {
                    recordingDuration += 0.1
                }
            }
            
            // 模拟AI准备就绪
            withAnimation(.easeInOut(duration: 0.5)) {
                isAIReady = true
            }
            
            // 这里应该集成真实的语音识别API
            // 模拟语音转录过程
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                simulateVoiceTranscription()
            }
        }
        
        // 停止录音
        private func stopRecording() {
            isRecording = false
            recordingTimer?.invalidate()
            recordingTimer = nil
            
            // 开始AI处理
            processVoiceWithAI()
        }
        
        // 暂停录音
        private func pauseRecording() {
            isPaused.toggle()
        }
        
        // 清除录音
        private func clearRecording() {
            recordingDuration = 0
            voiceTranscription = ""
            aiOptimizedContent = ""
            aiSuggestions.removeAll()
            isProcessingVoice = false
        }
        
        // 模拟语音转录
        private func simulateVoiceTranscription() {
            let sampleTranscriptions = [
                "今天和家人一起去公园散步，天气特别好，看到很多花都开了，心情很愉快。",
                "昨天妈妈做了我最爱吃的红烧肉，全家人围坐在一起吃饭，特别温馨。",
                "和朋友们一起去看电影，选了一部喜剧片，大家笑得很开心。",
                "周末参加了学校的运动会，虽然没有得奖，但是很享受比赛的过程。"
            ]
            
            withAnimation(.easeInOut(duration: 0.8)) {
                voiceTranscription = sampleTranscriptions.randomElement() ?? ""
            }
        }
        
        // AI处理语音
        private func processVoiceWithAI() {
            isProcessingVoice = true
            
            // 模拟AI处理延迟
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                generateAIOptimization()
                generateAISuggestions()
                
                withAnimation(.easeInOut(duration: 0.5)) {
                    isProcessingVoice = false
                }
            }
        }
        
        // 生成AI优化内容
        private func generateAIOptimization() {
            if !voiceTranscription.isEmpty {
                // 模拟AI优化
                let optimizedContent = """
                📅 时间：\(formatDate(selectedDate))
                🌟 心情：\(memoryMood.name) \(memoryMood.rawValue)
                
                📝 详细描述：
                \(voiceTranscription)
                
                💭 这是一个充满\(memoryMood.name)的美好回忆，值得永远珍藏。
                """
                
                withAnimation(.easeInOut(duration: 0.8)) {
                    aiOptimizedContent = optimizedContent
                }
            }
        }
        
        // 生成AI建议
        private func generateAISuggestions() {
            let suggestions = [
                "添加更多情感细节描述",
                "记录当时的天气情况",
                "描述其他参与者的反应",
                "添加这个回忆的特殊意义",
                "记录当时的具体时间",
                "描述周围的环境氛围"
            ]
            
            withAnimation(.easeInOut(duration: 0.8)) {
                aiSuggestions = Array(suggestions.shuffled().prefix(3))
            }
        }
        
        // 应用AI优化
        private func applyAIOptimization() {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                memoryContent = aiOptimizedContent
                aiOptimizedContent = ""
            }
        }
        
        // 应用建议
        private func applySuggestion(_ suggestion: String) {
            let currentContent = memoryContent.isEmpty ? voiceTranscription : memoryContent
            let newContent = currentContent + "\n\n💡 " + suggestion
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                memoryContent = newContent
            }
        }
        
        // 格式化录音时长
        private func formatRecordingDuration(_ duration: TimeInterval) -> String {
            let minutes = Int(duration) / 60
            let seconds = Int(duration) % 60
            let milliseconds = Int((duration.truncatingRemainder(dividingBy: 1)) * 100)
            return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
        }
        
        // 格式化日期
        private func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.locale = Locale(identifier: "zh_CN")
            return formatter.string(from: date)
        }
    }
    
    // 自定义文本字段样式
    struct CustomTextFieldStyle: TextFieldStyle {
        func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .padding(12)
                .background(Color.white.opacity(0.9))
                .cornerRadius(8)
                .foregroundColor(.black)
        }
    }
    
    // 邀请家人视图
    struct InviteFamilyView: View {
        @Environment(\.presentationMode) var presentationMode
        @State private var inviteCode = "FAMILY2024"
        @State private var showShareSheet = false
        
        var body: some View {
            NavigationView {
                ZStack {
                    starfieldBackground
                    
                    VStack(spacing: 30) {
                        // 邀请图标
                        VStack(spacing: 20) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 80))
                                .foregroundColor(.blue)
                                .padding(.top, 40)
                            
                            Text("邀请家人加入")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("分享邀请码让家人一起记录美好时光")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        
                        // 邀请码卡片
                        VStack(spacing: 16) {
                            Text("邀请码")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack {
                                Text(inviteCode)
                                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.blue.opacity(0.3))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.blue, lineWidth: 2)
                                            )
                                    )
                                
                                Button {
                                    UIPasteboard.general.string = inviteCode
                                } label: {
                                    Image(systemName: "doc.on.doc")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.white.opacity(0.1))
                                        )
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                        
                        // 分享按钮
                        Button {
                            showShareSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("分享邀请")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        
                        Spacer()
                    }
                    .padding(20)
                }
                .navigationTitle("邀请家人")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    trailing: Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                )
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: ["邀请您加入我们的家族记忆！邀请码：\(inviteCode)"])
            }
        }
        
        var starfieldBackground: some View {
            RadialGradient(
                colors: [
                    Color(red: 0.15, green: 0.1, blue: 0.4),
                    Color(red: 0.1, green: 0.05, blue: 0.25),
                    Color.black
                ],
                center: .center,
                startRadius: 50,
                endRadius: 600
            )
            .ignoresSafeArea()
        }
    }
    
    // 备份数据视图
    struct BackupDataView: View {
        @Environment(\.presentationMode) var presentationMode
        @State private var isBackingUp = false
        @State private var backupProgress: Double = 0
        @State private var lastBackupDate = "2024年1月15日"
        
        var body: some View {
            NavigationView {
                ZStack {
                    starfieldBackground
                    
                    VStack(spacing: 30) {
                        // 备份图标和标题
                        VStack(spacing: 20) {
                            Image(systemName: "icloud.and.arrow.up")
                                .font(.system(size: 80))
                                .foregroundColor(.purple)
                                .padding(.top, 40)
                            
                            Text("数据备份")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("保护您的珍贵回忆，确保数据安全")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        
                        // 备份状态卡片
                        VStack(spacing: 20) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("上次备份")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Text(lastBackupDate)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 8) {
                                    Text("备份大小")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Text("256 MB")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                            
                            if isBackingUp {
                                VStack(spacing: 12) {
                                    ProgressView(value: backupProgress)
                                        .accentColor(.purple)
                                    
                                    Text("备份中... \(Int(backupProgress * 100))%")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                        
                        // 备份选项
                        VStack(spacing: 16) {
                            backupOptionRow(
                                icon: "icloud",
                                title: "iCloud备份",
                                subtitle: "同步到您的iCloud账户",
                                isEnabled: true
                            )
                            
                            backupOptionRow(
                                icon: "externaldrive",
                                title: "本地备份",
                                subtitle: "保存到设备本地存储",
                                isEnabled: false
                            )
                        }
                        
                        // 立即备份按钮
                        Button {
                            startBackup()
                        } label: {
                            HStack {
                                if isBackingUp {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: "arrow.up.circle.fill")
                                }
                                Text(isBackingUp ? "备份中..." : "立即备份")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        .disabled(isBackingUp)
                        
                        Spacer()
                    }
                    .padding(20)
                }
                .navigationTitle("数据备份")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    trailing: Button("关闭") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                )
            }
        }
        
        func backupOptionRow(icon: String, title: String, subtitle: String, isEnabled: Bool) -> some View {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isEnabled ? .purple : .gray)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Toggle("", isOn: .constant(isEnabled))
                    .labelsHidden()
                    .disabled(!isEnabled)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        
        private func startBackup() {
            isBackingUp = true
            backupProgress = 0
            
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                backupProgress += 0.05
                if backupProgress >= 1.0 {
                    timer.invalidate()
                    isBackingUp = false
                    lastBackupDate = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
                }
            }
        }
        
        var starfieldBackground: some View {
            RadialGradient(
                colors: [
                    Color(red: 0.15, green: 0.1, blue: 0.4),
                    Color(red: 0.1, green: 0.05, blue: 0.25),
                    Color.black
                ],
                center: .center,
                startRadius: 50,
                endRadius: 600
            )
            .ignoresSafeArea()
        }
    }
    
    // 通知设置视图
    struct NotificationSettingsView: View {
        @Environment(\.presentationMode) var presentationMode
        @State private var allowNotifications = true
        @State private var memoryReminders = true
        @State private var familyUpdates = true
        @State private var birthdayReminders = true
        @State private var weeklyReports = false
        
        var body: some View {
            NavigationView {
                ZStack {
                    starfieldBackground
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // 主开关
                            VStack(spacing: 16) {
                                HStack {
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(.orange)
                                        .font(.title2)
                                    
                                    Text("推送通知")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $allowNotifications)
                                        .labelsHidden()
                                }
                                
                                Text("开启通知以接收重要的家族动态和提醒")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            
                            // 详细设置
                            if allowNotifications {
                                VStack(spacing: 16) {
                                    notificationOption(
                                        icon: "photo",
                                        title: "记忆提醒",
                                        subtitle: "提醒您记录生活中的美好时刻",
                                        isOn: $memoryReminders
                                    )
                                    
                                    notificationOption(
                                        icon: "person.2",
                                        title: "家人动态",
                                        subtitle: "家庭成员添加新记忆时通知您",
                                        isOn: $familyUpdates
                                    )
                                    
                                    notificationOption(
                                        icon: "gift",
                                        title: "生日提醒",
                                        subtitle: "家庭成员生日前一天提醒",
                                        isOn: $birthdayReminders
                                    )
                                    
                                    notificationOption(
                                        icon: "chart.line.uptrend.xyaxis",
                                        title: "周报推送",
                                        subtitle: "每周日推送本周回忆总结",
                                        isOn: $weeklyReports
                                    )
                                }
                                .transition(.slide)
                            }
                        }
                        .padding(20)
                    }
                }
                .navigationTitle("通知设置")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    trailing: Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                )
            }
            .animation(.easeInOut, value: allowNotifications)
        }
        
        func notificationOption(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Toggle("", isOn: isOn)
                    .labelsHidden()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        
        var starfieldBackground: some View {
            RadialGradient(
                colors: [
                    Color(red: 0.15, green: 0.1, blue: 0.4),
                    Color(red: 0.1, green: 0.05, blue: 0.25),
                    Color.black
                ],
                center: .center,
                startRadius: 50,
                endRadius: 600
            )
            .ignoresSafeArea()
        }
    }
    
    // 隐私设置视图
    struct PrivacySettingsView: View {
        @Environment(\.presentationMode) var presentationMode
        @State private var faceIDEnabled = true
        @State private var dataEncryption = true
        @State private var shareAnalytics = false
        @State private var locationTracking = false
        
        var body: some View {
            NavigationView {
                ZStack {
                    starfieldBackground
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // 安全认证
                            VStack(spacing: 16) {
                                sectionHeader(icon: "lock.shield", title: "安全认证")
                                
                                privacyOption(
                                    icon: "faceid",
                                    title: "Face ID / Touch ID",
                                    subtitle: "使用生物识别保护您的数据",
                                    isOn: $faceIDEnabled
                                )
                            }
                            
                            // 数据保护
                            VStack(spacing: 16) {
                                sectionHeader(icon: "shield.checkered", title: "数据保护")
                                
                                privacyOption(
                                    icon: "lock.doc",
                                    title: "数据加密",
                                    subtitle: "本地数据采用端到端加密",
                                    isOn: $dataEncryption
                                )
                                
                                privacyOption(
                                    icon: "location",
                                    title: "位置追踪",
                                    subtitle: "记录照片位置信息（可选）",
                                    isOn: $locationTracking
                                )
                            }
                            
                            // 数据使用
                            VStack(spacing: 16) {
                                sectionHeader(icon: "chart.pie", title: "数据使用")
                                
                                privacyOption(
                                    icon: "chart.bar",
                                    title: "分析数据",
                                    subtitle: "帮助改善应用体验（匿名）",
                                    isOn: $shareAnalytics
                                )
                            }
                            
                            // 数据导出
                            Button {
                                exportData()
                            } label: {
                                HStack {
                                    Image(systemName: "square.and.arrow.up.on.square")
                                        .font(.title2)
                                        .foregroundColor(.green)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("导出数据")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        Text("下载您的所有数据副本")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.08))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        .padding(20)
                    }
                }
                .navigationTitle("隐私设置")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    trailing: Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                )
            }
        }
        
        func sectionHeader(icon: String, title: String) -> some View {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
        }
        
        func privacyOption(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Toggle("", isOn: isOn)
                    .labelsHidden()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        
        private func exportData() {
            // 导出数据逻辑
        }
        
        var starfieldBackground: some View {
            RadialGradient(
                colors: [
                    Color(red: 0.15, green: 0.1, blue: 0.4),
                    Color(red: 0.1, green: 0.05, blue: 0.25),
                    Color.black
                ],
                center: .center,
                startRadius: 50,
                endRadius: 600
            )
            .ignoresSafeArea()
        }
    }
    
    // 帮助与支持视图
    struct HelpSupportView: View {
        @Environment(\.presentationMode) var presentationMode
        @State private var selectedQuestion: String?
        
        private let faqItems = [
            FAQ(question: "如何添加家庭成员？", answer: "点击首页的'邀请家人'按钮，分享邀请码给家庭成员即可。"),
            FAQ(question: "如何备份我的数据？", answer: "在个人资料页面选择'备份数据'，您可以选择备份到iCloud或本地存储。"),
            FAQ(question: "如何编辑记忆内容？", answer: "长按任意记忆卡片，选择'编辑'即可修改内容、添加标签或更改日期。"),
            FAQ(question: "如何设置隐私保护？", answer: "在设置中找到'隐私设置'，您可以开启Face ID保护、数据加密等功能。"),
            FAQ(question: "如何分享家族树？", answer: "点击'分享家族树'，选择您想要的格式（图片、PDF或链接）进行分享。")
        ]
        
        var body: some View {
            NavigationView {
                ZStack {
                    starfieldBackground
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // 常见问题
                            VStack(spacing: 16) {
                                sectionHeader(icon: "questionmark.circle", title: "常见问题")
                                
                                ForEach(faqItems, id: \.question) { faq in
                                    faqItem(faq: faq)
                                }
                            }
                            
                            // 联系我们
                            VStack(spacing: 16) {
                                sectionHeader(icon: "envelope", title: "联系我们")
                                
                                contactOption(
                                    icon: "envelope.fill",
                                    title: "发送邮件",
                                    subtitle: "support@aimemoirs.com",
                                    action: { sendEmail() }
                                )
                                
                                contactOption(
                                    icon: "message.fill",
                                    title: "在线客服",
                                    subtitle: "工作日 9:00-18:00",
                                    action: { openChat() }
                                )
                                
                                contactOption(
                                    icon: "star.fill",
                                    title: "应用评价",
                                    subtitle: "在App Store中评价我们",
                                    action: { rateApp() }
                                )
                            }
                        }
                        .padding(20)
                    }
                }
                .navigationTitle("帮助与支持")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    trailing: Button("关闭") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                )
            }
        }
        
        func sectionHeader(icon: String, title: String) -> some View {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
        }
        
        func faqItem(faq: FAQ) -> some View {
            VStack(spacing: 0) {
                Button {
                    withAnimation(.easeInOut) {
                        if selectedQuestion == faq.question {
                            selectedQuestion = nil
                        } else {
                            selectedQuestion = faq.question
                        }
                    }
                } label: {
                    HStack {
                        Text(faq.question)
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Image(systemName: selectedQuestion == faq.question ? "chevron.up" : "chevron.down")
                            .foregroundColor(.white.opacity(0.7))
                            .rotationEffect(.degrees(selectedQuestion == faq.question ? 180 : 0))
                    }
                    .padding(16)
                }
                
                if selectedQuestion == faq.question {
                    VStack {
                        Divider()
                            .background(Color.white.opacity(0.3))
                        
                        Text(faq.answer)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                    }
                    .transition(.slide)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        
        func contactOption(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
            Button(action: action) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.green)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }
        }
        
        private func sendEmail() {
            if let url = URL(string: "mailto:support@aimemoirs.com") {
                UIApplication.shared.open(url)
            }
        }
        
        private func openChat() {
            // 打开在线客服
        }
        
        private func rateApp() {
            // 打开App Store评价页面
        }
        
        var starfieldBackground: some View {
            RadialGradient(
                colors: [
                    Color(red: 0.15, green: 0.1, blue: 0.4),
                    Color(red: 0.1, green: 0.05, blue: 0.25),
                    Color.black
                ],
                center: .center,
                startRadius: 50,
                endRadius: 600
            )
            .ignoresSafeArea()
        }
    }
    
    // FAQ数据模型
    struct FAQ {
        let question: String
        let answer: String
    }
    
    // 关于应用视图
    struct AboutAppView: View {
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
            NavigationView {
                ZStack {
                    starfieldBackground
                    
                    ScrollView {
                        VStack(spacing: 30) {
                            // 应用图标和信息
                            VStack(spacing: 20) {
                                // 应用图标
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [.purple, .blue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(systemName: "memories")
                                            .font(.system(size: 50))
                                            .foregroundColor(.white)
                                    )
                                    .shadow(color: .purple.opacity(0.5), radius: 20)
                                
                                VStack(spacing: 8) {
                                    Text("AI Memoirs")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text("版本 1.0.0")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            .padding(.top, 40)
                            
                            // 应用描述
                            VStack(spacing: 16) {
                                Text("关于AI Memoirs")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Text("AI Memoirs是一款专为家庭记忆而设计的应用。我们相信每个家庭都有着珍贵的回忆值得被记录和传承。通过智能化的记忆管理，让您轻松记录、整理和分享家族的美好时光。")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                            }
                            .padding(.horizontal, 20)
                            
                            // 功能特色
                            VStack(spacing: 16) {
                                Text("核心功能")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                VStack(spacing: 12) {
                                    featureRow(icon: "photo.on.rectangle", title: "智能记忆管理", description: "AI助手帮您整理和分类回忆")
                                    featureRow(icon: "person.3", title: "家庭协作", description: "邀请家人共同记录美好时光")
                                    featureRow(icon: "icloud", title: "云端同步", description: "多设备无缝同步，永不丢失")
                                    featureRow(icon: "lock.shield", title: "隐私保护", description: "端到端加密，保护家庭隐私")
                                }
                            }
                            
                            // 开发团队
                            VStack(spacing: 16) {
                                Text("开发团队")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Text("由热爱家庭、关注情感连接的开发团队精心打造")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.horizontal, 20)
                            
                            // 版权信息
                            VStack(spacing: 8) {
                                Text("© 2024 AI Memoirs")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.5))
                                
                                Text("保留所有权利")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        .padding(20)
                    }
                }
                .navigationTitle("关于应用")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    trailing: Button("关闭") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                )
            }
        }
        
        func featureRow(icon: String, title: String, description: String) -> some View {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.purple)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        
        var starfieldBackground: some View {
            RadialGradient(
                colors: [
                    Color(red: 0.15, green: 0.1, blue: 0.4),
                    Color(red: 0.1, green: 0.05, blue: 0.25),
                    Color.black
                ],
                center: .center,
                startRadius: 50,
                endRadius: 600
            )
            .ignoresSafeArea()
        }
    }
    
    // 分享工具
    struct ShareSheet: UIViewControllerRepresentable {
        let items: [Any]
        
        func makeUIViewController(context: Context) -> UIActivityViewController {
            let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
            return controller
        }
        
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    }
    
    // 分享家族树视图
    struct ShareTreeView: View {
        let profile: UserProfile
        @Environment(\.presentationMode) var presentationMode
        @State private var showShareSheet = false
        @State private var selectedFormat: ShareFormat = .image
        
        enum ShareFormat: String, CaseIterable {
            case image = "图片"
            case pdf = "PDF"
            case link = "链接"
        }
        
        var body: some View {
            NavigationView {
                ZStack {
                    starfieldBackground
                    
                    VStack(spacing: 30) {
                        // 分享图标和标题
                        VStack(spacing: 20) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 80))
                                .foregroundColor(.orange)
                                .padding(.top, 40)
                            
                            Text("分享家族树")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("将您的家族记忆分享给更多人")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        
                        // 分享格式选择
                        VStack(spacing: 16) {
                            Text("选择分享格式")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            ForEach(ShareFormat.allCases, id: \.self) { format in
                                shareFormatOption(format: format)
                            }
                        }
                        
                        // 分享按钮
                        Button {
                            generateShareContent()
                            showShareSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                Text("开始分享")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        
                        Spacer()
                    }
                    .padding(20)
                }
                .navigationTitle("分享家族树")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    trailing: Button("关闭") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                )
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: [shareContent])
            }
        }
        
        func shareFormatOption(format: ShareFormat) -> some View {
            Button {
                selectedFormat = format
            } label: {
                HStack {
                    Image(systemName: formatIcon(for: format))
                        .font(.title2)
                        .foregroundColor(selectedFormat == format ? .orange : .white.opacity(0.7))
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(format.rawValue)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(formatDescription(for: format))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    if selectedFormat == format {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.orange)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedFormat == format ? Color.orange.opacity(0.2) : Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedFormat == format ? Color.orange : Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
        
        func formatIcon(for format: ShareFormat) -> String {
            switch format {
            case .image: return "photo"
            case .pdf: return "doc.richtext"
            case .link: return "link"
            }
        }
        
        func formatDescription(for format: ShareFormat) -> String {
            switch format {
            case .image: return "生成家族树图片，方便保存和分享"
            case .pdf: return "创建PDF文档，包含详细家族信息"
            case .link: return "生成在线链接，其他人可通过链接查看"
            }
        }
        
        var shareContent: String {
            switch selectedFormat {
            case .image:
                return "我的家族树图片已生成"
            case .pdf:
                return "我的家族树PDF文档已创建"
            case .link:
                return "查看我的家族树：https://aimemoirs.com/tree/\(profile.name)"
            }
        }
        
        private func generateShareContent() {
            // 根据选择的格式生成相应内容
        }
        
        var starfieldBackground: some View {
            RadialGradient(
                colors: [
                    Color(red: 0.15, green: 0.1, blue: 0.4),
                    Color(red: 0.1, green: 0.05, blue: 0.25),
                    Color.black
                ],
                center: .center,
                startRadius: 50,
                endRadius: 600
            )
            .ignoresSafeArea()
        }
    }
    
    // 增强的按钮样式
    struct EnhancedScaleButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .opacity(configuration.isPressed ? 0.8 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }
    
    #Preview {
        ProfileView()
    } 
}

// MARK: - Array Extensions
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
    
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
