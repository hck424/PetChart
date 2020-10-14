//
//  BaseViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/26.
//

import UIKit
import Toast_Swift
import JWTDecode

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
 
    @objc func actionPopViewCtrl() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func checkSessionGotoMyInfoVc() {
        if let token = SharedData.objectForKey(key: kPToken) as? String {
            do {
                let jwt = try decode(jwt: token)
                print ("=== old token: \(token)")
                print ("=== jwt expire date: \(String(describing: jwt.expiresAt))")
                if jwt.expired {
                    AlertView.showWithCancelAndOk(title: "인증시간 초과", message: "인증 시간이 초과하였습니다.\n 로그인 하시겠습니까?") { (index) in
                        if index == 1 {
                            self.gotoLoginVc()
                        }
                    }
                }
                else {
                    self.gotoMyinfoVc()
                }
            } catch let err {
                print("=== jwt decode error: \(err)")
            }
        }
        else {
            AlertView.showWithCancelAndOk(title: "로그인 안내", message: "로그인이 필요한 메뉴입니다.\n로그인하시겠습니까") { (index) in
                if index == 1 {
                    self.gotoLoginVc()
                }
            }
            return
        }
    }
    
    func gotoLoginVc() {
        let vc = LoginViewController.init(nibName: "LoginViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: false)
    }
    func gotoMyinfoVc() {
        let vc = MyInfoViewController.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
