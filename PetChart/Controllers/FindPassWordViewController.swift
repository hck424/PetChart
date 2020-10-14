//
//  FindPassWordViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/14.
//

import UIKit

class FindPassWordViewController: BaseViewController {

    @IBOutlet weak var tfUserId: CTextField!
    @IBOutlet weak var tfUserName: CTextField!
    @IBOutlet weak var tfPhoneNumber: CTextField!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var cornerBgView: UIView!
    @IBOutlet weak var lbHintUserId: UILabel!
    @IBOutlet weak var lbHintUserName: UILabel!
    @IBOutlet weak var lbHintPhoneNumber: UILabel!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    
    
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

    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        self.view.endEditing(true)
        if sender == btnOk {
            lbHintUserId.isHidden = true
            lbHintUserName.isHidden = true
            lbHintPhoneNumber.isHidden = true
            var isOk = true
            if tfUserId.text?.isEmpty == true {
                lbHintUserId.text = "회원가입시 이메일을 입력해주세요."
                lbHintUserId.isHidden = false
                isOk = false
            }
            else if tfUserId.text?.validateEmail() == false {
                lbHintUserId.text = "이메일 형식이 아닙니다."
                lbHintUserId.isHidden = false
                isOk = false
            }
            
            if tfUserName.text?.isEmpty == true {
                lbHintUserName.isHidden = false
                isOk = false
            }
            
            if tfPhoneNumber.text?.isEmpty == true {
                lbHintPhoneNumber.isHidden = false
                isOk = false
            }
            
            if isOk == false {
                return
            }
            var loginType = "none"
            if let type = SharedData.getLoginType() {
                loginType = type
            }
            
            let vc = NewPasswordViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
            
            return
            let param = ["id": tfUserId.text!, "join_type":loginType, "name":tfUserName.text!, "phone":tfPhoneNumber.text!];
            ApiManager.shared.requestFindUserPassword(param: param) { (response) in
                print(param)
                
            } failure: { (error) in
                self.showErrorAlertView(error)
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
}
