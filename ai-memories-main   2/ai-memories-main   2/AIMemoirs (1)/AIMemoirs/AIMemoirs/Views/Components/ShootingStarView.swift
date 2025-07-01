import SwiftUI

// MARK: - 流星动画视图
struct ShootingStarView: View {
    let x: CGFloat
    let y: CGFloat
    let style: ShootingStarStyle
    let rotation: Double
    
    // 流星样式枚举
    enum ShootingStarStyle {
        case detailed    // 详细样式 - 带头部光点和渐变
        case simple      // 简单样式 - 胶囊形状
    }
    
    // 默认初始化器 - 使用详细样式
    init(x: CGFloat, y: CGFloat, style: ShootingStarStyle = .detailed, rotation: Double = 0) {
        self.x = x
        self.y = y
        self.style = style
        self.rotation = rotation
    }
    
    var body: some View {
        Group {
            switch style {
            case .detailed:
                detailedShootingStar
            case .simple:
                simpleShootingStar
            }
        }
        .position(x: x, y: y)
    }
    
    // MARK: - 详细样式流星
    private var detailedShootingStar: some View {
        ZStack {
            // 流星主体
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 60, y: 20))
            }
            .stroke(
                LinearGradient(
                    colors: [
                        .white.opacity(0.8),
                        .yellow.opacity(0.6),
                        .orange.opacity(0.4),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 2, lineCap: .round)
            )
            .shadow(color: .yellow.opacity(0.5), radius: 4)
            
            // 流星头部光点
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .white,
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
                .shadow(color: .yellow.opacity(0.8), radius: 6)
        }
    }
    
    // MARK: - 简单样式流星
    private var simpleShootingStar: some View {
        Capsule()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [Color.white, Color.white.opacity(0)]), 
                    startPoint: .leading, 
                    endPoint: .trailing
                )
            )
            .frame(width: 100, height: 3)
            .rotationEffect(.degrees(rotation))
    }
}

// MARK: - 流星动画管理器
class ShootingStarManager: ObservableObject {
    @Published var shootingStarX: CGFloat = -100
    @Published var shootingStarY: CGFloat = 80
    @Published var isAnimating: Bool = false
    
    private var animationTimer: Timer?
    
    func startAnimation(duration: TimeInterval = 2.0, repeatCount: Int = -1) {
        isAnimating = true
        
        // 重置位置
        shootingStarX = -100
        shootingStarY = 80
        
        // 启动动画
        withAnimation(Animation.linear(duration: duration)) {
            shootingStarX = 500
            shootingStarY = 400
        }
        
        // 设置重复动画
        if repeatCount != 0 {
            animationTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: repeatCount > 0) { _ in
                self.restartAnimation(duration: duration)
            }
        }
    }
    
    func stopAnimation() {
        isAnimating = false
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func restartAnimation(duration: TimeInterval) {
        // 重置位置
        shootingStarX = -100
        shootingStarY = 80
        
        // 重新启动动画
        withAnimation(Animation.linear(duration: duration)) {
            shootingStarX = 500
            shootingStarY = 400
        }
    }
    
    deinit {
        stopAnimation()
    }
} 