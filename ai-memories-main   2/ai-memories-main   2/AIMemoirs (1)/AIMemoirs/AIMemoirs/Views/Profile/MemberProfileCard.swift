import SwiftUI

// MARK: - 温馨家庭成员资料卡
struct MemberProfileCard: View {
    let member: FamilyMember
    @Binding var isShowing: Bool
    @Binding var selectedTab: Int
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
        .onChange(of: showAddMemorySheet) { show in
            if show {
                // 直接跳转到"新的回忆"标签页
                selectedTab = 1
                showAddMemorySheet = false
            }
        }
    }
    
    // MARK: - 子视图组件
    
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
    
    // MARK: - 辅助方法
    
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