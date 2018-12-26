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

protocol PlayerDragDelegate {
    func startDragPlayerView(_ view: PlayerView)
    func endDragPlayerView()
}

class FootballFieldViewController: UIViewController, UITextFieldDelegate, SchemePickerDelegate, PlayerDragDelegate {

    
    // MARK: - Outlets:
    
    @IBOutlet private weak var footballFieldView: FootballFieldView!
    
    @IBOutlet private weak var firstTeamSchemeButton : UIButton!
    @IBOutlet private weak var secondTeamSchemeButton: UIButton!
    
    @IBOutlet private weak var firstTeamLabel: UILabel!
    @IBOutlet private weak var secondTeamLabel: UILabel!
    
    @IBOutlet private weak var firstTeamClearButton : UIButton!
    @IBOutlet private weak var secondTeamClearButton: UIButton!
    
    @IBOutlet private weak var banchView: UIView!
    
    
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
            changeSchemeAccordingTo(.blank, atThe: .top)
        } else {
            changeSchemeAccordingTo(.blank, atThe: .bottom)
        }
    }
    
    // MARK: - Lifecycle of FootballFieldViewController:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        footballFieldView.footballFieldManager = footballFieldManager
        
        
        controlsFontSize = view.frame.height * 0.03
        firstTeamClearButton.titleLabel?.font = UIFont.systemFont(ofSize: controlsFontSize)
        secondTeamClearButton.titleLabel?.font = UIFont.systemFont(ofSize: controlsFontSize)
        changeTeamSchemeControlsAtributedText(on: .top   , using: topDefaultTeam)
        changeTeamSchemeControlsAtributedText(on: .bottom, using: bottomDefaultTeam)
       
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        playerViewWidth  = footballFieldView.frame.width / maxPlayersInARow
        playerViewHeight = 0.5 * footballFieldView.frame.height / maxPlayersInARow
        
        UIView.animate(withDuration: 0.5, delay: 1.0, options: .curveEaseInOut, animations: {
            self.banchView.isHidden = self.banchView.frame.width < self.playerViewWidth
            self.banchView.alpha = 1.0
        })
        
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
            
            for (indexOfPlayer, player) in playersInLine.enumerated() {
               
                let playerViewOrigin = getStratPointFor(lineIndex, indexOfPlayer, side, padding: (h: horizontalPadding, v: verticalPadding))
                let playerCircle = PlayerView(frame: CGRect(origin: playerViewOrigin, size: CGSize(width: playerViewWidth, height: playerViewHeight)))
                
                playerCircle.delegate = self
                playerCircle.configureWith(player, teamColor: side.color)
                
                footballTeam.append(playerCircle)
            }
        }
        
        return footballTeam
    }
    
    private func getStratPointFor(_ lineIndex: Int, _ playerIndex: Int, _ side: TeamSide, padding: (h: CGFloat, v: CGFloat)) -> CGPoint {
        return CGPoint(x: getCoordinate(for: playerIndex, side,
                                        with: padding.h, min: footballFieldManager.rect.minX, max: footballFieldManager.rect.width, size: playerViewWidth),
                       y: getCoordinate(for: lineIndex  , side,
                                        with: padding.v, min: footballFieldManager.rect.minY, max: footballFieldManager.rect.height, size: playerViewHeight))
    }
    
    private func getCoordinate(for index: Int, _ side: TeamSide, with padding: CGFloat, min: CGFloat, max: CGFloat, size: CGFloat) -> CGFloat {
        let fieldMin = side == .bottom ? max - size : min
        return fieldMin + side.indicator * (size * CGFloat(index) + padding * CGFloat(index + 1))
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
    
    // MARK: - PlayerDragDelegate:
    
    func startDragPlayerView(_ view: PlayerView) {
        footballFieldView.bringSubviewToFront(view)
        
        teamAtTheTop.forEach {
            if $0 != view {
                $0.alpha = 0.5
            }
        }
        teamAtTheBottom.forEach {
            if $0 != view {
                $0.alpha = 0.5
            }
        }
    }
    
    func endDragPlayerView() {
        teamAtTheTop.forEach { $0.alpha = 1.0 }
        teamAtTheBottom.forEach { $0.alpha = 1.0 }
    }
}
