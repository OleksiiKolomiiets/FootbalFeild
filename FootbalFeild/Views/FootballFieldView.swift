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
    
    static let kPenaltyAreaLengthCoefficient = CGFloat(0.36)
    static let kPenaltyAreaWidthCoefficient  = CGFloat(0.6)
    
    static let kGoalWidthCoefficient = CGFloat(0.2)
    static let kGoalLength           = CGFloat(6)
    
    static let kGoalAreaWidthCoefficient  = CGFloat(0.3)
    static let kGoalAreaLengthCoefficient = CGFloat(0.3)
    
    static let kPenaltyCenterLengthCoefficient = CGFloat(0.1)
    
}

class FootballFieldView: UIView {
    
    // MARK: - Properies:
    
    // MARK: Constatnts:
    
    private let paddingTopAndBottom: CGFloat = 10
    private let paddingLeftAndRight: CGFloat = 2
    private let cornerArcsRadius   : CGFloat = 15
    private let lineWidth: CGFloat = 4
    private let footballFieldLinesPath = UIBezierPath()
    
    // MARK: Variables:
    
    private var fieldWidth: CGFloat {
        return bounds.width - CGFloat(2) * paddingLeftAndRight
    }
    private var fieldLength: CGFloat {
        return bounds.height - CGFloat(2) * paddingTopAndBottom 
    }
    private var centrRadius: CGFloat  {
        return fieldWidth * CGFloat(0.15)
    }
    private var feildRectangle: CGRect {
        return CGRect(x: bounds.origin.x + paddingLeftAndRight,
                      y: bounds.origin.y + paddingTopAndBottom,
                      width: fieldWidth,
                      height: fieldLength)
    }
    public var feildFrame: CGRect {
        return CGRect(x: frame.origin.x + paddingLeftAndRight,
                      y: frame.origin.y + paddingTopAndBottom,
                      width: fieldWidth,
                      height: fieldLength)
    }
    private var stripeHeight: CGFloat {
        return bounds.height / CGFloat(FootballFieldViewSettings.kStripeCount)
    }
    
    private var penaltyAreaSize: CGSize {
        return CGSize(width: feildRectangle.width * FootballFieldViewSettings.kPenaltyAreaWidthCoefficient,
                      height: feildRectangle.width * FootballFieldViewSettings.kPenaltyAreaLengthCoefficient)
    }
    
    private var goalSize: CGSize {
        return CGSize(width: penaltyAreaSize.width * FootballFieldViewSettings.kGoalWidthCoefficient,
                      height: FootballFieldViewSettings.kGoalLength)
    }
    
    private var goalAreaSize: CGSize {
        return CGSize(width: feildRectangle.width * FootballFieldViewSettings.kGoalAreaWidthCoefficient,
                      height: penaltyAreaSize.height * FootballFieldViewSettings.kGoalAreaLengthCoefficient)
    }
    
    private var penaltyArcStartX: CGFloat {
        return feildRectangle.origin.x + (feildRectangle.width - goalAreaSize.width) / 2
    }
    
    private var penaltyCenterLength: CGFloat {
        return feildRectangle.height * FootballFieldViewSettings.kPenaltyCenterLengthCoefficient
    }
    
    
    // MARK : - Lifecycle methods of FootballFieldView:
    
    override func draw(_ rect: CGRect) {
        addFootballFieldPattern()
        addLinesPath()
        setupLayerWith(footballFieldLinesPath)        
    }
    
    
    // MARK : - Functions:
    
    private func addLinesPath() {
        addFieldPath()
        addFieldCenterLinePath()
        addPenaltyAreasPath()
        addGoalPath()
        addGoalAreaPath()
        
        addFieldCenterCirclePath()
        addFieldCornersArcPaths()
        addPenaltyArcPath()
    }
    
    private func addFieldPath() {
        addPathIn(footballFieldLinesPath, for: feildRectangle)
    }
    
    private func addFieldCenterLinePath() {
        let startPoint = CGPoint(x: bounds.origin.x + paddingLeftAndRight, y: bounds.midY)
        let endPoint = CGPoint(x: bounds.width - paddingLeftAndRight, y: bounds.midY)
        
        addSingleLineIn(footballFieldLinesPath, from: startPoint, to: endPoint)
    }
    
    private func addPenaltyAreasPath() {
        addSymmetricRectPathsWith(rectSize: penaltyAreaSize, isInversed: false)
    }
    
    private func addGoalPath() {
       addSymmetricRectPathsWith(rectSize: goalSize, isInversed: true)
    }
    
    private func addGoalAreaPath() {
        addSymmetricRectPathsWith(rectSize: goalAreaSize, isInversed: false)
    }
    
    private func addPenaltyArcPath() {
        let topPenaltyCenterPoint = CGPoint(x: feildRectangle.midX, y: feildRectangle.origin.y + penaltyCenterLength)
        let topPenaltyArcStartPoint = getPenaltyArcStartPoint(with: feildRectangle.origin.y + penaltyAreaSize.height)
        addArcIn(footballFieldLinesPath,
                 center: topPenaltyCenterPoint,
                 radius: topPenaltyCenterPoint.distance(from: topPenaltyArcStartPoint),
                 arcType: .topPenalty)
        
        let arcShift = cos(0.25 * .pi) * lineWidth
        let bottomPenaltyCenterPoint = CGPoint(x: feildRectangle.midX, y: feildRectangle.maxY - penaltyCenterLength - arcShift)
        let bottomPenaltyArcStartPoint = getPenaltyArcStartPoint(with: feildRectangle.maxY - penaltyAreaSize.height)
        addArcIn(footballFieldLinesPath,
                 center: bottomPenaltyCenterPoint,
                 radius: bottomPenaltyCenterPoint.distance(from: bottomPenaltyArcStartPoint),
                 arcType: .bottomPenalty)
    }
    
    private func getPenaltyArcStartPoint(with startX: CGFloat) -> CGPoint {
        return CGPoint(x: penaltyArcStartX, y: startX)
    }
    
    private func addSymmetricRectPathsWith(rectSize: CGSize, isInversed: Bool) {
        let rectFrameX = feildRectangle.origin.x + (feildRectangle.width - rectSize.width) / 2
        
        let topRectFrameY = feildRectangle.origin.y - (isInversed ? rectSize.height : 0)
        addPathForRectWith(x: rectFrameX, y: topRectFrameY, size: rectSize)
        
        let bottomRectFrameY = feildRectangle.maxY - (isInversed ? 0 : rectSize.height)
        addPathForRectWith(x: rectFrameX, y: bottomRectFrameY, size: rectSize)
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
        path.move(to: frame.topLeftCorner)
        path.addLine(to: frame.topRightCorner)
        path.addLine(to: frame.bottomRightCorner)
        path.addLine(to: frame.bottomLeftCorner)
        path.addLine(to: frame.topLeftCorner)
        path.close()
    }
    
    private func addPathForRectWith(x: CGFloat, y: CGFloat, size: CGSize) {
        addPathIn(footballFieldLinesPath, for: CGRect(origin: CGPoint(x: x, y: y), size: size))
    }
    
    private func addCircleIn(_ path: UIBezierPath, center: CGPoint, radius: CGFloat) {
        path.move(to: CGPoint(x: center.x + radius, y: center.y))
        path.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: 2.0 * .pi, clockwise: true)
        path.close()
    }
    
    private func addArcIn(_ path: UIBezierPath, center: CGPoint, radius: CGFloat, arcType: ArcType) {
        path.move(to: CGPoint(x: center.x + radius * arcType.arcStartXCorrecion,
                              y: center.y + radius * arcType.arcStartYCorrection))
        
        path.addArc(withCenter: center, radius: radius, startAngle: arcType.startAngle, endAngle: arcType.endAngle, clockwise: false)
        
    }
    
    private func addSingleLineIn(_ path: UIBezierPath, from start: CGPoint, to end: CGPoint) {
        path.move(to: start)
        path.addLine(to: end)
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
    
    
    private func setupLayerWith(_ path: UIBezierPath) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.white.withAlphaComponent(0.4).cgColor
        shapeLayer.fillRule = .evenOdd
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = lineWidth
        
        self.layer.addSublayer(shapeLayer)
    }
    
}
