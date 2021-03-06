//
//  Player.swift
//  FootbalField
//
//  Created by Oleksii  Kolomiiets on 12/10/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

struct PlayerEntity {
    
    // MARK: - Properties:
    
    let number   : UInt
    let position : PlayerPostionType
    let firstName: String
    let lastName : String
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}


