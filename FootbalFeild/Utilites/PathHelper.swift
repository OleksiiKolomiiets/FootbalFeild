//
//  PathHelper.swift
//  FootbalFeild
//
//  Created by Oleksii  Kolomiiets on 12/7/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

protocol PathHelperProtocol {
    var path: UIBezierPath? { get set }
    func add(_ pathElement: Line)
}

protocol Line { }


struct ArcLine: Line {
    let center : CGPoint
    let radius : CGFloat
    let type   : ArcType
}

struct RectLine: Line {
    let rect: CGRect
}

struct SingleLine: Line {
    let start: CGPoint
    let end  : CGPoint
}

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

class PathHelper: PathHelperProtocol {
    
    public var path: UIBezierPath?
    
    public func add(_ pathElement: Line) {
        guard self.path != nil else { return }
        
        if let arcElement = pathElement as? ArcLine {
            addArcIn(center: arcElement.center, radius: arcElement.radius, arcType: arcElement.type)
        }
        if let rectElement = pathElement as? RectLine {
            addPathIn(for: rectElement.rect)
        }
        if let singleLine = pathElement as? SingleLine {
            addSingleLineIn(from: singleLine.start, to: singleLine.end)
        }
    }
    
    private func addPathIn(for frame: CGRect) {
        guard let path = self.path else { return }
        
        path.move(to: frame.topLeftCorner)
        path.addLine(to: frame.topRightCorner)
        path.addLine(to: frame.bottomRightCorner)
        path.addLine(to: frame.bottomLeftCorner)
        path.addLine(to: frame.topLeftCorner)
        path.close()
    }
    
    private func addArcIn(center: CGPoint, radius: CGFloat, arcType: ArcType) {
        guard let path = self.path else { return }
        
        path.move(to: CGPoint(x: center.x + radius * arcType.arcStartXCorrecion, y: center.y + radius * arcType.arcStartYCorrection))
        path.addArc(withCenter: center, radius: radius, startAngle: arcType.startAngle, endAngle: arcType.endAngle, clockwise: true)
    }
    
    private func addSingleLineIn(from start: CGPoint, to end: CGPoint) {
        guard let path = self.path else { return }
        
        path.move(to: start)
        path.addLine(to: end)
    }
}
