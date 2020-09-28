//
//  CommunityViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/26.
//

import UIKit

class CommunityViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawTitle(self, "차트톡", nil)
        CNavigationBar.drawProfile(self, #selector(onclickedButtonActins(_:)))
    }

    @objc @IBAction func onclickedButtonActins(_ sender: UIButton) {
        if sender.tag == TAG_NAVI_USER {
            
        }
    }
}
