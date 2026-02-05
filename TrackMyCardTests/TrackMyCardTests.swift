//
//  TrackMyCardTests.swift
//  TrackMyCardTests
//
//  Created by Jonathan Solichin on 2/1/26.
//

import Testing
import Foundation
@testable import TrackMyCard

struct TrackMyCardTests {

    @Test func testBenefitResetLogic() async throws {
        // Given
        let benefit = CardBenefit(name: "Test Benefit", cardName: "Test Card", amount: 10, period: .monthly)
        
        // When (simulate date in past)
        let pastDate = Calendar.current.date(byAdding: .month, value: -2, to: Date())!
        benefit.nextResetDate = pastDate
        benefit.isUsed = true
        
        // Act
        benefit.checkAndReset()
        
        // Then
        #expect(benefit.isUsed == false)
        #expect(benefit.nextResetDate > Date())
    }
    
    @Test func testUserCardRelationship() async throws {
        // Given
        let userCard = UserCard(name: "Test Card")
        let benefit = CardBenefit(name: "Ben", cardName: "Test Card", amount: 10, period: .monthly)
        
        // Link
        userCard.benefits.append(benefit)
        benefit.userCard = userCard // explicit backlink usually handled by SwiftData context but good to be safe in unit test logic if not using full context
        
        #expect(userCard.benefits.count == 1)
        #expect(benefit.userCard?.name == "Test Card")
    }
    
    @Test func testEveryFourYearsReset() async throws {
        // Given
        let benefit = CardBenefit(name: "Global Entry", cardName: "Venture", amount: 100, period: .everyFourYears)
        // Reset date is "now" by default
        let pastDate = Calendar.current.date(byAdding: .year, value: -5, to: Date())!
        benefit.nextResetDate = pastDate
        benefit.isUsed = true
        
        // Act
        benefit.checkAndReset()
        
        // Then
        // Should have advanced by 4 years (still in past relative to 5 years ago? No.)
        // -5 years + 4 years = -1 year.
        // -1 year is still < now.
        // Loop runs again.
        // -1 year + 4 years = +3 years from now.
        // Reset date should be in future.
        #expect(benefit.nextResetDate > Date())
        #expect(benefit.isUsed == false)
    }

}