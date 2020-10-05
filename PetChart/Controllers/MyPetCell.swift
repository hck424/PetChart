//
//  MyPetCell.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/05.
//

import UIKit

class MyPetCell: UITableViewCell {

    @IBOutlet weak var btnMain: UIButton!
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var lbUserName: UILabel!
    @IBOutlet weak var lbPetInfo: UILabel!
    @IBOutlet weak var btnSetting: UIButton!
    @IBOutlet weak var bgView: UIView!
    
    var data: Dictionary<String, Any>?
    var didClickedActionClosure:((_ selData:Dictionary<String, Any>?, _ actionIndex:Int) -> ())? {
        didSet {
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 20
        bgView.backgroundColor = UIColor.white
        
        ivProfile.layer.cornerRadius = ivProfile.bounds.height/2
        ivProfile.layer.borderWidth = 2
        ivProfile.layer.borderColor = RGB(239, 239, 239).cgColor
        
        let selBgView = UIView.init()
        selBgView.backgroundColor = UIColor.clear
        self.selectedBackgroundView = selBgView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configurationData(_ data: Dictionary<String, Any>? ) {
        self.data = data
        lbUserName.text = ""
        lbPetInfo.text = ""
        
        if let userName = data?["userName"] as? String {
            lbUserName.text = userName
        }
        
        if let petName = (data?["petName"] as? String) ?? "", let animalGender = (data?["animalGender"] as? String) ?? "" {
            var tmpStr = ""
            if animalGender == "M" {
                tmpStr = "숫컷"
            }
            else if animalGender == "W"{
                tmpStr = "암컷"
            }
            lbPetInfo.text = "\(petName)/\(tmpStr)"
        }
    }
    @IBAction func onClickedButtonActions(_ sender: UIButton) {
        if sender == btnMain {
            sender.isSelected = !sender.isSelected
            //TODO:: userdefault save
            self.didClickedActionClosure?(data, 1)
        }
        else if sender == btnSetting {
            self.didClickedActionClosure?(data, 2)
        }
    }
}
