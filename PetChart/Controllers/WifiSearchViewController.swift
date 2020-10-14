//
//  WifiSearchViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/14.
//

import UIKit

class WifiSearchViewController: BaseViewController {

    @IBOutlet weak var tfWifiName: CTextField!
    @IBOutlet weak var btnWifiName: UIButton!
    @IBOutlet weak var btnWifiPassword: CTextField!
    @IBOutlet weak var btnOk: CTextField!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var cornerBgview: UIView!
    @IBOutlet weak var lbHintPassword: UILabel!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        cornerBgview.layer.cornerRadius = 20
        cornerBgview.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        
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
    
    @objc func tapGestureHandler(_ gesture: UITapGestureRecognizer) {
        if gesture.view == self.view {
            self.view.endEditing(true)
        }
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnWifiName {
            
        }
        else if sender == btnOk {
            
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
