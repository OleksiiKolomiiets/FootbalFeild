//
//  ArcType.swift
//  FootbalFeild
//
//  Created by Oleksii  Kolomiiets on 12/3/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

enum ArcType {
    case topLeftCorner
    case topRightCorner
    case bottomRightCorner
    case bottomLeftCorner
    case topPenalty
    case bottomPenalty
    case circle
    
    var arcStartXCorrecion: CGFloat {
        return cos(startAngle)
    }
    
    var arcStartYCorrection: CGFloat {
        return sin(startAngle)
    }
    
    var endAngle: CGFloat {
        switch self {
        case .circle:
            return 2 * .pi
        default:
            return startAngle + 0.5 * .pi
        }
    }
    
    var startAngle: CGFloat {
        switch self {
        case .topLeftCorner:
            return 0
        case .topRightCorner:
            return 0.5 * .pi
        case .bottomRightCorner:
            return .pi
        case .bottomLeftCorner:
            return 1.5 * .pi
        case .topPenalty:
            return 0.25 * .pi
        case .bottomPenalty:
            return 1.25 * .pi
        case .circle:
            return 0
        }
    }
}
