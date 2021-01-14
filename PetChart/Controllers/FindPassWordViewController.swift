//
//  FindPassWordViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/14.
//

import UIKit
import PhoneNumberKit

class FindPassWordViewController: BaseViewController {

    @IBOutlet weak var tfUserId: CTextField!
    @IBOutlet weak var tfUserName: CTextField!
    @IBOutlet weak var tfPhoneNumber: CTextField!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var cornerBgView: UIView!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    
    let phoneNumberKit = PhoneNumberKit()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "비밀번호 찾기", nil)
        
        cornerBgView.layer.cornerRadius = 20.0
        cornerBgView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        if Utility.isIphoneX() == false {
            btnSafety.isHidden = true
        }
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureHandler(_ :)))
        self.view.addGestureRecognizer(tap)
        
        if let userId = SharedData.getUserId() {
            tfUserId.text = userId
        }
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

    @IBAction func textFieldEditingChange(_ sender: UITextField) {
        
        
        if sender == tfPhoneNumber  {
            guard let text = sender.text else {
                return
            }
            
            if text.isEmpty == true {
                return
            }
            else {
                do {
                    let phoneNumber = try phoneNumberKit.parse(text, ignoreType: true)
                    let newNum = self.phoneNumberKit.format(phoneNumber, toType: .national)
                    self.tfPhoneNumber.text = newNum
                } catch {
                    self.tfPhoneNumber.text = text
                }
            }
        }
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        self.view.endEditing(true)
        if sender == btnOk {
            guard let email = tfUserId.text, email.isEmpty == false, email.validateEmail() == true else {
                self.showToast("아이디를 입력해주세요.")
                return
            }
            
            guard let name = tfUserName.text, name.isEmpty == false else {
                self.showToast("이름을 입력해주세요.")
                return
            }
            
            guard let phone = tfPhoneNumber.text, phone.isEmpty == false else {
                self.showToast("연락처를 입력해주세요.")
                return
            }
            
            var loginType = "none"
            if let type = SharedData.getLoginType() {
                loginType = type
            }
            
            let param = ["id": email, "join_type":loginType, "name":name, "phone":phone];
            ApiManager.shared.requestFindUserPassword(param: param) { (response) in
                if let response = response as?[String:Any], let data = response["data"] as?[String:Any], let key = data["key"] as?String {
                    AlertView.showWithOk(title: "알림", message: "정보가 일치합니다.") { (index) in
                        let vc = NewPasswordViewController.init()
                        let param = ["id": email, "join_type":loginType, "key":key]
                        vc.param = param
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                
            } failure: { (error) in
//                self.showErrorAlertView(error)
                AlertView.showWithOk(title: "알림", message: "정보가 일치하지 않습니다.", completion: nil)
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
extension FindPassWordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfUserId {
            tfUserName.becomeFirstResponder()
        }
        else if textField == tfUserName {
            tfPhoneNumber.becomeFirstResponder()
        }
        else {
            self.view.endEditing(true)
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let textField = textField as? CTextField {
            textField.borderColor = ColorDefault
            textField.setNeedsDisplay()
        }
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let textField = textField as? CTextField {
            textField.borderColor = ColorBorder
            textField.setNeedsDisplay()
        }
        return true
    }
}
