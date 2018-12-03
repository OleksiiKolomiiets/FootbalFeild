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
    
    var arcStartXCorrecion: CGFloat {
        switch self {
        case .topLeftCorner, .bottomLeftCorner:
            return 1.0
        case .topRightCorner, .bottomRightCorner:
            return -1.0
        case .topPenalty, .bottomPenalty:
            return 0
        }
    }
    
    var arcStartYCorrection: CGFloat {
        switch self {
        case .topPenalty:
            return 1.0
        case .bottomPenalty:
            return -1.0
        default:
            return 0
        }
    }
    
    var endAngle: CGFloat {
        switch self {
        case .topPenalty, .bottomPenalty:
            return self.startAngle + 0.5 * .pi
        default:
            return self.startAngle +  0.5 * .pi
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
        }
    }
}
