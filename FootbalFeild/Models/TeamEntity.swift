//
//  Team.swift
//  FootbalField
//
//  Created by Oleksii  Kolomiiets on 12/10/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

class TeamEntity {
    
    
    // MARK: - Properties:
    
    private let playerFirstNames = ["Alex", "Jhon", "Kurt", "Nick"]
    private let playerLastNames  = ["Stone", "Storm", "Flower", "Snow"]
    
    public let scheme : TeamSchemeType
    public let players: [PlayerEntity]
    
    public var teamMatrix: [[PlayerEntity]] {
        var teamMatrix = Array(repeating: [PlayerEntity](), count: PlayerPostionType.allCases.count)
        players.forEach() { player in
            teamMatrix[player.position.rawValue].append(player)
        }
        return teamMatrix.filter({ !$0.isEmpty })
    }
    
    
    // MARK: - Constructor:
    
    init(by scheme: TeamSchemeType) {
        var players: [PlayerEntity] = []
        var playerIndex: UInt = 1
        
        for (positionIndex, positionCount) in scheme.teamPositionCounts.enumerated() {
            guard let position = PlayerPostionType(rawValue: positionIndex) else { continue }
            
            for _ in 0 ..< positionCount {
                let player = PlayerEntity(number: playerIndex, position: position, firstName: "\(playerFirstNames[Int.random(in: playerFirstNames.indices)])", lastName: "\(playerLastNames[Int.random(in: playerLastNames.indices)])")
                players.append(player)
                playerIndex += 1
            }
        }
        
        self.players = players
        self.scheme = scheme
    }
    
}
