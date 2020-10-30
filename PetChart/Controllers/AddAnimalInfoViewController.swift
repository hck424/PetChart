//
//  AddAnimalInfoViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/01.
//

import UIKit

class AddAnimalInfoViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    
    @IBOutlet weak var lbGenderTitle: UILabel!
    @IBOutlet weak var lbNeutralTitle: UILabel!
    @IBOutlet weak var lbPreventTitle: UILabel!
    @IBOutlet weak var lbRegiTitle: UILabel!
    
    @IBOutlet var arrBtnGender: [SelectedButton]!
    @IBOutlet var arrBtnNeutral: [SelectedButton]!
    @IBOutlet var arrBtnPrevent: [SelectedButton]!
    
    @IBOutlet weak var tfRegiNumber: CTextField!
    @IBOutlet weak var btnRegiUnKnow: SelectedButton!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnQuestion: UIButton!
    
    
    var selGender: String?
    var selNeutral: String?
    var selPrevent: String?
    var regiNumber: String?
    
    var animal: Animal?
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "반려동물 등록", nil)

        if let name = animal?.name {
            var result = String(format: "%@의 성별은 무엇인가요?", name)
            self.decorationTitle(label: lbGenderTitle, result: result, name: name)
            
            result = String(format: "%@의 중성화 여부를 알려주세요.", name)
            self.decorationTitle(label: lbNeutralTitle, result: result, name: name)
            
            result = String(format: "%@의 예방접종 여부를 알려주세요.", name)
            self.decorationTitle(label: lbPreventTitle, result: result, name: name)
            
            result = String(format: "%@의 등록번호를 알려주세요.", name)
            self.decorationTitle(label: lbRegiTitle, result: result, name: name)
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
    
    func decorationTitle(label: UILabel, result: String, name:String) {
        let attr = NSMutableAttributedString.init(string: result, attributes: [.foregroundColor : RGB(136, 136, 136)])
        let nsRange = NSString(string: result).range(of: name, options: String.CompareOptions.caseInsensitive)
        attr.addAttribute(.foregroundColor, value: RGB(23, 133, 239), range: nsRange)
        attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 13, weight: .bold), range: nsRange)
        label.attributedText = attr
    }
    
    @IBAction func textFieldEdtingChanged(_ sender: UITextField) {
        if sender.text!.count > 0 {
            btnRegiUnKnow.isSelected = false
        }
    }
    @IBAction func tapGestureHandler(_ sender: UITapGestureRecognizer) {
        if sender.view == self.view {
            view.endEditing(true)
        }
    }
    
    @IBAction func onClickedButtonActions(_ sender: UIButton) {
        self.view.endEditing(true)
     
        if sender.tag == 100 || sender.tag == 101 {
            for btn  in arrBtnGender {
                btn.isSelected = false
            }
            sender.isSelected = true
            
            if sender.tag == 100 {
                selGender = "M"
            }
            else {
                selGender = "F"
            }
        }
        else if sender.tag == 200 || sender.tag == 201 {
            for btn  in arrBtnNeutral {
                btn.isSelected = false
            }
            sender.isSelected = true
            
            if sender.tag == 200 {
                selNeutral = "N"
            }
            else {
                selNeutral = "Y"
            }
        }
        else if sender.tag == 300 || sender.tag == 301 || sender.tag == 302 {
            for btn  in arrBtnPrevent {
                btn.isSelected = false
            }
            sender.isSelected = true
            
            if sender.tag == 300 {
                selPrevent = "N"
            }
            else if sender.tag == 301{
                selPrevent = "Y"
            }
            else {
                selPrevent = "D"
            }
        }
        else if sender.tag == 400 {
            btnRegiUnKnow.isSelected = true
            regiNumber = nil
        }
        else if sender == btnQuestion {
            let vc = AnimalRegiNumberInfoViewController.init()
            self.navigationController?.pushViewController(vc, animated: false)
        }
        else if sender == btnOk {
            animal?.gender = selGender
            animal?.neutral = selNeutral
            animal?.prevent = selPrevent
            
            if tfRegiNumber.text!.count > 0 {
                animal?.regiNumber = tfRegiNumber.text
            }
         
            ApiManager.shared.requestRegistAnimal(anmail: animal!) { (response) in
                print(String(describing: response))
            } failure: { (error) in
                self.showErrorAlertView(error)
            }
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
