//
//  AnimalRegiNumberInfoViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/01.
//

import UIKit

class AnimalRegiNumberInfoViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "반려동물 등록", nil)
    }
    
    @IBAction func onClickedButton(_ sender: Any) {
        
    }
    
}
