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

class FootballFieldViewController: UIViewController, UITextFieldDelegate {

    
    // MARK: - Outlets:
    
    @IBOutlet private weak var footballFieldView: FootballFieldView!
    
    @IBOutlet private weak var firstTeamSchemeButton : UIButton!
    @IBOutlet private weak var secondTeamSchemeButton: UIButton!
    
    @IBOutlet private weak var firstTeamSchemeInputTextField : UITextField!
    @IBOutlet private weak var secondTeamSchemeInputTextField: UITextField!
    
    @IBOutlet private weak var secondTeamSchemeNameInputBottomConstraint: NSLayoutConstraint!
    
    
    // MARK: - Properties:
    
    private let maxPlayersInARow = 5.0
    
    private let defaultTeam = TeamEntity(by: .s1432)
    
    private(set) var teamAtTheTop    : [PlayerCircleView]!
    private(set) var teamAtTheBottom : [PlayerCircleView]!
    
    private var activeTextField : UITextField!
    private var editingTeameSide: TeamSide!
    
    private var footballFieldManager = FootballFieldManager()
    
    private var circleDiameter: CGFloat!
    private var controlsFontSize: CGFloat!
    
    
    // MARK: - Actions:
    
    @IBAction func schemeButtonTouched(_ sender: UIButton) {
        sender.isHidden = true
        if sender == firstTeamSchemeButton {
            show(firstTeamSchemeInputTextField, animated: true)
        } else {
            show(secondTeamSchemeInputTextField, animated: true)
        }
    }
    
    @objc private func cancelNumberPad() {
        dismiss(activeTextField)
    }
    
    @objc private func doneWithNumberPad() {
        changeSchemeAccordingTo(inputtedText: activeTextField.text, atThe: editingTeameSide)
        
        dismiss(activeTextField)
    }
    
    
    // MARK: - Lifecycle of FootballFieldViewController:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewResizerOnKeyboardShown()
        
        setupKeyboardToolbar(for: firstTeamSchemeInputTextField)
        setupKeyboardToolbar(for: secondTeamSchemeInputTextField)
        
        footballFieldView.footballFieldManager = footballFieldManager
        
        
        circleDiameter = view.frame.width / CGFloat(maxPlayersInARow * 3 )
        controlsFontSize = circleDiameter * 0.5
        
        firstTeamSchemeInputTextField.font = UIFont.systemFont(ofSize: controlsFontSize,  weight: .thin)
        secondTeamSchemeInputTextField.font = UIFont.systemFont(ofSize: controlsFontSize,  weight: .thin)
        
        changeTeamSchemeControlsAtributedText(on: .top, using: defaultTeam)
        changeTeamSchemeControlsAtributedText(on: .bottom, using: defaultTeam)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        teamAtTheTop = getFootballTeamCircleViewsWith(model: defaultTeam, atThe: .top)
        
        teamAtTheBottom = getFootballTeamCircleViewsWith(model: defaultTeam, atThe: .bottom)
        
        teamAtTheTop.forEach() { footballFieldView.addSubview($0)}
        teamAtTheBottom.forEach() { footballFieldView.addSubview($0)}
    }
    
    
    // MARK: - Functions:
    
    private func changeTeamSchemeControlsAtributedText(on side: TeamSide, using model: TeamEntity) {
        
        let buttonTitleFont = UIFont.systemFont(ofSize: controlsFontSize,  weight: .thin)
        let buttonTitleAtributedString = NSAttributedString(string: model.scheme.buttonTitle, attributes: [.font : buttonTitleFont])
        
        switch side {
        case .top:
            firstTeamSchemeButton.setAttributedTitle(buttonTitleAtributedString, for: .normal)
        case .bottom:
            secondTeamSchemeButton.setAttributedTitle(buttonTitleAtributedString, for: .normal)
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
    
    private func show(_ textField: UITextField, animated: Bool) {
        textField.isHidden = false
        UIView.animate(withDuration: animated ? 0.3 : 0, animations: {
            textField.alpha = 1.0
            textField.becomeFirstResponder()
        })
    }
    
    private func dismiss(_ textField: UITextField) {
        
        clearTextFields()
        
        hideTextField(textField, animated: true)
        
        showButtonResponsibleFor(textField)
        
        textField.resignFirstResponder()
    }
    
    private func hideTextField(_ textField: UITextField, animated: Bool) {
        textField.isHidden = true
        UIView.animate(withDuration: animated ? 0.3 : 0, animations: {
            textField.alpha = 0.0
            textField.resignFirstResponder()
        })
    }
    
    private func clearTextFields() {
        firstTeamSchemeInputTextField.text = ""
        secondTeamSchemeInputTextField.text = ""
    }
    
    private func showButtonResponsibleFor(_ textField: UITextField) {
        if textField == firstTeamSchemeInputTextField {
            firstTeamSchemeButton.isHidden = false
        } else {
            secondTeamSchemeButton.isHidden = false
        }
    }
    
    private func changeSchemeAccordingTo(inputtedText: String?, atThe side: TeamSide) {
        if let text = inputtedText,
            let shemeType = TeamSchemeType(rawValue: text) {
            
            let team = TeamEntity(by: shemeType)
            changeTeamSchemeControlsAtributedText(on: side, using: team)
            
            switch side {
            case .top:
                teamAtTheTop.forEach() { $0.removeFromSuperview()}
                teamAtTheTop = getFootballTeamCircleViewsWith(model: TeamEntity(by: shemeType), atThe: side)
                teamAtTheTop.forEach() { self.footballFieldView.addSubview($0)}
                
            case .bottom:
                teamAtTheBottom.forEach() { $0.removeFromSuperview()}
                teamAtTheBottom = getFootballTeamCircleViewsWith(model: TeamEntity(by: shemeType), atThe: side)
                teamAtTheBottom.forEach() { self.footballFieldView.addSubview($0)}
            }
        }
    }
    
    private func setupKeyboardToolbar(for textField: UITextField) {
        let keyboardToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        
        keyboardToolbar.barStyle = .blackOpaque
        keyboardToolbar.tintColor = .white
        keyboardToolbar.items = [UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelNumberPad)),
                                 UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                                 UIBarButtonItem(title: "Apply", style: .done, target: self, action: #selector(doneWithNumberPad))]
        keyboardToolbar.sizeToFit()
        
        textField.inputAccessoryView = keyboardToolbar
    }
    
    // MARK: - UITextFieldDelegate:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField != firstTeamSchemeInputTextField {
            editingTeameSide = .bottom
            dismiss(firstTeamSchemeInputTextField)
        } else {
            editingTeameSide = .top
            dismiss(secondTeamSchemeInputTextField)
            makeConstant(8, for: secondTeamSchemeNameInputBottomConstraint, animated: false)
        }
        activeTextField = textField
        
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        changeSchemeAccordingTo(inputtedText: textField.text, atThe: editingTeameSide)
        
        dismiss(textField)
        
        return true
    }
    
    // MARK: - Keyboard function
    
    func setupViewResizerOnKeyboardShown() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    private func makeConstant(_ newConstant: CGFloat, for constraint: NSLayoutConstraint, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 1, animations: {
                constraint.constant = newConstant
            })
        } else {
            constraint.constant = newConstant
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        if secondTeamSchemeInputTextField.isEditing {
            if notification.name == UIResponder.keyboardWillHideNotification {
                makeConstant(8, for: secondTeamSchemeNameInputBottomConstraint, animated: false)
            } else {
                let keyboardScreenEndFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                makeConstant(keyboardScreenEndFrame.height, for: secondTeamSchemeNameInputBottomConstraint, animated: true)
            }
        }
    }
    
}
