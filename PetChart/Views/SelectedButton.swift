//
//  SelectedButton.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/01.
//

import UIKit

class SelectedButton: UIButton {
    var data:Any? = nil
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.decorationNormalBtn()
    }
    override var isSelected: Bool {
        didSet {
            if isSelected {
                decorationSelectedBtn()
            }
            else {
                decorationNormalBtn()
            }
        }
    }
    
    func decorationSelectedBtn() {
        self.layer.borderColor = ColorDefault.cgColor
        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = 4.0
        self.setTitleColor(ColorDefault, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: (self.titleLabel?.font.pointSize)!, weight: .bold)
    }
    func decorationNormalBtn() {
        self.layer.borderColor = RGB(221, 221, 221).cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 4.0
        self.setTitleColor(UIColor.black, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: (self.titleLabel?.font.pointSize)!, weight: .regular)
    }
}
