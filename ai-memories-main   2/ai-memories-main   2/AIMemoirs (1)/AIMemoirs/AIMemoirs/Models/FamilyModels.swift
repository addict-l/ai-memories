import SwiftUI

// MARK: - 性别枚举
enum Gender {
    case male
    case female
}

// MARK: - 家庭成员模型
struct FamilyMember: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let gender: Gender
    let generation: Int
    let position: Int // 在该轨道上的位置索引
    var spouseId: UUID?
    var parentIds: Set<UUID>
    var childrenIds: Set<UUID>
    var profileImages: [String]
    var memoryCount: Int
    var birthYear: Int?
    var description: String
    var loveLevel: Int
    var specialTrait: String
    var planetColor: Color // 行星颜色
    
    static func == (lhs: FamilyMember, rhs: FamilyMember) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - 家族关系图
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
    
    func getParents(of memberId: UUID) -> [FamilyMember] {
        guard let member = members[memberId] else { return [] }
        return member.parentIds.compactMap { members[$0] }
    }
}

// MARK: - 回忆相关模型
struct MemoryItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let date: String
    let images: [String]
    let emotion: MemoryEmotion
}

enum MemoryEmotion {
    case happy, peaceful, warm, excited, nostalgic
    
    var color: Color {
        switch self {
        case .happy: return .yellow
        case .peaceful: return .green
        case .warm: return .orange
        case .excited: return .red
        case .nostalgic: return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .happy: return "face.smiling"
        case .peaceful: return "leaf.fill"
        case .warm: return "heart.fill"
        case .excited: return "star.fill"
        case .nostalgic: return "clock.fill"
        }
    }
} 