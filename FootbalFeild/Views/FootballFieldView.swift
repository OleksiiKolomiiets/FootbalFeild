//
//  FootballFieldView.swift
//  FootbalFeild
//
//  Created by Oleksii  Kolomiiets on 12/3/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

fileprivate class FootballFieldViewSettings {
    static let kStripeCount = 19
    static let kFieldColor  = #colorLiteral(red: 0.2691331506, green: 0.3710823655, blue: 0.04835906625, alpha: 1)
    
    static let kPenaltyAreaLengthCoefficient = CGFloat(0.6)
    static let kPenaltyAreaWidthCoefficient  = CGFloat(0.6)
}

class FootballFieldView: UIView {
    
    // MARK: - Properies:
    
    // MARK: Constatnts:
    
    private let paddingTopAndBottom: CGFloat = 8
    private let paddingLeftAndRight: CGFloat = 32
    private let cornerArcsRadius   : CGFloat = 15
    private let footballFieldLinesPath = UIBezierPath()
    
    // MARK: Variables:
    
    private var fieldWidth: CGFloat {
        return bounds.width - CGFloat(2) * paddingLeftAndRight
    }
    private var fieldLength: CGFloat {
        return bounds.height - CGFloat(2) * (paddingTopAndBottom + bounds.height / CGFloat(FootballFieldViewSettings.kStripeCount))
    }
    private var centrRadius: CGFloat  {
        return fieldWidth * CGFloat(0.15)
    }
    private var feildRectangle: CGRect {
        return CGRect(x: bounds.origin.x + paddingLeftAndRight,
                      y: bounds.origin.y + paddingTopAndBottom + bounds.height / CGFloat(FootballFieldViewSettings.kStripeCount),
                      width: fieldWidth,
                      height: fieldLength)
    }
    private var stripeHeight: CGFloat {
        return bounds.height / CGFloat(FootballFieldViewSettings.kStripeCount)
    }
    private var penaltyAreaWidth: CGFloat {
        return feildRectangle.width * FootballFieldViewSettings.kPenaltyAreaWidthCoefficient
    }
    private var penaltyAreaLength: CGFloat {
        return penaltyAreaWidth * FootballFieldViewSettings.kPenaltyAreaLengthCoefficient
    }
    private var penaltyAreaSize: CGSize {
        return CGSize(width: penaltyAreaWidth, height: penaltyAreaLength)
    }
    
    
    // MARK : - Lifecycle methods of FootballFieldView:
    
    override func draw(_ rect: CGRect) {
        
        addFootballFieldPattern()
        
        addFieldPath()
        
        addFieldCenterCirclePath()
        
        addFieldCenterLinePath()
        
        addFieldCornersArcPaths()
        
        addPenaltyAreasPath()
        
        let topPenaltyCenter = CGPoint(x: feildRectangle.midX, y: feildRectangle.origin.y + feildRectangle.height * 0.1)
        addArcIn(footballFieldLinesPath, center: topPenaltyCenter, radius: feildRectangle.height * 0.1, arcType: .topPenalty)
        
        let bottomPenaltyCenter = CGPoint(x: feildRectangle.midX, y: feildRectangle.height - feildRectangle.height * 0.1)
        addArcIn(footballFieldLinesPath, center: bottomPenaltyCenter, radius: feildRectangle.height * 0.1, arcType: .bottomPenalty)
        
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = footballFieldLinesPath.cgPath
        shapeLayer.strokeColor = UIColor.white.withAlphaComponent(0.6).cgColor
        shapeLayer.fillRule = .evenOdd
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2
        
        self.layer.addSublayer(shapeLayer)
        
    }
    
    
    // MARK : - Functions:
    
    private func addFieldCenterLinePath() {
        let startPoint = CGPoint(x: bounds.origin.x + paddingLeftAndRight, y: bounds.midY)
        let endPoint = CGPoint(x: bounds.width - paddingLeftAndRight, y: bounds.midY)
        
        addSingleLineIn(footballFieldLinesPath, from: startPoint, to: endPoint)
    }
    
    private func addFieldPath() {
        addPathIn(footballFieldLinesPath, for: feildRectangle)
    }
    
    private func addPenaltyAreasPath() {
        addPathForTopPenaltyArea()
        addPathForBottomPenaltyArea()
    }
    
    private func addPathForTopPenaltyArea() {
        let topPenaltyAreaTopLeftCorner = CGPoint(x: feildRectangle.origin.x + (feildRectangle.width - penaltyAreaWidth) / 2,
                                                  y: feildRectangle.origin.y)
        let topPenaltyAreaFrame = CGRect(origin: topPenaltyAreaTopLeftCorner, size: penaltyAreaSize)
        addPathIn(footballFieldLinesPath, for: topPenaltyAreaFrame)
    }
    
    private func addPathForBottomPenaltyArea() {
        let bottomPenaltyAreaTopLeftCorner = CGPoint(x: feildRectangle.origin.x + (feildRectangle.width - penaltyAreaWidth) / 2,
                                                     y: feildRectangle.maxY - penaltyAreaLength)
        let bottomPenaltyAreaFrame = CGRect(origin: bottomPenaltyAreaTopLeftCorner, size: penaltyAreaSize)
        addPathIn(footballFieldLinesPath, for: bottomPenaltyAreaFrame)
    }
    
    private func addFieldCornersArcPaths() {
        addArcIn(footballFieldLinesPath, center: feildRectangle.topLeftCorner, radius: cornerArcsRadius, arcType: .topLeftCorner)
        addArcIn(footballFieldLinesPath, center: feildRectangle.topRightCorner, radius: cornerArcsRadius, arcType: .topRightCorner)
        addArcIn(footballFieldLinesPath, center: feildRectangle.bottomRightCorner, radius: cornerArcsRadius, arcType: .bottomRightCorner)
        addArcIn(footballFieldLinesPath, center: feildRectangle.bottomLeftCorner, radius: cornerArcsRadius, arcType: .bottomLeftCorner)
        
    }
    
    private func addFieldCenterCirclePath() {
        addCircleIn(footballFieldLinesPath, center: CGPoint(x: bounds.midX, y: bounds.midY), radius: centrRadius)
    }
    
    private func addPathIn(_ path: UIBezierPath, for frame: CGRect) {
        addSingleLineIn(path, from: frame.topLeftCorner,     to: frame.topRightCorner)
        addSingleLineIn(path, from: frame.topRightCorner,    to: frame.bottomRightCorner)
        addSingleLineIn(path, from: frame.bottomRightCorner, to: frame.bottomLeftCorner)
        addSingleLineIn(path, from: frame.bottomLeftCorner,  to: frame.topLeftCorner)
    }
    
    private func addCircleIn(_ path: UIBezierPath, center: CGPoint, radius: CGFloat) {
        path.move(to: CGPoint(x: center.x + radius, y: center.y))
        path.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        path.close()
    }
    
    private func addArcIn(_ path: UIBezierPath, center: CGPoint, radius: CGFloat, arcType: ArcType) {
        path.move(to: CGPoint(x: center.x + arcType.arcStartXCorrecion * radius * cos(arcType.startAngle.degreesToRadians), y: center.y + arcType.arcStartXCorrecion * radius * sin(arcType.startAngle.degreesToRadians)))
        path.addArc(withCenter: center, radius: radius, startAngle: arcType.startAngle, endAngle: arcType.endAngle, clockwise: true)
//        path.close()
    }
    
    private func addSingleLineIn(_ path: UIBezierPath, from start: CGPoint, to end: CGPoint) {
        path.move(to: start)
        path.addLine(to: end)
        path.close()
    }
    
    private func addFootballFieldPattern() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        setupColors(for: gradientLayer)
        setupLocations(for: gradientLayer)
        layer.addSublayer(gradientLayer)
    }
    
    private func setupLocations(for gradientLayer: CAGradientLayer) {
        let stripeCount = FootballFieldViewSettings.kStripeCount
        let stripeGradientLayerLocationLength = 1 / Double(stripeCount)
        
        var locations = [NSNumber]()
        
        for _ in 0 ..< stripeCount {
            locations.append(locations.last ?? 0)
            let locationEnd = Double(truncating: locations.last!) + stripeGradientLayerLocationLength
            locations.append(NSNumber(value: locationEnd))
        }
        
        gradientLayer.locations = locations
    }
    
    private func setupColors(for gradientLayer: CAGradientLayer) {
        let stripeCount = FootballFieldViewSettings.kStripeCount
        
        var colors = [CGColor]()
        
        for index in 0 ..< stripeCount {
            let currentAlpha: CGFloat = (index%2 == 0) ? 0.9 : 1
            let stripeColor = FootballFieldViewSettings.kFieldColor.withAlphaComponent(currentAlpha).cgColor
            colors.append(stripeColor)
            colors.append(stripeColor)
        }
        
        gradientLayer.colors = colors
    }
    
    private func getStripeHeight() -> CGFloat {
        return bounds.height / CGFloat(FootballFieldViewSettings.kStripeCount)
    }
    
}

extension CGFloat {
    var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}
