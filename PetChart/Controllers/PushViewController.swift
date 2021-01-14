//
//  PushViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/05.
//

import UIKit
import FirebaseMessaging
class PushViewController: BaseViewController {
    @IBOutlet weak var btnToggle: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    var count = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "알림 설정", nil)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapgestureHandler(_ :)))
        lbTitle.addGestureRecognizer(tap)
        self.requestPushState()
    }
    @objc func tapgestureHandler(_ gesture:UITapGestureRecognizer) {
        count += 1
        if count%5 == 0 {
            if let fcmKey = Messaging.messaging().fcmToken {
                self.showToast(fcmKey)
                UIPasteboard.general.string = fcmKey
            }
        }
    }
    func requestPushState() {
        ApiManager.shared.requestPushState { (response) in
            if let response = response as?[String:Any], let data = response["data"] as? [String:Any], let notifiaction = data["notifiaction"] as? Bool  {
                self.btnToggle.isSelected = notifiaction
            }
            else {
                self.showErrorAlertView(response)
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnToggle {
            let isOn:Bool = !sender.isSelected
            guard let fcmToken = Messaging.messaging().fcmToken, let deviceUID = SharedData.objectForKey(key: kAPPLECATION_UUID) as? String  else {
                return
            }
            let param:[String:Any] = ["deviceUID":deviceUID, "p_token":fcmToken, "is_main":isOn, "dtype":"ios"]
            ApiManager.shared.requestPushSetting(param: param) { (response) in
                sender.isSelected = !sender.isSelected
            } failure: { (error) in
                self.showErrorAlertView(error)
            }
        }
    }
}
