import SwiftUI

// MARK: - 控制按钮组件
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