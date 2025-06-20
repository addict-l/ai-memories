import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Int
    @State private var shootingStarX: CGFloat = -100
    @State private var shootingStarY: CGFloat = 80
    @State private var animate = false
    var body: some View {
        ZStack {
            // 渐变夜空背景
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.7), Color.black]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            // 流星动画
            ShootingStarView(x: shootingStarX, y: shootingStarY)
                .opacity(0.8)
                .onAppear {
                    withAnimation(Animation.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                        shootingStarX = 500
                        shootingStarY = 400
                    }
                }
            VStack(spacing: 32) {
                Spacer().frame(height: 60)
                Text("AIMemoirs")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                    .shadow(radius: 8)
                Spacer()
                // 卡片
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white.opacity(0.95))
                    .frame(width: 340, height: 220)
                    .shadow(color: Color.black.opacity(0.18), radius: 20, x: 0, y: 8)
                    .overlay(
                        VStack(spacing: 12) {
                            Text("欢迎来到AI人生回忆录")
                                .font(.title2).bold()
                                .foregroundColor(.black)
                            Text("记录你的生活点滴，发现家族故事。")
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                    )
                Spacer()
                // 底部按钮
                Button(action: {
                    selectedTab = 1 // 跳转到"新的回忆"tab
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("添加新的回忆")
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(24)
                    .shadow(radius: 8)
                }
                Spacer().frame(height: 60)
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
            .frame(width: 120, height: 4)
            .rotationEffect(.degrees(-20))
            .position(x: x, y: y)
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
} 