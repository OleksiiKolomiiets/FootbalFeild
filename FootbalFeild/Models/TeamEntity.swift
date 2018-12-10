//
//  Team.swift
//  FootbalFeild
//
//  Created by Oleksii  Kolomiiets on 12/10/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

class TeamEntity {
    
    // MARK: - Constants:
    public let scheme : TeamSchemeType
    public let players: [PlayerEntity]!
    
    // MARK: - Variables:
    public var teamMatrix: [[PlayerEntity]] {
        var teamMatrix = Array(repeating: [PlayerEntity](), count: PlayerPostionType.allCases.count)
        players.forEach() { player in
            teamMatrix[player.position.rawValue].append(player)
        }
        return teamMatrix.filter({ !$0.isEmpty })
    }
    
    init(by scheme: TeamSchemeType) {
        var players: [PlayerEntity] = []
        var playerIndex: UInt = 1
        
        for (positionIndex, positionCount) in scheme.teamPositionCounts.enumerated() {
            guard let position = PlayerPostionType(rawValue: positionIndex) else { continue }
            
            for _ in 0 ..< positionCount {
                let player = PlayerEntity(number: playerIndex, position: position)
                players.append(player)
                playerIndex += 1
            }
        }
        
        self.players = players
        self.scheme = scheme
    }
    
}
