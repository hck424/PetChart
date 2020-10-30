//
//  NewPasswordViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/14.
//

import UIKit

class NewPasswordViewController: BaseViewController {

    @IBOutlet weak var btnEye1: UIButton!
    @IBOutlet weak var btnEye2: UIButton!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var lbHintPasword: UILabel!
    @IBOutlet weak var tfPasswordConfirm: UITextField!
    @IBOutlet weak var lbHitPasswordConfirm: UILabel!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var bgCornerView: UIView!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "비밀번호 설정", nil)
        bgCornerView.layer.cornerRadius = 20
        bgCornerView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        tfPassword.delegate = self
        tfPasswordConfirm.delegate = self
        if Utility.isIphoneX() == false {
            btnSafety.isHidden = true
        }
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureHandler(_ :)))
        self.view.addGestureRecognizer(tap)
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
    @objc func tapGestureHandler(_ gesture:UITapGestureRecognizer) {
        if gesture.view == self.view {
            self.view.endEditing(true)
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        
        if sender == btnEye1 {
            sender.isSelected = !sender.isSelected
            tfPassword.isSecureTextEntry = !sender.isSelected
        }
        else if sender == btnEye2 {
            sender.isSelected = !sender.isSelected
            tfPasswordConfirm.isSecureTextEntry = !sender.isSelected
        }
        else if sender == btnOk {
            self.view.endEditing(true)
            var isOk = true
            lbHintPasword.isHidden = true
            lbHitPasswordConfirm.isHidden = true
            
            let password1:String = tfPassword.text ?? ""
            let password2:String = tfPasswordConfirm.text ?? ""
            
            if password1.isEmpty == true {
                lbHintPasword.isHidden = false
                isOk = false
            }
            else if password1.validatePassword() == false {
                lbHintPasword.isHidden = false
                isOk = false
            }
            
            if password2.isEmpty == true {
                lbHitPasswordConfirm.isHidden = false
                isOk = false
            }
            else if password1 != password2 {
                lbHitPasswordConfirm.isHidden = false
                isOk = false
            }
            
            if isOk == false {
                return
            }
            
//            "id": "test@test.com",
//             "join_type": "none",
//             "key": "a+zAj00AnMu/SiFY5YTLwKoyq1J2Cku8pB2FjwHXFwY=",
//             "password": 1234567
            
            AlertView.showWithOk(title: "비밀번호 변경", message: "비밀번호를 확인해주세요.") { (index) in
                ApiManager.shared.requestModifyPassword(param: [:]) { (response) in
                    
                } failure: { (error) in
                    self.showErrorAlertView(error)
                }
            }
        }
    }
    
    @objc func notificationHandler(_ notification: Notification) {
        let heightKeyboard = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
        let duration = CGFloat((notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.0)
        
        if notification.name == UIResponder.keyboardWillShowNotification {
            let safeBottom = AppDelegate.instance()?.window?.safeAreaInsets.bottom ?? 0
            bottomContainer.constant = heightKeyboard - safeBottom
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

extension NewPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfPassword {
            tfPasswordConfirm.becomeFirstResponder()
        }
        else {
            self.view.endEditing(true)
        }
        return true
    }
}
