import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Int
    @State private var shootingStarX: CGFloat = -100
    @State private var shootingStarY: CGFloat = 80
    @State private var animate = false
    @State private var buttonPressed = false
    @State private var cardPressed = false
    var body: some View {
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
            VStack(spacing: 60) {
                Spacer().frame(height: 80)
                
                // 简洁的标题区域
                VStack(spacing: 16) {
                    Text("AI Memories")
                        .font(.system(size: 48, weight: .thin, design: .default))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 6)
                        .tracking(1)
                    
                    Text("记录生活的美好瞬间")
                        .font(.system(size: 16, weight: .light, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                        .tracking(1)
                }
                
                Spacer()
                
                // 简洁的卡片设计
                RoundedRectangle(cornerRadius: 24)
                    .fill(.regularMaterial)
                    .frame(width: 320, height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                    .scaleEffect(cardPressed ? 0.98 : 1.0)
                    .overlay(
                        VStack(spacing: 24) {
                            // 简洁图标
                            Image(systemName: "sparkles")
                                .font(.system(size: 36, weight: .ultraLight))
                                .foregroundColor(.white.opacity(0.9))
                            
                            VStack(spacing: 16) {
                                Text("AI 人生回忆录")
                                    .font(.system(size: 22, weight: .medium, design: .rounded))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                
                                Text("记录生活点滴，珍藏美好时光")
                                    .font(.system(size: 15, weight: .regular, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .opacity(0.75)
                            }
                        }
                        .padding(32)
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            cardPressed = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                cardPressed = false
                            }
                        }
                    }
                
                Spacer()
                
                // 现代按钮设计
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        buttonPressed = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            buttonPressed = false
                        }
                        selectedTab = 1 // 跳转到"新的回忆"tab
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                        
                        Text("开始记录")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(width: 180, height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 26)
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.blue.opacity(0.4), radius: 15, x: 0, y: 8)
                                         .scaleEffect(buttonPressed ? 0.95 : 1.0)
                }
                
                Spacer().frame(height: 100)
            }
        }
    }
}

struct ShootingStarView: View {
    var x: CGFloat
    var y: CGFloat
    var body: some View {
        Capsule()
            .fill(LinearGradient(gradient: Gradient(colors: [Color.white, Color.white.opacity(0)]), startPoint: .leading, endPoint: .trailing))
            .frame(width: 100, height: 3)
            .rotationEffect(.degrees(-25))
            .position(x: x, y: y)
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
} 