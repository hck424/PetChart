//
//  ChartRecordWeightViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/03.
//

import UIKit

class ChartRecordWeightViewController: BaseViewController {
    @IBOutlet weak var btnDay: UIButton!
    @IBOutlet weak var tfDay: UITextField!
    
    @IBOutlet weak var btnToday: SelectedButton!
    @IBOutlet weak var tfWeight: UITextField!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    
    var selDate: Date? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawTitle(self, PetHealth.weight.koreanValue(), nil)
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawRight(self, "완료", nil, 1111, #selector(onClickedBtnActions(_ :)))
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureHanlder(_ :)))
        self.view.addGestureRecognizer(tap)
     
        tfWeight.delegate = self
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
        else if sender.tag == 1111 {
            
            guard let date = tfDay.text, date.isEmpty == false else {
                self.view.makeToast("날짜를 입력해주세요.", position:.top)
                return
            }
            guard let amount = tfWeight.text, amount.isEmpty == false else {
                self.view.makeToast("체중을 입력해주세요.", position:.top)
                return
            }
            guard let petId = SharedData.objectForKey(key: kMainShowPetId) else {
                self.view.makeToast("등록된 동물이 없습니다.", position:.top)
                return
            }
            
            //체중 기록
            let param:[String:Any] = ["date_key":date, "weight":amount, "pet_id":petId ]
            ApiManager.shared.requestWriteChart(type: .weight, param: param) { (response) in
                if let response = response as? [String:Any],
                   let msg = response["msg"] as? String,
                   let success = response["success"] as? Bool, success == true {
                    AlertView.showWithCancelAndOk(title: "체중 기록", message: msg) { (index) in
                        self.navigationController?.popViewController(animated: true)
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

extension ChartRecordWeightViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
}
