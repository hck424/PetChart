//
//  MemberInfoModifyViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/02.
//

import UIKit
import SwiftyJSON
import PhoneNumberKit

class MemberInfoModifyViewController: BaseViewController, UITextViewDelegate {
    @IBOutlet weak var tfName: CTextField!
    @IBOutlet weak var tfNicName: CTextField!
    @IBOutlet weak var tfEmail: CTextField!
    @IBOutlet weak var btnPhoneNumberChange: CButton!
    @IBOutlet weak var tfPhoneNumber: CTextField!
    @IBOutlet var arrBtnPrivacy: [SelectedButton]!
    @IBOutlet weak var tvAddress: CTextView!
    @IBOutlet weak var btnAddressSearch: CButton!
    @IBOutlet weak var tfAddressDetail: CTextField!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    @IBOutlet var accessoryView: UIToolbar!
    @IBOutlet weak var btnKeyboardDown: UIBarButtonItem!
    let phoneNumberKit = PhoneNumberKit()
    
    var user: UserInfo? = nil
    var privacy_term = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "로그인 정보수정", nil)
        
        if Utility.isIphoneX() == false {
            btnSafety.isHidden = true
        }
        tvAddress.delegate = self
        tfName.inputAccessoryView = accessoryView
        tfNicName.inputAccessoryView = accessoryView
        tfEmail.inputAccessoryView = accessoryView
        tfEmail.inputAccessoryView = accessoryView
        tfPhoneNumber.inputAccessoryView = accessoryView
        tfAddressDetail.inputAccessoryView = accessoryView
        
        self.requestMyInfo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
        if tvAddress.text.isEmpty == false {
            tvAddress.placeholderLabel?.isHidden = true
        }
        else {
            tvAddress.placeholderLabel?.isHidden = false
        }
        tvAddress.delegate = self
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
        tvAddress.text = user?.addressLine1
        self.textViewDidChange(tvAddress)
        tfAddressDetail.text = user?.addressLine2
        
        
        guard let privacy_term = user?.privacy_term else {
            return
        }
        for btn in arrBtnPrivacy {
            if privacy_term == 0 {
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
    @IBAction func onClickedButtonActions(_ sender: Any) {
        self.view.endEditing(true)
        
        if sender as? NSObject == btnPhoneNumberChange {
            print("ph number change")
        }
        else if sender as? NSObject == btnAddressSearch {
            let vc = WkWebViewController.init()
            vc.vcTitle = "주소 검색"
            vc.strUrl = "https://crm.zayuroun.com/address.html"
            vc.type = .normal
            self.navigationController?.pushViewController(vc, animated: true)
            vc.didFinishSelectedAddressClourse = ({(_ selData:[String:Any]?) -> () in
                if let selData = selData {
                    print(String(describing: selData))
                    
//                    ["roadAddress": 경기 하남시 아리수로 565, "bname1": , "postcode2": , "roadAddressEnglish": 565, Arisu-ro, Hanam-si, Gyeonggi-do, Korea, "jibunAddressEnglish": 949, Mangwol-dong, Hanam-si, Gyeonggi-do, Korea, "roadname": 아리수로, "userSelectedType": R, "autoRoadAddress": , "addressType": R, "query": 아리수로 565, "address": 경기 하남시 아리수로 565, "bname2": 망월동, "autoJibunAddressEnglish": , "buildingName": 미사강변도시13단지, "sido": 경기, "jibunAddress": 경기 하남시 망월동 949, "autoRoadAddressEnglish": , "bcode": 4145010900, "sigunguCode": 41450, "noSelected": N, "hname": , "postcode1": , "addressEnglish": 565, Arisu-ro, Hanam-si, Gyeonggi-do, Korea, "postcodeSeq": , "sigungu": 하남시, "autoJibunAddress": , "apartment": Y, "zonecode": 12910, "buildingCode": 4145010900101800003000001, "postcode": , "roadnameCode": 3000035, "bname": 망월동, "userLanguageType": K]
                    let data = JSON(selData)
                    if data["userSelectedType"] == "R" {
                        if data["userLanguageType"] == "K" {
                            self.tvAddress.text = data["roadAddress"].stringValue
                        }
                        else {
                            self.tvAddress.text = data["roadAddressEnglish"].stringValue
                        }
                    }
                    else {
                        if data["userLanguageType"] == "K" {
                            self.tvAddress.text = data["jibunAddress"].stringValue
                        }
                        else {
                            self.tvAddress.text = data["jibunAddressEnglish"].stringValue
                        }
                    }
                    self.textViewDidChange(self.tvAddress)
                }
            })
                
        }
        else if let sender = (sender as? NSObject) as? SelectedButton {
            print("privarsy")
            for btn in arrBtnPrivacy {
                btn.isSelected = false
            }
            sender.isSelected = true
            privacy_term = sender.tag * 365
        }
        else if sender as? NSObject == btnOk {
            
            user?.name = tfName.text
            user?.nickname = tfNicName.text
            user?.email = tfEmail.text
            user?.phone = tfPhoneNumber.text
            user?.addressLine1 = tvAddress.text
            user?.addressLine2 = tfAddressDetail.text
            
            var isTermSelected = false
            for btn in arrBtnPrivacy {
                if (btn.isSelected) {
                    isTermSelected = true
                    break
                }
            }
            
            if user?.name == nil {
                self.view.makeToast("이름은 필수 항목입니다.")
                return
            }
            if user?.nickname == nil {
                self.view.makeToast("닉네임 필수 항목입니다.")
                return
            }
            if user?.email == nil {
                self.view.makeToast("이메일은 필수 항목입니다.")
                return
            }

            if isTermSelected == false {
                self.view.makeToast("개인정보 유효기간을 설정해주세요.")
                return
            }
            
            let dic:[String:Any]? = user?.toJSON() ?? nil
            guard var param = dic else {
                return
            }
            param["privacy_term"] = privacy_term
            
            AlertView.showWithCancelAndOk(title: "회원정보 변경", message: "회원정보 변경이 하시겠습니까?.") { (index) in
                if (index == 1) {
                    ApiManager.shared.requestModifyUserInfo(param: param) { (response) in
                        if let response = response as? [String:Any], (response["success"] as! Bool) == true {
                            self.view.makeToast("회원정보 변경이 완료되었습니다.")
                            self.navigationController?.popViewController(animated: true)
                        }
                        else {
                            self.showErrorAlertView(response)
                        }
                    } failure: { (error) in
                        self.showErrorAlertView(error)
                    }
                }
            }
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
        else if textField == tfPhoneNumber {
            tvAddress.becomeFirstResponder()
        }
        else if textField == tvAddress {
            tfAddressDetail.becomeFirstResponder()
        }
        else {
            self.view.endEditing(true)
        }
        return true
    }
}
