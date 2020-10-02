//
//  BaseViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/26.
//

import UIKit
import Toast_Swift

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
 
    @objc func actionPopViewCtrl() {
        self.navigationController?.popViewController(animated: true)
    }
}
