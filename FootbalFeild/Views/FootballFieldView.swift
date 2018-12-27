//
//  FootballFieldView.swift
//  FootbalField
//
//  Created by Oleksii  Kolomiiets on 12/3/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class FootballFieldView: UIView {
    
    // MARK: - Propeties:
    
    public var footballFieldManager: FootballFieldManager!
    
    
    // MARK : - Lifecycle methods of FootballFieldView:
    
    override func draw(_ rect: CGRect) {
        
        footballFieldManager.delegate = self
        
        footballFieldManager.drawFootballField()
    }
    
}
