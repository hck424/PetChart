//
//  MrStep3ViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/30.
//

import UIKit

@IBDesignable class MrStep3ViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnSafety: UIButton!
    @IBInspectable @IBOutlet weak var tfEmail: CTextField!
    @IBInspectable @IBOutlet weak var tfNickName: CTextField!
    @IBOutlet weak var btnEye1: UIButton!
    @IBOutlet weak var btnEye2: UIButton!
    @IBInspectable @IBOutlet weak var tfPassword: UITextField!
    @IBInspectable @IBOutlet weak var tfPasswordConfirm: UITextField!
    @IBInspectable @IBOutlet weak var btnEmailCheck: CButton!
    @IBInspectable @IBOutlet weak var btnNickNameCheck: CButton!
    @IBOutlet weak var bgCornerView: UIView!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    
    @IBOutlet weak var lbHintEmail: UILabel!
    @IBOutlet weak var lbHitNickName: UILabel!
    @IBOutlet weak var lbHintPassword: UILabel!
    @IBOutlet weak var lbHintPasswordConfirm: UILabel!
    
    var user: UserInfo?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "회원가입", nil)
        
        if Utility.isIphoneX() == false {
            btnSafety.isHidden = true
        }
        bgCornerView.layer.cornerRadius = 20
        bgCornerView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        
        btnEmailCheck.setBackgroundImage(UIImage.image(from: RGB(229, 229, 229)), for: .normal)
        btnEmailCheck.setBackgroundImage(UIImage.image(from: ColorDefault), for: .selected)
        btnEmailCheck.setTitleColor(RGB(166, 166, 166), for: .normal)
        btnEmailCheck.setTitleColor(UIColor.white, for: .selected)
        
        btnNickNameCheck.setBackgroundImage(UIImage.image(from: RGB(229, 229, 229)), for: .normal)
        btnNickNameCheck.setBackgroundImage(UIImage.image(from: ColorDefault), for: .selected)
        btnNickNameCheck.setTitleColor(RGB(166, 166, 166), for: .normal)
        btnNickNameCheck.setTitleColor(UIColor.white, for: .selected)
    
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
    
    //FIXME:: button actions
    @IBAction func onclickedButtonActions(_ sender: UIButton) {
        if sender == btnEmailCheck {
            guard let id = tfEmail.text, id.isEmpty == false else {
                return
            }
            
            ApiManager.shared.requestFindUserIdCheck(id: id) { (response) in
                if let response = response as? [String : Any], let success = response["success"] as? Bool {
                    
                    if let msg = response["msg"] as? String {
                        if msg == "사용할 수 있는 아이디 입니다." {
                            self.btnEmailCheck.isSelected = true
                        }
                        else {
                            self.showErrorAlertView(response)
                        }
                    }
                }
                else {
                    self.showErrorAlertView(response)
                }
                
            } failure: { (error) in
                self.showErrorAlertView(error)
            }
        }
        else if sender == btnNickNameCheck {
            guard let nicName = tfNickName.text else {
                return
            }
            
            ApiManager.shared.requestFindUserNicNameCheck(nickName: nicName, success: { (response) in
                if let response = response as? [String : Any], let success = response["success"] as? Bool {
                    if let msg = response["msg"] as? String {
                        if msg == "사용할 수 있는 닉네임 입니다." {
                            self.btnNickNameCheck.isSelected = true
                        }
                        else {
                            self.showErrorAlertView(response)
                        }
                    }
                    else {
                        self.showErrorAlertView(response)
                    }
                }
            }, failure: { (error) in
                self.showErrorAlertView(error)
            })
        }
        else if sender == btnEye1 {
            sender.isSelected = !sender.isSelected
            tfPassword.isSecureTextEntry = !sender.isSelected
        }
        else if sender == btnEye2 {
            sender.isSelected = !sender.isSelected
            tfPasswordConfirm.isSecureTextEntry = !sender.isSelected
        }
        else if sender == btnOk {
            lbHintEmail.isHidden = true
            lbHitNickName.isHidden = true
            lbHintPassword.isHidden = true
            lbHintPasswordConfirm.isHidden = true
            
            var isOk = true
            if (tfEmail.text?.count == 0 || tfEmail.text?.validateEmail() == false) {
                lbHintEmail.text = "이메일 형식이 아닙니다."
                lbHintEmail.isHidden = false
                isOk = false
            }
            else if btnEmailCheck.isSelected == false {
                lbHintEmail.text = "이메일 중복 체크를 해주세요."
                lbHintEmail.isHidden = false
                isOk = false
            }
            
            if (tfNickName.text?.count == 0) {
                lbHitNickName.text = "닉네임을 입력해주세요."
                lbHitNickName.isHidden = false
                isOk = false
            }
            else if btnNickNameCheck.isSelected == false {
                lbHitNickName.text = "닉네임을 체크해주세요"
                lbHitNickName.isHidden = false
                isOk = false
            }
            
            if (tfPassword.text?.count == 0) || (tfPassword.text?.validatePassword() == false) {
                lbHintPassword.text = "숫자, 영문, 특수문자 조합 8자 이상"
                lbHintPassword.isHidden = false
                isOk = false
            }
            
            if tfPassword.text != tfPasswordConfirm.text {
                lbHintPasswordConfirm.text = "비밀번호가 일치하지 않습니다."
                lbHintPasswordConfirm.isHidden = false
                isOk = false
            }
            
            if isOk == false {
                return
            }
            guard let user = user else {
                return
            }
            
            var param: Dictionary<String, String> = [:]
            guard let email = tfEmail.text else  {
                return
            }
            guard let jonin_type = user.joinType,
                  let name = user.name,
                  let nickname = tfNickName.text,
                  let password = tfPassword.text,
                  let birthday = user.birthday,
                  let sex = user.gender else {
                
                return
            }
            
            param["email"] = email
            param["id"] = email
            param["join_type"] = jonin_type
            param["name"] = name
            param["nickname"] = nickname
            param["sex"] = sex
            param["password"] = password
            param["birthday"] = birthday
            param["privacy_agree"] = "true"
            param["termsservice_agree"] = "true"
            param["Marketing_agree"] = "true"
            
            self.view.endEditing(true)
            ApiManager.shared.requestUserSignOut(param: param) { (response) in
                print("회원가입 성공: \(String(describing: response))")
                
                if let response = response as? [String: Any], let success = response["success"] as? Bool {
                    if success == true {
                        
                    }
                    else {
                        self.showErrorAlertView(response)
                    }
                }
            } failure: { (error) in
                print("회원가입 실패: \(String(describing: error))")
                if let error = error as? Dictionary<String, Any> {
                    
                    var title = "에러"
                    var errorCode: Int = 0
                    if let code = error["code"] as? Int {
                        title.append(":\(code)")
                        errorCode = code
                    }
                    guard let msg = error["msg"] as? String else {
                        return
                    }
                    
                    AlertView.showWithOk(title: title, message: msg) { (index) in
                        if errorCode == -1005 {
                            let vcs:Array = self.navigationController!.viewControllers as Array
                            var findIndex:Int = 0
                            for index in stride(from: vcs.count-1, to: 0, by: -1) {
                                let vc = vcs[index]
                                if vc.isKind(of: LoginViewController.classForCoder()) == true {
                                    findIndex = index
                                    break
                                }
                            }
                            self.navigationController?.popToViewController(vcs[findIndex], animated: true)
                        }
                        
                    }
                }
                else if (error as? Error) != nil {
                    AlertView.showWithOk(title: "에러", message: "시스템 에러", completion: nil)
                }
            }
        }
    }
    
    @objc func notificationHandler(_ notification: Notification) {
            
        let heightKeyboard = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
        let duration = CGFloat((notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.0)
 
        if notification.name == UIResponder.keyboardWillShowNotification {
            
            bottomContainer.constant = heightKeyboard - (AppDelegate.instance()?.window?.safeAreaInsets.bottom)!
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
    
    //MARK:: textfiled actions
    @IBAction func textFeildEdtingChange(_ textField: UITextField) {
        
        if textField == tfEmail {
            
        }
        else if textField == tfNickName {
            
        }
        else if textField == tfPassword {
            
        }
        else if textField == tfPasswordConfirm {
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfEmail {
            tfNickName.becomeFirstResponder()
        }
        else if textField == tfNickName {
            tfPassword.becomeFirstResponder()
        }
        else if textField == tfPassword {
            tfPasswordConfirm.becomeFirstResponder()
        }
        else if textField == tfPasswordConfirm {
            self.view.endEditing(true)
        }
        return true
    }
    
}
