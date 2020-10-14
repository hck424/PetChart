//
//  NoticeCellView.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/14.
//

import UIKit

class NoticeCellView: UIView {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var btnExpand: CButton!
    @IBOutlet weak var lbContent: UILabel!
    @IBOutlet weak var svContent: UIStackView!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
    }
    func configurationData(_ data:[String:Any]?) {
        btnExpand.data = data
        btnExpand.isSelected = false
        svContent.isHidden = true
    }
    
    @IBAction func onClickedButtonAction(_ sender: CButton) {
        if sender == btnExpand {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                svContent.isHidden = false
            }
            else {
                svContent.isHidden = true
            }
            
        }
    }
}
