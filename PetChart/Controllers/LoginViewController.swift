//
//  LoginViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/27.
//

import UIKit
@IBDesignable
class LoginViewController: BaseViewController {
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var bgCorner: UIView!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var btnLogin: CButton!
    @IBOutlet weak var tfEmail: CTextField!
    @IBOutlet weak var tfPassword: CTextField!
    @IBOutlet weak var btnFindPassword: UIButton!
    @IBOutlet weak var btnJoinEmail: UIButton!
    @IBOutlet weak var btnKakao: CButton!
    @IBOutlet weak var btnFacebook: CButton!
    @IBOutlet weak var btnNaver: CButton!
    @IBOutlet weak var btnApple: CButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var bottomScrollView: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bgCorner.layer.cornerRadius = 20
        bgCorner.layer.maskedCorners = [CACornerMask.layerMinXMinYCorner, CACornerMask.layerMaxXMinYCorner]
        
        let str1: String = "안녕하세요.\n스마트한 우리아이 건강관리의 시작\n "
        let img = UIImage(named: "group_18")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        let attchment = NSTextAttachment.init(image: img!)
        
        attchment.bounds = CGRect.init(x: 0, y: -1, width: img!.size.width, height: img!.size.height)
        let attr = NSMutableAttributedString.init(attachment: attchment)
        attr.addAttribute(NSAttributedString.Key.foregroundColor, value: ColorDefault, range:NSRange(location: 0, length: attr.length))
        
        let resultAttr = NSMutableAttributedString.init(string: str1)
        resultAttr.append(attr)
        resultAttr.append(NSAttributedString.init(string: " 입니다"))
        
        lbTitle.attributedText = resultAttr
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func tapGestureHanlder(_ sender: UITapGestureRecognizer) {
        if sender.view == self.view {
            self.view.endEditing(true)
        }
    }
    @IBAction func onClickedButtonActions(_ sender: UIButton) {
        self.view.endEditing(true)
        if sender == btnClose {
            self.navigationController?.popViewController(animated: false)
        }
        else if sender == btnLogin {
            
        }
        else if sender == btnCheck {
            
        }
        else if sender == btnKakao {
            
        }
        else if sender == btnNaver {
            
        }
        else if sender == btnFacebook {
            
        }
        else if sender == btnApple {
            
        }
        else if sender == btnFindPassword {
            
        }
        else if sender == btnJoinEmail {
            
        }
    }
    @objc func notificationHandler(_ notification: Notification) {
            
        let heightKeyboard = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
        let duration = CGFloat((notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.0)
 
        if notification.name == UIResponder.keyboardWillShowNotification {
            
            bottomScrollView.constant = heightKeyboard
            UIView.animate(withDuration: TimeInterval(duration), animations: { [self] in
                self.view.layoutIfNeeded()
            })
            
        }
        else if notification.name == UIResponder.keyboardWillHideNotification {
            bottomScrollView.constant = 0
            UIView.animate(withDuration: TimeInterval(duration)) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
