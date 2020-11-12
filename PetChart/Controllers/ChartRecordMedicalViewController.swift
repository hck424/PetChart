//
//  ChartRecordMedicalViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/03.
//

import UIKit

class ChartRecordMedicalViewController: BaseViewController {
    @IBOutlet weak var btnDay: UIButton!
    @IBOutlet weak var tfDay: UITextField!
    @IBOutlet weak var btnToday: SelectedButton!
    @IBOutlet var arrBtnCare: [SelectedButton]!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    @IBOutlet weak var textView: CTextView!
    
    var selDate:Date?
    
    var arrData:Array<Any>?
    var selDtypeData: [String:Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawTitle(self, PetHealth.medical.koreanValue(), nil)
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawRight(self, "완료", nil, 1111, #selector(onClickedBtnActions(_ :)))
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureHanlder(_ :)))
        self.view.addGestureRecognizer(tap)
        arrBtnCare = arrBtnCare.sorted(by: { (btn1, btn2) -> Bool in
            return btn1.tag < btn2.tag
        })
        for btn in arrBtnCare {
            btn.addTarget(self, action: #selector(onClickedBtnActions(_:)), for: .touchUpInside)
        }
        
        self.requestConfigInfo()
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
    
    func requestConfigInfo() {
        ApiManager.shared.requestAppConfig { (response) in
            if let response = response as? [String:Any],
               let data = response["data"] as? [String:Any],
               let chart_types = data["chart_types"] as? Array<Any> {
                self.arrData = chart_types
            }
            self.setData()
        } failure: { (error) in
            self.showErrorAlertView(error)
        }
    }
    
    func setData() {
        
        guard let arrData = arrData else {
            for btn in arrBtnCare {
                btn.setTitle("", for: .normal)
            }
            return
        }
//                dtype = Dental;
//                id = 1;
//                lable = "\Uce58\Uacfc\Uc9c4\Ub8cc";
        var i = 0
        for btn in arrBtnCare {
            if i < arrData.count {
                btn.isUserInteractionEnabled = true
                if let item = arrData[i] as? [String:Any], let lable = item["lable"] as? String {
                    btn.setTitle(lable, for: .normal)
                    btn.data = item
                }
            }
            else {
                btn.setTitle("", for: .normal)
                btn.layer.borderColor = UIColor.clear.cgColor
                btn.isUserInteractionEnabled = false
            }
            i += 1
        }
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
        else if let selectedBtn = sender as? SelectedButton, arrBtnCare.contains(selectedBtn) == true {
            for btn in arrBtnCare {
                btn.isSelected = false
            }
            selectedBtn.isSelected = true
            self.selDtypeData = selectedBtn.data as? [String:Any]
        }
        else if sender.tag == 1111 {
            guard let date = tfDay.text, date.isEmpty == false else {
                self.view.makeToast("날짜를 입력해주세요.", position:.top)
                return
            }
            
            guard let selDtypeData = selDtypeData, let dtype = selDtypeData["dtype"] as? String else {
                self.view.makeToast("진료 종류를 선택해주세요.", position:.top)
                return
            }
            guard let content = textView.text, content.isEmpty == false else {
                self.view.makeToast("진료 내용을 입력해주세요.", position:.top)
                return
            }
            guard let petId = SharedData.objectForKey(key: kMainShowPetId) else {
                self.view.makeToast("등록된 동물이 없습니다.", position:.top)
                return
            }
            
            let param = ["contents": content, "date_key": date, "kind_code": dtype, "pet_id": petId]
            ApiManager.shared.requestWriteChart(type: .medical, param: param) { (response) in
                if let response = response as? [String:Any],
                   let msg = response["msg"] as? String,
                   let success = response["success"] as? Bool, success == true {
                    AlertView.showWithCancelAndOk(title: "진료 기록", message: msg) { (index) in
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

extension ChartRecordMedicalViewController:UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let textView = textView as? CTextView {
            textView.placeholderLabel?.isHidden = !textView.text.isEmpty
        }
    }
}
