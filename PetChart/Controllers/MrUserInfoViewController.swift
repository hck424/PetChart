//
//  MrUserInfoViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/30.
//

import UIKit

@IBDesignable class MrUserInfoViewController: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var svEmail: UIStackView!
    @IBOutlet weak var svNickName: UIStackView!
    @IBOutlet weak var svPassword: UIStackView!
    @IBOutlet weak var svPasswordConfirm: UIStackView!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnSafety: UIButton!
    @IBInspectable @IBOutlet weak var tfEmail: UITextField!
    @IBInspectable @IBOutlet weak var tfNickName: UITextField!
    @IBInspectable @IBOutlet weak var tfPassword: CTextField!
    @IBInspectable @IBOutlet weak var tfPasswordConfirm: CTextField!
    @IBInspectable @IBOutlet weak var btnEmailCheck: CButton!
    @IBInspectable @IBOutlet weak var btnNickNameCheck: CButton!
    @IBOutlet weak var bgCornerView: UIView!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    @IBOutlet weak var seperatorEmail: UIView!
    @IBOutlet weak var seperatorNickName: UIView!
    
    var user: UserInfo?
    var isSocial = false
    var pw:String = ""
    var pwComfirm:String = ""
    
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
        
        if let joinType = user?.joinType, joinType != "none" {
            self.isSocial = true
            tfNickName.text = user?.nickname
        }
        
        if isSocial {
            svEmail.isHidden = true
            svPassword.isHidden = true
            svPasswordConfirm.isHidden = true
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
    
    @IBAction func tapGestureHandler(_ sender: UITapGestureRecognizer) {
        if sender.view == self.scrollView {
            self.view.endEditing(true)
        }
    }
    
    //FIXME:: button actions
    @IBAction func onclickedButtonActions(_ sender: UIButton) {
        if sender == btnEmailCheck {
            guard let email = tfEmail.text, email.isEmpty == false, email.validateEmail() == true else {
                self.scrollView.makeToast("이메일 형식이 아닙니다.")
                return
            }
            ApiManager.shared.requestFindUserIdCheck(id: email) { (response) in
                if let response = response as? [String : Any], let code = response["code"] as? Int, let msg = response["msg"] as? String {
                    if code == 0 {
                        self.btnEmailCheck.isSelected = true
                        self.scrollView.makeToast(msg)
                    }
                    else {
                        self.btnEmailCheck.isSelected = false
                        self.scrollView.makeToast(msg)
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
            guard let nickName = tfNickName.text, nickName.isEmpty == false else {
                self.scrollView.makeToast("닉네임을 입력해주세요.")
                return
            }
            if nickName.length < 2 {
                self.scrollView.makeToast("닉네임 2자리이상 입력해주세요.")
                return
            }
            ApiManager.shared.requestFindUserNicNameCheck(nickName: nickName, success: { (response) in
                if let response = response as? [String : Any], let code = response["code"] as? Int, let msg = response["msg"] as? String {
                    if code == 0 {
                        self.scrollView.makeToast(msg)
                        self.btnNickNameCheck.isSelected = true
                    }
                    else {
                        self.btnNickNameCheck.isSelected = false
                        self.scrollView.makeToast(msg)
                    }
                }
                else {
                    self.showErrorAlertView(response)
                }
            }, failure: { (error) in
                self.showErrorAlertView(error)
            })
        }
        else if sender == btnOk {
            self.view.endEditing(true)
            var param: Dictionary<String, Any> = [:]
            
            if isSocial {
                guard let nickName = tfNickName.text, nickName.isEmpty == false else {
                    self.scrollView.makeToast("닉네임을 입력해주세요.")
                    return
                }
                if nickName.length < 2 {
                    self.scrollView.makeToast("닉네임 2자리이상 입력해주세요.")
                    return
                }
                else if btnNickNameCheck.isSelected == false {
                    self.scrollView.makeToast("닉네임을 체크해주세요")
                    return
                }
                
                guard let user = user else {
                    return
                }
                
                if let email = user.email, email.isEmpty == false {
                    param["email"] = email
                }
                param["id"] = user.userId
                param["join_type"] = user.joinType
                param["name"] = user.name
                param["nickname"] = tfNickName.text!
                param["sex"] = user.gender
                param["password"] = user.userId
                param["birthday"] = user.birthday
                param["privacy_agree"] = user.privacyAgree
                param["termsservice_agree"] = user.termsserviceAgree
                param["marketing_agree"] = user.marketingAgree
            }
            else {
                guard let email = tfEmail.text, email.isEmpty == false, email.validateEmail() == true else {
                    self.scrollView.makeToast("이메일 형식이 아닙니다.")
                    return
                }
                if btnEmailCheck.isSelected == false {
                    self.scrollView.makeToast("아이디 중복체크를 해주세요.")
                    return
                }
                
                guard let nickName = tfNickName.text, nickName.isEmpty == false else {
                    self.scrollView.makeToast("닉네임을 입력해주세요.")
                    return
                }
                if nickName.length < 2 {
                    self.scrollView.makeToast("닉네임 2자리이상 입력해주세요.")
                    return
                }
                else if btnNickNameCheck.isSelected == false {
                    self.scrollView.makeToast("닉네임을 체크해주세요")
                    return
                }
                
                if pw.isEmpty == true ||  pw.validatePassword() == false {
                    self.scrollView.makeToast("비밀번호(숫자,영문,특수문자 8자이상)를 입력해주세요.")
                    return
                }
                
                if pwComfirm.isEmpty == true || pwComfirm.validatePassword() == false {
                    self.scrollView.makeToast("비밀번호(숫자,영문,특수문자 8자이상)를 입력해주세요.")
                    return
                }
                
                if pw != pwComfirm {
                    self.scrollView.makeToast("비밀번호가 일치하지 않습니다.")
                    return
                }
                
                guard let user = user else {
                    return
                }
                
                guard let jonin_type = user.joinType,
                      let name = user.name,
                      let nickname = tfNickName.text,
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
                param["password"] = pw
                param["birthday"] = birthday
                param["privacy_agree"] = user.privacyAgree
                param["termsservice_agree"] = user.termsserviceAgree
                param["marketing_agree"] = user.marketingAgree
            }
           
            self.view.endEditing(true)
            
            ApiManager.shared.requestUserSignUp(param: param) { (response) in
                
                if let response = response as? [String:Any],
                   let success = response["success"] as? Bool,
                   let data = response["data"] as? [String: Any], success == true {
                    
                    print("회원가입 성공: \(String(describing: response))")
                    
                    self.view.makeToast("회원가입 성공")
                    if let token = data["token"] as? String {
                        //로그인 유지 userdefault 쓴다.
                        SharedData.setObjectForKey(key: kPToken, value: token)
                        SharedData.instance.pToken = token
                    }
                    if let idx = data["idx"] as? Int {
                        SharedData.setObjectForKey(key: kUserIdx, value: idx)
                        SharedData.instance.userIdx = idx
                    }
                    if let password = param["password"] {
                        SharedData.setObjectForKey(key: kUserPassword, value: password)
                    }
                    SharedData.setObjectForKey(key: kUserNickName, value: param["nickname"])
                    if let join_type = data["join_type"] as? String,
                       let user_id = data["user_id"] as? String {
                        
                        let realUserId = user_id.deletingPrefix("\(join_type)_")
                        if join_type == "kakao" {
                            
                        }
                        else if join_type == "naver" {
                            
                        }
                        else if join_type == "facebook" {
                            
                        }
                        else if join_type == "apple" {
                            
                        }
                        
                        SharedData.setObjectForKey(key: kLoginType, value: join_type)
                        SharedData.setObjectForKey(key: kUserId, value: realUserId)
                    }
                    
                    AppDelegate.instance()?.callMainVc()
                }
                else {
                    self.showErrorAlertView(response)
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
}

extension MrUserInfoViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == tfPassword || textField == tfPasswordConfirm {
            if string.isEmpty == false {
                if string.checkEnglish() || string.checkNum() || string.checkSpecialPw() {
                    var txt = textField.text
                    txt?.append("●")
                    textField.text = txt
                    if textField == tfPassword {
                        pw.append(string)
                        print(pw)
                    }
                    else {
                        pwComfirm.append(string)
                        print(pwComfirm)
                    }
                }
                return false
            }
            else {
                if textField == tfPassword {
                    pw = String(pw.dropLast())
                    print(pw)
                }
                else {
                    pwComfirm = String(pwComfirm.dropLast())
                    print(pwComfirm)
                }
                return true
            }
        }
        else if textField == tfEmail {
            btnEmailCheck.isSelected = false
        }
        else if textField == tfNickName {
            btnNickNameCheck.isSelected = false
        }
        return true
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
        else {
            textField.resignFirstResponder()
        }
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == tfPassword {
            pw = ""
        }
        else if textField == tfPasswordConfirm {
            pwComfirm = ""
        }
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == tfEmail {
            seperatorEmail.backgroundColor = ColorDefault
        }
        else if textField == tfNickName {
            seperatorNickName.backgroundColor = ColorDefault
        }
        else if let textField = textField as? CTextField {
            textField.borderColor = ColorDefault
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tfEmail {
            seperatorEmail.backgroundColor = ColorBorder
        }
        else if textField == tfNickName {
            seperatorNickName.backgroundColor = ColorBorder
        }
        else if let textField = textField as? CTextField {
            textField.borderColor = ColorBorder
        }
    }
}
