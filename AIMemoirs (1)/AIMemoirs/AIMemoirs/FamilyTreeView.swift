import SwiftUI

// 性别枚举
enum Gender {
    case male
    case female
}

// 家庭成员模型
struct FamilyMember: Identifiable {
    let id = UUID()
    let name: String
    let gender: Gender
    let generation: Int
    var spouseId: UUID? // 配偶ID
    var parentIds: Set<UUID> // 父母ID集合
    var childrenIds: Set<UUID> // 子女ID集合
}

// 家族关系图
class FamilyGraph {
    var members: [UUID: FamilyMember]
    
    init() {
        self.members = [:]
    }
    
    func addMember(_ member: FamilyMember) {
        members[member.id] = member
    }
    
    func getSpouse(of memberId: UUID) -> FamilyMember? {
        guard let member = members[memberId],
              let spouseId = member.spouseId else { return nil }
        return members[spouseId]
    }
    
    func getChildren(of memberId: UUID) -> [FamilyMember] {
        guard let member = members[memberId] else { return [] }
        return member.childrenIds.compactMap { members[$0] }
    }
}

// 树枝连接线
struct TreeBranchLine: View {
    let isVertical: Bool
    
    var body: some View {
        Group {
            if isVertical {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addCurve(
                        to: CGPoint(x: 0, y: 20),
                        control1: CGPoint(x: 4, y: 7),
                        control2: CGPoint(x: -4, y: 13)
                    )
                }
                .stroke(Color(red: 139/255, green: 69/255, blue: 19/255), style: StrokeStyle(lineWidth: 2))
                .frame(width: 10, height: 20)
            } else {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addCurve(
                        to: CGPoint(x: 40, y: 0),
                        control1: CGPoint(x: 15, y: -4),
                        control2: CGPoint(x: 25, y: 4)
                    )
                }
                .stroke(Color(red: 139/255, green: 69/255, blue: 19/255), style: StrokeStyle(lineWidth: 2))
                .frame(width: 40, height: 10)
            }
        }
    }
}

// 配偶对视图
struct SpousePairView: View {
    let member1: FamilyMember
    let member2: FamilyMember
    
    var body: some View {
        HStack(spacing: 4) {
            FamilyMemberCard(member: member1)
            Path { path in
                path.move(to: CGPoint(x: 0, y: 5))
                path.addCurve(
                    to: CGPoint(x: 20, y: 5),
                    control1: CGPoint(x: 7, y: 3),
                    control2: CGPoint(x: 13, y: 7)
                )
            }
            .stroke(Color(red: 139/255, green: 69/255, blue: 19/255), style: StrokeStyle(lineWidth: 2))
            .frame(width: 20, height: 10)
            FamilyMemberCard(member: member2)
        }
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.6))
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
        )
        .padding(8)
    }
}

// 家庭成员卡片
struct FamilyMemberCard: View {
    let member: FamilyMember
    
    var backgroundColor: Color {
        switch member.generation {
        case 0: return Color(red: 255/255, green: 228/255, blue: 225/255).opacity(0.9)
        case 1: return Color(red: 230/255, green: 230/255, blue: 250/255).opacity(0.9)
        case 2: return Color(red: 240/255, green: 248/255, blue: 255/255).opacity(0.9)
        default: return Color(red: 245/255, green: 255/255, blue: 250/255).opacity(0.9)
        }
    }
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .shadow(color: .gray.opacity(0.2), radius: 3)
                    .frame(width: 44, height: 44)
                
                Image(systemName: member.gender == .male ? "person.circle.fill" : "person.circle")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(member.gender == .male ? .blue.opacity(0.7) : .pink.opacity(0.7))
            }
            
            Text(member.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black.opacity(0.8))
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(backgroundColor)
        .cornerRadius(22)
        .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// 家族树节点
struct FamilyNodeView: View {
    let familyGraph: FamilyGraph
    let rootMemberId: UUID
    
    var body: some View {
        VStack(spacing: 0) {
            if let rootMember = familyGraph.members[rootMemberId],
               let spouse = familyGraph.getSpouse(of: rootMemberId) {
                SpousePairView(member1: rootMember, member2: spouse)
                
                let children = familyGraph.getChildren(of: rootMemberId)
                if !children.isEmpty {
                    TreeBranchLine(isVertical: true)
                    
                    if children.count > 1 {
                        HStack(spacing: 0) {
                            ForEach(0..<children.count-1, id: \.self) { _ in
                                TreeBranchLine(isVertical: false)
                            }
                        }
                    }
                    
                    HStack(spacing: 20) {
                        ForEach(children, id: \.id) { child in
                            VStack {
                                TreeBranchLine(isVertical: true)
                                if let _ = familyGraph.getSpouse(of: child.id) {
                                    FamilyNodeView(familyGraph: familyGraph, rootMemberId: child.id)
                                } else {
                                    FamilyMemberCard(member: child)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct FamilyTreeView: View {
    let familyGraph: FamilyGraph
    
    init() {
        // 创建家族图谱
        let graph = FamilyGraph()
        
        // 创建成员
        let grandfather = FamilyMember(name: "爷爷", gender: .male, generation: 0, parentIds: [], childrenIds: [])
        let grandmother = FamilyMember(name: "奶奶", gender: .female, generation: 0, parentIds: [], childrenIds: [])
        let father = FamilyMember(name: "爸爸", gender: .male, generation: 1, parentIds: [], childrenIds: [])
        let mother = FamilyMember(name: "妈妈", gender: .female, generation: 1, parentIds: [], childrenIds: [])
        let aunt = FamilyMember(name: "姑姑", gender: .female, generation: 1, parentIds: [], childrenIds: [])
        let uncle = FamilyMember(name: "姑父", gender: .male, generation: 1, parentIds: [], childrenIds: [])
        let me = FamilyMember(name: "我", gender: .male, generation: 2, parentIds: [], childrenIds: [])
        let sister = FamilyMember(name: "妹妹", gender: .female, generation: 2, parentIds: [], childrenIds: [])
        let cousin = FamilyMember(name: "表姐", gender: .female, generation: 2, parentIds: [], childrenIds: [])
        
        // 添加关系
        var updatedGrandfather = grandfather
        var updatedGrandmother = grandmother
        updatedGrandfather.spouseId = grandmother.id
        updatedGrandmother.spouseId = grandfather.id
        updatedGrandfather.childrenIds = [father.id, aunt.id]
        updatedGrandmother.childrenIds = [father.id, aunt.id]
        
        var updatedFather = father
        var updatedMother = mother
        updatedFather.spouseId = mother.id
        updatedMother.spouseId = father.id
        updatedFather.childrenIds = [me.id, sister.id]
        updatedMother.childrenIds = [me.id, sister.id]
        updatedFather.parentIds = [grandfather.id, grandmother.id]
        updatedMother.parentIds = []
        
        var updatedAunt = aunt
        var updatedUncle = uncle
        updatedAunt.spouseId = uncle.id
        updatedUncle.spouseId = aunt.id
        updatedAunt.childrenIds = [cousin.id]
        updatedUncle.childrenIds = [cousin.id]
        updatedAunt.parentIds = [grandfather.id, grandmother.id]
        updatedUncle.parentIds = []
        
        var updatedMe = me
        var updatedSister = sister
        var updatedCousin = cousin
        updatedMe.parentIds = [father.id, mother.id]
        updatedSister.parentIds = [father.id, mother.id]
        updatedCousin.parentIds = [aunt.id, uncle.id]
        
        // 将成员添加到图中
        graph.addMember(updatedGrandfather)
        graph.addMember(updatedGrandmother)
        graph.addMember(updatedFather)
        graph.addMember(updatedMother)
        graph.addMember(updatedAunt)
        graph.addMember(updatedUncle)
        graph.addMember(updatedMe)
        graph.addMember(updatedSister)
        graph.addMember(updatedCousin)
        
        self.familyGraph = graph
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical]) {
                ZStack {
                    // 渐变背景
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 240/255, green: 248/255, blue: 255/255),
                            Color(red: 250/255, green: 247/255, blue: 247/255)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    
                    // 装饰性树叶背景
                    ForEach(0..<10) { i in
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.green.opacity(0.1))
                            .rotationEffect(.degrees(Double(i * 36)))
                            .scaleEffect(1.5)
                            .offset(
                                x: CGFloat.random(in: -geometry.size.width/2...geometry.size.width/2),
                                y: CGFloat.random(in: -geometry.size.height/2...geometry.size.height/2)
                            )
                    }
                    
                    VStack(spacing: 20) {
                        Text("我的家族树")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 67/255, green: 134/255, blue: 171/255),
                                        Color(red: 159/255, green: 134/255, blue: 192/255)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .white.opacity(0.5), radius: 2, x: 0, y: 1)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 15)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.white.opacity(0.95))
                                    
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    .white,
                                                    Color(red: 159/255, green: 134/255, blue: 192/255).opacity(0.5)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                        .blur(radius: 0.5)
                                }
                                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            )
                            .padding(.top, 30)
                        
                        if let rootMember = familyGraph.members.values.first(where: { $0.generation == 0 && $0.gender == .male }) {
                            FamilyNodeView(familyGraph: familyGraph, rootMemberId: rootMember.id)
                                .padding(20)
                        }
                    }
                }
                .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
            }
        }
    }
}

#Preview {
    FamilyTreeView()
} 