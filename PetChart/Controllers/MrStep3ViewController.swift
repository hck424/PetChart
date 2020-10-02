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
    @IBInspectable @IBOutlet weak var tfPassword: CTextField!
    @IBInspectable @IBOutlet weak var tfPasswordConfirm: CTextField!
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
            sender.isSelected = true
        }
        else if sender == btnNickNameCheck {
            sender.isSelected = true
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
