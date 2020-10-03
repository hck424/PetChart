//
//  ChartRecordDrinkViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/03.
//

import UIKit

class ChartRecordDrinkViewController: BaseViewController {
    @IBOutlet weak var btnDay: UIButton!
    @IBOutlet weak var tfDay: UITextField!
    @IBOutlet weak var btnToday: SelectedButton!
    @IBOutlet weak var tfDringAmount: UITextField!
    @IBOutlet weak var tfDrinkCount: UITextField!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    
    var selDate:Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawTitle(self, PetHealth.drink.koreanValue(), nil)
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
        self.view.endEditing(true)
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        self.view.endEditing(true)
        if sender == btnDay {
            
            btnToday.isSelected = false
            let curDate = Date()
            let picker = CDatePickerView.init(type: .yearMonthDay, minDate: curDate.getStartDate(withYear: -10), maxDate: curDate, apointDate: curDate) { (strDate, date) in
                
                if let strDate = strDate {
                    self.tfDay.text = strDate
                    self.selDate = date
                }
            }
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
            
            if self.selDate == nil {
                self.view.makeToast("날짜를 입력해주세요.", position:.top)
                return
            }
            if tfDringAmount.text?.count == 0 {
                self.view.makeToast("하루 음수량을 입력해주세요.", position:.top)
                return
            }
            
            if tfDrinkCount.text?.count == 0 {
                self.view.makeToast("하루 음수횟수를 입력해주세요.", position:.top)
            }
            
            //음수 저장
            
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