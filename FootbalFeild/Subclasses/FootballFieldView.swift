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
    
    static let kPenaltyAreaLengthCoefficient = CGFloat(0.2)
    static let kPenaltyAreaWidthCoefficient  = CGFloat(0.5)
    
    static let kGoalWidthCoefficient = CGFloat(0.2)
    static let kGoalLength           = CGFloat(6)
    
    static let kGoalAreaWidthCoefficient  = CGFloat(0.3)
    static let kGoalAreaLengthCoefficient = CGFloat(0.3)
    
    static let kPenaltyCenterLengthCoefficient = CGFloat(0.1)
    
}

class FootballFieldView: UIView {
    
    // MARK: - Properies:
    
    private let paddingTopAndBottom: CGFloat = 0
    private let cornerArcsRadius   : CGFloat = 15
    
    private let lineWidth: CGFloat = 3
    
    private let footballFieldLinesPath = UIBezierPath()
    
    private let penaltyArcAngle: CGFloat = 0.25 * .pi
    
    
    private var pathHelper: PathHelperProtocol!
    
    private var paddingLeftAndRight: CGFloat {
        return lineWidth / 2
    }
    
    private var fieldWidth: CGFloat {
        return bounds.width - CGFloat(2) * paddingLeftAndRight
    }
    
    private var fieldLength: CGFloat {
        return bounds.height - CGFloat(2) * paddingTopAndBottom
    }
    
    private var centrRadius: CGFloat  {
        return fieldWidth * CGFloat(0.15)
    }
    
    public var feildRectangle: CGRect {
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
    
    private var penaltyArcRadius: CGFloat {
        return (goalAreaSize.width / 2) / cos(penaltyArcAngle)
    }
    
    private var penaltyArcStartX: CGFloat {
        return feildRectangle.origin.x + (feildRectangle.width - goalAreaSize.width) / 2
    }
    
    private var penaltyCenterLength: CGFloat {
        return feildRectangle.height * FootballFieldViewSettings.kPenaltyCenterLengthCoefficient
    }
    
    
    // MARK : - Lifecycle methods of FootballFieldView:
    
    override func draw(_ rect: CGRect) {
        
        pathHelper = PathHelper()
        pathHelper.path = footballFieldLinesPath
        
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
        pathHelper.add(RectLine(frame: feildRectangle))
    }
    
    private func addFieldCenterLinePath() {
        let startPoint = CGPoint(x: bounds.origin.x + paddingLeftAndRight, y: bounds.midY)
        let endPoint = CGPoint(x: bounds.width - paddingLeftAndRight, y: bounds.midY)
        let singleLine = SingleLine(start: startPoint, end: endPoint)
        
        pathHelper.add(singleLine)
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
    
    private func addFieldCenterCirclePath() {
        let centerCircleArcLine = ArcLine(center: CGPoint(x: bounds.midX, y: bounds.midY), radius: centrRadius, type: .circle)
        pathHelper.add(centerCircleArcLine)
    }

    private func addPenaltyArcPath() {
        let topPenaltyArcStartPoint = getPenaltyArcStartPoint(with: feildRectangle.origin.y + penaltyAreaSize.height)
        let topPenaltyCenterPoint = getPenaltyCenterPoint(accordingToArcStart: topPenaltyArcStartPoint)
        let topPenaltyArc = ArcLine(center: topPenaltyCenterPoint, radius: penaltyArcRadius, type: .topPenalty)
        pathHelper.add(topPenaltyArc)
        
        let bottomPenaltyArcStartPoint = getPenaltyArcStartPoint(with: feildRectangle.maxY - penaltyAreaSize.height)
        let bottomPenaltyCenterPoint = getPenaltyCenterPoint(accordingToArcStart: bottomPenaltyArcStartPoint)
        let bottomPenaltyArc = ArcLine(center: bottomPenaltyCenterPoint, radius: penaltyArcRadius, type: .bottomPenalty)
        pathHelper.add(bottomPenaltyArc)
    }
    
    private func getPenaltyCenterPoint(accordingToArcStart point: CGPoint) -> CGPoint {
        let sideIndicator: CGFloat = point.y < bounds.midY ? -1 : 1
        let xShift: CGFloat = goalAreaSize.width / 2
        let yShift = sqrt(penaltyArcRadius * penaltyArcRadius - xShift * xShift)
        
        return CGPoint(x: point.x + xShift, y: point.y + sideIndicator * yShift)
    }
    
    private func getPenaltyArcStartPoint(with startX: CGFloat) -> CGPoint {
        return CGPoint(x: penaltyArcStartX, y: startX)
    }
    
    private func addSymmetricRectPathsWith(rectSize: CGSize, isInversed: Bool) {
        let rectFrameX = feildRectangle.origin.x + (feildRectangle.width - rectSize.width) / 2
        
        let topRectFrameY = feildRectangle.origin.y - (isInversed ? rectSize.height : 0)
        let topRectPoint = CGPoint(x: rectFrameX, y: topRectFrameY)
        let topRectLine = RectLine(frame: CGRect(origin: topRectPoint, size: rectSize))
        pathHelper.add(topRectLine)
        
        let bottomRectFrameY = feildRectangle.maxY - (isInversed ? 0 : rectSize.height)
        let bottomRectPoint = CGPoint(x: rectFrameX, y: bottomRectFrameY)
        let bottomRectLine = RectLine(frame: CGRect(origin: bottomRectPoint, size: rectSize))
        pathHelper.add(bottomRectLine)
    }
    
    private func addFieldCornersArcPaths() {
        let topLeftArc = ArcLine(center: feildRectangle.topLeftCorner, radius: cornerArcsRadius, type: .topLeftCorner)        
        pathHelper.add(topLeftArc)
        
        let topRightArc = ArcLine(center: feildRectangle.topRightCorner, radius: cornerArcsRadius, type: .topRightCorner)
        pathHelper.add(topRightArc)
        
        let bottomRightArc = ArcLine(center: feildRectangle.bottomRightCorner, radius: cornerArcsRadius, type: .bottomRightCorner)
        pathHelper.add(bottomRightArc)
        
        let bottomLeftArc = ArcLine(center: feildRectangle.bottomLeftCorner, radius: cornerArcsRadius, type: .bottomLeftCorner)
        pathHelper.add(bottomLeftArc)
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
