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
        return cos(startAngle)
    }
    
    var arcStartYCorrection: CGFloat {
        return sin(startAngle)
    }
    
    var endAngle: CGFloat {
        return startAngle - 0.5 * .pi
    }
    
    var startAngle: CGFloat {
        switch self {
        case .topLeftCorner:
            return 0.5 * .pi
        case .topRightCorner:
            return .pi
        case .bottomRightCorner:
            return 1.5 * .pi
        case .bottomLeftCorner:
            return 0
        case .topPenalty:
            return 0.75 * .pi
        case .bottomPenalty:
            return 1.75 * .pi
        }
    }
}
