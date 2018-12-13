//
//  SchemePopupViewController.swift
//  FootbalField
//
//  Created by Oleksii  Kolomiiets on 12/13/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

protocol SchemePickerDelegate {
    func pickerView(_ pickerView: UIPickerView, picked scheme: TeamSchemeType)
}

class SchemePopupViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    // MARK: - Outlets:
    
    @IBOutlet private weak var schemePickerView: UIPickerView!
    
    
    // MARK: Properties:
    
    public var delegate: SchemePickerDelegate!
    
    private var schemes: [TeamSchemeType]!
    private var selectedSchemeIndex: Int!
    
    // MARK: Lifecycle methods of SchemePopupViewController:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        schemePickerView.selectRow(selectedSchemeIndex, inComponent: 0, animated: false)
    }
    
    
    // MARK: Functions:
    
    public func configure(with schemes: [TeamSchemeType], selected scheme: TeamSchemeType) {
        self.schemes = schemes
        self.selectedSchemeIndex = schemes.firstIndex(of: scheme) ?? 0
    }
    
    
    // MARK: UIPickerViewDataSource:
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return schemes.count
    }
    
    //MARK: UIPickerViewDelegate:
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return schemes?[row].buttonTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate.pickerView(schemePickerView, picked: schemes[row])
        self.view.removeFromSuperview()
    }
    
    
}
