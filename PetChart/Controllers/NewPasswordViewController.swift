//
//  NewPasswordViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/14.
//

import UIKit

class NewPasswordViewController: BaseViewController {
@IBOutlet weak var tfPassword: CTextField!
    @IBOutlet weak var tfPasswordConfirm: CTextField!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var bgCornerView: UIView!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    
    var param:[String:Any] = [String:Any]()
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
        
        if sender == btnOk {
            self.view.endEditing(true)
            
            guard let password = tfPassword.text, password.isEmpty == false, password.validatePassword() else {
                self.showToast("비밀번호(숫자,영문,특수문자 8자이상)를 입력해주세요.")
                return
            }
            
            guard let password2 = tfPasswordConfirm.text, password2.isEmpty == false else {
                self.showToast("비밀번호를 확인해주세요.")
                return
            }
            
            if password != password2 {
                self.showToast("비밀번호가 일치하지 않습니다.")
                return
            }
            
//            "id": "test@test.com",
//             "join_type": "none",
//             "key": "a+zAj00AnMu/SiFY5YTLwKoyq1J2Cku8pB2FjwHXFwY=",
//             "password": 1234567

            param["password"] = password2
            AlertView.showWithOk(title: "비밀번호 변경", message: "비밀번호를 확인해주세요.") { (index) in
                ApiManager.shared.requestModifyPassword(param: self.param) { (response) in
                    if let _ = response as?[String:Any] {
                        SharedData.setObjectForKey(key: kUserPassword, value: password2)
                        if let viewcontrollers = self.navigationController?.viewControllers {
                            for vc in viewcontrollers {
                                if let vc = vc as? LoginViewController {
                                    self.navigationController?.popToViewController(vc, animated: true)
                                }
                            }
                        }
                        else {
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let textField = textField as? CTextField {
            textField.borderColor = ColorDefault
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let textField = textField as? CTextField {
            textField.borderColor = ColorBorder
        }
    }
}
