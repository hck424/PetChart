//
//  NoticeViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/05.
//

import UIKit

class NoticeViewController: BaseViewController {
    @IBOutlet weak var svContent: UIStackView!
    var listData:Array<Any>?
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "공지 사항", nil)
        
        requestNoticeList()
    }
    
    func requestNoticeList() {
        ApiManager.shared.requestNoticeList { (response) in
            if let response = response as? [String:Any], let data = response["data"] as? [String:Any], let notices = data["notices"] as? Array<Any> {
                self.listData = notices
                self.configurationUi()
            }
            else {
                self.showErrorAlertView(response)
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
        }

        configurationUi()
    }
    func configurationUi() {
        guard let listData = listData else {
            return
        }
        for item in listData {
            let cell = Bundle.main.loadNibNamed("NoticeCellView", owner: self, options: nil)?.first as! NoticeCellView
            cell.type = .notice
            cell.configurationData(item as? [String:Any])
            svContent.addArrangedSubview(cell)
        }
    }
}
