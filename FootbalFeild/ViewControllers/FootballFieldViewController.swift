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
    static let kFieldColor = #colorLiteral(red: 0.2691331506, green: 0.3710823655, blue: 0.04835906625, alpha: 1)
}

class FootballFieldViewController: UIViewController {

    
    // MARK: - Outlets:
    
    @IBOutlet weak var footballFieldView: UIView!
    
    
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
