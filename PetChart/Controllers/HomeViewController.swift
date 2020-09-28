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
        if sender.tag == TAG_NAVI_PROFILE {
            print("profile clicked")
        }
    }
}
