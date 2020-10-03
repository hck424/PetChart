//
//  MemberInfoModifyViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/02.
//

import UIKit

class MemberInfoModifyViewController: BaseViewController {
    @IBOutlet weak var tfName: CTextField!
    @IBOutlet weak var tfNicName: CTextField!
    @IBOutlet weak var tfEmail: CTextField!
    @IBOutlet weak var btnPhoneNumberChange: CButton!
    @IBOutlet weak var tfPhoneNumber: CTextField!
    @IBOutlet var arrBtnPrivacy: [SelectedButton]!
    @IBOutlet weak var tfAddress: CTextField!
    @IBOutlet weak var btnAddressSearch: CButton!
    @IBOutlet weak var tfAddressDetail: CTextField!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    @IBOutlet var accessoryView: UIToolbar!
    @IBOutlet weak var btnKeyboardDown: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "로그인 정보수정", nil)
        
        if Utility.isIphoneX() == false {
            btnSafety.isHidden = true
        }
        
        tfName.inputAccessoryView = accessoryView
        tfNicName.inputAccessoryView = accessoryView
        tfEmail.inputAccessoryView = accessoryView
        tfEmail.inputAccessoryView = accessoryView
        tfPhoneNumber.inputAccessoryView = accessoryView
        tfAddressDetail.inputAccessoryView = accessoryView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @IBAction func tapGestureHandler(_ sender: UITapGestureRecognizer) {
        if sender.view == self.view {
            self.view.endEditing(true)
        }
    }
    
    @IBAction func onClickedButtonActions(_ sender: Any) {
        self.view.endEditing(true)
        
        if sender as? NSObject == btnPhoneNumberChange {
            print("ph number change")
        }
        else if sender as? NSObject == btnAddressSearch {
            print("address search")
        }
        else if let sender = (sender as? NSObject) as? SelectedButton {
            print("privarsy")
            for btn in arrBtnPrivacy {
                btn.isSelected = false
            }
            sender.isSelected = true
        }
        else if sender as? NSObject == btnOk {
            print("btn Ok")
        }
    }
    
    @objc func notificationHandler(_ notification: Notification) {
            
        let heightKeyboard = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
        let duration = CGFloat((notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.0)
 
        if notification.name == UIResponder.keyboardWillShowNotification {
            
            bottomContainer.constant = heightKeyboard - (AppDelegate.instance()?.window?.safeAreaInsets.bottom ?? 0) - btnOk.bounds.height
            UIView.animate(withDuration: TimeInterval(duration), animations: { [self] in
                self.view.layoutIfNeeded()
            })
        }
        else if notification.name == UIResponder.keyboardWillHideNotification {
            bottomContainer.constant = 0
            UIView.animate(withDuration: TimeInterval(duration)) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension MemberInfoModifyViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == tfName {
            tfNicName.becomeFirstResponder()
        }
        else if textField == tfNicName {
            tfEmail.becomeFirstResponder()
        }
        else if textField == tfEmail {
            tfPhoneNumber.becomeFirstResponder()
        }
        else if textField == tfPhoneNumber {
            tfAddress.becomeFirstResponder()
        }
        else if textField == tfAddress {
            tfAddressDetail.becomeFirstResponder()
        }
        else {
            self.view.endEditing(true)
        }
        return true
    }
}
