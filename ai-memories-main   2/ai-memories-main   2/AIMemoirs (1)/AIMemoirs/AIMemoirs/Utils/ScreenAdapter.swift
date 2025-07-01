import SwiftUI

// MARK: - 屏幕适配工具
struct ScreenAdapter {
    
    // MARK: - iPhone 屏幕尺寸枚举
    enum iPhoneScreen {
        case mini      // iPhone 12/13/14 mini (375 × 812)
        case standard  // iPhone 12/13/14 (390 × 844)
        case pro       // iPhone 14 Pro (393 × 852)
        case proMax    // iPhone 14 Pro Max (430 × 932)
        
        static func current() -> iPhoneScreen {
            let screenSize = UIScreen.main.bounds.size
            let width = screenSize.width
            let height = screenSize.height
            
            switch (width, height) {
            case (375, 812): return .mini
            case (390, 844): return .standard
            case (393, 852): return .pro
            case (430, 932): return .proMax
            default: return .standard // 默认使用标准尺寸
            }
        }
    }
    
    // MARK: - 屏幕尺寸配置
    struct ScreenConfig {
        let topAreaHeight: CGFloat
        let bottomAreaHeight: CGFloat
        let horizontalMargin: CGFloat
        let homeIconSize: CGFloat
        let memberIconSize: CGFloat
        let orbitSpacing: CGFloat
        let titleFontSize: CGFloat
        let subtitleFontSize: CGFloat
        
        static func getConfig(for screen: iPhoneScreen) -> ScreenConfig {
            switch screen {
            case .mini:
                return ScreenConfig(
                    topAreaHeight: 100,
                    bottomAreaHeight: 100,
                    horizontalMargin: 30,
                    homeIconSize: 60,
                    memberIconSize: 55,
                    orbitSpacing: 0.25,
                    titleFontSize: 28,
                    subtitleFontSize: 14
                )
            case .standard:
                return ScreenConfig(
                    topAreaHeight: 110,
                    bottomAreaHeight: 110,
                    horizontalMargin: 35,
                    homeIconSize: 65,
                    memberIconSize: 60,
                    orbitSpacing: 0.3,
                    titleFontSize: 30,
                    subtitleFontSize: 15
                )
            case .pro:
                return ScreenConfig(
                    topAreaHeight: 120,
                    bottomAreaHeight: 120,
                    horizontalMargin: 40,
                    homeIconSize: 70,
                    memberIconSize: 65,
                    orbitSpacing: 0.35,
                    titleFontSize: 32,
                    subtitleFontSize: 16
                )
            case .proMax:
                return ScreenConfig(
                    topAreaHeight: 130,
                    bottomAreaHeight: 130,
                    horizontalMargin: 45,
                    homeIconSize: 75,
                    memberIconSize: 70,
                    orbitSpacing: 0.4,
                    titleFontSize: 34,
                    subtitleFontSize: 17
                )
            }
        }
    }
    
    // MARK: - 计算中心点
    static func calculateCenter(geometry: GeometryProxy) -> CGPoint {
        let screen = iPhoneScreen.current()
        let config = ScreenConfig.getConfig(for: screen)
        
        let availableHeight = geometry.size.height - (config.topAreaHeight + config.bottomAreaHeight)
        let centerY = config.topAreaHeight + availableHeight / 2
        
        return CGPoint(x: geometry.size.width / 2, y: centerY)
    }
    
    // MARK: - 计算轨道半径
    static func calculateOrbitRadii(geometry: GeometryProxy) -> [CGFloat] {
        let screen = iPhoneScreen.current()
        let config = ScreenConfig.getConfig(for: screen)
        
        let availableWidth = geometry.size.width - (config.horizontalMargin * 2)
        let availableHeight = geometry.size.height - (config.topAreaHeight + config.bottomAreaHeight)
        
        let homeRadius = config.homeIconSize / 2
        let memberRadius = config.memberIconSize / 2
        let minMargin: CGFloat = 15
        let baseRadius = homeRadius + memberRadius + minMargin
        
        let maxRadius = min(availableWidth, availableHeight) / 2.2
        
        return [
            baseRadius + (maxRadius - baseRadius) * config.orbitSpacing,      // 内轨道 - 保持不变
            baseRadius + (maxRadius - baseRadius) * (config.orbitSpacing + 0.45), // 中轨道 - 居中
            baseRadius + (maxRadius - baseRadius) * (config.orbitSpacing + 0.9)   // 外轨道 - 增大
        ]
    }
    
    // MARK: - 获取当前屏幕配置
    static func getCurrentConfig() -> ScreenConfig {
        let screen = iPhoneScreen.current()
        return ScreenConfig.getConfig(for: screen)
    }
    
    // MARK: - 调试信息
    static func debugInfo() -> String {
        let screen = iPhoneScreen.current()
        let config = ScreenConfig.getConfig(for: screen)
        let screenSize = UIScreen.main.bounds.size
        
        return """
        当前屏幕: \(screen)
        屏幕尺寸: \(screenSize.width) × \(screenSize.height)
        顶部区域: \(config.topAreaHeight)px
        底部区域: \(config.bottomAreaHeight)px
        水平边距: \(config.horizontalMargin)px
        家图标大小: \(config.homeIconSize)px
        成员图标大小: \(config.memberIconSize)px
        轨道间距: \(config.orbitSpacing)
        """
    }
} 