//
//  FootballFieldViewController.swift
//  FootbalFeild
//
//  Created by Oleksii  Kolomiiets on 11/30/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

fileprivate enum TeamSchemeType {
    case s4411
    case s433
    
    var teamMatrix: [[Int]] {
        switch self {
        case .s433:
            return [ [1], [2, 3, 4, 5],  [6, 7, 8],  [9, 10, 11] ]
        case .s4411:
            return [ [1], [2,3,4,5], [6,7,8,9], [10], [11] ]
        }
    }
}

fileprivate enum TeamSide: Int {
    case top
    case bottom
    
    var color: UIColor {
        switch self {
        case .top:
            return .white
        case .bottom:
            return .black
        }
    }
    
    var indicator: CGFloat {
        switch self {
        case .top:
            return 1
        case .bottom:
            return -1
        }
    }
}

class FootballFieldViewController: UIViewController {

    
    // MARK: - Outlets:
    
    @IBOutlet weak var footballFieldView: FootballFieldView!
    
    
    // MARK: - Properties:
    
    // MARK: Constants:
    private let circleDiameter: CGFloat = 32
    
    
    // MARK: Variables:
    
    
    // MARK: - Lifecycle of FootballFieldViewController:
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        getFootballTeamCircleViewsWith(scheme: .s4411, atThe: .top).forEach() { self.view.addSubview($0)}
        getFootballTeamCircleViewsWith(scheme: .s433, atThe: .bottom).forEach() { self.view.addSubview($0)}
    }
    
    // MARK: - Functions:
    
    private func getFootballTeamCircleViewsWith(scheme: TeamSchemeType, atThe side: TeamSide) -> [PlayerCircleView] {
        
        var footballTeam: [PlayerCircleView] = []
        
        let topBottomPadding: CGFloat = (footballFieldView.feildFrame.maxY / 2 - circleDiameter * CGFloat(scheme.teamMatrix.count + 1)) / CGFloat(scheme.teamMatrix.count + 1)
        
        
        for (lineIndex, playersInLine) in scheme.teamMatrix.enumerated() {
            
            let leftRighPadding = (footballFieldView.feildFrame.width - circleDiameter * CGFloat(playersInLine.count)) / CGFloat(playersInLine.count + 1)
            
            for (indexFirstTeam, player)in playersInLine.enumerated() {
                let startX = footballFieldView.feildFrame.minX + circleDiameter * CGFloat(indexFirstTeam) + leftRighPadding * CGFloat(indexFirstTeam + 1)
                let startY = (side == .top ? footballFieldView.feildFrame.minY : footballFieldView.bounds.maxY) + side.indicator * (circleDiameter * CGFloat(lineIndex) + topBottomPadding * CGFloat(lineIndex + 1))
                let playerCircle = PlayerCircleView(frame: CGRect(x: startX,
                                                                  y: startY,
                                                                  width: circleDiameter,
                                                                  height: circleDiameter))
                
                playerCircle.configureWith(playerNumber: player, teamColor: side.color)
                
                footballTeam.append(playerCircle)
            }
        }
        
        return footballTeam
    }
    
}
