//
//  TeamSchemeType.swift
//  FootbalFeild
//
//  Created by Oleksii  Kolomiiets on 12/10/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

enum TeamSchemeType: String {
    case s442  = "442"
    case s433  = "433"
    case s451  = "451"
    case s343  = "343"
    case s352  = "352"
    case s4231 = "4231"
    case s1441 = "1441"
    case s1432 = "1432"
    case s4222 = "4222"
    case s4132 = "4132"
    case s5221 = "5221"
    case s4411 = "4411"
    
    var teamPositionCounts: [Int] {
        return [goalkeeperCount,
                defenderCount,
                midfielderCount,
                wingerCount,
                forwardCount]
    }
    
    private var goalkeeperCount: Int {
        return 1
    }
    
    private var defenderCount: Int {
        switch self {
        case .s1441, .s1432:
            return 1
        case .s343, .s352:
            return 3
        case .s442, .s433, .s451, .s4231, .s4222, .s4132, .s4411:
            return 4
        case .s5221:
            return 5
        }
    }
    
    private var midfielderCount: Int {
        switch self {
        case .s4132:
            return 1
        case .s4231, .s4222, .s5221:
            return 2
        case .s433:
            return 3
        case .s442, .s343, .s1441, .s1432, .s4411:
            return 4
        case .s451, .s352:
            return 5
        }
    }
    
    private var wingerCount: Int {
        switch self {
        case .s4411:
            return 1
        case .s4222, .s5221:
            return 2
        case .s4132, .s4231, .s1432:
            return 3
        case .s1441:
            return 4
        default:
            return 0
        }
    }
    
    private var forwardCount: Int {
        switch self {
        case .s451, .s4231, .s1441, .s5221, .s4411:
            return 1
        case .s442, .s352, .s1432, .s4222, .s4132:
            return 2
        case .s433, .s343:
            return 3
        }
    }
    
    var buttonTitle: String {
        var title = String()
        for (index, character) in self.rawValue.enumerated() {
            let separator = (index != self.rawValue.count - 1) ? "-" : ""
            title.append("\(character)\(separator)")
        }
        return title
    }
}