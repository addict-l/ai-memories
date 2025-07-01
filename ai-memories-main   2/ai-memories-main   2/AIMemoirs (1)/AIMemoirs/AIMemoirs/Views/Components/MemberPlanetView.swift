import SwiftUI

// MARK: - 成员行星视图
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
        let iconSize = ScreenAdapter.getCurrentConfig().memberIconSize
        ZStack {
            // 行星背景
            planetBackgroundView
            // 成员图标
            memberIconView
            // 高级回忆数字标签
            memoryCountBadgeView
            // 高级粒子特效
            if isHighlighted {
                particleEffectsView
                haloRingsView
            }
            // 选中发光效果
            if isSelected {
                selectedGlowEffectsView
            }
            // 能量波纹效果
            if isHighlighted {
                energyWaveEffectsView
            }
            // 名字标签（叠加在icon下半部分，不超出icon范围）
            Text(member.name)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.8))
                )
                .frame(maxWidth: iconSize * 0.85) // 限制标签宽度
                .offset(y: iconSize * 0.28) // 让标签嵌入icon下半部分（0.25~0.32可微调）
        }
        .frame(width: iconSize, height: iconSize) // 只用icon高度
        .clipped()
        // 动画
        .animation(.easeInOut(duration: 0.2), value: isHighlighted)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isSelected)
        // 监听高亮
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
    
    // MARK: - 子视图组件
    
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
                .allowsHitTesting(false) // 防止影响交互
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
                .allowsHitTesting(false) // 防止影响交互
            
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
                .allowsHitTesting(false) // 防止影响交互
        }
    }
    
    // 行星背景视图
    private var planetBackgroundView: some View {
        let config = ScreenAdapter.getCurrentConfig()
        let iconSize = config.memberIconSize
        
        return Circle()
            .fill(
                RadialGradient(
                    colors: [
                        .white.opacity(0.4),
                        getEnhancedColor().opacity(0.95),
                        getEnhancedColor().opacity(0.8)
                    ],
                    center: UnitPoint(x: 0.25, y: 0.25),
                    startRadius: 5,
                    endRadius: iconSize / 2
                )
            )
            .frame(width: iconSize, height: iconSize)
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
    
    // MARK: - 辅助方法
    
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