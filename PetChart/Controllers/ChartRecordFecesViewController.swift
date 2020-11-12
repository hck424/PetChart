//
//  ChartRecordFecesViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/03.
//

import UIKit

class ChartRecordFecesViewController: BaseViewController {
    @IBOutlet weak var btnDay: UIButton!
    @IBOutlet weak var tfDay: UITextField!
    @IBOutlet weak var btnToday: SelectedButton!
    
    @IBOutlet var arrBtnColor: [CButton]!
    @IBOutlet var arrBtnFeces: [SelectedButton]!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    @IBOutlet weak var tfCountS: UITextField!
    @IBOutlet weak var tfCountP: UITextField!
    
    var selDate: Date?
    var isCompletionS: Bool = false
    var isCompletionP: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawTitle(self, PetHealth.feces.koreanValue(), nil)
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawRight(self, "완료", nil, 1111, #selector(onClickedBtnActions(_ :)))
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureHanlder(_ :)))
        self.view.addGestureRecognizer(tap)
        arrBtnColor = arrBtnColor.sorted(by: { (btn1, btn2) -> Bool in
            return btn1.tag < btn2.tag
        })
        arrBtnFeces = arrBtnFeces.sorted(by: { (btn1, btn2) -> Bool in
            return btn1.tag  < btn2.tag
        })
        
        for btn in arrBtnColor {
            btn.addTarget(self, action: #selector(onClickedBtnActions(_:)), for: .touchUpInside)
        }
        for btn in arrBtnFeces {
            btn.addTarget(self, action: #selector(onClickedBtnActions(_:)), for: .touchUpInside)
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
    
    @objc func tapGestureHanlder(_ gesture:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if sender == btnDay {
            btnToday.isSelected = false
            
            let curDate = Date()
            let picker = CDatePickerView.init(type: .yearMonthDay, minDate: curDate.getStartDate(withYear: -10), maxDate: curDate, apointDate: curDate) { (strDate, date) in
                if let date = date {
                    self.selDate = date
                    self.tfDay.text = strDate
                }
            }
            picker?.local = Locale(identifier: "ko_KR")
            picker?.show()
        }
        else if sender == btnToday {
            sender.isSelected = true
            let curDate = Date()
            let df = CDateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            self.selDate = curDate
            tfDay.text = df.string(from: curDate)
        }
        else if let colorBtn = sender as? CButton,  arrBtnColor.contains(colorBtn) == true {
            for btn in arrBtnColor {
                btn.layer.borderColor = nil
                btn.layer.borderWidth = 0
                btn.isSelected = false
            }
            colorBtn.isSelected = true
            colorBtn.layer.borderColor = ColorDefault.cgColor
            colorBtn.layer.borderWidth = 2.0
            
        }
        else if let selBtn = sender as? SelectedButton,  arrBtnFeces.contains(selBtn) == true {
            for btn in arrBtnFeces {
                btn.isSelected = false
            }
            selBtn.isSelected = true
            
        }
        else if sender.tag == 1111 {
            guard let petId = SharedData.objectForKey(key: kMainShowPetId) else {
                self.view.makeToast("등록된 동물이 없습니다.", position:.top)
                return
            }
            guard let date = tfDay.text, date.isEmpty == false else {
                self.view.makeToast("날짜를 입력해주세요.", position:.top)
                return
            }
            
            guard let sCount = tfCountS.text, sCount.isEmpty == false else {
                self.view.makeToast("소변 횟수 입력해주세요.", position:.top)
                return
            }
            guard let pCount = tfCountS.text, pCount.isEmpty == false else {
                self.view.makeToast("대변 횟수 입력해주세요.", position:.top)
                return
            }
            
            var colorS = 0
            var isSelectedS = false
            for btn in arrBtnColor {
                if btn.isSelected {
                    isSelectedS = true
                    if btn.tag < 6 {
                        colorS = btn.tag
                    }
                    break
                }
            }
            if isSelectedS == false {
                self.view.makeToast("소변 색갈을 선택해주세요.", position:.top)
                return
            }
            
            var colorP = 0
            var isSelectedP = false
            for btn in arrBtnColor {
                if btn.isSelected {
                    isSelectedP = true
                    if btn.tag < 6 {
                        colorP = btn.tag
                    }
                    break
                }
            }
            
            if isSelectedP == false {
                self.view.makeToast("대변 종류를 선택해주세요.", position:.top)
                return
            }
            
            let param1 = ["dtype":"S", "pet_id": petId, "cnt":sCount, "color": colorS, "date_key": date]
            let param2 = ["dtype":"P", "pet_id": petId, "cnt":pCount, "color": colorP, "date_key": date]
            //소변기록
            ApiManager.shared.requestWriteChart(type: .feces, param: param1) { (response) in
                if let response = response as? [String:Any],
                   let msg = response["msg"] as? String,
                   let success = response["success"] as? Bool, success == true {
                    
                    self.isCompletionS = true
                    if self.isCompletionS && self.isCompletionP {
                        AlertView.showWithCancelAndOk(title: "배변 기록", message: msg) { (index) in
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
                else {
                    self.showErrorAlertView(response)
                }

            } failure: { (error) in
                self.showErrorAlertView(error)
            }
            
            //대변 기록
            ApiManager.shared.requestWriteChart(type: .feces, param: param2) { (response) in
                if let response = response as? [String:Any],
                   let msg = response["msg"] as? String,
                   let success = response["success"] as? Bool, success == true {
                    
                    self.isCompletionP = true
                    if self.isCompletionS && self.isCompletionP {
                        AlertView.showWithCancelAndOk(title: "배변 기록", message: msg) { (index) in
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
                else {
                    self.showErrorAlertView(response)
                }

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
}
