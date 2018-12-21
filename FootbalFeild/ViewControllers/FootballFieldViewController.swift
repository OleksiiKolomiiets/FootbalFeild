//
//  FootballFieldViewController.swift
//  FootbalField
//
//  Created by Oleksii  Kolomiiets on 11/30/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

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

class FootballFieldViewController: UIViewController, UITextFieldDelegate, SchemePickerDelegate {

    
    // MARK: - Outlets:
    
    @IBOutlet private weak var footballFieldView: FootballFieldView!
    
    @IBOutlet private weak var firstTeamSchemeButton : UIButton!
    @IBOutlet private weak var secondTeamSchemeButton: UIButton!
    
    @IBOutlet private weak var firstTeamLabel: UILabel!
    @IBOutlet private weak var secondTeamLabel: UILabel!
    
    @IBOutlet weak var firstTeamClearButton : UIButton!
    @IBOutlet weak var secondTeamClearButton: UIButton!
    
    // MARK: - Properties:
    
    private let maxPlayersInARow: CGFloat = 5
    
    private let topDefaultTeam = TeamEntity(by: TeamSchemeType.allCases[Int.random(in: TeamSchemeType.allCases.indices)])
    private let bottomDefaultTeam = TeamEntity(by: TeamSchemeType.allCases[Int.random(in: TeamSchemeType.allCases.indices)])
    
    private(set) var teamAtTheTop    : [PlayerView]!
    private(set) var teamAtTheBottom : [PlayerView]!
    
    private var editingTeameSide: TeamSide!
    
    private var footballFieldManager = FootballFieldManager()
    
    private var playerViewWidth : CGFloat!
    private var playerViewHeight: CGFloat!
    
    private var controlsFontSize: CGFloat!
    
    
    // MARK: - Actions:
    
    @IBAction func schemeButtonTouched(_ sender: UIButton) {
       
        let storyboard = UIStoryboard(name: "SchemePopupViewController", bundle: nil)
        let popupViewController = storyboard.instantiateViewController(withIdentifier: "SchemePopupViewController") as! SchemePopupViewController
        
        popupViewController.delegate = self
        
        if sender == firstTeamSchemeButton {
            editingTeameSide = .top
            popupViewController.configure(with: TeamSchemeType.allCases, selected: topDefaultTeam.scheme)
        } else {
            popupViewController.configure(with: TeamSchemeType.allCases, selected: bottomDefaultTeam.scheme)
            editingTeameSide = .bottom
        }
        
        self.addChild(popupViewController)
        popupViewController.view.frame = self.view.frame
        self.view.addSubview(popupViewController.view)
        popupViewController.didMove(toParent: self)
    }
    
    @IBAction func clearSchemeButtonTouched(_ sender: UIButton) {
        if sender == firstTeamClearButton {
            changeSchemeAccordingTo(.cleared, atThe: .top)
        } else {
            changeSchemeAccordingTo(.cleared, atThe: .bottom)
        }
    }
    
    // MARK: - Lifecycle of FootballFieldViewController:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        footballFieldView.footballFieldManager = footballFieldManager
        
        
        controlsFontSize = view.frame.height * 0.03
        
        changeTeamSchemeControlsAtributedText(on: .top   , using: topDefaultTeam)
        changeTeamSchemeControlsAtributedText(on: .bottom, using: bottomDefaultTeam)
       
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        playerViewWidth  = (footballFieldView.frame.width - (maxPlayersInARow + 1 ) * 8) / maxPlayersInARow
        playerViewHeight = (0.5 * footballFieldView.frame.height  - (maxPlayersInARow + 1 ) * 4) / maxPlayersInARow
        
        teamAtTheTop = getFootballTeamCircleViewsWith(model: topDefaultTeam, atThe: .top)
        
        teamAtTheBottom = getFootballTeamCircleViewsWith(model: bottomDefaultTeam, atThe: .bottom)
        
        teamAtTheTop.forEach() { footballFieldView.addSubview($0)}
        teamAtTheBottom.forEach() { footballFieldView.addSubview($0)}
    }
    
    
    // MARK: - Functions:
    
    private func changeTeamSchemeControlsAtributedText(on side: TeamSide, using model: TeamEntity) {
        
        let titleFont = UIFont.systemFont(ofSize: controlsFontSize,  weight: .thin)
        
        let buttonTitleAtributedString = NSAttributedString(string: model.scheme.buttonTitle, attributes: [.font : titleFont])
        let teamNameTitleAtributedString = NSAttributedString(string: model.name, attributes: [.font : titleFont])
        
        switch side {
        case .top:
            firstTeamSchemeButton.setAttributedTitle(buttonTitleAtributedString, for: .normal)
            firstTeamLabel.attributedText = teamNameTitleAtributedString
        case .bottom:
            secondTeamSchemeButton.setAttributedTitle(buttonTitleAtributedString, for: .normal)
            secondTeamLabel.attributedText = teamNameTitleAtributedString
        }
    }
    
    private func getFootballTeamCircleViewsWith(model: TeamEntity, atThe side: TeamSide) -> [PlayerView] {
        
        var footballTeam: [PlayerView] = []
        
        let verticalPadding = getPaddingForElements(length: playerViewHeight, amount: model.teamMatrix.count, in: footballFieldManager.rect.height / 2)
        
        for (lineIndex, playersInLine) in model.teamMatrix.enumerated() {
            
            let horizontalPadding = getPaddingForElements(length: playerViewWidth, amount: playersInLine.count, in: footballFieldManager.rect.width)
            
            for (indexOfPlayer, player)in playersInLine.enumerated() {
                
                var fieldMinX = footballFieldManager.rect.minX
                if side == .bottom {
                    fieldMinX = footballFieldManager.rect.width - playerViewWidth
                }
                let lengthOfAddedVerticalCircles = playerViewWidth * CGFloat(indexOfPlayer)
                let lengthOfAddedVerticalPaddings = horizontalPadding * CGFloat(indexOfPlayer + 1)
                
                let startX = fieldMinX + side.indicator * (lengthOfAddedVerticalCircles + lengthOfAddedVerticalPaddings)
                
                
                var fieldMinY = footballFieldManager.rect.minY
                if side == .bottom {
                    fieldMinY = footballFieldManager.rect.height - playerViewHeight
                }
                let lengthOfAddedHorizontalCircles = playerViewHeight * CGFloat(lineIndex)
                let lengthOfAddedHorizontalPaddings = verticalPadding * CGFloat(lineIndex + 1)
                
                let startY = fieldMinY + side.indicator * (lengthOfAddedHorizontalCircles + lengthOfAddedHorizontalPaddings)
                
                let playerCircle = PlayerView(frame: CGRect(x: startX, y: startY, width: playerViewWidth, height: playerViewHeight))
                
                playerCircle.configureWith(player, teamColor: side.color)
                
                footballTeam.append(playerCircle)
            }
        }
        
        return footballTeam
    }
    
    private func getPaddingForElements(length: CGFloat,  amount: Int, in lineLength: CGFloat) -> CGFloat {
        let lengthOfAllCirclesVertical = length * CGFloat(amount)
        let amountOfVerticalPaddings = CGFloat(amount + 1)
        
        return (lineLength - lengthOfAllCirclesVertical) / amountOfVerticalPaddings
    }
    
    private func changeSchemeAccordingTo(_ scheme: TeamSchemeType, atThe side: TeamSide) {
        
        var team: TeamEntity
        
        switch side {
        case .top:
            team = topDefaultTeam
            team.scheme = scheme
            teamAtTheTop.forEach() { $0.removeFromSuperview()}
            teamAtTheTop = getFootballTeamCircleViewsWith(model: team, atThe: side)
            teamAtTheTop.forEach() { self.footballFieldView.addSubview($0)}
            
        case .bottom:
            team = bottomDefaultTeam
            team.scheme = scheme
            teamAtTheBottom.forEach() { $0.removeFromSuperview()}
            teamAtTheBottom = getFootballTeamCircleViewsWith(model: team, atThe: side)
            teamAtTheBottom.forEach() { self.footballFieldView.addSubview($0)}
        }
        
        changeTeamSchemeControlsAtributedText(on: side, using: team)
    }
    
    
    // MARK: - SchemePickerDelegate:
    
    func pickerView(_ pickerView: UIPickerView, picked scheme: TeamSchemeType) {
        changeSchemeAccordingTo(scheme, atThe: editingTeameSide)
    }
    
}
