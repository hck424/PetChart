//
//  TalkCell.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/04.
//

import UIKit

class TalkCell: UITableViewCell {
    @IBOutlet weak var ivThumb: UIImageView!
    @IBOutlet weak var lbMsg: UILabel!
    @IBOutlet weak var lbAnimalKind: UILabel!
    @IBOutlet weak var lbReplyCount: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    
    var data: Dictionary<String, Any>? = nil
    var didClickedActionClosure:((_ selData:Dictionary<String, Any>?, _ btnAction:Int)->())? {
        didSet { }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configurationData(_ data: Dictionary<String, Any>?) {
        self.data = data
        ivThumb.layer.cornerRadius = 2.0
        ivThumb.clipsToBounds = true
        ivThumb.contentMode = .scaleAspectFit
        ivThumb.layer.borderColor = RGB(243, 243, 243).cgColor
        ivThumb.layer.borderWidth = 0.5
        
        
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnLike {
            self.didClickedActionClosure?(data, 0)
        }
    }
}
