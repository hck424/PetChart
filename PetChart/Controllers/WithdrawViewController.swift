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
    
    var user:UserInfo?
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "탈퇴하기", nil)
        if Utility.isIphoneX() == false {
            btnSafety.isHidden = true
        }
        
        bgConnerView.layer.cornerRadius = 20
        bgConnerView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        self.requestUserInfo()
    }
    func requestUserInfo() {
        ApiManager.shared.requestGetUserInfo { (response) in
            if let response = response as?[String:Any], let data = response["data"] as? [String:Any], let user = data["user"] as? [String:Any] {
                self.user = UserInfo.init(JSON: user)
                self.configurationUI()
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
        }

    }
    func configurationUI() {
        guard let user = user else {
            lbTitle.text = "정말 탈퇴하시겠어요?"
            return
        }
        
        guard let name = user.name else {
            return
        }
        lbTitle.text = "\(name)님,\n정말 탈퇴하시겠어요?"
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnExit {
            AlertView.showWithCancelAndOk(title: "회원 탈퇴", message: "확인 버튼을 누르면 탈퇴 처리가 완료됩니다.") { (index) in
                if index == 1 {
                    //TODO:: 회원 탈퇴
                    
                    var param = [String: Any]()
                    
                    guard let id = SharedData.getUserId(),
                          let login_type = SharedData.getLoginType(),
                          let password = SharedData.objectForKey(key: kUserPassword) else {
                        return
                    }
                    
                    param["id"] = "\(id)"
                    param["login_type"] = login_type
                    if login_type != "none" {
                        param["password"] = id
                    }
                    
                    ApiManager.shared.requestUserExit(param: param) { (response) in
                        if let response = response as? [String : Any], (response["success"] as! Bool) == true {
                            SharedData.removeObjectForKey(key: kUserId)
                            SharedData.removeObjectForKey(key: kUserPassword)
                            SharedData.removeObjectForKey(key: kPToken)
                            SharedData.removeObjectForKey(key: kLoginType)
                            SharedData.instance.pToken = nil
                            
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                        else {
                            self.showErrorAlertView(response)
                        }
                    } failure: { (error) in
                        self.showErrorAlertView(error)
                    }
                }
            }
        }
    }
}
