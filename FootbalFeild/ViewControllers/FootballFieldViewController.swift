//
//  FootballFieldViewController.swift
//  FootbalFeild
//
//  Created by Oleksii  Kolomiiets on 11/30/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

fileprivate class FootballFieldViewControllerSettings {
    static let kStripeCount = 19
    static let kFieldColor  = #colorLiteral(red: 0.2691331506, green: 0.3710823655, blue: 0.04835906625, alpha: 1)
}
class FootballFieldView: UIView {
    
    // MARK: - Properies:
    
    // MARK: Constatnts:
    
    let paddingTopAndBottom: CGFloat = 8
    let paddingLeftAndRight: CGFloat = 32
    
    // MARK: Variables:
    
    var fieldWidth: CGFloat {
        return bounds.width - CGFloat(2) * paddingLeftAndRight
    }
    var fieldLength: CGFloat {
        return bounds.height - CGFloat(2) * (paddingTopAndBottom + self.bounds.height / CGFloat(FootballFieldViewControllerSettings.kStripeCount))
    }
    var centrRadius: CGFloat  {
        return fieldWidth * CGFloat(0.15)
    }
    
    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath()
        
        let fieldRectangle = CGRect(x: self.bounds.origin.x + paddingLeftAndRight,
                                    y: self.bounds.origin.y + paddingTopAndBottom + self.bounds.height / CGFloat(FootballFieldViewControllerSettings.kStripeCount),
                                    width: fieldWidth,
                                    height: fieldLength)
        drawPathFor(rect: fieldRectangle, in: path)
       
        
        
        // draw center circle
        drawFieldCenterCircle(in: path)
        
        // draw center line
        drawFieldCenterLine(in: path)
        
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillRule = .evenOdd
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2
        
        self.layer.addSublayer(shapeLayer)
        
//        self.drawLine(startX: 8, toEndingX: textStartX - 8, startingY: midY, toEndingY: midY, ofColor: UIColor.white, widthOfLine: 1, inView: self)
//        self.drawLine(startX: textEndX + 8, toEndingX: Int(self.frame.maxX) - 8, startingY: midY, toEndingY: midY, ofColor: UIColor.white, widthOfLine: 2, inView: self)
        
    }
    
    private func drawFieldCenterLine(in path: UIBezierPath) {
        let startPoint = CGPoint(x: self.bounds.origin.x + paddingLeftAndRight,
                                 y: self.bounds.midY)
        let endPoint = CGPoint(x: self.bounds.width - paddingLeftAndRight,
                               y: self.bounds.midY)
        
        drawSingleLine(from: startPoint, to: endPoint, in: path)
    }
    
    private func drawSingleLine(from start: CGPoint, to end: CGPoint, in path: UIBezierPath) {
        path.move(to: start)
        path.addLine(to: end)
        path.close()
    }
    
    private func drawPathFor(rect: CGRect, in path: UIBezierPath) {
        // left top corner
        let topLeftCorner = rect.origin
        path.move(to: rect.origin)
        
        // right top corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.origin.y))
        
        // right bottom corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        
        // left bottom corner
        path.addLine(to: CGPoint(x: rect.origin.x,
                                 y: rect.maxY))
        
        path.close()
    }
    
    private func drawFieldCenterCircle(in path: UIBezierPath) {
        path.move(to: CGPoint(x: self.bounds.midX + centrRadius,
                              y: self.bounds.midY))
        
        path.addArc(withCenter: CGPoint(x: self.bounds.midX,
                                        y: self.bounds.midY),
                    radius: centrRadius,
                    startAngle: 2 * .pi,
                    endAngle: 0,
                    clockwise: false)
        
        path.close()
    }
    
    func drawLine(startX: Int, toEndingX endX: Int, startingY startY: Int, toEndingY endY: Int, ofColor lineColor: UIColor, widthOfLine lineWidth: CGFloat, inView view: UIView) {
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: endX, y: endY))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = lineWidth
        
        view.layer.addSublayer(shapeLayer)
        
    }
    
    
}
class FootballFieldViewController: UIViewController {

    
    // MARK: - Outlets:
    
    @IBOutlet weak var footballFieldView: FootballFieldView!
    
    
    // MARK: - Properties:
    
    // MARK: Variables:
    
    private var stripeHeight: CGFloat {
        return footballFieldView.bounds.height / CGFloat(FootballFieldViewControllerSettings.kStripeCount)
    }
    
    
    // MARK: - Lifecycle of FootballFieldViewController:
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        addFootbalFieldPattern()
    }
    
    
    // MARK: - Functions:
    
    private func addFootbalFieldPattern() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = footballFieldView.bounds
        setupColors(for: gradientLayer)
        setupLocations(for: gradientLayer)
        footballFieldView.layer.addSublayer(gradientLayer)
    }
    
    private func setupLocations(for gradientLayer: CAGradientLayer) {
        let stripeCount = FootballFieldViewControllerSettings.kStripeCount
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
        let stripeCount = FootballFieldViewControllerSettings.kStripeCount
        
        var colors = [CGColor]()
        
        for index in 0 ..< stripeCount {
            let currentAlpha: CGFloat = (index%2 == 0) ? 0.9 : 1
            let stripeColor = FootballFieldViewControllerSettings.kFieldColor.withAlphaComponent(currentAlpha).cgColor
            colors.append(stripeColor)
            colors.append(stripeColor)
        }
        
        gradientLayer.colors = colors
    }
    
    private func getStripeHeight() -> CGFloat {
        return footballFieldView.bounds.height / CGFloat(FootballFieldViewControllerSettings.kStripeCount)
    }
    
    
    
}
