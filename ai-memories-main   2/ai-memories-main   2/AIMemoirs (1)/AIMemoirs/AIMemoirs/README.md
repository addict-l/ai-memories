# AIMemoirs - 星空家族树应用

## 项目结构

本项目已按照功能模块进行了重构，将原本的单一文件拆分为多个独立的模块：

### 📁 Models/
- **FamilyModels.swift** - 数据模型层
  - `Gender` - 性别枚举
  - `FamilyMember` - 家庭成员模型
  - `FamilyGraph` - 家族关系图类
  - `MemoryItem` - 回忆项目模型
  - `MemoryEmotion` - 回忆情感枚举

### 📁 Views/
- **FamilyTreeView.swift** - 主视图层
  - 星空家族树主界面
  - 动画控制逻辑
  - 布局管理

#### 📁 Components/
- **ShootingStarView.swift** - 流星动画组件
- **MemberPlanetView.swift** - 成员行星视图组件
- **ControlButton.swift** - 控制按钮组件

#### 📁 Memory/
- **MemoryGalleryView.swift** - 回忆画廊视图

#### 📁 Profile/
- **MemberProfileCard.swift** - 成员资料卡视图

## 功能模块说明

### 🎯 核心功能
1. **星空家族树展示** - 以行星轨道形式展示家族成员
2. **成员资料管理** - 查看和编辑家庭成员信息
3. **回忆系统** - 为每个成员添加和管理珍贵回忆
4. **动画效果** - 流星、粒子、轨道旋转等视觉效果

### 🎨 设计特色
- **星空主题** - 深空渐变背景配合星星和星云效果
- **行星化展示** - 每个家族成员以独特颜色的行星形式展示
- **动态交互** - 点击、悬停、选中等多种交互状态
- **情感化设计** - 温馨的文案和温暖的色彩搭配

### 🔧 技术特点
- **模块化架构** - 清晰的职责分离，便于维护和扩展
- **响应式布局** - 适配不同屏幕尺寸
- **流畅动画** - 60fps的流畅动画效果
- **状态管理** - 完善的视图状态管理

## 使用说明

### 主要交互
1. **点击成员行星** - 查看成员详细资料
2. **底部控制按钮** - 暂停/继续动画、随机选择、回到中心
3. **资料卡操作** - 查看回忆、添加新回忆
4. **回忆管理** - 浏览、添加、编辑回忆内容

### 数据配置
家族成员数据在 `FamilyTreeView.swift` 的 `init()` 方法中配置，包括：
- 成员基本信息（姓名、性别、年龄等）
- 轨道位置（generation、position）
- 个性化设置（颜色、图标、回忆数等）

## 扩展建议

### 功能扩展
- 添加更多家族成员
- 实现真实的照片上传功能
- 添加家族关系连线
- 支持回忆分享功能

### 技术优化
- 集成Core Data进行数据持久化
- 添加网络同步功能
- 优化动画性能
- 增加单元测试覆盖

## 开发环境
- **Xcode**: 15.0+
- **iOS**: 17.0+
- **Swift**: 5.9+
- **SwiftUI**: 5.0+ 