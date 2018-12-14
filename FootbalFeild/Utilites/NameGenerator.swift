//
//  NameGenerator.swift
//  FootbalField
//
//  Created by Oleksii  Kolomiiets on 12/14/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

class NameGenerator {
    
    // MARK: - Constants:
    
    private static let playerFirstNames     = ["Alex", "Jhon", "Kurt", "Nick", "Bran"]
    private static let playerLastNames      = ["Stone", "Storm", "Flower", "Snow"]
    private static let teamNames            = ["KIEV", "LVIV", "DNIPRO", "VINNYTSIA"]
    private static let footballsClubAcronym = "FC"
    
    
    // MARK: - Functions:
    
    public static func getPlayerFirstName() -> String {
        return "\(playerFirstNames[Int.random(in: playerFirstNames.indices)])"
    }
    
    public static func getPlayerLastName() -> String {
        return "\(playerLastNames[Int.random(in: playerLastNames.indices)])"
    }
    
    public static func getTeamName() -> String {
        return "\(footballsClubAcronym) \(teamNames[Int.random(in: teamNames.indices)])"
    }
}
