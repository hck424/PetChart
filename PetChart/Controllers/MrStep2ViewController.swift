//
//  MrStep2ViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/29.
//

import UIKit

@IBDesignable class MrStep2ViewController: BaseViewController {
    var user: UserInfo?
    
    @IBOutlet weak var btnCanlendar: UIButton!
    
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var bgCornerView: UIView!
    @IBOutlet weak var tfBirthDay: UITextField!
    
    var selDate: Date? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "회원가입", nil)
        
        if Utility.isIphoneX() == false {
            btnSafety.isHidden = true
        }
        bgCornerView.layer.cornerRadius = 20
        bgCornerView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
    }

    @IBAction func onClickedButtonActions(_ sender: UIButton) {
        
        if sender == btnCanlendar {
            let todaysDate = Date()
            let minDate = todaysDate.getStartDate(withYear: -70)
            let maxDate = todaysDate
            let apoint = todaysDate.getStartDate(withYear: -30)
            
            let picker = CDatePickerView.init(type: .yearMonthDay, minDate: minDate, maxDate: maxDate, apointDate: apoint) { (strDate, date) in
                if let date = date {
                    self.selDate = date
                    self.tfBirthDay.text = strDate
                }
            }
            picker?.local = Locale(identifier: "ko_KR")
            picker?.show()
            
            return
        }
        else if sender == btnOk {
            if tfBirthDay.text?.length  == 0 {
                self.view.makeToast("생년월일을 입력해주세요.")
                return
            }
            self.user?.birthday = tfBirthDay.text
            
            let vc = MrStep3ViewController.init(nibName: "MrStep3ViewController", bundle: nil)
            vc.user = self.user
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
}
