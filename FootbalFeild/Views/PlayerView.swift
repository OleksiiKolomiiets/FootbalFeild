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
        let longTap = UIPanGestureRecognizer(target: self, action: #selector(dragPlayer(_:)))
        self.circleView.addGestureRecognizer(longTap)
    }
    
    var distX: CGFloat = 0
    var distY: CGFloat = 0
    
    @objc func dragPlayer(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            distX = gesture.location(in: self.superview).x - self.frame.origin.x
            distY = gesture.location(in: self.superview).y - self.frame.origin.y
        case .changed:
            self.frame.origin = CGPoint(x: gesture.location(in: self.superview).x - distX,
                                        y: gesture.location(in: self.superview).y - distY)
        default:
            break
        }
        
        let circleViewInFieldFrame = convert(circleView.frame, to: superview)
        let circlePadding = (frame.width - circleViewInFieldFrame.width) / 2
        let superviewBounds = superview!.bounds
        
        if circleViewInFieldFrame.minX < superviewBounds.minX {
            frame.origin.x = superviewBounds.minX - circlePadding
        }
        if circleViewInFieldFrame.minY < superviewBounds.minY {
            frame.origin.y = superviewBounds.minY
        }
        if circleViewInFieldFrame.maxX > superviewBounds.width {
            frame.origin.x = superviewBounds.width - frame.width + circlePadding
        }
        if frame.maxY > superviewBounds.height {
            frame.origin.y = superviewBounds.height - frame.height
        }
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
