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
    @IBOutlet weak var btnMypetName: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var svContaner: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawTitle(self, UIImage(named: "header_logo")!, nil)
        CNavigationBar.drawProfile(self, #selector(onclickedButtonActins(_:)))
    
        cornerBgView.layer.cornerRadius = 20.0
        cornerBgView.layer.maskedCorners = [CACornerMask.layerMinXMinYCorner, CACornerMask.layerMaxXMinYCorner]
        
    
        self.configurationUI()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func configurationUI() {
        let hasPet = false
        
        if hasPet == false {
            let addPetCell: EmptyPetCell = EmptyPetCell.initWithFromNib()
            svContaner.addArrangedSubview(addPetCell)
            addPetCell.didSelectedClouser = ({(selData:Any?, index:Int) -> () in
                let vc = AddAnimalNameViewController.init(nibName: "AddAnimalNameViewController", bundle: nil)
                self.navigationController?.pushViewController(vc, animated: false)
            })
        }
        else {
            
        }
            
    }
    @objc @IBAction func onclickedButtonActins(_ sender: UIButton) {
        if sender.tag == TAG_NAVI_USER {
            let vc = AnimalModifyInfoViewController.init(nibName: "AnimalModifyInfoViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: false)

            return

            
            AlertView.showWithCancelAndOk(title: "로그인 안내", message: "로그인이 필요한 메뉴입니다.\n로그인하시겠습니까") { (index) in
                if index == 1 {
                    let vc = LoginViewController.init(nibName: "LoginViewController", bundle: nil)
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            }
        }
        
    }
}
