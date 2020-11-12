//
//  FAQViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/05.
//

import UIKit

class FAQViewController: BaseViewController {
    @IBOutlet weak var svContent: UIStackView!
    
    var listData:Array<Any>?
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "자주묻는 질문", nil)
        
        self.requestFAQList()
    }
    
    func requestFAQList() {
        ApiManager.shared.requestFAQList(group: "none") { (response) in
            if let response = response as? [String:Any], let data = response["data"] as? [String:Any], let faqs = data["faqs"] as? Array<Any> {
                self.listData = faqs
                self.configurationUi()
            }
            else {
                self.showErrorAlertView(response)
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
        }
    }
    
    func configurationUi() {
        guard let listData = listData else {
            return
        }
        
        for item in listData {
            let cell = Bundle.main.loadNibNamed("NoticeCellView", owner: self, options: nil)?.first as! NoticeCellView
            cell.type = .faq
            cell.configurationData(item as? [String : Any])
            svContent.addArrangedSubview(cell)
        }
    }
}
