//
//  MrStep1ViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/29.
//

import UIKit

@IBDesignable class MrStep1ViewController: BaseViewController, UITextFieldDelegate {

    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    @IBOutlet weak var bgCornerView: UIView!
    @IBInspectable @IBOutlet weak var tfName: CTextField!
    @IBOutlet weak var btnMale: UIButton!
    @IBOutlet weak var btnFemale: UIButton!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnSafety: UIButton!
    
    var user: UserInfo? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "회원가입", nil)
        
        if Utility.isIphoneX() == false {
            btnSafety.isHidden = true
        }
        bgCornerView.layer.cornerRadius = 20
        bgCornerView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
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
    
    @IBAction func onclickedButtonActions(_ sender: UIButton) {
        if sender == btnMale {
            btnFemale.isSelected = false
            sender.isSelected = true
        }
        else if sender == btnFemale {
            btnMale.isSelected = false
            sender.isSelected = true
        }
        else if sender == btnOk {
            
            if tfName.text?.count == 0 {
                
                self.view.makeToast("이름은 필수 항목입니다.", position:.top)
                return
            }
            
            if btnMale.isSelected == false && btnFemale.isSelected == false {
                self.view.makeToast("성별을 선택해 주세요.", position:.top)
                return
            }
            self.user = UserInfo(JSON: ["join_type": "none"])
            user?.name = tfName.text!
            if btnMale.isSelected {
                user?.gender = "M"
            }
            else {
                user?.gender = "F"
            }
            
            let vc = MrStep2ViewController.init(nibName: "MrStep2ViewController", bundle: nil)
            vc.user = self.user
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.count ?? 0 > 0 {
            self.view.endEditing(true)
        }
        return true
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
