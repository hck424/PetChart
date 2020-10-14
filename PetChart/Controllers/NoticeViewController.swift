//
//  NoticeViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/05.
//

import UIKit

class NoticeViewController: BaseViewController {
    @IBOutlet weak var svContent: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "공지 사항", nil)
        
        requestNoticeList()
    }
    
    func requestNoticeList() {
        configurationUi()
    }
    func configurationUi() {
        for _ in 0..<10 {
            let cell = Bundle.main.loadNibNamed("NoticeCellView", owner: self, options: nil)?.first as! NoticeCellView
            cell.configurationData(nil)
            svContent.addArrangedSubview(cell)
        }
    }
}
