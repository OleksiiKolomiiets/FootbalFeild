//
//  FootballFieldManager.swift
//  FootbalField
//
//  Created by Oleksii  Kolomiiets on 12/12/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

protocol FootballFieldManagable {
    var delegate: FootballFieldView? { get set }
    var rect: CGRect! { get }    
    func drawFootballField()
}

fileprivate class FootballFieldSettings {
    static let kStripeCount = 15
    static let kFieldColor  = #colorLiteral(red: 0.2691331506, green: 0.3710823655, blue: 0.04835906625, alpha: 1)
    
    static let kLineWidthCoefficient = CGFloat(5)
    
    static let kPenaltyAreaLengthCoefficient = CGFloat(0.2)
    static let kPenaltyAreaWidthCoefficient  = CGFloat(0.5)
    static let kPenaltyArcAngle: CGFloat     = .pi / 4
    
    static let kGoalWidthCoefficient = CGFloat(0.2)
    static let kGoalLength           = CGFloat(6)
    
    static let kGoalAreaWidthCoefficient  = CGFloat(0.3)
    static let kGoalAreaLengthCoefficient = CGFloat(0.3)
    
    static let kPenaltyCenterLengthCoefficient = CGFloat(0.12)
    
}

class FootballFieldManager: FootballFieldManagable {
    
    // MARK: - Constants:
    
    private let pathHelper = PathHelper()
    
    public let path = UIBezierPath()
    
    
    // MARK: - Variables:
    
    public var delegate: FootballFieldView?
    
    public var rect: CGRect!
    
    
    // MARK: - Computed properies:
    
    private var fieldRect: CGRect {
        guard let delegate = delegate else { return CGRect(x: 0, y: 0, width: 0, height: 0) }
        
        if rect == nil {
            rect = delegate.bounds
        }
        return delegate.bounds
    }
    
    private var lineWidth: CGFloat {
        guard let delegate = delegate else { return 0 }
        
        return delegate.frame.width / delegate.frame.height * FootballFieldSettings.kLineWidthCoefficient
    }
    
    private var cornerArcRadius: CGFloat {
        guard let delegate = delegate else { return 0 }
        
        return delegate.frame.height / CGFloat(FootballFieldSettings.kStripeCount * 2)
    }
    
    private var centerRadius: CGFloat  {
        return fieldRect.size.width * CGFloat(0.15)
    }
    
    
    private var stripeHeight: CGFloat {
        guard let delegate = delegate else { return 0 }
        
        return delegate.bounds.height / CGFloat(FootballFieldSettings.kStripeCount)
    }
    
    private var penaltyAreaSize: CGSize {
        return CGSize(width: fieldRect.width * FootballFieldSettings.kPenaltyAreaWidthCoefficient,
                      height: fieldRect.width * FootballFieldSettings.kPenaltyAreaLengthCoefficient)
    }
    
    private var goalSize: CGSize {
        return CGSize(width: penaltyAreaSize.width * FootballFieldSettings.kGoalWidthCoefficient,
                      height: FootballFieldSettings.kGoalLength)
    }
    
    private var goalAreaSize: CGSize {
        return CGSize(width: fieldRect.width * FootballFieldSettings.kGoalAreaWidthCoefficient,
                      height: penaltyAreaSize.height * FootballFieldSettings.kGoalAreaLengthCoefficient)
    }
    
    private var penaltyArcRadius: CGFloat {
        return (goalAreaSize.width / 2) / cos(FootballFieldSettings.kPenaltyArcAngle)
    }
    
    private var penaltyArcStartX: CGFloat {
        return fieldRect.origin.x + (fieldRect.width - goalAreaSize.width) / 2
    }
    
    private var penaltyCenterLength: CGFloat {
        return fieldRect.width * FootballFieldSettings.kPenaltyCenterLengthCoefficient
    }
    
    
    // MARK: - Functions:
    
    public func drawFootballField() {
        addFootballFieldPattern()
        addLinesPath()
        setupLayerWith(pathHelper.path)
    }
    
    
    private func addLinesPath() {
        addFieldPath()
        addFieldCenterLinePath()
        addPenaltyAreasPath()
        addGoalPath()
        addGoalAreaPath()
        
        addFieldCenterCirclePath()
        addFieldCornersArcPaths()
        addPenaltyArcPath()
        
        addPenaltyDotPath()
    }
    
    private func addFieldPath() {
        pathHelper.add(RectLine(frame: fieldRect))
    }
    
    private func addFieldCenterLinePath() {
        guard let delegate = delegate else { return }
        
        let startPoint = CGPoint(x: delegate.bounds.origin.x, y: delegate.bounds.midY)
        let endPoint = CGPoint(x: delegate.bounds.width, y: delegate.bounds.midY)
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
        guard let delegate = delegate else { return }
        
        let centerCircleArcLine = ArcLine(center: CGPoint(x: delegate.bounds.midX, y: delegate.bounds.midY), radius: centerRadius, type: .circle)
        pathHelper.add(centerCircleArcLine)
    }
    
    private func addPenaltyArcPath() {
        let topPenaltyArcStartPoint = getPenaltyArcStartPoint(with: fieldRect.origin.y + penaltyAreaSize.height)
        let topPenaltyCenterPoint = getPenaltyCenterPoint(accordingToArcStart: topPenaltyArcStartPoint)
        let topPenaltyArc = ArcLine(center: topPenaltyCenterPoint, radius: penaltyArcRadius, type: .topPenalty)
        pathHelper.add(topPenaltyArc)
        
        let bottomPenaltyArcStartPoint = getPenaltyArcStartPoint(with: fieldRect.maxY - penaltyAreaSize.height)
        let bottomPenaltyCenterPoint = getPenaltyCenterPoint(accordingToArcStart: bottomPenaltyArcStartPoint)
        let bottomPenaltyArc = ArcLine(center: bottomPenaltyCenterPoint, radius: penaltyArcRadius, type: .bottomPenalty)
        pathHelper.add(bottomPenaltyArc)
    }
    
    private func addPenaltyDotPath() {
        let topPenaltyDotPoint = CGPoint(x: fieldRect.midX, y: fieldRect.minY + penaltyCenterLength)
        let topPenaltyDot = ArcLine(center: topPenaltyDotPoint, radius: lineWidth / 2, type: .circle)
        pathHelper.add(topPenaltyDot)
        
        let bottomPenaltyDotPoint = CGPoint(x: fieldRect.midX, y: fieldRect.maxY - penaltyCenterLength)
        let bottomPenaltyDot = ArcLine(center: bottomPenaltyDotPoint, radius: lineWidth / 2, type: .circle)
        pathHelper.add(bottomPenaltyDot)
    }
    
    private func getPenaltyCenterPoint(accordingToArcStart point: CGPoint) -> CGPoint {
        guard let delegate = delegate else {
            return CGPoint(x: 0, y: 0)
        }
        
        let sideIndicator: CGFloat = point.y < delegate.bounds.midY ? -1 : 1
        let xShift: CGFloat = goalAreaSize.width / 2
        let yShift = sqrt(penaltyArcRadius * penaltyArcRadius - xShift * xShift)
        
        return CGPoint(x: point.x + xShift, y: point.y + sideIndicator * yShift)
    }
    
    private func getPenaltyArcStartPoint(with startX: CGFloat) -> CGPoint {
        return CGPoint(x: penaltyArcStartX, y: startX)
    }
    
    private func addSymmetricRectPathsWith(rectSize: CGSize, isInversed: Bool) {
        let rectFrameX = fieldRect.origin.x + (fieldRect.width - rectSize.width) / 2
        
        let topRectFrameY = fieldRect.origin.y - (isInversed ? rectSize.height : 0)
        let topRectPoint = CGPoint(x: rectFrameX, y: topRectFrameY)
        let topRectLine = RectLine(frame: CGRect(origin: topRectPoint, size: rectSize))
        pathHelper.add(topRectLine)
        
        let bottomRectFrameY = fieldRect.maxY - (isInversed ? 0 : rectSize.height)
        let bottomRectPoint = CGPoint(x: rectFrameX, y: bottomRectFrameY)
        let bottomRectLine = RectLine(frame: CGRect(origin: bottomRectPoint, size: rectSize))
        pathHelper.add(bottomRectLine)
    }
    
    private func addFieldCornersArcPaths() {
        let topLeftArc = ArcLine(center: fieldRect.topLeftCorner, radius: cornerArcRadius, type: .topLeftCorner)
        pathHelper.add(topLeftArc)
        
        let topRightArc = ArcLine(center: fieldRect.topRightCorner, radius: cornerArcRadius, type: .topRightCorner)
        pathHelper.add(topRightArc)
        
        let bottomRightArc = ArcLine(center: fieldRect.bottomRightCorner, radius: cornerArcRadius, type: .bottomRightCorner)
        pathHelper.add(bottomRightArc)
        
        let bottomLeftArc = ArcLine(center: fieldRect.bottomLeftCorner, radius: cornerArcRadius, type: .bottomLeftCorner)
        pathHelper.add(bottomLeftArc)
    }
    
    private func addFootballFieldPattern() {
        guard let delegate = delegate else { return }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = delegate.bounds
        setupColors(for: gradientLayer)
        setupLocations(for: gradientLayer)
        delegate.layer.addSublayer(gradientLayer)
    }
    
    private func setupLocations(for gradientLayer: CAGradientLayer) {
        let stripeCount = FootballFieldSettings.kStripeCount
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
        let stripeCount = FootballFieldSettings.kStripeCount
        
        var colors = [CGColor]()
        
        for index in 0 ..< stripeCount {
            let currentAlpha: CGFloat = (index%2 == 0) ? 0.9 : 1
            let stripeColor = FootballFieldSettings.kFieldColor.withAlphaComponent(currentAlpha).cgColor
            colors.append(stripeColor)
            colors.append(stripeColor)
        }
        
        gradientLayer.colors = colors
    }
    
    private func getStripeHeight() -> CGFloat {
        guard let delegate = delegate else { return 0 }
        
        return delegate.bounds.height / CGFloat(FootballFieldSettings.kStripeCount)
    }
    
    
    private func setupLayerWith(_ path: UIBezierPath) {
        guard let delegate = delegate else { return }
        
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.white.withAlphaComponent(0.4).cgColor
        shapeLayer.fillRule = .evenOdd
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = lineWidth
        
        delegate.layer.addSublayer(shapeLayer)
    }
    
}
