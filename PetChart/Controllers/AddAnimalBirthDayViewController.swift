//
//  AddAnimalBirthDayViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/01.
//

import UIKit
@IBDesignable
class AddAnimalBirthDayViewController: BaseViewController {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var btnCheck1: UIButton!
    @IBOutlet weak var btnCheck2: UIButton!
    @IBOutlet weak var btnCanlendar: UIButton!
    @IBOutlet weak var tfBirthDay1: CTextField!
    @IBOutlet weak var tfBirthDay2: CTextField!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    
    var selStrDate:String? = nil
    var animal: Animal?
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "반려동물 등록", nil)
        btnSafety.isHidden = true
        if Utility.isIphoneX() {
            btnSafety.isHidden = false
        }
        tfBirthDay2.delegate = self
        if let name = animal?.name {
            let result: String = String(format: "%@의 나이를 알려주세요.", name)
            let attr = NSMutableAttributedString.init(string: result, attributes: [.foregroundColor : RGB(136, 136, 136)])
            let nsRange = NSString(string: result).range(of: name, options: String.CompareOptions.caseInsensitive)
            attr.addAttribute(.foregroundColor, value: RGB(23, 133, 239), range: nsRange)
            attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 13, weight: .bold), range: nsRange)
            lbTitle.attributedText = attr
        }
        
        btnCheck1.sendActions(for: .touchUpInside)
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
            view.endEditing(true)
        }
    }
    
    @IBAction func onClickedButtonActions(_ sender: UIButton) {
        self.view.endEditing(true)
        if sender == btnCheck1 {
            sender.isSelected = true
            btnCheck2.isSelected = false
            tfBirthDay2.text = ""
            animal?.birthday = nil
        }
        else if sender == btnCheck2 {
            sender.isSelected = true
            btnCheck1.isSelected = false
            tfBirthDay1.text = ""
            animal?.birthday = nil
        }
        else if sender == btnCanlendar {
            let maxDate = Date()
            let minDate = Date().getStartDate(withYear: -30)
            let apoint = Date()
            let picker = CDatePickerView.init(type: .yearMonthDay, minDate: minDate, maxDate: maxDate, apointDate: apoint) { (strDate, date) in
                
                let df = CDateFormatter()
                df.dateFormat = "yyyy-MM-dd"
                self.tfBirthDay1.text = df.string(from: date!)
                self.selStrDate = strDate
            }
            picker?.show()
        }
        else if sender == btnOk {
            
            if btnCheck1.isSelected {
                animal?.birthday = selStrDate
            }
            else if btnCheck2.isSelected {
                animal?.birthday = tfBirthDay2.text
            }
            
            if (animal?.birthday) == nil || animal?.birthday?.length == 0 {
                self.view.makeToast("\(animal?.name! ?? "")의 나이를 입력해주세요", position:.top)
                return
            }
            
            let vc = AddAnimalInfoViewController.init()
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
}
extension AddAnimalBirthDayViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.btnCheck1.isSelected = false
        self.btnCheck2.isSelected = true
        self.tfBirthDay1.text = ""
        return true
    }
}
