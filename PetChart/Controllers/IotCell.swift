//
//  IotCell.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/05.
//

import UIKit

class IotCell: UITableViewCell {

    @IBOutlet weak var ivIotThumb: UIImageView!
    @IBOutlet weak var lbIotName: UILabel!
    @IBOutlet weak var lbIotModel: UILabel!
    @IBOutlet weak var lbIotState: UILabel!
    @IBOutlet weak var btnIotSetting: UIButton!
    @IBOutlet weak var bgView: UIView!
    
    var data: Dictionary<String, Any>?
    var didClickedClosure:((_ selData:Dictionary<String, Any>?, _ actionIndex:Int) ->())? {
        didSet {
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        let view = UIView.init()
        view.backgroundColor = UIColor.clear
        self.selectedBackgroundView = view
        bgView.layer.cornerRadius = 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configurationData(_ data: Dictionary<String, Any>?) {
        self.data = data
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnIotSetting {
            didClickedClosure?(data, 0)
        }
    }
}
