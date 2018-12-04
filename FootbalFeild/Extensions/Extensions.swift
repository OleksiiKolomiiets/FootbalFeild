//
//  Extensions.swift
//  FootbalFeild
//
//  Created by Oleksii  Kolomiiets on 12/3/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

extension CGRect {
    
    var topLeftCorner: CGPoint {
        return self.origin
    }
    
    var topRightCorner: CGPoint {
        return CGPoint(x: self.maxX, y: self.origin.y)
    }
    
    var bottomRightCorner: CGPoint {
        return  CGPoint(x: self.maxX, y: self.maxY)
    }
    
    var bottomLeftCorner: CGPoint  {
        return  CGPoint(x: self.origin.x, y: self.maxY)
    }
    
}

extension CGPoint {
    func distance(from point: CGPoint) -> CGFloat {
        let xDist = x - point.x
        let yDist = y - point.y
        return sqrt((xDist * xDist) + (yDist * yDist))
    }
}
