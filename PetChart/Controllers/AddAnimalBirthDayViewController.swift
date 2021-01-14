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
    @IBOutlet weak var seperator1: UIView!
    @IBOutlet weak var seperator2: UIView!
    var animal: Animal?
    var images:Array<UIImage>?
    var arrMonthBirthday:[[String:Any]]?
    var selMonthBirthday:[String:Any]?
    
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
//            seperator1.backgroundColor = ColorDefault
//            seperator2.backgroundColor = ColorBorder
            let maxDate = Date()
            let minDate = Date().getStartDate(withYear: -30)
            let apoint = Date()
            
            let picker = CDatePickerView.init(type: .yearMonthDay, minDate: minDate, maxDate: maxDate, apointDate: apoint) { (strDate, date) in
                
                if let strDate = strDate {
                    self.tfBirthDay1.text = strDate
                    self.selMonthBirthday = nil
                    self.tfBirthDay2.text = nil
                }
            }
            picker?.local = Locale(identifier: "ko_KR")
            picker?.show()
        }
        else if sender == btnBirthDay2 {
            btnCheck1.isSelected = false
            btnCheck2.isSelected = true
//            seperator1.backgroundColor = ColorBorder
//            seperator2.backgroundColor = ColorDefault
            if let _ = arrMonthBirthday {
                self.showBirthdayMonthPopup()
            }
            else {
                ApiManager.shared.requestAnimalBirthdayMonthList { (response) in
                    if let response = response as? [String:Any], let data = response["data"] as? [String:Any], let items = data["itmes"] as? Array<[String:Any]> {
                        self.arrMonthBirthday = items
                        self.showBirthdayMonthPopup()
                    }
                } failure: { (error) in
                    self.showErrorAlertView(error)
                }
            }
        }
        else if sender == btnOk {
            
            if self.selMonthBirthday == nil && tfBirthDay1.text?.isEmpty == true {
                self.showToast("생년월일을 선택해주세요.")
                return
            }
            
            if let birthday = tfBirthDay1.text, birthday.isEmpty == false {
                animal?.birthday = birthday
                
                let df = CDateFormatter.init()
                df.dateFormat = "yyyy-MM-dd"
                if let date = df.date(from: birthday) {
                    let componet = self.getAgeInfo(birthDay: date)
                    if let age = componet.year {
                        animal?.age = age
                    }
                }
            }
            else if let birthMonth = selMonthBirthday?["id"] as? Int {
                animal?.birthMonth = birthMonth
                animal?.age = Int(birthMonth/12)
            }
          
            let vc = AddAnimalInfoViewController.init()
            vc.animal = animal
            vc.images = images
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    func showBirthdayMonthPopup() {
        guard let arrMonthBirthday = arrMonthBirthday else {
            return
        }
        let vc = PopupListViewController.init(type: .normal, title: nil, data: arrMonthBirthday, keys: ["label"]) { (vcs, selData, index) in
            vcs.dismiss(animated: false, completion: nil)
            guard let selData = selData as? [String:Any] else {
                return
            }
            
            self.tfBirthDay1.text = nil
            self.selMonthBirthday = selData
            if let label = selData["label"] as? String {
                self.tfBirthDay2.text = label
            }
        }
        self.present(vc, animated: true, completion: nil)
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
