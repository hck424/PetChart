//
//  ChartRecordEatViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/03.
//

import UIKit

class ChartRecordEatViewController: BaseViewController {
    
    @IBOutlet weak var btnDay: UIButton!
    @IBOutlet weak var tfDay: UITextField!
    @IBOutlet weak var btnToday: SelectedButton!
    @IBOutlet weak var tfEatAmount: UITextField!
    @IBOutlet weak var tfEatCount: UITextField!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    
    var selDate:Date? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawTitle(self, PetHealth.eat.koreanValue(), nil)
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawRight(self, "완료", nil, 1111, #selector(onClickedBtnActions(_ :)))
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureHanlder(_ :)))
        self.view.addGestureRecognizer(tap)
        
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
        if gesture.view == self.view {
            self.view.endEditing(true)
        }
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
            self.view.endEditing(true)
            guard let date = tfDay.text, date.isEmpty == false else {
                self.showToast("날짜를 선택해주세요.")
                return
            }
            guard let amount = tfEatAmount.text, amount.isEmpty == false else {
                self.showToast("식사량을 적어주세요.")
                return
            }
            
            guard let count = tfEatCount.text, count.isEmpty == false else {
                self.showToast("식사 횟수를 적어주세요.")
                return
            }
            guard let petId = SharedData.objectForKey(key: kMainShowPetId) else {
                return
            }
            
            //식사 저장
            let param:[String:Any] = ["date_key":date, "eat_cnt":count, "eating":amount, "pet_id":petId ]
            ApiManager.shared.requestWriteChart(type: .eat, param: param) { (response) in
                if let response = response as? [String:Any],
                   let msg = response["msg"] as? String,
                   let success = response["success"] as? Bool, success == true {
                    self.showToast(msg)
                    self.navigationController?.popViewController(animated: true)
//                    AlertView.showWithCancelAndOk(title: "식사 기록", message: msg) { (index) in
//                        self.navigationController?.popViewController(animated: true)
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
