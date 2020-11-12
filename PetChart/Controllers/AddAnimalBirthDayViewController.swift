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
    @IBOutlet weak var btnBirthDay1: UIButton!
    @IBOutlet weak var btnBirthDay2: UIButton!
    @IBOutlet weak var tfBirthDay1: UITextField!
    @IBOutlet weak var tfBirthDay2: UITextField!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    
    var animal: Animal?
    var images:Array<UIImage>?
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "반려동물 등록", nil)
        btnSafety.isHidden = true
        if Utility.isIphoneX() {
            btnSafety.isHidden = false
        }
        tfBirthDay2.delegate = self
        if let name = animal?.petName {
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
        else if sender == btnBirthDay1 {
            btnCheck1.isSelected = true
            btnCheck2.isSelected = false
            let maxDate = Date()
            let minDate = Date().getStartDate(withYear: -30)
            let apoint = Date()
            
            let picker = CDatePickerView.init(type: .yearMonthDay, minDate: minDate, maxDate: maxDate, apointDate: apoint) { (strDate, date) in
                
                if let date = date, let strDate = strDate {
                    self.tfBirthDay2.text = ""
                    self.tfBirthDay1.text = strDate
                    let ageComponet = self.getAgeInfo(birthDay: date)
                    self.animal?.age = ageComponet.year ?? 0
                    self.animal?.birthday = strDate
                }
            }
            picker?.local = Locale(identifier: "ko_KR")
            picker?.show()
        }
        else if sender == btnBirthDay2 {
            btnCheck1.isSelected = false
            btnCheck2.isSelected = true
            let maxDate = Date()
            let minDate = Date().getStartDate(withYear: -30)
            let apoint = Date()
            
            let picker = CDatePickerView.init(type: .yearMonth, minDate: minDate, maxDate: maxDate, apointDate: apoint) { (strDate, date) in
                
                if let strDate = strDate {
                    self.tfBirthDay1.text = ""
                    let df = CDateFormatter.init()
                    df.dateFormat = "yyyy-MM-dd"
                    let birthday = df.date(from: "\(strDate)-01")
                    let ageComponet = self.getAgeInfo(birthDay: birthday!)
                    let year = ageComponet.year ?? 0
                    let month = ageComponet.month ?? 0
                    if  year > 0 {
                        let str = "\(year)세 \(month)개월"
                        self.tfBirthDay2.text = str
                    }
                    else {
                        let str = "\(month)개월"
                        self.tfBirthDay2.text = str
                    }
                    self.animal?.age = ageComponet.year ?? 0
                    self.animal?.birthday = "\(strDate)-01"
                }
            }
            picker?.local = Locale(identifier: "ko_KR")
            picker?.show()
        }
        else if sender == btnOk {
            
            if btnCheck1.isSelected {
                animal?.birthday = tfBirthDay1.text
            }
            else if btnCheck2.isSelected {
                animal?.birthday = tfBirthDay2.text
            }
            
            if (animal?.birthday) == nil || animal?.birthday?.length == 0 {
                self.view.makeToast("\(animal?.petName! ?? "")의 나이를 입력해주세요", position:.top)
                return
            }
            
            let vc = AddAnimalInfoViewController.init()
            vc.animal = animal
            vc.images = images
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    func getAgeInfo(birthDay:Date) -> DateComponents {
        let now = Date()
        var calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        calendar.locale = Locale.init(identifier: "en_US_POSIX")
        let componets = calendar.dateComponents([.year, .month,.day], from: birthDay, to: now)
        return componets
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
