//
//  ChartViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/26.
//

import UIKit

class ChartViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawTitle(self, "차트", nil)
        CNavigationBar.drawProfile(self, #selector(onclickedButtonActins(_:)))
        
    }

    @objc @IBAction func onclickedButtonActins(_ sender: UIButton) {
        if sender.tag == TAG_NAVI_USER {
            
        }
    }
}
