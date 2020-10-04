//
//  PetHealthFavoriteCell.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/02.
//

import UIKit

class PetHealthFavoriteCell: UITableViewCell {

    @IBOutlet weak var btnToggle: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    var data: Dictionary<String, Any>? = nil
    var didClickedClourse:((_ selData: Dictionary<String, Any>?, _ selected: Bool) ->())? {
        didSet {
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        let bgView = UIView()
        bgView.backgroundColor = UIColor.clear
        self.selectedBackgroundView = bgView
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func confifurationData(_ data:Dictionary<String, Any>) {
        self.data = data
        if let type:PetHealth = (data["type"] as? PetHealth) {
            lbTitle.text = type.koreanValue()
        }
        if let selected = data["selected"] as? Bool {
            btnToggle.isSelected = selected
        }
    }
    @IBAction func onClickedButtonActions(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        didClickedClourse?(data, sender.isSelected)
    }
}
