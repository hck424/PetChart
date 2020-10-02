//
//  AnimalModifyInfoViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/01.
//

import UIKit

class AnimalModifyInfoViewController: BaseViewController, UITextFieldDelegate {

    @IBOutlet weak var btnProfile: CButton!
    @IBOutlet weak var tfName: CTextField!
    @IBOutlet weak var tfBirthDay: CTextField!
    @IBOutlet weak var btnCalendar: UIButton!
    @IBOutlet weak var btnMale: SelectedButton!
    @IBOutlet weak var btnFemale: SelectedButton!
    
    @IBOutlet weak var btnDog: SelectedButton!
    @IBOutlet weak var btnCat: SelectedButton!
    @IBOutlet weak var btnOther: SelectedButton!
    @IBOutlet weak var tfItem: CTextField!
    @IBOutlet weak var btnArrowItem: UIButton!
    @IBOutlet weak var tfPrevent: CTextField!
    @IBOutlet weak var btnPrevent: UIButton!
    
    @IBOutlet weak var btnPreNeutral: SelectedButton!
    @IBOutlet weak var btnAfeterNeutral: SelectedButton!
    @IBOutlet weak var tfRegiNumber: CTextField!
    @IBOutlet weak var btnEmptyRegiNumber: SelectedButton!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "반려동물 정보수정", nil)

        btnSafety.isHidden = true
        if Utility.isIphoneX() {
            btnSafety.isHidden = false
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

    //FIXME:: button actions
    @IBAction func onClickedButtonActions(_ sender: UIButton) {
        
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }

}
