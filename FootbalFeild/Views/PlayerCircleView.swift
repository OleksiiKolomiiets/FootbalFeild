//
//  PlayerCircleView.swift
//  FootbalFeild
//
//  Created by Oleksii  Kolomiiets on 12/4/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class PlayerCircleView: UIView {
    
    
    // MARK: - Outlets:

    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var playerNumberLabel: UILabel!
    
    
    // MARK: - Constructors:
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUsingXIB()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUsingXIB()
    }
    
    private func initUsingXIB() {
        Bundle.main.loadNibNamed("PlayerCircleView", owner: self, options: nil)
        initSubviews()
    }
    
    
    // MARK: - Functions:
    
    public func configureWith(playerNumber: UInt, teamColor: UIColor) {
        playerNumberLabel.text = "\(playerNumber)"
        contentView.backgroundColor = teamColor
        contentView.layer.cornerRadius = contentView.bounds.width / 2
        playerNumberLabel.textColor = teamColor == .black ? .white : .black
    }

    private func initSubviews() {
        let nib = UINib(nibName: "PlayerCircleView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
    }
}
