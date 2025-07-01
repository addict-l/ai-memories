import SwiftUI

// MARK: - 添加回忆视图
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
    
    // MARK: - 子视图组件
    
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

// MARK: - 情感按钮组件
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