//
//  PushViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/05.
//

import UIKit

class PushViewController: BaseViewController {
    @IBOutlet weak var btnToggle: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "알림 설정", nil)

        if let isOn = UserDefaults.standard.object(forKey: kPushSetting) as? String, isOn == "Y" {
            btnToggle.isSelected = true
        }
        else {
            btnToggle.isSelected = false
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnToggle {
            sender.isSelected = !sender.isSelected
            
            if sender.isSelected {
                //TODO:: userdefault push key
                UserDefaults.standard.setValue("Y", forKey: kPushSetting)
            }
            else {
                UserDefaults.standard.removeObject(forKey: kPushSetting)
            }
            UserDefaults.standard.synchronize()
        }
    }
}
