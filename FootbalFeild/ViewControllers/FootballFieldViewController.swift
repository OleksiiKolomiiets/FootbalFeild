//
//  FootballFieldViewController.swift
//  FootbalFeild
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
    @IBOutlet private weak var firstTeamSchemeButton: UIButton!
    @IBOutlet private weak var secondTeamSchemeButton: UIButton!
    @IBOutlet private weak var firstTeamSchemeInputTextField: UITextField!
    @IBOutlet private weak var secondTeamSchemeNameInputTextField: UITextField!
    @IBOutlet weak var secondTeamSchemeNameInputBottomConstraint: NSLayoutConstraint!
    
    
    // MARK: - Properties:
    
    // MARK: Constants:
    private let maxPlayersInARow = 5
    
    // MARK: Variables:
    private var circleDiameter: CGFloat {
        return view.frame.width / CGFloat(maxPlayersInARow * 2 + 1)
    }
    
    private(set) var teamAtTheTop    : [PlayerCircleView]!
    private(set) var teamAtTheBottom : [PlayerCircleView]!
    
    private var activeTextField : UITextField!
    private var editingTeameSide: TeamSide!
    
    
    // MARK: - Actions:
    
    @IBAction func schemeButtonTouched(_ sender: UIButton) {
        sender.isHidden = true
        if sender == firstTeamSchemeButton {
            show(firstTeamSchemeInputTextField, animated: true)
        } else {
            show(secondTeamSchemeNameInputTextField, animated: true)
        }
    }
    
    @objc func cancelNumberPad() {
        dismiss(activeTextField)
    }
    
    @objc func doneWithNumberPad() {
        changeSchemeAccordingTo(inputtedText: activeTextField.text, atThe: editingTeameSide)
        
        dismiss(activeTextField)
    }
    
    
    // MARK: - Lifecycle of FootballFieldViewController:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewResizerOnKeyboardShown()
        
        setupKeyboardToolbar(for: firstTeamSchemeInputTextField)
        setupKeyboardToolbar(for: secondTeamSchemeNameInputTextField)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaultTeam = TeamEntity(by: .s433)
        
        teamAtTheTop = getFootballTeamCircleViewsWith(model: defaultTeam, atThe: .top)
        changeTeamSchemeButtonTitle(for: .top, using: defaultTeam)
        
        teamAtTheBottom = getFootballTeamCircleViewsWith(model: defaultTeam, atThe: .bottom)
        changeTeamSchemeButtonTitle(for: .bottom, using: defaultTeam)
        
        teamAtTheTop.forEach() { self.view.addSubview($0)}
        teamAtTheBottom.forEach() { self.view.addSubview($0)}
        
        
    }
    
    
    // MARK: - Functions:
    
    private func changeTeamSchemeButtonTitle(for side: TeamSide, using model: TeamEntity) {
        switch side {
        case .top:
            firstTeamSchemeButton.setTitle(model.scheme.buttonTitle, for: .normal)
        case .bottom:
            secondTeamSchemeButton.setTitle(model.scheme.buttonTitle, for: .normal)
        }
    }
    
    private func getFootballTeamCircleViewsWith(model: TeamEntity, atThe side: TeamSide) -> [PlayerCircleView] {
        
        var footballTeam: [PlayerCircleView] = []
        
        let topBottomPadding: CGFloat = (footballFieldView.feildFrame.maxY / 2 - circleDiameter * CGFloat(model.teamMatrix.count + 1)) / CGFloat(model.teamMatrix.count + 1)
        
        for (lineIndex, playersInLine) in model.teamMatrix.enumerated() {
            
            let leftRighPadding = (footballFieldView.feildFrame.width - circleDiameter * CGFloat(playersInLine.count)) / CGFloat(playersInLine.count + 1)
            
            for (indexFirstTeam, player)in playersInLine.enumerated() {
                let startX = footballFieldView.feildFrame.minX + circleDiameter * CGFloat(indexFirstTeam) + leftRighPadding * CGFloat(indexFirstTeam + 1)
                let startY = (side == .top ? footballFieldView.feildFrame.minY : footballFieldView.frame.maxY - circleDiameter) + side.indicator * (circleDiameter * CGFloat(lineIndex) + topBottomPadding * CGFloat(lineIndex + 1))
                
                let playerCircle = PlayerCircleView(frame: CGRect(x: startX, y: startY, width: circleDiameter, height: circleDiameter))
                
                playerCircle.configureWith(playerNumber: player.number, teamColor: side.color)
                
                footballTeam.append(playerCircle)
            }
        }
        
        return footballTeam
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
        secondTeamSchemeNameInputTextField.text = ""
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
            changeTeamSchemeButtonTitle(for: side, using: team)
            
            switch side {
            case .top:
                teamAtTheTop.forEach() { $0.removeFromSuperview()}
                teamAtTheTop = getFootballTeamCircleViewsWith(model: TeamEntity(by: shemeType), atThe: side)
                teamAtTheTop.forEach() { self.view.addSubview($0)}
                
            case .bottom:
                teamAtTheBottom.forEach() { $0.removeFromSuperview()}
                teamAtTheBottom = getFootballTeamCircleViewsWith(model: TeamEntity(by: shemeType), atThe: side)
                teamAtTheBottom.forEach() { self.view.addSubview($0)}
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
            dismiss(secondTeamSchemeNameInputTextField)
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
        UIView.animate(withDuration: animated ? 1 : 0, animations: {
            constraint.constant = newConstant
        })
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        if secondTeamSchemeNameInputTextField.isEditing {
            if notification.name == UIResponder.keyboardWillHideNotification {
                makeConstant(8, for: secondTeamSchemeNameInputBottomConstraint, animated: false)
            } else {
                let keyboardScreenEndFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                makeConstant(keyboardScreenEndFrame.height, for: secondTeamSchemeNameInputBottomConstraint, animated: true)
            }
        }
    }
    
}
