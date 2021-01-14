//
//  MrTermsViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/11/08.
//

import UIKit

class MrTermsViewController: BaseViewController {

    @IBOutlet weak var bgCornerView: UIView!
    @IBOutlet weak var btnTerm1: UIButton!
    @IBOutlet weak var btnTermShow1: UIButton!
    @IBOutlet weak var btnTerm2: UIButton!
    @IBOutlet weak var btnTermShow2: UIButton!
    @IBOutlet weak var btnTerm3: UIButton!
    @IBOutlet weak var btnTermShow3: UIButton!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var btnOk: UIButton!
    var user: UserInfo? = nil
    var joinType: String = "none"
    override func viewDidLoad() {
        
        super.viewDidLoad()
        CNavigationBar.drawTitle(self, "약 관", nil)
        CNavigationBar.drawBackButton(self, nil, #selector(onClickedBtnActions(_:)))
        if Utility.isIphoneX() == false {
            btnSafety.isHidden = true
        }
        bgCornerView.layer.cornerRadius = 20
        bgCornerView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
    }

    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender.tag == TAG_NAVI_BACK {
            self.navigationController?.popViewController(animated: true)
        }
        else if sender == btnTerm1 {
            sender.isSelected = !sender.isSelected
            user?.termsserviceAgree = sender.isSelected
        }
        else if sender == btnTerm2 {
            sender.isSelected = !sender.isSelected
            user?.privacyAgree = sender.isSelected
        }
        else if sender == btnTerm3 {
            sender.isSelected = !sender.isSelected
            user?.marketingAgree = sender.isSelected
        }
        else if sender == btnTermShow1 {
            self.requestTerms(type: "service")
        }
        else if sender == btnTermShow2 {
            self.requestTerms(type: "privacy")
        }
        else if sender == btnTermShow3 {
            self.requestTerms(type: "marketing")
        }
        else if sender == btnOk {
            if btnTerm1.isSelected == false {
                self.showToast("약관을 체크해주세요.")
                return
            }
            if btnTerm2.isSelected == false {
                self.showToast("약관을 체크해주세요.")
                return
            }
            
            let vc = MrNameInputViewController.init(nibName: "MrNameInputViewController", bundle: nil)
            vc.user = user
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func requestTerms(type:String) {
//        privacy|service|marketing
        var param:[String:Any]? = nil
        if type == "privacy" || type == "service" || type == "marketing" {
            param = ["dtype": type]
        }
        
        guard let body = param else {
            return
        }
        
        ApiManager.shared.requestTerms(param: body) { (response) in
            if let response = response as? [String:Any], let data = response["data"] as?[String:Any] {
                
                let vc = CustomTextViewController.init()
                if let dtype = data["dtype"] as? String {
                    var vcTitie = ""
                    if dtype == "privacy" {
                        vcTitie = "개인정보 처리방침"
                    }
                    else if dtype == "service" {
                        vcTitie = "이용약관"
                    }
                    else {
                        vcTitie = "마켓팅 수신 동의"
                    }
                    vc.vcTitle = vcTitie
                }
                if let contents = data["contents"] as? String {
                    vc.content = contents
                }
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                self.showErrorAlertView(response)
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
        }
    }
}
