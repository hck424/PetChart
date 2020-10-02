//
//  AddAnimalNameViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/01.
//

import UIKit

class AddAnimalNameViewController: BaseViewController {

    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var tfPetName: CTextField!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var cornerBgView: UIView!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    
    var animal: Animal? = nil
    var profileImg: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "반려동물 등록", nil)
        
        btnSafety.isHidden = true
        if Utility.isIphoneX() {
            btnSafety.isHidden = false
        }
        cornerBgView.layer.cornerRadius = 20
        cornerBgView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        
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
    
    @IBAction func onClickedButtonActions(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if sender == btnAdd {
            let alert = UIAlertController.init(title: nil, message: nil, preferredStyle:.actionSheet)
            alert.addAction(UIAlertAction.init(title: "카메라", style: .default, handler: { (action) in
                alert.dismiss(animated: false, completion: nil)
            }))
            alert.addAction(UIAlertAction.init(title: "캘러리", style: .default, handler: { (action) in
                alert.dismiss(animated: false, completion: nil)
            }))
            alert.addAction(UIAlertAction.init(title: "취소", style: .cancel, handler: { (action) in
                alert.dismiss(animated: false, completion: nil)
            }))
            present(alert, animated: false, completion: nil)
        }
        else if sender == btnOk {
            if tfPetName.text?.count == 0 {
                self.view.makeToast("반려동물 이름을 알려주세요.", position:.top)
                return
            }
            self.animal = Animal()
            animal?.name = tfPetName.text
            animal?.profileImage = profileImg
            
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
