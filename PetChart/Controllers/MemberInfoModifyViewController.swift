//
//  MemberInfoModifyViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/02.
//

import UIKit
import SwiftyJSON
import PhoneNumberKit

class MemberInfoModifyViewController: BaseViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tfName: CTextField!
    @IBOutlet weak var tfNicName: CTextField!
    @IBOutlet weak var tfEmail: CTextField!
    @IBOutlet weak var tfPhoneNumber: CTextField!
    @IBOutlet var arrBtnPrivacy: [SelectedButton]!
    @IBOutlet weak var tfAddress: UITextField!
    @IBOutlet weak var btnAddressSearch: CButton!
    @IBOutlet weak var btnAddress: UIButton!
    @IBOutlet weak var tfAddressDetail: CTextField!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    @IBOutlet var accessoryView: UIToolbar!
    @IBOutlet weak var btnKeyboardDown: UIBarButtonItem!
    let phoneNumberKit = PhoneNumberKit()
    @IBOutlet weak var seperatorNickName: UIView!
    @IBOutlet weak var btnNickName: CButton!
    var user: UserInfo? = nil
    var privacy_term = 0
    
    
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
        btnNickName.setBackgroundImage(UIImage.image(from: RGB(229, 229, 229)), for: .normal)
        btnNickName.setBackgroundImage(UIImage.image(from: ColorDefault), for: .selected)
        btnNickName.setTitleColor(RGB(166, 166, 166), for: .normal)
        btnNickName.setTitleColor(UIColor.white, for: .selected)
        
        self.requestMyInfo()
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

    
    func requestMyInfo() {
        ApiManager.shared.requestGetUserInfo { (response) in
            if let response = response as? [String : Any],
               let success = response["success"] as? Bool,
               let data = response["data"] as? [String : Any],
               let user = data["user"] as? [String : Any] {
                
                if  success {
                    self.user = UserInfo.init(JSON: user)
                    self.decorationUi()
                }
                else {
                    self.showErrorAlertView(response)
                }
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
        }

    }
    
    func decorationUi() {
        tfName.text = user?.name
        tfNicName.text = user?.nickname
        tfEmail.text = user?.email
        tfPhoneNumber.text = user?.phone
        
        if let addressLine1 = user?.addressLine1, addressLine1.isEmpty == false {
            tfAddress.text = addressLine1
        }
        tfAddressDetail.text = user?.addressLine2
        btnNickName.isSelected = true
        guard let privacy_term = user?.privacy_term else {
            return
        }
        for btn in arrBtnPrivacy {
            if privacy_term == -1 {
                arrBtnPrivacy.last?.isSelected = true
                break
            }
            else {
                let term = Int(privacy_term/365)
                if term == btn.tag {
                    btn.isSelected = true
                    break
                }
            }
        }
    }
    
    @IBAction func tapGestureHandler(_ sender: UITapGestureRecognizer) {
        if sender.view == self.view {
            self.view.endEditing(true)
        }
    }
    
    @IBAction func textFiledViewEdtingChanged(_ sender: UITextField) {
        guard let text = sender.text, text.isEmpty == false else {
            return
        }
        do {
            let phoneNumber = try phoneNumberKit.parse(text, ignoreType: true)
            let newNum = self.phoneNumberKit.format(phoneNumber, toType: .national)
            self.tfPhoneNumber.text = newNum
        } catch {
            self.tfPhoneNumber.text = text
        }
    }
    @IBAction func onClickedKeybaordDown(_ sender: Any) {
        self.view.endEditing(true)
    }
    @IBAction func textFieldEdtingChanged(_ textField: UITextField) {
        if textField == tfNicName {
            guard let text = textField.text, text.isEmpty == false else {
                return
            }
            if text == user?.nickname! {
                btnNickName.isSelected = true
            }
            else {
                btnNickName.isSelected = false
            }
        }
    }
    
    @IBAction func onClickedButtonActions(_ sender: UIButton) {
        
        if sender == btnAddressSearch || sender == btnAddress {
            self.view.endEditing(true)
            let vc = WkWebViewController.init()
            vc.vcTitle = "주소 검색"
            vc.strUrl = "https://crm.zayuroun.com/address.html"
            vc.type = .normal
            self.navigationController?.pushViewController(vc, animated: true)
            vc.didFinishSelectedAddressClourse = ({(_ selData:[String:Any]?) -> () in
                if let selData = selData {
                    print(String(describing: selData))
                    
                    let data = JSON(selData)
                    if data["userSelectedType"] == "R" {
                        self.tfAddress.text = data["roadAddress"].stringValue
                    }
                    else {
                        self.tfAddress.text = data["jibunAddress"].stringValue
                    }
                }
            })
                
        }
        else if let sender = sender  as? SelectedButton {
            print("privarsy")
            for btn in arrBtnPrivacy {
                btn.isSelected = false
            }
            sender.isSelected = true
            if sender.tag == 0 {
                privacy_term = -1
            }
            else {
                privacy_term = sender.tag * 365
            }
        }
        else if sender == btnNickName {
            guard let nickName = tfNicName.text, nickName.isEmpty == false else {
                self.scrollView.makeToast("닉네임을 입력해주세요.")
                return
            }
            if nickName.length < 2 {
                self.scrollView.makeToast("닉네임 2자리이상 입력해주세요.")
                return
            }
            
            ApiManager.shared.requestFindUserNicNameCheck(nickName: nickName, success: { (response) in
                if let response = response as? [String : Any],
                   let code = response["code"] as? Int,
                   let msg = response["msg"] as? String {
                    if code == 0 {
                        self.btnNickName.isSelected = true
                        self.scrollView.makeToast(msg)
                        return
                    }
                    else if code == 1 {
                        self.btnNickName.isSelected = false
                        self.scrollView.makeToast(msg)
                        return
                    }
                }
            }, failure: { (error) in
                self.showErrorAlertView(error)
            })
        }
        else if sender == btnOk {
            self.view.endEditing(true)
            guard let name = tfName.text, name.isEmpty == false else {
                self.showToast("이름을 입력해주세요.")
                return
            }
            guard let nickName = tfNicName.text, nickName.isEmpty == false else {
                self.scrollView.makeToast("닉네임을 입력해주세요.")
                return
            }
            if nickName.length < 2 {
                self.scrollView.makeToast("닉네임 2자리이상 입력해주세요.")
                return
            }
            else if btnNickName.isSelected == false {
                self.scrollView.makeToast("닉네임을 체크해주세요")
                return
            }
            guard let phone = tfPhoneNumber.text, phone.isEmpty == false else {
                self.showToast("휴대폰 번호를 입력해주세요.")
                return
            }
            guard let address = tfAddress.text, address.isEmpty == false else {
                self.showToast("주소를 입력해주세요.")
                return
            }
            guard let address2 = tfAddressDetail.text, address2.isEmpty == false else {
                self.showToast("상세주소를 입력해주세요.")
                return
            }
            
            if let email = tfEmail.text, email.isEmpty == false {
                user?.email = email
            }
            
            user?.name = name
            user?.nickname = nickName
            user?.phone = phone
            user?.addressLine1 = address
            user?.addressLine2 = address2
            
            
            var isTermSelected = false
            for btn in arrBtnPrivacy {
                if (btn.isSelected) {
                    isTermSelected = true
                    break
                }
            }

            if isTermSelected == false {
                self.showToast("개인정보 유효기간을 설정해주세요.")
                return
            }
            
            let dic:[String:Any]? = user?.toJSON() ?? nil
            guard var param = dic else {
                return
            }
            param["privacy_term"] = privacy_term
            
//            AlertView.showWithCancelAndOk(title: "회원정보 변경", message: "회원정보 변경이 하시겠습니까?.") { (index) in
//                if (index == 1) {
                    ApiManager.shared.requestModifyUserInfo(param: param) { (response) in
                        if let response = response as? [String:Any], let success = response["success"] as? Bool, success == true {
                            SharedData.setObjectForKey(key: kUserNickName, value: nickName)
                            self.showToast("회원정보가 변경되었습니다.")
                            self.navigationController?.popViewController(animated: true)
                        }
                        else {
                            self.showErrorAlertView(response)
                        }
                    } failure: { (error) in
                        self.showErrorAlertView(error)
                    }
//                }
//            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let textView = textView as? CTextView {
            textView.placeholderLabel?.isHidden = !textView.text.isEmpty
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
        else {
            self.view.endEditing(true)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == tfNicName {
            seperatorNickName.backgroundColor = ColorDefault
        }
        else {
            if let textField = textField as? CTextField {
                textField.borderColor = ColorDefault
            }
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tfNicName {
            seperatorNickName.backgroundColor = ColorBorder
        }
        else {
            if let textField = textField as? CTextField {
                textField.borderColor = ColorBorder
            }
        }
    }
}
