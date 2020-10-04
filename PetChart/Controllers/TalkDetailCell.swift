//
//  TalkDetailCell.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/04.
//

import UIKit

class TalkDetailCell: UITableViewCell {

    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var lbContent: UILabel!
    
    var data: Dictionary<String, Any>?
    var didSelectActionClosure:((_ selData: Dictionary<String, Any>?, _ actionIndex:Int) ->())? {
        didSet {
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ivProfile.layer.borderWidth = ivProfile.bounds.height/2
        ivProfile.layer.borderWidth = 2.0
        ivProfile.layer.borderColor = RGB(239, 239, 239).cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configurationData(_ data: Dictionary<String, Any>?) {
        self.data = data
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnDelete {
            self.didSelectActionClosure?(data, 0)
        }
    }
}
