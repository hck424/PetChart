//
//  AddAnimalInfoViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/01.
//

import UIKit

class AddAnimalInfoViewController: BaseViewController {
    
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
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var tfWeight: CTextField!
    
    @IBOutlet weak var lbWeightTitle: UILabel!
    
    var selGender: String?
    var  selNeutral: String?
    var selPrevent: String?
    var regiNumber: String?
    
    var animal: Animal?
    var images:Array<UIImage>?
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "반려동물 등록", nil)
        btnQuestion.imageView?.contentMode = .scaleAspectFit
        
        if let name = animal?.petName {
            var result = String(format: "%@의 성별은 무엇인가요?", name)
            self.decorationTitle(label: lbGenderTitle, result: result, name: name)
            
            result = String(format: "%@의 중성화 여부를 알려주세요.", name)
            self.decorationTitle(label: lbNeutralTitle, result: result, name: name)
            
            result = String(format: "%@의 예방접종 여부를 알려주세요.", name)
            self.decorationTitle(label: lbPreventTitle, result: result, name: name)
            
            result = String(format: "%@의 등록번호를 알려주세요.", name)
            self.decorationTitle(label: lbRegiTitle, result: result, name: name)
            
            result = String(format: "%@의 몸무게를 알려주세요.", name)
            self.decorationTitle(label: lbWeightTitle, result: result, name: name)
        }
        
        if Utility.isIphoneX() == false {
            btnSafety.isHidden = true
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
            self.view.endEditing(true)
            guard let gender = selGender else {
                self.showToast("성별을 선택해주세요.")
                return
            }
            guard let neutral = selNeutral else {
                self.showToast("중성화 여부를 선택해주세요.")
                return
            }
            guard let prevent = selPrevent else {
                self.showToast("예방접종 여부를 선택해주세요.")
                return
            }
            
            guard let weight = tfWeight.text, weight.isEmpty == false else {
                self.view.makeToast("몸무게를 입력해주세요.")
                return
            }
            
            if Float(weight)! > 200 {
                self.view.makeToast("몸무게는 최대 200kg까지 입력가능합니다.")
                return
            }
            animal?.sex = gender
            animal?.neutral = neutral
            animal?.prevention = prevent
            
            if tfRegiNumber.text!.count > 0 {
                animal?.regist_id = tfRegiNumber.text
            }
            
            
            guard let animal = animal else {
                return;
            }
            
            var param:[String:Any] = [String:Any]()
            if let files = images { param["images"] = files }
            
            if let petName = animal.petName { param["name"] = petName }
            if let is_main = animal.is_main { param["is_main"] = is_main }
            if let birthday = animal.birthday { param["birthday"] = birthday }
            if let birthMonth = animal.birthMonth { param["birthMonth"] = birthMonth }
            if let neutral = animal.neutral { param["neutral"] = neutral }
            if let size = animal.size { param["size"] = size }
            if let dtype = animal.dtype { param["dtype"] = dtype }
            param["age"] = animal.age
            if let regist_id = animal.regist_id { param["regist_id"] = regist_id }
            if let sex = animal.sex { param["sex"] = sex }
            if let kind = animal.kind { param["kind"] = kind }
            if let images = animal.images { param["images"] = images }
            if let id = animal.id { param["id"] = id }
            if let prevention = animal.prevention { param["prevention"] = prevention }
    
            param["weight"] =  Int(Float(weight)!*1000)
            
            ApiManager.shared.requestRegistAnimal(param:param) { (response) in
                if let response = response as? [String:Any], let data = response["data"] as? [String:Any], let success = response["success"] as? Bool, success == true {
                    
                    self.showToast("동물이 등록되었습니다.")
                    
                    SharedData.setObjectForKey(key: "Y", value: kHasAnimal)
                    self.requestRegistMainShow(data)
                    
//                    guard let viewcontrollers = self.navigationController?.viewControllers else {
//                        self.navigationController?.popToRootViewController(animated: true)
//                        return
//                    }
//                    var isFindVc = false
//                    for vc in  viewcontrollers {
//                        if let vc = vc as? MyPetViewController {
//                            isFindVc = true
//                            self.navigationController?.popToViewController(vc, animated: true)
//                        }
//                    }
//                    if isFindVc == false {
                        self.navigationController?.popToRootViewController(animated: true)
//                    }
                }
                else {
                    self.showErrorAlertView(response)
                }
            } failure: { (error) in
                self.showErrorAlertView(error)
            }
        }
    }
    func requestRegistMainShow(_ data:[String:Any]) {
        guard let id = data["id"] as? Int else {
            return
        }
        let param:[String : Any] = ["pet_id":id, "enable": "Y"]
        ApiManager.shared.requestPetMainEnable(param: param) { (response) in
            
        } failure: { (error) in
            
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

extension AddAnimalInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
          if let textField = textField as? CTextField {
              textField.borderColor = ColorDefault
          }
      }
      func textFieldDidEndEditing(_ textField: UITextField) {
          if let textField = textField as? CTextField {
              textField.borderColor = ColorBorder
          }
      }

}
