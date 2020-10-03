//
//  ChartDetailViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/03.
//

import UIKit

class ChartDetailViewController: BaseViewController {
    var vcTitle:String?
    var type:PetHealth?
    var data: Dictionary<String, Any>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var title = ""
        if let tt = vcTitle {
            title = tt
        }
        CNavigationBar.drawTitle(self, title, nil)
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
    }
    
}
