import Foundation
import SwiftData

@Model
final class UserCard {
    var name: String
    @Relationship(deleteRule: .cascade, inverse: \CardBenefit.userCard) var benefits: [CardBenefit] = []
    
    init(name: String) {
        self.name = name
    }
}
