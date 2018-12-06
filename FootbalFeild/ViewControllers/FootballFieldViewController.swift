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
    
    init?(pattern: String) {
        switch pattern {
        case "433":
            self = .s433
        case "4411":
            self = .s4411
        default:
            return nil
        }
    }
    
    var teamMatrix: [[Int]] {
        switch self {
        case .s433:
            return [ [1], [2, 3, 4, 5],  [6, 7, 8],  [9, 10, 11] ]
        case .s4411:
            return [ [1], [2, 3, 4, 5], [6, 7, 8, 9], [10], [11] ]
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .s433:
            return "4-3-3"
        case .s4411:
            return "4-4-1-1"
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
    
    @IBAction func schemeButtonTouched(_ sender: UIButton) {
        sender.isHidden = true
        if sender == firstTeamSchemeButton {
            show(firstTeamSchemeInputTextField, animated: true)
        } else {
            show(secondTeamSchemeNameInputTextField, animated: true)
        }
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
        
        teamAtTheTop = getFootballTeamCircleViewsWith(scheme: .s4411, atThe: .top)
        teamAtTheBottom = getFootballTeamCircleViewsWith(scheme: .s433, atThe: .bottom)
        
        teamAtTheTop.forEach() { self.view.addSubview($0)}
        teamAtTheBottom.forEach() { self.view.addSubview($0)}
        
        
    }
    
    @objc func cancelNumberPad() {
        dismiss(activeTextField)
    }
    
    @objc func doneWithNumberPad() {        
        changeSchemeAccordingTo(inputtedText: activeTextField.text, atThe: editingTeameSide)
        
        dismiss(activeTextField)
    }
    
    // MARK: - Functions:
    
    private func getFootballTeamCircleViewsWith(scheme: TeamSchemeType, atThe side: TeamSide) -> [PlayerCircleView] {
        
        switch side {
        case .top:
            firstTeamSchemeButton.setTitle(scheme.buttonTitle, for: .normal)
        case .bottom:
            secondTeamSchemeButton.setTitle(scheme.buttonTitle, for: .normal)
        }
        
        var footballTeam: [PlayerCircleView] = []
        
        let topBottomPadding: CGFloat = (footballFieldView.feildFrame.maxY / 2 - circleDiameter * CGFloat(scheme.teamMatrix.count + 1)) / CGFloat(scheme.teamMatrix.count + 1)
        
        for (lineIndex, playersInLine) in scheme.teamMatrix.enumerated() {
            
            let leftRighPadding = (footballFieldView.feildFrame.width - circleDiameter * CGFloat(playersInLine.count)) / CGFloat(playersInLine.count + 1)
            
            for (indexFirstTeam, player)in playersInLine.enumerated() {
                let startX = footballFieldView.feildFrame.minX + circleDiameter * CGFloat(indexFirstTeam) + leftRighPadding * CGFloat(indexFirstTeam + 1)
                let startY = (side == .top ? footballFieldView.feildFrame.minY : footballFieldView.frame.maxY - circleDiameter) + side.indicator * (circleDiameter * CGFloat(lineIndex) + topBottomPadding * CGFloat(lineIndex + 1))
                
                let playerCircle = PlayerCircleView(frame: CGRect(x: startX, y: startY, width: circleDiameter, height: circleDiameter))
                
                playerCircle.configureWith(playerNumber: player, teamColor: side.color)
                
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
    
    private func hideTextField(_ textField: UITextField, animated: Bool) {
        textField.isHidden = true
        UIView.animate(withDuration: animated ? 0.3 : 0, animations: {
            textField.alpha = 0.0
            textField.resignFirstResponder()
        })
    }
    
    private func dismiss(_ textField: UITextField) {
        
        firstTeamSchemeInputTextField.text = ""
        secondTeamSchemeNameInputTextField.text = ""
        
        textField.resignFirstResponder()
        
        hideTextField(textField, animated: true)
        
        if textField == firstTeamSchemeInputTextField {
            firstTeamSchemeButton.isHidden = false
        } else {
            secondTeamSchemeButton.isHidden = false
        }
    }
    
    private func changeSchemeAccordingTo(inputtedText: String?, atThe: TeamSide) {
        if let text = inputtedText,
            let shemeType = TeamSchemeType(pattern: text) {
            switch atThe {
            case .top:
                teamAtTheTop.forEach() { $0.removeFromSuperview()}
                teamAtTheTop = getFootballTeamCircleViewsWith(scheme: shemeType, atThe: atThe)
                teamAtTheTop.forEach() { self.view.addSubview($0)}
            case .bottom:
                teamAtTheBottom.forEach() { $0.removeFromSuperview()}
                teamAtTheBottom = getFootballTeamCircleViewsWith(scheme: shemeType, atThe: atThe)
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
    
    fileprivate func makeConstant(_ newConstant: CGFloat, for constraint: NSLayoutConstraint, animated: Bool) {
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
