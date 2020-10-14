//
//  IotManagementViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/05.
//

import UIKit

class IotManagementViewController: BaseViewController {
    @IBOutlet weak var lbPetNameTitle: UILabel!
    @IBOutlet weak var lbIotName: UILabel!
    @IBOutlet weak var lbIotModel: UILabel!
    @IBOutlet weak var btnModify: UIButton!
    @IBOutlet weak var btnConent: CButton!
    @IBOutlet weak var btnIotRemove: UIButton!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var cornerContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "기기 설정", nil)
        if Utility.isIphoneX() == false {
            btnSafety.isHidden = true
        }
        cornerContainer.layer.cornerRadius = 20
        cornerContainer.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnModify {
            
        }
        else if sender == btnConent {
            sender.isSelected = !sender.isSelected
        }
        else if sender == btnIotRemove {
            
        }
    }
}
