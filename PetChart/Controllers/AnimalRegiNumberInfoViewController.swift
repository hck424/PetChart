//
//  AnimalRegiNumberInfoViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/01.
//

import UIKit

class AnimalRegiNumberInfoViewController: BaseViewController {
    var url:String?
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "반려동물 등록", nil)
        
    }
    
    @IBAction func onClickedButton(_ sender: Any) {
        if let url = url, url.isEmpty == false {
            self.openUrl()
        }
        else {
            ApiManager.shared.requestAppConfig { (response) in
                if let response = response as? [String:Any], let data = response["data"] as? [String:Any], let animalUrl = data["animalUrl"] as? String {
                    self.url = animalUrl
                    self.openUrl()
                }
                else {
                    self.showErrorAlertView(response)
                }
            } failure: { (errror) in
                self.showErrorAlertView(errror)
            }
        }
    }
    
    func openUrl() {
        guard let url = url else {
            return
        }
        AppDelegate.instance()?.openUrl(url, completion:nil)
    }
}
