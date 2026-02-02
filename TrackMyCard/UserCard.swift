import Foundation
import SwiftData

@Model
final class UserCard {
    var name: String
    var issuer: String
    @Relationship(deleteRule: .cascade, inverse: \CardBenefit.userCard) var benefits: [CardBenefit] = []
    
    init(name: String, issuer: String) {
        self.name = name
        self.issuer = issuer
    }
}
