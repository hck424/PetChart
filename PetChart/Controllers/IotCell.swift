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
    
    var data:[String:Any]?
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
    
    func configurationData(_ data:[String:Any]?) {
        self.data = data
        
        lbIotName.text = ""
        lbIotModel.text = "펫차트 스마트 식기"
        lbIotState.text = ""
        
        guard let data = data else {
            return
        }
        
        if let name = data["name"] as? String, name.isEmpty == false {
            lbIotName.text = name
        }
        
        if let model = data["model"] as? String, model.isEmpty == false {
            lbIotModel.text = "\(model)"
        }
        
        if let state = data["state"] as? String, state == "run" {
            lbIotState.text = "연결 중"
            lbIotState.textColor = RGB(51, 150, 254)
        }
        else {
            lbIotState.text = "연결안됨"
            lbIotState.textColor = RGB(136, 136, 136)
        }
        
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnIotSetting {
            didClickedClosure?(data, 0)
        }
    }
}
