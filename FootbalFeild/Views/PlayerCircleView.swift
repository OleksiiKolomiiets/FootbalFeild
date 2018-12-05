//
//  PlayerCircleView.swift
//  FootbalFeild
//
//  Created by Oleksii  Kolomiiets on 12/4/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class PlayerCircleView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var playerNumberLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("PlayerCircleView", owner: self, options: nil)
        initSubviews()
//        playerCircleView.translatesAutoresizingMaskIntoConstraints = false
//        playerCircleView.fixInView(self)
    }
    
    public func configureWith(playerNumber: Int, teamColor: UIColor) {
        playerNumberLabel.text = "\(playerNumber)"
        contentView.backgroundColor = teamColor
        contentView.layer.cornerRadius = contentView.bounds.width / 2
        playerNumberLabel.textColor = teamColor == .black ? .white : .black
    }

    func initSubviews() {
        let nib = UINib(nibName: "PlayerCircleView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
    }
}
