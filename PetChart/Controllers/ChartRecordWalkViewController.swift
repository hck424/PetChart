//
//  ChartRecordWalkViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/03.
//

import UIKit

class ChartRecordWalkViewController: BaseViewController {

    @IBOutlet weak var btnDay: UIButton!
    @IBOutlet weak var tfDay: UITextField!
    @IBOutlet weak var btnToday: SelectedButton!
    @IBOutlet weak var btnStartTime: UIButton!
    @IBOutlet weak var btnEndTime: UIButton!
    @IBOutlet weak var tfTakeTime: UITextField!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    
    var stDate: Date? = nil
    var edDate: Date? = nil
    var selDate: Date? = nil
    var walkTime:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawTitle(self, PetHealth.walk.koreanValue(), nil)
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawRight(self, "완료", nil, 1111, #selector(onClickedBtnActions(_ :)))
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureHanlder(_ :)))
        self.view.addGestureRecognizer(tap)
        
        btnStartTime.setTitleColor(RGB(202, 202, 202), for: .normal)
        btnStartTime.setTitleColor(UIColor.black, for: .selected)
        btnEndTime.setTitleColor(RGB(202, 202, 202), for: .normal)
        btnEndTime.setTitleColor(UIColor.black, for: .selected)
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
        else if sender == btnStartTime {
            let picker = CDatePickerView.init(type: .time) { (strDate, date) in
                if let date = date {
                    self.stDate = date
                    self.btnStartTime.setTitle(strDate, for: .normal)
                    self.btnStartTime.isSelected = true
                    self.decorationTakeTime()
                }
            }
            picker?.minuteInterval = 5
            picker?.local = Locale(identifier: "ko_KR")
            picker?.show()
        }
        else if sender == btnEndTime {
            let picker = CDatePickerView.init(type: .time) { (strDate, date) in
                if let date = date {
                    self.edDate = date
                    self.btnEndTime.setTitle(strDate, for: .normal)
                    self.btnEndTime.isSelected = true
                    self.decorationTakeTime()
                }
            }
            picker?.minuteInterval = 5
            picker?.local = Locale(identifier: "ko_KR")
            picker?.show()
        }
        else if sender.tag == 1111 {
            self.view.endEditing(true)
            guard let date = tfDay.text, date.isEmpty == false else {
                self.showToast("날짜를 선택해주세요.")
                return
            }
            
            guard let stDate = stDate, let edDate = edDate else {
                self.showToast("산책시간을 입력해주세요.")
                return
            }
            
            if walkTime <= 0 {
                self.showToast("산책시간을 입력해주세요.")
                return
            }
            
            guard let petId = SharedData.objectForKey(key: kMainShowPetId) else {
                return
            }
            
            let df = CDateFormatter.init()
            df.dateFormat = "yyyy-MM-dd HH:MM"
            guard let walkStDate = df.string(from: stDate) as? String, let walkEdDate = df.string(from: edDate) as? String else {
                return
            }
            
            let param:[String:Any] = ["date_key":date, "walk_start_dt":walkStDate, "walk_end_dt":walkEdDate, "pet_id":petId, "walk_time":walkTime]
            
            ApiManager.shared.requestWriteChart(type: .walk, param: param) { (response) in
                if let response = response as? [String:Any],
                   let msg = response["msg"] as? String,
                   let success = response["success"] as? Bool, success == true {
                    self.showToast(msg)
                    self.navigationController?.popViewController(animated: true)
//                    AlertView.showWithCancelAndOk(title: "산책 기록", message: msg) { (index) in
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
    
    func decorationTakeTime() {
        walkTime = 0
        tfTakeTime.text = nil
        
        if (self.stDate != nil)
            && (self.edDate != nil)
            && (self.stDate! < self.edDate!) {
            
            let interval = self.edDate! - self.stDate!
//            var result = ""
            if let hour = interval.hour, hour > 0 {
//                result.append(String(format: "%02d:", hour))
                walkTime = hour*60
            }
//            else {
//                result = "00:"
//            }
            
            if let minute = interval.minute {
//                result.append(String(format: "%02d", minute))
                walkTime += minute
            }
            print("=== walk time: \(walkTime)")
//            if result.length > 0 {
                tfTakeTime.text = "\(walkTime)"
//            }
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
