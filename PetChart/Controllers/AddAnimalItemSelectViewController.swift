//
//  AddAnimalItemSelectViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/01.
//

import UIKit

@IBDesignable class AddAnimalItemSelectViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnItemKnow: UIButton!
    @IBOutlet weak var btnItemUnknow: UIButton!
    @IBInspectable @IBOutlet weak var btnSearch: CButton!
    @IBInspectable @IBOutlet weak var tfItem: CTextField!
    
    @IBOutlet weak var btnSmall: SelectedButton!
    @IBOutlet weak var btnMiddle: SelectedButton!
    @IBOutlet weak var btnLarge: SelectedButton!
    
    
    @IBOutlet weak var bgMsg: UIView!
    @IBOutlet weak var lbMsg: UILabel!
    @IBOutlet weak var svKnow: UIStackView!
    @IBOutlet weak var svUnknow: UIStackView!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    
    var animal: Animal?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "반려동물 등록", nil)
        
        btnSafety.isHidden = true
        if Utility.isIphoneX() {
            btnSafety.isHidden = false
        }
        
        bgMsg.layer.cornerRadius = 4.0
        bgMsg.clipsToBounds = true
        
        if let name = animal?.name {
            let result: String = String(format: "%@의 품종을 알려주세요.", name)
            let attr = NSMutableAttributedString.init(string: result, attributes: [.foregroundColor : RGB(136, 136, 136)])
            let nsRange = NSString(string: result).range(of: name, options: String.CompareOptions.caseInsensitive)
            attr.addAttribute(.foregroundColor, value: RGB(23, 133, 239), range: nsRange)
            attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 13, weight: .bold), range: nsRange)
            lbTitle.attributedText = attr
            
            let result2: String = String(format: "%@가 성장기인가요?\n아직 성장기라면 다 자란 후의 예상 크기를 기준으로 해주세요.", name)
            let attr2 = NSMutableAttributedString.init(string: result2, attributes: [.foregroundColor : RGB(136, 136, 136)])
            let nsRange2 = NSString(string: result2).range(of: name, options: String.CompareOptions.caseInsensitive)
            attr2.addAttribute(.foregroundColor, value: RGB(23, 133, 239), range: nsRange2)
            attr2.addAttribute(.font, value: UIFont.systemFont(ofSize: 13, weight: .bold), range: nsRange2)
            lbMsg.attributedText = attr2
        }
        
        btnItemKnow.sendActions(for: .touchUpInside)
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
    
    @IBAction func onClickedButtonActions(_ sender: CButton) {
        self.view.endEditing(true)
        
        if sender == btnItemKnow {
            btnItemUnknow.isSelected = false
            sender.isSelected = true
            
            svKnow.isHidden = false
            svUnknow.isHidden = true
            
            tfItem.text = ""
        }
        else if sender == btnItemUnknow {
            btnItemKnow.isSelected = false
            sender.isSelected = true
            
            svKnow.isHidden = true
            svUnknow.isHidden = false
            
            btnSmall.isSelected = false
            btnMiddle.isSelected = false
            btnLarge.isSelected = false
        }
        else if sender == btnSearch {
            
        }
        else if sender == btnSmall {
            btnSmall.isSelected = true
            btnMiddle.isSelected = false
            btnLarge.isSelected = false
        }
        else if sender == btnMiddle {
            btnSmall.isSelected = false
            btnMiddle.isSelected = true
            btnLarge.isSelected = false
        }
        else if sender == btnLarge {
            btnSmall.isSelected = false
            btnMiddle.isSelected = false
            btnLarge.isSelected = true
        }
        else if sender == btnOk {
            if btnItemKnow.isSelected {
                animal?.item = tfItem.text
            }
            else if btnItemUnknow.isSelected {
                if btnSmall.isSelected {
                    animal?.item = "소형"
                }
                else if btnMiddle.isSelected {
                    animal?.item = "중형"
                }
                else if btnLarge.isSelected {
                    animal?.item = "대형"
                }
            }
            
            if (animal?.item) == nil {
                self.view.makeToast("품종을 알려주세요", position:.top)
                return
            }
            
            let vc = AddAnimalBirthDayViewController.init(nibName: "AddAnimalBirthDayViewController", bundle: nil)
            vc.animal = animal
            self.navigationController?.pushViewController(vc, animated: false)
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


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
    
}
