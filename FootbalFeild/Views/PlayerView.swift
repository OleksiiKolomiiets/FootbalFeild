//
//  PlayerCircleView.swift
//  FootbalField
//
//  Created by Oleksii  Kolomiiets on 12/4/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class PlayerView: UIView {
    
    
    // MARK: - Outlets:

    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var circleView: UIView!
    @IBOutlet private weak var playerNumberLabel: UILabel!
    @IBOutlet private weak var playerNameLabel: UILabel!
    
    
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
    
    // MARK: Lifecycle methods of PlayerView:
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        circleView.layer.cornerRadius = circleView.bounds.width / 2
        let playerNumberFontSize = circleView.bounds.width / 2
        playerNumberLabel.font = UIFont.systemFont(ofSize: playerNumberFontSize)
    }

    // MARK: - Functions:
    
    public func configureWith(_ model: PlayerEntity, teamColor: UIColor) {
        playerNumberLabel.text = "\(model.number)"
        circleView.backgroundColor = teamColor
        playerNameLabel.text = "\(model.fullName)"
       
        playerNumberLabel.textColor = teamColor == .black ? .white : .black
    }

    private func initSubviews() {
        let nib = UINib(nibName: "PlayerCircleView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
    }
}
