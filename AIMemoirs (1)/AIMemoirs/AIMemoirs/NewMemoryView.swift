import SwiftUI

struct ChatMessage: Identifiable {
    enum Sender {
        case user, ai
    }
    let id = UUID()
    let sender: Sender
    let text: String
}

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
    @StateObject private var memoryManager = MemoryManager.shared
    
    // 示例家族成员
    let familyMembers: [FamilyMember] = [
        FamilyMember(name: "我", gender: .male, generation: 2, parentIds: [], childrenIds: []),
        FamilyMember(name: "爷爷", gender: .male, generation: 0, parentIds: [], childrenIds: []),
        FamilyMember(name: "奶奶", gender: .female, generation: 0, parentIds: [], childrenIds: []),
        FamilyMember(name: "爸爸", gender: .male, generation: 1, parentIds: [], childrenIds: []),
        FamilyMember(name: "妈妈", gender: .female, generation: 1, parentIds: [], childrenIds: []),
        FamilyMember(name: "大舅", gender: .male, generation: 1, parentIds: [], childrenIds: []),
        FamilyMember(name: "大姨", gender: .female, generation: 1, parentIds: [], childrenIds: []),
        FamilyMember(name: "二舅", gender: .male, generation: 1, parentIds: [], childrenIds: [])
    ]
    
    func resetAfter(step: Step) {
        switch step {
        case .selectPerson:
            selectedDate = Date()
            userInput = ""
            aiResponse = ""
            chatMessages = []
            isChatFinished = false
        case .selectDate:
            userInput = ""
            aiResponse = ""
            chatMessages = []
            isChatFinished = false
        case .aiChat:
            break
        }
    }
    
    // 模拟AI多轮引导
    @State private var aiStep: Int = 0
    let aiQuestions = [
        "请简单描述这一天发生的主要事件。",
        "这个事件发生在什么地点？",
        "有哪些重要的人参与了这个事件？",
        "你觉得这个事件对你或家人有什么影响？",
        "还有什么细节想补充吗？如果没有可以直接点击生成事件。"
    ]
    
    func sendUserMessage() {
        guard !userInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        chatMessages.append(ChatMessage(sender: .user, text: userInput))
        userInput = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            nextAIMessage()
        }
    }
    
    func nextAIMessage() {
        if aiStep < aiQuestions.count {
            chatMessages.append(ChatMessage(sender: .ai, text: aiQuestions[aiStep]))
            aiStep += 1
            if aiStep == aiQuestions.count {
                isChatFinished = true
            }
        }
    }
    
    func startChatIfNeeded() {
        if chatMessages.isEmpty && aiStep == 0 {
            nextAIMessage()
        }
    }
    
    // 生成回忆标题
    func generateTitle(from content: String) -> String {
        // 简单的标题生成逻辑
        let sentences = content.components(separatedBy: ["。", "！", "？", ".", "!", "?"])
        if let firstSentence = sentences.first, !firstSentence.trimmingCharacters(in: .whitespaces).isEmpty {
            let trimmed = firstSentence.trimmingCharacters(in: .whitespaces)
            if trimmed.count > 15 {
                return String(trimmed.prefix(15)) + "..."
            } else {
                return trimmed
            }
        }
        
        // 如果没有找到合适的句子，使用前20个字符
        if content.count > 20 {
            return String(content.prefix(20)) + "..."
        } else {
            return content
        }
    }
    
    // 创建新的回忆事件
    func createMemoryEvent() {
        // 从AI结构化结果中提取内容
        let lines = aiResponse.components(separatedBy: "\n")
        var content = ""
        var title = ""
        
        for line in lines {
            if line.hasPrefix("标题：") {
                title = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
            } else if line.hasPrefix("内容：") {
                content = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
            }
        }
        
        // 如果没有找到内容，使用用户输入的内容
        if content.isEmpty {
            content = chatMessages.filter { $0.sender == .user }.map { $0.text }.joined(separator: "\n")
        }
        
        // 如果没有找到标题，生成标题
        if title.isEmpty {
            title = generateTitle(from: content)
        }
        
        // 创建新的回忆事件并保存
        let newEvent = MemoryEvent(
            personName: selectedPerson?.name ?? "",
            date: selectedDate,
            content: content,
            title: title
        )
        
        memoryManager.addMemoryEvent(newEvent)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部进度指示（可点击）
            HStack(spacing: 16) {
                ForEach(Step.allCases, id: \ .rawValue) { s in
                    Button(action: {
                        if s.rawValue <= step.rawValue {
                            step = s
                            resetAfter(step: s)
                        }
                    }) {
                        StepCircle(title: s.title, isActive: step == s, isCompleted: s.rawValue < step.rawValue)
                    }
                    if s != .aiChat {
                        Rectangle().frame(width: 24, height: 2).foregroundColor(.gray.opacity(0.3))
                    }
                }
            }
            .padding(.top, 32)
            .padding(.bottom, 24)
            
            Spacer(minLength: 20)
            
            // 步骤内容
            Group {
                switch step {
                case .selectPerson:
                    VStack(spacing: 24) {
                        Text("请选择回忆对象")
                            .font(.title2).bold()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(familyMembers, id: \ .id) { member in
                                    Button(action: {
                                        selectedPerson = member
                                        step = .selectDate
                                    }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: member.gender == .male ? "person.circle.fill" : "person.circle")
                                                .resizable()
                                                .frame(width: 48, height: 48)
                                                .foregroundColor(member.gender == .male ? .blue.opacity(0.7) : .pink.opacity(0.7))
                                            Text(member.name)
                                                .font(.system(size: 14))
                                                .foregroundColor(.black)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.8)
                                                .frame(height: 20)
                                        }
                                        .padding(10)
                                        .frame(width: 80, height: 100)
                                        .background(selectedPerson?.id == member.id ? Color.blue.opacity(0.15) : Color.white)
                                        .cornerRadius(16)
                                        .shadow(color: .gray.opacity(0.08), radius: 4, x: 0, y: 2)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                case .selectDate:
                    VStack(spacing: 32) {
                        Text("请选择回忆发生的时间")
                            .font(.title2).bold()
                        DatePicker("选择日期", selection: $selectedDate, displayedComponents: [.date])
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                            .padding(.horizontal, 24)
                        Button(action: { step = .aiChat }) {
                            Text("下一步")
                                .font(.headline)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 14)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                        .padding(.top, 10)
                    }
                case .aiChat:
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: selectedPerson?.gender == .male ? "person.circle.fill" : "person.circle")
                                .resizable()
                                .frame(width: 36, height: 36)
                                .foregroundColor(selectedPerson?.gender == .male ? .blue.opacity(0.7) : .pink.opacity(0.7))
                            VStack(alignment: .center) {
                                Text("描述那天发生了什么")
                                    .font(.title2).bold()
                                Text(selectedDate, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(.bottom, 8)
                        // 聊天区
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(chatMessages) { msg in
                                    HStack {
                                        if msg.sender == .ai {
                                            Image(systemName: "sparkles")
                                                .foregroundColor(.purple)
                                        }
                                        Text(msg.text)
                                            .padding(10)
                                            .background(msg.sender == .user ? Color.blue.opacity(0.15) : Color.purple.opacity(0.08))
                                            .foregroundColor(.black)
                                            .cornerRadius(12)
                                        if msg.sender == .user {
                                            Spacer(minLength: 20)
                                            Image(systemName: "person.fill")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: msg.sender == .user ? .trailing : .leading)
                                }
                            }
                        }
                        .frame(minHeight: 180, maxHeight: 260)
                        .background(Color.gray.opacity(0.04))
                        .cornerRadius(12)
                        .onAppear { startChatIfNeeded() }
                        // 输入区
                        if !isChatFinished {
                            HStack {
                                TextField("请输入...", text: $userInput)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Button(action: sendUserMessage) {
                                    Image(systemName: "paperplane.fill")
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.blue)
                                        .cornerRadius(8)
                                }
                            }
                        } else {
                            Button(action: {
                                // 生成结构化事件
                                let userContents = chatMessages.filter { $0.sender == .user }.map { $0.text }.joined(separator: "\n")
                                let title = generateTitle(from: userContents)
                                aiResponse = "【结构化事件】\n对象：\(selectedPerson?.name ?? "")\n时间：\(selectedDate.formatted(date: .long, time: .omitted))\n标题：\(title)\n内容：\n\(userContents)"
                            }) {
                                Text("生成事件")
                                    .font(.subheadline)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 10)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                            }
                        }
                        // 结构化事件展示
                        if !aiResponse.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 12) {
                                        // 解析结构化内容
                                        let lines = aiResponse.components(separatedBy: "\n")
                                        ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
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
                                    .padding(16)
                                }
                                .frame(maxHeight: 200)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.purple.opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                                        )
                                )
                                
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        // 创建新的回忆事件
                                        createMemoryEvent()
                                        showingTimeLine = true
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "heart.fill")
                                                .font(.system(size: 14))
                                            Text("保存回忆")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(Color.purple)
                                        .foregroundColor(.white)
                                        .cornerRadius(20)
                                    }
                                    Spacer()
                                }
                            }
                            .padding(.top, 16)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .animation(.easeInOut, value: step)
            Spacer()
        }
        .sheet(isPresented: $showingTimeLine) {
            if let person = selectedPerson {
                TimeLineView(selectedPerson: person)
            }
        }
    }
}

struct StepCircle: View {
    let title: String
    let isActive: Bool
    let isCompleted: Bool
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(isActive ? Color.blue : (isCompleted ? Color.green : Color.gray.opacity(0.2)))
                .frame(width: 16, height: 16)
            Text(title)
                .font(.caption)
                .foregroundColor(isActive ? .blue : (isCompleted ? .green : .gray))
        }
    }
}

#Preview {
    NewMemoryView()
} 
