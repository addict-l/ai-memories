import SwiftUI
import PhotosUI

struct ChatMessage: Identifiable {
    enum Sender {
        case user, ai
    }
    let id = UUID()
    let sender: Sender
    let text: String
}

// MARK: - 分离子视图组件
struct PersonSelectionView: View {
    let familyMembers: [FamilyMember]
    @Binding var selectedPerson: FamilyMember?
    let onPersonSelected: () -> Void
    @State private var searchText = ""
    @State private var showingSearch = false
    
    private var filteredMembers: [FamilyMember] {
        if searchText.isEmpty {
            return familyMembers
        } else {
            return familyMembers.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 简洁标题区域
            VStack(spacing: 8) {
                Text("选择回忆对象")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("选择与你分享美好时光的人")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 8)
            .padding(.bottom, 12)
            
            // 现代化搜索栏
            if familyMembers.count > 6 {
                VStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            showingSearch.toggle()
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text(showingSearch ? "收起搜索" : "搜索家庭成员")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: showingSearch ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black.opacity(0.2))
                                .background(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.white.opacity(0.2), Color.blue.opacity(0.1)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if showingSearch {
                        HStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16))
                                .foregroundColor(.cyan)
                            
                            TextField("输入名字搜索...", text: $searchText)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .textFieldStyle(PlainTextFieldStyle())
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        searchText = ""
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black.opacity(0.25))
                                .background(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.cyan.opacity(0.3), Color.blue.opacity(0.2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            
            // 可滚动的人员选择区域
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 16) {
                    ForEach(filteredMembers, id: \.id) { member in
                        PersonCard(
                            member: member, 
                            isSelected: selectedPerson?.id == member.id
                        ) {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                selectedPerson = member
                            }
                            
                            // 添加触觉反馈
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                onPersonSelected()
                            }
                        }
                    }
                                    }
                                    .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .scrollContentBackground(.hidden)
        }
    }
}

struct PersonCard: View {
    let member: FamilyMember
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    @State private var isHovering = false
    
    private var avatarGradient: LinearGradient {
        member.gender == .male 
            ? LinearGradient(
                colors: [.blue.opacity(0.9), .cyan.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            : LinearGradient(
                colors: [.pink.opacity(0.9), .purple.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
    }
    
    private var cardBackground: some View {
        ZStack {
            // 主背景
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    isSelected 
                        ? LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.blue.opacity(0.08),
                                Color.purple.opacity(0.06)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [
                                Color.black.opacity(0.2),
                                Color.black.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                )
                .background(.ultraThinMaterial)
            
            // 选中时的光效边框
            if isSelected {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.cyan.opacity(0.6),
                                Color.blue.opacity(0.4),
                                Color.purple.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            } else {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.1), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 14) {
                // 增强的头像区域
                ZStack {
                    // 光晕效果
                    if isSelected {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        member.gender == .male ? Color.blue.opacity(0.3) : Color.pink.opacity(0.3),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 40
                                )
                            )
                            .frame(width: 80, height: 80)
                            .blur(radius: 8)
                    }
                    
                    // 主头像
                    Circle()
                        .fill(avatarGradient)
                        .frame(width: 64, height: 64)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.4), Color.clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(
                            color: member.gender == .male ? .blue.opacity(0.4) : .pink.opacity(0.4),
                            radius: isSelected ? 12 : 6,
                            x: 0,
                            y: isSelected ? 6 : 3
                        )
                    
                    // 头像图标
                    Image(systemName: member.gender == .male ? "person.fill" : "person")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    
                    // 选中标记
                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.green)
                                    .background(Circle().fill(Color.white))
                                    .scaleEffect(isSelected ? 1.0 : 0.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                            }
                            Spacer()
                        }
                        .frame(width: 64, height: 64)
                    }
                }
                .scaleEffect(isSelected ? 1.1 : (isHovering ? 1.05 : 1.0))
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isHovering)
                
                // 优化的名称显示
                VStack(spacing: 4) {
                    Text(member.name)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    // 关系标识
                    Text(member.gender == .male ? "👨" : "👩")
                        .font(.caption)
                        .opacity(0.8)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .frame(width: 100, height: 130)
            .background(cardBackground)
            .shadow(
                color: isSelected 
                    ? (member.gender == .male ? .blue.opacity(0.3) : .pink.opacity(0.3))
                    : .black.opacity(0.15),
                radius: isSelected ? 16 : 8,
                x: 0,
                y: isSelected ? 8 : 4
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .onLongPressGesture(minimumDuration: 0) {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }
    }
}

struct DateSelectionView: View {
    @Binding var selectedDate: Date
    let onNext: () -> Void
    @State private var showingDatePicker = false
    @State private var dateAnimation = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                // 简洁标题区域
                VStack(spacing: 8) {
                    Text("选择回忆时间")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("这个美好的时刻发生在什么时候")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 8)
                .padding(.bottom, 12)
                

                                
                // 精美的日期选择卡片
                Button(action: { 
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showingDatePicker.toggle() 
                    }
                    
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }) {
                    ZStack {
                        // 主卡片背景
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.black.opacity(0.15),
                                        Color.orange.opacity(0.05),
                                        Color.pink.opacity(0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .background(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.orange.opacity(0.4),
                                                Color.pink.opacity(0.3),
                                                Color.purple.opacity(0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                        
                        HStack(spacing: 20) {
                            // 日历图标区
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.orange.opacity(0.8), .pink.opacity(0.6)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 56, height: 56)
                                    .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                                
                                Image(systemName: "calendar")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            
                            // 日期信息区
                            VStack(alignment: .leading, spacing: 6) {
                                Text("选中的日期")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.7))
                                    .textCase(.uppercase)
                                    .kerning(0.5)
                                
                                Text(selectedDate.formatted(date: .complete, time: .omitted))
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.9)
                            }
                            
                            Spacer()
                            
                            // 操作指示
                            VStack(spacing: 4) {
                                Image(systemName: "hand.tap.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Text("点击")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        .padding(20)
                    }
                    .shadow(
                        color: Color.orange.opacity(0.2),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(showingDatePicker ? 0.98 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showingDatePicker)
                .padding(.horizontal, 16)
                
                Spacer()
                
                // 梦幻的下一步按钮
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                    impactFeedback.impactOccurred()
                    
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        onNext()
                    }
                }) {
                    ZStack {
                        // 主按钮背景
                        RoundedRectangle(cornerRadius: 32)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.orange.opacity(0.9),
                                        Color.pink.opacity(0.8),
                                        Color.purple.opacity(0.7)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        // 光效叠加
                        RoundedRectangle(cornerRadius: 32)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.2),
                                        Color.clear,
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        // 按钮内容
                        HStack(spacing: 16) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 18, weight: .medium))
                            
                            Text("开始记录回忆")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 20, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.4),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: Color.orange.opacity(0.4),
                        radius: 20,
                        x: 0,
                        y: 10
                    )
                    .shadow(
                        color: Color.pink.opacity(0.3),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            

        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showingDatePicker)
        .sheet(isPresented: $showingDatePicker) {
            DatePickerPage(selectedDate: $selectedDate)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - 快速日期选择按钮
struct QuickDateButton: View {
    let title: String
    let date: Date
    let icon: String
    let tempDate: Date
    let onSelect: () -> Void
    
    private var isSelected: Bool {
        Calendar.current.isDate(tempDate, inSameDayAs: date)
    }
    
    private var iconColor: Color {
        isSelected ? .white : .orange
    }
    
    private var titleColor: Color {
        isSelected ? .white : .primary
    }
    
    private var subtitleColor: Color {
        isSelected ? .white.opacity(0.8) : .secondary
    }
    
    private var backgroundGradient: LinearGradient {
        if isSelected {
            return LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing)
        } else {
            return LinearGradient(colors: [.gray.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
        }
    }
    
    private var shadowColor: Color {
        isSelected ? .orange.opacity(0.4) : .black.opacity(0.1)
    }
    
    private var shadowRadius: CGFloat {
        isSelected ? 8 : 4
    }
    
    private var shadowOffset: CGFloat {
        isSelected ? 4 : 2
    }
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(titleColor)
                    
                    Text(date.formatted(.dateTime.month(.abbreviated).day()))
                        .font(.system(size: 13))
                        .foregroundColor(subtitleColor)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundGradient)
                    .shadow(
                        color: shadowColor,
                        radius: shadowRadius,
                        x: 0,
                        y: shadowOffset
                    )
            )
        }
    }
}

// MARK: - 日期选择页面
struct DatePickerPage: View {
    @Binding var selectedDate: Date
    @State private var tempDate: Date = Date()
    @Environment(\.dismiss) private var dismiss
    
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        self._tempDate = State(initialValue: selectedDate.wrappedValue)
    }
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.8),
                Color.purple.opacity(0.7),
                Color.black
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var confirmButtonGradient: LinearGradient {
        LinearGradient(
            colors: [.orange, .pink],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景渐变
                backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 28) {
                        // 头部标题
                        VStack(spacing: 12) {
                            Text("选择日期")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("选择回忆发生的时间")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 20)
                        
                        // 日期选择器
                        VStack(spacing: 20) {
                            DatePicker("选择日期", selection: $tempDate, displayedComponents: [.date])
                                .datePickerStyle(.graphical)
                                .labelsHidden()
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.ultraThinMaterial)
                                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                )
                                .padding(.horizontal, 20)
                            
                            // 快捷日期选择
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("快速选择")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                                    ForEach([
                                        ("今天", Date(), "sun.max.fill"),
                                        ("昨天", Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), "moon.fill"),
                                        ("一周前", Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(), "calendar.badge.clock"),
                                        ("一个月前", Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(), "calendar.badge.minus")
                                    ], id: \.0) { title, date, icon in
                                        QuickDateButton(
                                            title: title,
                                            date: date,
                                            icon: icon,
                                            tempDate: tempDate,
                                            onSelect: {
                                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                    tempDate = date
                                                }
                                                
                                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                                impactFeedback.impactOccurred()
                                            }
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // 底部确认按钮
                        Button(action: {
                            selectedDate = tempDate
                            
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            
                            dismiss()
                        }) {
                            HStack(spacing: 12) {
                                Text("确认选择")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(confirmButtonGradient)
                            .cornerRadius(25)
                            .shadow(color: .orange.opacity(0.4), radius: 12, x: 0, y: 6)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct ChatView: View {
    let selectedPerson: FamilyMember?
    let selectedDate: Date
    @Binding var chatMessages: [ChatMessage]
    @Binding var userInput: String
    @Binding var isChatFinished: Bool
    @Binding var aiResponse: String
    @Binding var selectedImageName: String?
    @Binding var selectedImageData: Data?
    @Binding var selectedPhotoItem: PhotosPickerItem?
    let aiQuestions: [String]
    @Binding var aiStep: Int
    let onSaveMemory: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 高级聊天背景
                MessagesBackground()
                
                VStack(spacing: 0) {
                    // 固定头部
                    ChatHeaderView(selectedPerson: selectedPerson, selectedDate: selectedDate)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                        .background(
                            ZStack {
                                Color.black.opacity(0.2)
                                    .background(.ultraThinMaterial)
                                
                                // 顶部渐变装饰
                                LinearGradient(
                                    colors: [Color.white.opacity(0.05), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            }
                        )
                    
                    // 可滚动内容区
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(spacing: 16) {
                                // 聊天指导提示
                                if chatMessages.isEmpty {
                                    WelcomeMessageView()
                                        .id("guidance")
                                        .padding(.top, 20)
                                }
                                
                                // 聊天消息区域
                                if !chatMessages.isEmpty {
                                    ForEach(chatMessages) { message in
                                        ModernMessageRow(message: message)
                                            .transition(.asymmetric(
                                                insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.8)),
                                                removal: .opacity.combined(with: .scale(scale: 0.8))
                                            ))
                                    }
                                    .id("messages")
                                }
                                
                                // 输入区域或图片选择区域
                                if !isChatFinished {
                                    VStack(spacing: 16) {
                                        // 重新开始对话按钮
                                        if !chatMessages.isEmpty {
                                            RestartChatButton {
                                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                                    chatMessages = []
                                                    userInput = ""
                                                    aiResponse = ""
                                                    isChatFinished = false
                                                    aiStep = 0
                                                }
                                                
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    if aiStep < aiQuestions.count {
                                                        chatMessages.append(ChatMessage(sender: .ai, text: aiQuestions[aiStep]))
                                                        aiStep += 1
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .id("input")
                                } else {
                                    VStack(spacing: 20) {
                                        ImageSelectionView(
                                            selectedImageData: $selectedImageData,
                                            selectedImageName: $selectedImageName,
                                            selectedPhotoItem: $selectedPhotoItem
                                        )
                                        
                                        GenerateEventButton(onGenerate: generateEvent)
                                    }
                                    .id("imageSelection")
                                }
                                
                                // 事件预览区域
                                if !aiResponse.isEmpty {
                                    EventPreviewView(aiResponse: aiResponse, onSave: onSaveMemory)
                                        .id("preview")
                                }
                                
                                // 底部安全间距
                                Spacer()
                                    .frame(height: 100)
                            }
                            .padding(.horizontal, 16)
                        }
                        .scrollContentBackground(.hidden)
                        .onAppear {
                            // 滚动到底部
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    if !chatMessages.isEmpty {
                                        proxy.scrollTo(chatMessages.last?.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                        .onChange(of: chatMessages.count) { _, _ in
                            withAnimation(.easeOut(duration: 0.5)) {
                                if let lastMessage = chatMessages.last {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                        .onChange(of: isChatFinished) { _, finished in
                            if finished {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    proxy.scrollTo("imageSelection", anchor: .center)
                                }
                            }
                        }
                        .onChange(of: aiResponse) { _, response in
                            if !response.isEmpty {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    proxy.scrollTo("preview", anchor: .bottom)
                                }
                            }
                        }
                    }
                    
                    // 固定在底部的输入框
                    if !isChatFinished {
                        ModernChatInputView(userInput: $userInput, onSend: sendUserMessage)
                            .padding(.horizontal, 16)
                            .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 0 : 16)
                            .background(
                                ZStack {
                                    Color.black.opacity(0.2)
                                        .background(.ultraThinMaterial)
                                    
                                    // 底部渐变装饰
                                    LinearGradient(
                                        colors: [Color.clear, Color.white.opacity(0.03)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                }
                            )
                    }
                }
            }
        }
        .onAppear { 
            startChatIfNeeded()
        }
    }
    
    private func sendUserMessage() {
        guard !userInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        chatMessages.append(ChatMessage(sender: .user, text: userInput))
        userInput = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            nextAIMessage()
        }
    }
    
    private func nextAIMessage() {
        if aiStep < aiQuestions.count {
            chatMessages.append(ChatMessage(sender: .ai, text: aiQuestions[aiStep]))
            aiStep += 1
            if aiStep == aiQuestions.count {
                isChatFinished = true
            }
        }
    }
    
    private func startChatIfNeeded() {
        if chatMessages.isEmpty && aiStep == 0 {
            nextAIMessage()
        }
    }
    
    private func generateEvent() {
        let userContents = chatMessages.filter { $0.sender == .user }.map { $0.text }.joined(separator: "\n")
        
        // 如果用户没有输入任何内容，提供提示
        guard !userContents.trimmingCharacters(in: .whitespaces).isEmpty else {
            aiResponse = "【提示】\n请先回答AI的问题来描述这个回忆，然后再生成事件。"
            return
        }
        
        let title = generateTitle(from: userContents)
        let analysis = analyzeContent(userContents)
        let location = extractLocation(from: userContents)
        let people = extractPeople(from: userContents)
        let emotion = analyzeEmotion(from: userContents)
        
        // 生成更丰富的事件描述
        var eventDescription = "【结构化事件】\n"
        eventDescription += "对象：\(selectedPerson?.name ?? "未知")\n"
        eventDescription += "时间：\(selectedDate.formatted(date: .long, time: .omitted))\n"
        eventDescription += "标题：\(title)\n"
        
        if !location.isEmpty {
            eventDescription += "地点：\(location)\n"
        }
        
        if !people.isEmpty {
            eventDescription += "参与人员：\(people.joined(separator: "、"))\n"
        }
        
        if !emotion.isEmpty {
            eventDescription += "情感色彩：\(emotion)\n"
        }
        
        eventDescription += "内容：\n\(analysis)"
        
        aiResponse = eventDescription
    }
    
    private func analyzeContent(_ content: String) -> String {
        // 简单的内容分析和结构化
        let sentences = content.components(separatedBy: ["。", "！", "？", ".", "!", "?"])
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        if sentences.count <= 1 {
            return content
        }
        
        var structuredContent = ""
        for (_, sentence) in sentences.enumerated() {
            let trimmed = sentence.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty {
                structuredContent += "• \(trimmed)\n"
            }
        }
        
        return structuredContent.trimmingCharacters(in: .newlines)
    }
    
    private func extractLocation(from content: String) -> String {
        // 简单的地点提取逻辑
        let locationKeywords = ["在", "去", "到", "从"]
        let placeWords = ["家", "学校", "公园", "海边", "山上", "商场", "医院", "餐厅", "操场", "教室"]
        
        for keyword in locationKeywords {
            if let range = content.range(of: keyword) {
                let afterKeyword = String(content[range.upperBound...])
                for place in placeWords {
                    if afterKeyword.contains(place) {
                        return place
                    }
                }
            }
        }
        
        return ""
    }
    
    private func extractPeople(from content: String) -> [String] {
        // 简单的人物提取逻辑
        let peopleKeywords = ["爸爸", "妈妈", "爷爷", "奶奶", "哥哥", "姐姐", "弟弟", "妹妹", "老师", "同学", "朋友", "家人"]
        var foundPeople: [String] = []
        
        for person in peopleKeywords {
            if content.contains(person) && !foundPeople.contains(person) {
                foundPeople.append(person)
            }
        }
        
        return foundPeople
    }
    
    private func analyzeEmotion(from content: String) -> String {
        // 简单的情感分析
        let positiveWords = ["开心", "快乐", "高兴", "兴奋", "满足", "幸福", "愉快", "舒服", "美好", "棒", "好"]
        let negativeWords = ["难过", "伤心", "失望", "害怕", "紧张", "焦虑", "痛苦", "不开心", "沮丧"]
        let neutralWords = ["平静", "普通", "一般", "还好"]
        
        var positiveCount = 0
        var negativeCount = 0
        var neutralCount = 0
        
        for word in positiveWords {
            if content.contains(word) {
                positiveCount += 1
            }
        }
        
        for word in negativeWords {
            if content.contains(word) {
                negativeCount += 1
            }
        }
        
        for word in neutralWords {
            if content.contains(word) {
                neutralCount += 1
            }
        }
        
        if positiveCount > negativeCount && positiveCount > neutralCount {
            return "积极正面 😊"
        } else if negativeCount > positiveCount && negativeCount > neutralCount {
            return "需要关怀 😔"
        } else if neutralCount > 0 {
            return "平静淡然 😌"
        } else {
            return "复杂情感 🤔"
        }
    }
    
    private func generateTitle(from content: String) -> String {
        let sentences = content.components(separatedBy: ["。", "！", "？", ".", "!", "?"])
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        if let firstSentence = sentences.first {
            let trimmed = firstSentence.trimmingCharacters(in: .whitespaces)
            return trimmed.count > 15 ? String(trimmed.prefix(15)) + "..." : trimmed
        }
        
        return content.count > 20 ? String(content.prefix(20)) + "..." : content
    }
}

// MARK: - 现代化聊天组件
struct MessagesBackground: View {
    var body: some View {
        ZStack {
            // 与HomeView一致的深色星空背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.8), 
                    Color.purple.opacity(0.7), 
                    Color.black
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // 星空装饰效果
            GeometryReader { geometry in
                ZStack {
                    // 流动的光晕效果
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.blue.opacity(0.15), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 150
                            )
                        )
                        .frame(width: 300, height: 300)
                        .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.2)
                        .blur(radius: 30)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.purple.opacity(0.12), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.6)
                        .blur(radius: 25)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.cyan.opacity(0.08), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .position(x: geometry.size.width * 0.6, y: geometry.size.height * 0.8)
                        .blur(radius: 35)
                }
            }
            
            // 微妙的星点装饰
            ForEach(0..<20, id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 2...4))
                            .repeatForever(autoreverses: true),
                        value: UUID()
                    )
            }
        }
    }
}

struct WelcomeMessageView: View {
    var body: some View {
        VStack(spacing: 20) {
            // 图标
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.15), .purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: .blue.opacity(0.1), radius: 20, x: 0, y: 10)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // 文字内容
            VStack(spacing: 12) {
                Text("开始记录美好回忆")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("AI助手会通过几个简单的问题\n帮助您详细记录这段珍贵的时光")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
        }
        .padding(.horizontal, 40)
    }
}

struct ModernMessageRow: View {
    let message: ChatMessage
    @State private var isVisible = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            if message.sender == .ai {
                // AI头像
                AIAvatar()
                
                // AI消息气泡
                AIMessageBubble(text: message.text)
                
                Spacer(minLength: 60)
            } else {
                Spacer(minLength: 60)
                
                // 用户消息气泡
                UserMessageBubble(text: message.text)
            }
        }
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(isVisible ? 1 : 0.8, anchor: message.sender == .ai ? .bottomLeading : .bottomTrailing)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                isVisible = true
            }
        }
    }
}

struct AIAvatar: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.6), .blue.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 32, height: 32)
                .shadow(color: .purple.opacity(0.3), radius: 4, x: 0, y: 2)
            
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

struct AIMessageBubble: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .regular))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    // 玻璃拟态背景
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.25))
                        .background(.ultraThinMaterial)
                    
                    // 微光边框
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.2), Color.blue.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            .frame(maxWidth: 280, alignment: .leading)
    }
}

struct UserMessageBubble: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .regular))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    // 主渐变背景
                    LinearGradient(
                        colors: [Color.blue.opacity(0.9), Color.purple.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // 微光效果
                    LinearGradient(
                        colors: [Color.white.opacity(0.1), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                }
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 20)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .blue.opacity(0.4), radius: 12, x: 0, y: 6)
            .frame(maxWidth: 280, alignment: .trailing)
    }
}

struct ModernChatInputView: View {
    @Binding var userInput: String
    let onSend: () -> Void
    @FocusState private var isTextFieldFocused: Bool
    @State private var textHeight: CGFloat = 40
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            // 输入框容器
            HStack(alignment: .bottom, spacing: 8) {
                // 多行文本输入框
                ZStack(alignment: .topLeading) {
                    // 背景
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.3))
                        .background(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    isTextFieldFocused 
                                        ? LinearGradient(
                                            colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.4)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                        : LinearGradient(
                                            colors: [Color.white.opacity(0.2), Color.white.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                    lineWidth: isTextFieldFocused ? 2 : 1
                                )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    // 占位符
                    if userInput.isEmpty && !isTextFieldFocused {
                        Text("分享你的想法...")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                    }
                    
                    // 文本输入框
                    TextField("", text: $userInput, axis: .vertical)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .focused($isTextFieldFocused)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .lineLimit(1...6)
                        .submitLabel(.send)
                        .onSubmit {
                            if !userInput.trimmingCharacters(in: .whitespaces).isEmpty {
                                onSend()
                            }
                        }
                }
                .frame(minHeight: 40)
                .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
            }
            
            // 发送按钮
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                isTextFieldFocused = false
                onSend()
            }) {
                ZStack {
                    Circle()
                        .fill(
                            userInput.trimmingCharacters(in: .whitespaces).isEmpty
                                ? LinearGradient(
                                    colors: [.gray.opacity(0.4), .gray.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [.blue.opacity(0.9), .purple.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    userInput.trimmingCharacters(in: .whitespaces).isEmpty
                                        ? LinearGradient(
                                            colors: [Color.clear, Color.clear],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                        : LinearGradient(
                                            colors: [Color.white.opacity(0.3), Color.clear],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(
                            color: userInput.trimmingCharacters(in: .whitespaces).isEmpty 
                                ? .black.opacity(0.2) 
                                : .blue.opacity(0.4),
                            radius: userInput.trimmingCharacters(in: .whitespaces).isEmpty ? 4 : 8,
                            x: 0,
                            y: userInput.trimmingCharacters(in: .whitespaces).isEmpty ? 2 : 4
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .disabled(userInput.trimmingCharacters(in: .whitespaces).isEmpty)
            .scaleEffect(userInput.trimmingCharacters(in: .whitespaces).isEmpty ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: userInput.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.vertical, 8)
    }
}

struct RestartChatButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 14, weight: .medium))
                
                Text("重新开始对话")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.25))
                    .background(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.2), Color.blue.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ChatHeaderView: View {
    let selectedPerson: FamilyMember?
    let selectedDate: Date
    
    var body: some View {
        HStack(spacing: 16) {
            // 头像
            if let person = selectedPerson {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: person.gender == .male 
                                    ? [.blue.opacity(0.8), .cyan.opacity(0.6)]
                                    : [.pink.opacity(0.8), .purple.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: person.gender == .male ? "person.fill" : "person")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            
            // 信息区域
            VStack(alignment: .leading, spacing: 2) {
                Text("与 \(selectedPerson?.name ?? "")的回忆")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // 状态指示器
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                
                Text("AI助手")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.green)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(.clear)
        )
    }
}



struct ImageSelectionView: View {
    @Binding var selectedImageData: Data?
    @Binding var selectedImageName: String?
    @Binding var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                Text("为回忆添加图片")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("选择一张图片来记录这个美好时刻")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    PhotosPickerButton(
                        selectedPhotoItem: $selectedPhotoItem,
                        selectedImageData: $selectedImageData,
                        selectedImageName: $selectedImageName
                    )
                    
                    NoImageButton(
                        selectedImageName: $selectedImageName,
                        selectedImageData: $selectedImageData,
                        selectedPhotoItem: $selectedPhotoItem
                    )
                }
                
                PresetImagesView(
                    selectedImageName: $selectedImageName,
                    selectedImageData: $selectedImageData,
                    selectedPhotoItem: $selectedPhotoItem
                )
                
                if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                    ImagePreview(image: uiImage)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.gray.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
    }
}

struct PhotosPickerButton: View {
    @Binding var selectedPhotoItem: PhotosPickerItem?
    @Binding var selectedImageData: Data?
    @Binding var selectedImageName: String?
    @State private var isPressed = false
    
    var body: some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: selectedImageData != nil 
                                ? [.green.opacity(0.2), .green.opacity(0.1)]
                                : [.blue.opacity(0.15), .blue.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 24))
                            .foregroundColor(selectedImageData != nil ? .green : .blue)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                selectedImageData != nil 
                                    ? LinearGradient(colors: [.green, .green.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    : LinearGradient(colors: [.clear, .clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 2
                            )
                    )
                    .shadow(
                        color: selectedImageData != nil ? .green.opacity(0.3) : .blue.opacity(0.2), 
                        radius: selectedImageData != nil ? 8 : 4, 
                        x: 0, 
                        y: selectedImageData != nil ? 4 : 2
                    )
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                
                Text("本地图片")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(selectedImageData != nil ? .green : .primary)
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                await handleImageSelection(newItem)
            }
        }
    }
    

    
    @MainActor
    private func handleImageSelection(_ newItem: PhotosPickerItem?) async {
        guard let newItem = newItem else { return }
        
        do {
            if let data = try await newItem.loadTransferable(type: Data.self) {
                // 在后台线程压缩图片
                let compressedData = await compressImageInBackground(data)
                selectedImageData = compressedData
                selectedImageName = nil
            }
        } catch {
            print("图片加载失败: \(error)")
        }
    }
    
    private func compressImageInBackground(_ imageData: Data) async -> Data? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let result = compressImageData(imageData)
                continuation.resume(returning: result)
            }
        }
    }
    
    private func compressImageData(_ imageData: Data) -> Data? {
        guard let uiImage = UIImage(data: imageData) else { return nil }
        
        if imageData.count < 1024 * 1024 {
            return imageData
        }
        
        let maxSize: CGFloat = 1024
        let scale = min(maxSize / uiImage.size.width, maxSize / uiImage.size.height, 1.0)
        
        if scale < 1.0 {
            let newSize = CGSize(width: uiImage.size.width * scale, height: uiImage.size.height * scale)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            uiImage.draw(in: CGRect(origin: .zero, size: newSize))
            let compressedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return compressedImage?.jpegData(compressionQuality: 0.8)
        }
        
        return uiImage.jpegData(compressionQuality: 0.8)
    }
}

struct NoImageButton: View {
    @Binding var selectedImageName: String?
    @Binding var selectedImageData: Data?
    @Binding var selectedPhotoItem: PhotosPickerItem?
    @State private var isPressed = false
    
    var body: some View {
        Button(action: clearSelection) {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: isSelected 
                                ? [.gray.opacity(0.3), .gray.opacity(0.2)]
                                : [.gray.opacity(0.1), .gray.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 24))
                            .foregroundColor(isSelected ? .gray : .gray.opacity(0.6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected 
                                    ? LinearGradient(colors: [.gray, .gray.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    : LinearGradient(colors: [.clear, .clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 2
                            )
                    )
                    .shadow(
                        color: isSelected ? .gray.opacity(0.3) : .black.opacity(0.1), 
                        radius: isSelected ? 6 : 3, 
                        x: 0, 
                        y: isSelected ? 3 : 1
                    )
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                
                Text("无图片")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .gray : .secondary)
            }
        }
        .onLongPressGesture(minimumDuration: 0) {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }
    }
    
    private var isSelected: Bool {
        selectedImageName == nil && selectedImageData == nil
    }
    
    private func clearSelection() {
        selectedImageName = nil
        selectedImageData = nil
        selectedPhotoItem = nil
    }
}

struct PresetImagesView: View {
    @Binding var selectedImageName: String?
    @Binding var selectedImageData: Data?
    @Binding var selectedPhotoItem: PhotosPickerItem?
    
    private let presetImages = ["christmas_tree", "sports_medal", "beach_sunset", "bicycle_learning", "home_cooking"]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(presetImages, id: \.self) { imageName in
                    PresetImageButton(
                        imageName: imageName,
                        isSelected: selectedImageName == imageName,
                        action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                selectedImageName = imageName
                                selectedImageData = nil
                                selectedPhotoItem = nil
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 4)
        }
        .scrollContentBackground(.hidden)
    }
}

struct PresetImageButton: View {
    let imageName: String
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: isSelected 
                                ? [.blue.opacity(0.2), .purple.opacity(0.15)]
                                : [.blue.opacity(0.1), .blue.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: getSystemIconName(imageName))
                            .font(.system(size: 24))
                            .foregroundColor(isSelected ? .blue : .blue.opacity(0.6))
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected 
                                    ? LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    : LinearGradient(colors: [.clear, .clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 2
                            )
                    )
                    .shadow(
                        color: isSelected ? .blue.opacity(0.3) : .black.opacity(0.05),
                        radius: isSelected ? 8 : 4,
                        x: 0,
                        y: isSelected ? 4 : 2
                    )
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                
                Text(getImageDisplayName(imageName))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .blue : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .onLongPressGesture(minimumDuration: 0) {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }
    }
    
    private func getSystemIconName(_ imageName: String) -> String {
        switch imageName {
        case "christmas_tree": return "tree.fill"
        case "sports_medal": return "medal.fill"
        case "beach_sunset": return "sun.max.fill"
        case "bicycle_learning": return "bicycle"
        case "home_cooking": return "fork.knife"
        default: return "photo"
        }
    }
    
    private func getImageDisplayName(_ imageName: String) -> String {
        switch imageName {
        case "christmas_tree": return "圣诞树"
        case "sports_medal": return "运动奖牌"
        case "beach_sunset": return "海边日落"
        case "bicycle_learning": return "学自行车"
        case "home_cooking": return "家常菜"
        default: return imageName
        }
    }
}

struct ImagePreview: View {
    let image: UIImage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.green)
                
                Text("已选择的图片")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
                
                Spacer()
            }
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [.green.opacity(0.3), .green.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: .green.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct GenerateEventButton: View {
    let onGenerate: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            onGenerate()
        }) {
            HStack(spacing: 12) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 18))
                Text("生成美好回忆")
                    .font(.headline)
                    .fontWeight(.semibold)
                Image(systemName: "sparkles")
                    .font(.system(size: 16))
            }
            .foregroundColor(.white)
                                    .padding(.horizontal, 28)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [.purple, .pink, .orange],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(28)
            .shadow(color: .purple.opacity(0.4), radius: 12, x: 0, y: 6)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .onLongPressGesture(minimumDuration: 0) {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isPressed)
    }
}

struct EventPreviewView: View {
    let aiResponse: String
    let onSave: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                            .shadow(color: .purple.opacity(0.3), radius: 4, x: 0, y: 2)
                        
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("回忆预览")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("确认信息无误后保存")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                // 固定高度的滚动内容区域
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        let lines = aiResponse.components(separatedBy: "\n")
                        ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                            EventPreviewLine(line: line)
                        }
                    }
                    .padding(16)
                }
                .frame(height: 200)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.regularMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.gray.opacity(0.3), lineWidth: 1)
                        )
                )
                .scrollContentBackground(.hidden)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [.purple.opacity(0.3), .pink.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .purple.opacity(0.1), radius: 12, x: 0, y: 6)
            )
            
            SaveMemoryButton(onSave: onSave)
        }
        .padding(.top, 8)
    }
}

struct EventPreviewLine: View {
    let line: String
    
    var body: some View {
        if line.hasPrefix("对象：") || line.hasPrefix("时间：") || line.hasPrefix("内容：") {
            HStack(alignment: .top, spacing: 8) {
                Text(line.components(separatedBy: "：").first ?? "")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
                    .frame(width: 40, alignment: .leading)
                
                Text(line.components(separatedBy: "：").dropFirst().joined(separator: "："))
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
        } else if !line.isEmpty && !line.hasPrefix("【") && !line.hasSuffix("】") {
            Text(line)
                .font(.subheadline)
                .foregroundColor(.black)
                .padding(.leading, 48)
        }
    }
}

struct SaveMemoryButton: View {
    let onSave: () -> Void
    @State private var isPressed = false
    @State private var isSaved = false
    
    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isSaved = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onSave()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: isSaved ? "checkmark.circle.fill" : "heart.fill")
                    .font(.system(size: 20))
                    .scaleEffect(isSaved ? 1.2 : 1.0)
                
                Text(isSaved ? "保存成功！" : "保存美好回忆")
                    .font(.title3)
                    .fontWeight(.bold)
                
                if !isSaved {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16))
                }
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 18)
            .background(
                Group {
                    if isSaved {
                        LinearGradient(
                            colors: [.green, .green.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        LinearGradient(
                            colors: [.purple, .pink, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                }
            )
            .cornerRadius(30)
            .shadow(
                color: isSaved ? .green.opacity(0.4) : .purple.opacity(0.4), 
                radius: 16, 
                x: 0, 
                y: 8
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .disabled(isSaved)
        .onLongPressGesture(minimumDuration: 0) {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isPressed)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isSaved)
    }
}

// MARK: - 主视图
struct NewMemoryView: View {
    enum Step: Int, CaseIterable {
        case selectPerson = 0, selectDate, aiChat
        var title: String {
            switch self {
            case .selectPerson: return "选择对象"
            case .selectDate: return "选择时间"
            case .aiChat: return "AI对话"
            }
        }
    }
    
    @State private var step: Step = .selectPerson
    @State private var selectedPerson: FamilyMember? = nil
    @State private var selectedDate: Date = Date()
    @State private var chatMessages: [ChatMessage] = []
    @State private var userInput: String = ""
    @State private var aiResponse: String = ""
    @State private var isChatFinished: Bool = false
    @State private var showingTimeLine: Bool = false
    @State private var selectedImageName: String? = nil
    @State private var selectedImageData: Data? = nil
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @StateObject private var memoryManager = MemoryManager.shared
    @State private var aiStep: Int = 0
    @State private var selectedImages: [Data] = []
    @State private var isTyping: Bool = false
    @Binding var isShowingNewMemory: Bool
    
    init(isShowingNewMemory: Binding<Bool>) {
        self._isShowingNewMemory = isShowingNewMemory
    }
    
    // 示例家族成员 - 使用lazy初始化优化性能
    private let familyMembers: [FamilyMember] = [
        FamilyMember(name: "我", gender: .male, generation: 2, position: 0, parentIds: [], childrenIds: [], profileImages: ["person.crop.circle.fill", "gamecontroller.fill", "laptopcomputer"], memoryCount: 0, birthYear: 1995, description: "年轻一代，热爱科技和游戏", loveLevel: 4, specialTrait: "科技达人", planetColor: Color.green),
        FamilyMember(name: "爷爷", gender: .male, generation: 0, position: 0, parentIds: [], childrenIds: [], profileImages: ["person.crop.circle", "mustache", "glasses"], memoryCount: 0, birthYear: 1940, description: "慈祥的长者，喜欢下棋和讲故事", loveLevel: 5, specialTrait: "智慧长者", planetColor: Color.purple),
        FamilyMember(name: "奶奶", gender: .female, generation: 0, position: 1, parentIds: [], childrenIds: [], profileImages: ["person.crop.circle", "heart.circle", "house.circle"], memoryCount: 0, birthYear: 1942, description: "温柔贤惠，擅长烹饪和手工", loveLevel: 5, specialTrait: "温暖港湾", planetColor: Color.blue),
        FamilyMember(name: "爸爸", gender: .male, generation: 1, position: 0, parentIds: [], childrenIds: [], profileImages: ["person.crop.circle.fill", "car.circle", "briefcase.circle"], memoryCount: 0, birthYear: 1965, description: "勤劳的父亲，为家庭默默付出", loveLevel: 4, specialTrait: "坚强支柱", planetColor: Color.blue),
        FamilyMember(name: "妈妈", gender: .female, generation: 1, position: 1, parentIds: [], childrenIds: [], profileImages: ["person.crop.circle", "leaf.circle", "book.circle"], memoryCount: 0, birthYear: 1968, description: "温柔的母亲，总是关心着每个人", loveLevel: 5, specialTrait: "温暖阳光", planetColor: Color.blue),
        FamilyMember(name: "大舅", gender: .male, generation: 1, position: 2, parentIds: [], childrenIds: [], profileImages: ["person.crop.circle.fill", "figure.walk", "briefcase.fill"], memoryCount: 0, birthYear: 1963, description: "事业有成的舅舅，喜欢运动和户外活动", loveLevel: 3, specialTrait: "运动健将", planetColor: Color.blue),
        FamilyMember(name: "大姨", gender: .female, generation: 1, position: 3, parentIds: [], childrenIds: [], profileImages: ["person.crop.circle", "flower", "heart.text.square"], memoryCount: 0, birthYear: 1966, description: "温柔的大姨，热爱园艺和手工艺术", loveLevel: 4, specialTrait: "园艺达人", planetColor: Color.blue),
        FamilyMember(name: "二舅", gender: .male, generation: 1, position: 4, parentIds: [], childrenIds: [], profileImages: ["person.crop.circle.fill", "music.note.house", "sportscourt.circle"], memoryCount: 0, birthYear: 1969, description: "音乐爱好者，喜欢运动和户外活动", loveLevel: 3, specialTrait: "音乐才子", planetColor: Color.blue)
    ]
    
    private let aiQuestions = [
        "请简单描述这一天发生的主要事件。",
        "这个事件发生在什么地点？",
        "有哪些重要的人参与了这个事件？",
        "你觉得这个事件对你或家人有什么影响？",
        "还有什么细节想补充吗？如果没有可以直接点击生成事件。"
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 动态背景渐变
                LinearGradient(
                    colors: backgroundColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.0), value: step)
                
                // 背景装饰圆圈
                BackgroundDecoration()
                
                VStack(spacing: 0) {
                    // 顶部导航栏
                    HStack {
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 2)
                    
                    // 顶部进度指示
                    ProgressIndicatorView(step: step, onStepSelected: handleStepChange)
                        .padding(.bottom, 4)
                    
                    // 主要内容
                    Group {
                        switch step {
                        case .selectPerson:
                            PersonSelectionView(
                                familyMembers: familyMembers,
                                selectedPerson: $selectedPerson
                            ) {
                                withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                                    step = .selectDate
                                }
                            }
                        case .selectDate:
                            DateSelectionView(selectedDate: $selectedDate) {
                                withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                                    step = .aiChat
                                }
                            }
                        case .aiChat:
                            ChatView(
                                selectedPerson: selectedPerson,
                                selectedDate: selectedDate,
                                chatMessages: $chatMessages,
                                userInput: $userInput,
                                isChatFinished: $isChatFinished,
                                aiResponse: $aiResponse,
                                selectedImageName: $selectedImageName,
                                selectedImageData: $selectedImageData,
                                selectedPhotoItem: $selectedPhotoItem,
                                aiQuestions: aiQuestions,
                                aiStep: $aiStep,
                                onSaveMemory: createMemoryEvent
                            )
                            .onAppear {
                                // 确保进入聊天步骤时开始对话
                                if chatMessages.isEmpty && aiStep == 0 {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        if aiStep < aiQuestions.count {
                                            chatMessages.append(ChatMessage(sender: .ai, text: aiQuestions[aiStep]))
                                            aiStep += 1
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .animation(.spring(response: 0.8, dampingFraction: 0.8), value: step)
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showingTimeLine) {
            if let person = selectedPerson {
                TimeLineView(selectedPerson: person)
            }
        }
    }
    
    // 统一的深色星空背景
    private var backgroundColors: [Color] {
        // 与HomeView保持一致的深色星空主题
        return [
            Color.blue.opacity(0.8),
            Color.purple.opacity(0.7),
            Color.black
        ]
    }
    
    private func handleStepChange(to newStep: Step) {
        if newStep.rawValue <= step.rawValue {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                step = newStep
            }
            resetAfter(step: newStep)
        }
    }
    
    private func handleBackAction() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            if step.rawValue > 0 {
                step = Step(rawValue: step.rawValue - 1) ?? .selectPerson
            } else {
                isShowingNewMemory = false
            }
        }
    }
    
    private func resetAfter(step: Step) {
        switch step {
        case .selectPerson:
            selectedDate = Date()
            userInput = ""
            aiResponse = ""
            chatMessages = []
            isChatFinished = false
            selectedImageName = nil
            selectedImageData = nil
            selectedPhotoItem = nil
            aiStep = 0
        case .selectDate:
            userInput = ""
            aiResponse = ""
            chatMessages = []
            isChatFinished = false
            selectedImageName = nil
            selectedImageData = nil
            selectedPhotoItem = nil
            aiStep = 0
        case .aiChat:
            break
        }
    }
    
    // 优化的创建回忆事件方法
    private func createMemoryEvent() {
        guard let person = selectedPerson,
              !aiResponse.isEmpty,
              !aiResponse.contains("【提示】") else {
            return
        }
        
        // 解析结构化事件内容
        var eventTitle = ""
        var eventContent = ""
        var location = ""
        var participants: [String] = []
        var emotion = ""
        
        if aiResponse.contains("【结构化事件】") {
            // 解析结构化格式
            let lines = aiResponse.components(separatedBy: .newlines)
            var contentStarted = false
            var contentLines: [String] = []
            
            for line in lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                
                if trimmedLine.hasPrefix("标题：") {
                    eventTitle = String(trimmedLine.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                } else if trimmedLine.hasPrefix("地点：") {
                    location = String(trimmedLine.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                } else if trimmedLine.hasPrefix("参与人员：") {
                    let peopleString = String(trimmedLine.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                    participants = peopleString.components(separatedBy: "、").map { $0.trimmingCharacters(in: .whitespaces) }
                } else if trimmedLine.hasPrefix("情感色彩：") {
                    emotion = String(trimmedLine.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                } else if trimmedLine == "内容：" {
                    contentStarted = true
                } else if contentStarted && !trimmedLine.isEmpty {
                    contentLines.append(trimmedLine)
                }
            }
            
            eventContent = contentLines.joined(separator: "\n")
        } else {
            // 传统格式回退
            eventTitle = extractTitle(from: aiResponse)
            eventContent = aiResponse
        }
        
        // 如果没有提取到标题，生成一个
        if eventTitle.isEmpty {
            eventTitle = generateTitle(from: eventContent)
        }
        
        // 构建增强的内容描述
        var enhancedContent = ""
        
        if !location.isEmpty || !participants.isEmpty || !emotion.isEmpty {
            if !location.isEmpty {
                enhancedContent += "📍 地点：\(location)\n"
            }
            
            if !participants.isEmpty {
                enhancedContent += "👥 参与者：\(participants.joined(separator: "、"))\n"
            }
            
            if !emotion.isEmpty {
                enhancedContent += "💝 情感：\(emotion)\n"
            }
            
            enhancedContent += "\n📝 详细内容：\n\(eventContent)"
        } else {
            enhancedContent = eventContent
        }
        
        // 处理图片数据
        let imageData: Data?
        if let selectedData = selectedImageData {
            imageData = compressImageData(selectedData)
        } else {
            imageData = nil
        }
        let imageName = selectedImageName ?? getSystemIconName(for: eventContent, emotion: emotion)
        
        // 创建内存事件 - 使用现有的MemoryEvent结构
        let newEvent = MemoryEvent(
            personName: person.name,
            date: selectedDate,
            content: enhancedContent,
            title: eventTitle,
            imageName: imageName,
            imageData: imageData
        )
        
        // 添加到内存管理器
        memoryManager.addMemoryEvent(newEvent)
        
        // 重置状态
        resetViewState()
        
        #if DEBUG
        print("✅ 创建了新的内存事件: \(eventTitle)")
        print("📊 内容长度: \(enhancedContent.count) 字符")
        if !location.isEmpty {
            print("📍 地点: \(location)")
        }
        if !participants.isEmpty {
            print("👥 参与者: \(participants.joined(separator: ", "))")
        }
        #endif
    }
    
    private func getSystemIconName(for content: String, emotion: String) -> String {
        // 基于内容和情感选择合适的系统图标
        let lowerContent = content.lowercased()
        
        // 优先基于内容关键词
        if lowerContent.contains("生日") || lowerContent.contains("庆祝") {
            return "birthday"
        } else if lowerContent.contains("学习") || lowerContent.contains("学校") || lowerContent.contains("作业") {
            return "book"
        } else if lowerContent.contains("家") || lowerContent.contains("家人") {
            return "home"
        } else if lowerContent.contains("朋友") || lowerContent.contains("同学") {
            return "friends"
        } else if lowerContent.contains("旅行") || lowerContent.contains("去") || lowerContent.contains("公园") {
            return "travel"
        } else if lowerContent.contains("运动") || lowerContent.contains("体育") {
            return "sports"
        } else if lowerContent.contains("音乐") || lowerContent.contains("唱歌") {
            return "music"
        } else if lowerContent.contains("画画") || lowerContent.contains("艺术") {
            return "art"
        } else if lowerContent.contains("吃") || lowerContent.contains("美食") {
            return "food"
        }
        
        // 基于情感选择
        if emotion.contains("😊") {
            return "happy"
        } else if emotion.contains("😔") {
            return "growth"
        } else if emotion.contains("😌") {
            return "calm"
        } else {
            return "memory"
        }
    }
    
    private func extractTitle(from content: String) -> String {
        // 从传统格式中提取标题
        if content.contains("标题：") {
            let components = content.components(separatedBy: "标题：")
            if components.count > 1 {
                let titleLine = components[1].components(separatedBy: .newlines).first ?? ""
                return titleLine.trimmingCharacters(in: .whitespaces)
            }
        }
        
        return generateTitle(from: content)
    }
    
    private func resetViewState() {
        // 显示成功提示
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            // 重置所有状态
            selectedImageData = nil
            selectedImageName = nil
            selectedPhotoItem = nil
            chatMessages = []
            userInput = ""
            aiResponse = ""
            isChatFinished = false
            aiStep = 0
            selectedPerson = nil
            step = .selectPerson
        }
        
        // 延时关闭界面
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isShowingNewMemory = false
        }
    }
    

    

    
    private func generateTitle(from content: String) -> String {
        let sentences = content.components(separatedBy: ["。", "！", "？", ".", "!", "?"])
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        if let firstSentence = sentences.first {
            let trimmed = firstSentence.trimmingCharacters(in: .whitespaces)
            return trimmed.count > 15 ? String(trimmed.prefix(15)) + "..." : trimmed
        }
        
        return content.count > 20 ? String(content.prefix(20)) + "..." : content
    }
    
    private func compressImageData(_ imageData: Data) -> Data? {
        guard let uiImage = UIImage(data: imageData) else { return nil }
        
        if imageData.count < 1024 * 1024 {
            return imageData
        }
        
        let maxSize: CGFloat = 1024
        let scale = min(maxSize / uiImage.size.width, maxSize / uiImage.size.height, 1.0)
        
        if scale < 1.0 {
            let newSize = CGSize(width: uiImage.size.width * scale, height: uiImage.size.height * scale)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            uiImage.draw(in: CGRect(origin: .zero, size: newSize))
            let compressedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return compressedImage?.jpegData(compressionQuality: 0.8)
        }
        
        return uiImage.jpegData(compressionQuality: 0.8)
    }
}

struct BackgroundDecoration: View {
    @State private var shootingStarX: CGFloat = -100
    @State private var shootingStarY: CGFloat = 100
    @State private var starOpacity: Double = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 深层星空装饰
                ForEach(0..<30, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.1...0.3)))
                        .frame(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .opacity(starOpacity)
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 2...4))
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.1),
                            value: starOpacity
                        )
                }
                
                // 星云效果
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.blue.opacity(0.15), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.2)
                    .blur(radius: 30)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.purple.opacity(0.12), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.4)
                    .blur(radius: 25)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.cyan.opacity(0.08), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .position(x: geometry.size.width * 0.1, y: geometry.size.height * 0.7)
                    .blur(radius: 35)
                
                // 流星效果
                ShootingStarView(x: shootingStarX, y: shootingStarY)
                    .onAppear {
                        withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
                            shootingStarX = geometry.size.width + 100
                            shootingStarY = geometry.size.height * 0.7
                        }
                        
                        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                            starOpacity = 1.0
                        }
                    }
            }
        }
        .ignoresSafeArea()
    }
}



struct ProgressIndicatorView: View {
    let step: NewMemoryView.Step
    let onStepSelected: (NewMemoryView.Step) -> Void
    @State private var glowAnimation = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 现代化进度指示器
            HStack(spacing: 16) {
                ForEach(NewMemoryView.Step.allCases, id: \.rawValue) { s in
                    Button(action: { 
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        onStepSelected(s) 
                    }) {
                        StepIndicator(
                            step: s,
                            isActive: step == s,
                            isCompleted: s.rawValue < step.rawValue
                        )
                    }
                    .disabled(s.rawValue > step.rawValue)
                    
                    if s != .aiChat {
                        // 简洁连接线
                        ZStack {
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(Color.white.opacity(0.08))
                                .frame(height: 2)
                            
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(
                                    s.rawValue < step.rawValue 
                                        ? LinearGradient(
                                            colors: [.cyan.opacity(0.8), .blue.opacity(0.6)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        : LinearGradient(
                                            colors: [.clear, .clear],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                )
                                .frame(height: 2)
                                .scaleEffect(x: s.rawValue < step.rawValue ? 1.0 : 0.0, anchor: .leading)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: step)
                        }
                        .frame(width: 28)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        .onAppear {
            glowAnimation = true
        }
    }
}

struct StepIndicator: View {
    let step: NewMemoryView.Step
    let isActive: Bool
    let isCompleted: Bool
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // 外圈光晕（仅激活状态）
                if isActive {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [stepColor.opacity(0.2), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 25
                            )
                        )
                        .frame(width: 50, height: 50)
                        .scaleEffect(pulseAnimation ? 1.15 : 1.0)
                        .opacity(pulseAnimation ? 0.0 : 1.0)
                        .animation(
                            Animation.easeOut(duration: 1.8).repeatForever(autoreverses: false),
                            value: pulseAnimation
                        )
                }
                
                // 主圆圈背景
                Circle()
                    .fill(backgroundGradient)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(borderGradient, lineWidth: isActive ? 1.5 : 0.8)
                    )
                    .shadow(
                        color: shadowColor,
                        radius: isActive ? 8 : 4,
                        x: 0,
                        y: isActive ? 4 : 2
                    )
                
                // 图标或数字
                Group {
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .background(
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 24, height: 24)
                            )
                    } else {
                        ZStack {
                            // 数字背景
                            Circle()
                                .fill(isActive ? Color.white.opacity(0.2) : Color.clear)
                                .frame(width: 28, height: 28)
                            
                            Text("\(step.rawValue + 1)")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                }
                .scaleEffect(isActive ? 1.1 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isActive)
            }
            
            // 步骤标题
            Text(step.title)
                .font(.caption)
                .fontWeight(isActive ? .bold : .medium)
                .foregroundColor(isActive ? .white : .white.opacity(0.6))
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .onAppear {
            if isActive {
                pulseAnimation = true
            }
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                pulseAnimation = true
            }
        }
    }
    
    private var backgroundGradient: LinearGradient {
        if isCompleted {
            return LinearGradient(
                colors: [Color.green.opacity(0.9), Color.mint.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if isActive {
            return LinearGradient(
                colors: [stepColor.opacity(0.9), stepColor.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var borderGradient: LinearGradient {
        if isCompleted {
            return LinearGradient(
                colors: [Color.green, Color.mint],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if isActive {
            return LinearGradient(
                colors: [stepColor, stepColor.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.white.opacity(0.2), Color.white.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var stepColor: Color {
        switch step {
        case .selectPerson:
            return .cyan
        case .selectDate:
            return .orange
        case .aiChat:
            return .purple
        }
    }
    
    private var shadowColor: Color {
        if isCompleted {
            return .green.opacity(0.4)
        } else if isActive {
            return stepColor.opacity(0.4)
        } else {
            return .black.opacity(0.15)
        }
    }
}



#Preview {
    NewMemoryView(isShowingNewMemory: .constant(true))
} 

