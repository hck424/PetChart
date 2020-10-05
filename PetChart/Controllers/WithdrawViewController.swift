//
//  WithdrawViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/05.
//

import UIKit

class WithdrawViewController: BaseViewController {
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSubTitle: UILabel!
    @IBOutlet weak var lbMsg: UILabel!
    @IBOutlet weak var btnExit: UIButton!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var bgConnerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "탈퇴하기", nil)
        if Utility.isIphoneX() == false {
            btnSafety.isHidden = true
        }
        
        bgConnerView.layer.cornerRadius = 20
        bgConnerView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnExit {
            AlertView.showWithCancelAndOk(title: "회원 탈퇴", message: "확인 버튼을 누르면 탈퇴 처리가 완료됩니다.") { (index) in
                if index == 1 {
                    //TODO:: 회원 탈퇴
                }
            }
        }
    }
}
