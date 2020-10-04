//
//  AnimalModifyInfoViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/01.
//

import UIKit

class AnimalModifyInfoViewController: BaseViewController {

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
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    @IBOutlet var accessoryView: UIToolbar!
    
    var profileImg: UIImage?
    var selDate: Date? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "반려동물 정보수정", nil)

        
        if Utility.isIphoneX() == false {
            btnSafety.isHidden = true
        }
        
        tfName.inputAccessoryView = accessoryView
        tfRegiNumber.inputAccessoryView = accessoryView
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
    @IBAction func onClickedButtonActions(_ sender: Any) {
        
        self.view.endEditing(true)
        if (sender as? NSObject) == btnCalendar {
            
            let picker = CDatePickerView.init(type: .yearMonthDay, minDate: Date().getStartDate(withYear: -30), maxDate: Date(), apointDate: Date()) { (strDate, date) in
                
                if let date = date {
                    self.tfBirthDay.text = strDate
                    self.selDate = date
                }
            }
            picker?.local = Locale(identifier: "ko_KR")
            picker?.show()
        }
        else if (sender as? NSObject) == btnArrowItem {
            
        }
        else if (sender as? NSObject) == btnPrevent {
            
        }
        else if let sender = (sender as? NSObject) as? SelectedButton {
            if sender == btnMale {
                btnMale.isSelected = true
                btnFemale.isSelected = false
                print("mail")
            }
            else if sender == btnFemale {
                btnMale.isSelected = false
                btnFemale.isSelected = true
                print("femail")
            }
            else if sender == btnDog {
                btnDog.isSelected = true
                btnCat.isSelected = false
                btnOther.isSelected = false
                print("dog")
            }
            else if sender == btnCat {
                btnDog.isSelected = false
                btnCat.isSelected = true
                btnOther.isSelected = false
                print("cat")
            }
            else if sender == btnOther {
                btnDog.isSelected = false
                btnCat.isSelected = false
                btnOther.isSelected = true
                print("other")
            }
            else if sender == btnPreNeutral {
                btnPreNeutral.isSelected = true
                btnAfeterNeutral.isSelected = false
                print("pre neutral")
            }
            else if sender == btnAfeterNeutral {
                btnPreNeutral.isSelected = false
                btnAfeterNeutral.isSelected = true
                print("after neutral")
            }
            else if sender == btnEmptyRegiNumber {
                sender.isSelected = true
                print("empty regist number")
            }
        }
        else if (sender as? NSObject) == btnProfile {
            let alert = UIAlertController.init(title: nil, message: nil, preferredStyle:.actionSheet)
            alert.addAction(UIAlertAction.init(title: "카메라", style: .default, handler: { (action) in
                self.showCamera(UIImagePickerController.SourceType.camera)
                alert.dismiss(animated: false, completion: nil)
            }))
            alert.addAction(UIAlertAction.init(title: "캘러리", style: .default, handler: { (action) in
                self.showCamera(UIImagePickerController.SourceType.photoLibrary)
                alert.dismiss(animated: false, completion: nil)
            }))
            alert.addAction(UIAlertAction.init(title: "취소", style: .cancel, handler: { (action) in
                alert.dismiss(animated: false, completion: nil)
            }))
            present(alert, animated: false, completion: nil)

        }
        else if (sender as? NSObject) == btnOk {
            print("btn ok")
        }
    }

    func showCamera(_ sourceType: UIImagePickerController.SourceType) {
        let vc = CameraViewController.init()
        vc.delegate = self
        vc.sourceType = sourceType
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @objc func notificationHandler(_ notification: Notification) {
            
        let heightKeyboard = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
        let duration = CGFloat((notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.0)
 
        if notification.name == UIResponder.keyboardWillShowNotification {
            
            bottomContainer.constant = heightKeyboard - (AppDelegate.instance()?.window?.safeAreaInsets.bottom)! - btnOk.bounds.height
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
extension AnimalModifyInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
}

extension AnimalModifyInfoViewController: CameraViewControllerDelegate {
    func didFinishImagePicker(origin: UIImage?, crop: UIImage?) {
        self.profileImg = crop
        self.btnProfile.setImage(self.profileImg, for: .normal)
        self.btnProfile.borderColor = RGB(217, 217, 217)
        self.btnProfile.borderWidth = 2.0
        self.btnProfile.setNeedsDisplay()
    }
}
