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
    
    var animal: Animal?
    var didClickedActionClosure:((_ selData:Animal?, _ actionIndex:Int) -> ())? {
        didSet {
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 20
        bgView.backgroundColor = UIColor.white
        
        ivProfile.layer.cornerRadius = ivProfile.bounds.height/2
        ivProfile.layer.borderWidth = 1.5
        ivProfile.layer.borderColor = RGB(239, 239, 239).cgColor
        
        let selBgView = UIView.init()
        selBgView.backgroundColor = UIColor.clear
        self.selectedBackgroundView = selBgView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configurationData(_ animal: Animal? ) {
        self.animal = animal
        lbUserName.text = ""
        lbPetInfo.text = ""
        
        if let petName = animal?.petName {
            lbUserName.text = petName
        }
        if let is_main = animal?.is_main, is_main == "Y" {
            btnMain.isSelected = true
        }
        else {
            btnMain.isSelected = false
        }
        
        if let sex = animal?.sex, let kind = animal?.kind, let size = animal?.size {
            var tmpStr = ""
            if kind.isEmpty == false {
                tmpStr.append("\(kind)")
            }
            else if size.isEmpty == false {
                tmpStr.append("\(size)")
            }
            
            if sex == "M" {
                tmpStr.append(" / 숫컷")
            }
            else {
                tmpStr.append(" / 암컷")
            }
            
            lbPetInfo.text = tmpStr
        }
        
        if let images = animal?.images, let imgInfo = images.first, let original = imgInfo.original {
            ivProfile.setImageCache(url: original, placeholderImgName: nil)
        }
    }
    
    @IBAction func onClickedButtonActions(_ sender: UIButton) {
        if sender == btnMain {
            if let is_main = animal?.is_main, is_main == "Y" {
                animal?.is_main = "N"
            }
            else {
                animal?.is_main = "Y"
            }
            self.didClickedActionClosure?(animal, 1)
        }
        else if sender == btnSetting {
            self.didClickedActionClosure?(animal, 2)
        }
    }
}
