//
//  HomeViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/26.
//

import UIKit
@IBDesignable
class HomeViewController: BaseViewController {
    @IBOutlet weak var cornerBgView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var btnPetAdd: CButton!
    @IBOutlet weak var btnMypetName: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawTitle(self, UIImage(named: "header_logo")!, nil)
        CNavigationBar.drawProfile(self, #selector(onclickedButtonActins(_:)))
    
        cornerBgView.layer.cornerRadius = 20.0
        cornerBgView.layer.maskedCorners = [CACornerMask.layerMinXMinYCorner, CACornerMask.layerMaxXMinYCorner]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    @objc @IBAction func onclickedButtonActins(_ sender: UIButton) {
        if sender.tag == TAG_NAVI_USER {
            print("profile clicked")
            AlertView.showWithCancelAndOk(title: "로그인 안내", message: "로그인이 필요한 메뉴입니다.\n로그인하시겠습니까") { (index) in
                if index == 1 {
                    let vc = LoginViewController.init(nibName: "LoginViewController", bundle: nil)
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            }
//            let optionBtn = ["스팸/광고글", "폭력물", "혐오발언", "카테고리 부적절"]
//            AlertView.showWithCancelAndOk(title: "알럿", message: "커스텀 알럿 뷰입니다. 커스텀 알럿 뷰입니다. 커스텀 알럿 뷰입니다. 커스텀 알럿 뷰입니다. 커스텀 알럿 뷰입니다. 커스텀 알럿 뷰입니다.", optionBtnTitles: optionBtn) { (index) in
//                print(index)
//            }
         
        }
        else if sender == btnPetAdd {
            
        }
    }
}
