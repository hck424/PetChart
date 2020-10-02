//
//  MemberRegistStep1ViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/29.
//

import UIKit

class MemberRegistStep1ViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "회원가입", nil)
    }

    @objc func @IBAction onclickedButtonActions(_ sender: UIButton) {
        
    }
    

}
