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
    
    @IBOutlet private weak var firstTeamSchemeInputTextField : UITextField!
    @IBOutlet private weak var secondTeamSchemeInputTextField: UITextField!
    
    @IBOutlet private weak var secondTeamSchemeNameInputBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var firstTeamLabel: UILabel!
    @IBOutlet weak var secondTeamLabel: UILabel!
    
    // MARK: - Properties:
    
    private let maxPlayersInARow = 5.0
    
    private let topDefaultTeam = TeamEntity(by: TeamSchemeType.allCases[Int.random(in: TeamSchemeType.allCases.indices)])
    private let bottomDefaultTeam = TeamEntity(by: TeamSchemeType.allCases[Int.random(in: TeamSchemeType.allCases.indices)])
    
    private(set) var teamAtTheTop    : [PlayerCircleView]!
    private(set) var teamAtTheBottom : [PlayerCircleView]!
    
    private var activeTextField : UITextField!
    private var editingTeameSide: TeamSide!
    
    private var footballFieldManager = FootballFieldManager()
    
    private var circleDiameter: CGFloat!
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
    
    // MARK: - Lifecycle of FootballFieldViewController:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        footballFieldView.footballFieldManager = footballFieldManager
        
        circleDiameter = view.frame.width / CGFloat(maxPlayersInARow * 3 )
        controlsFontSize = circleDiameter * 0.5
        
        changeTeamSchemeControlsAtributedText(on: .top, using: topDefaultTeam)
        changeTeamSchemeControlsAtributedText(on: .bottom, using: bottomDefaultTeam)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
    
    private func getFootballTeamCircleViewsWith(model: TeamEntity, atThe side: TeamSide) -> [PlayerCircleView] {
        
        var footballTeam: [PlayerCircleView] = []
        
        let verticalPadding = getPaddingFor(elements: model.teamMatrix.count, inLine: footballFieldManager.rect.height / 2)
        
        for (lineIndex, playersInLine) in model.teamMatrix.enumerated() {
            
            let horizontalPadding = getPaddingFor(elements: playersInLine.count, inLine: footballFieldManager.rect.width)
            
            for (indexFirstTeam, player)in playersInLine.enumerated() {
                
                let fieldMinX = footballFieldManager.rect.minX
                let lengthOfAddedVerticalCircles = circleDiameter * CGFloat(indexFirstTeam)
                let lengthOfAddedVerticalPaddings = horizontalPadding * CGFloat(indexFirstTeam + 1)
                
                let startX = fieldMinX + lengthOfAddedVerticalCircles + lengthOfAddedVerticalPaddings
                
                var fieldMinY: CGFloat
                if side == .top {
                    fieldMinY = footballFieldManager.rect.minY
                } else {
                    fieldMinY = footballFieldManager.rect.height - circleDiameter
                }
                let lengthOfAddedHorizontalCircles = circleDiameter * CGFloat(lineIndex)
                let lengthOfAddedHorizontalPaddings = verticalPadding * CGFloat(lineIndex + 1)
                
                let startY = fieldMinY + side.indicator * (lengthOfAddedHorizontalCircles + lengthOfAddedHorizontalPaddings)
                
                let playerCircle = PlayerCircleView(frame: CGRect(x: startX, y: startY, width: circleDiameter, height: circleDiameter + controlsFontSize))
                
                let playerNumberFont = UIFont.systemFont(ofSize: controlsFontSize, weight: .thin)
                
                let playerNumberAtributedString = NSAttributedString(string: "\(player.number)", attributes: [.font : playerNumberFont])
                
                let playerNameFont = UIFont.systemFont(ofSize: controlsFontSize * 0.5, weight: .thin)
                let playerNameAtributedString = NSAttributedString(string: "\(player.fullName)", attributes: [.font : playerNameFont])
                
                playerCircle.configureWith(playerNumber: playerNumberAtributedString, teamColor: side.color, playerName: playerNameAtributedString)
                
                footballTeam.append(playerCircle)
            }
        }
        
        return footballTeam
    }
    
    private func getPaddingFor(elements amount: Int, inLine length: CGFloat) -> CGFloat {
        let lengthOfAllCirclesVertical = circleDiameter * CGFloat(amount)
        let amountOfVerticalPaddings = CGFloat(amount + 1)
        
        return (length - lengthOfAllCirclesVertical) / amountOfVerticalPaddings
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
