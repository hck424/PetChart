//
//  BaseNavigationController.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/26.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
extension BaseNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController.isEqual(navigationController.viewControllers.first) {
//            viewController.navigationController?.setNavigationBarHidden(true, animated: animated)
            viewController.navigationController?.tabBarController?.tabBar.isHidden = false
        }
        else {
//            viewController.navigationController?.setNavigationBarHidden(false, animated: animated)
            viewController.navigationController?.tabBarController?.tabBar.isHidden = true
        }
    }
}
