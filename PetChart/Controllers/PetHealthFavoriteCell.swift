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
        let dfs = UserDefaults.standard
        
        let type:PetHealth = (data!["type"] as? PetHealth)!
        if sender.isSelected {
            if type == .drink {
                dfs.setValue(true, forKey: kDrink)
            }
            else if type == .eat {
                dfs.setValue(true, forKey: kEat)
            }
            else if type == .weight {
                dfs.setValue(true, forKey: kWeight)
            }
            else if type == .feces {
                dfs.setValue(true, forKey: kFeces)
            }
            else if type == .walk  {
                dfs.setValue(true, forKey: kWalk)
            }
            else if type == .medical {
                dfs.setValue(true, forKey: kMedical)
            }
        }
        else {
            if type == .drink {
                dfs.removeObject(forKey: kDrink)
            }
            else if type == .eat {
                dfs.removeObject(forKey: kEat)
            }
            else if type == .weight {
                dfs.removeObject(forKey: kWeight)
            }
            else if type == .feces {
                dfs.removeObject(forKey: kFeces)
            }
            else if type == .walk  {
                dfs.removeObject(forKey: kWalk)
            }
            else if type == .medical {
                dfs.removeObject(forKey: kMedical)
            }
        }
        dfs.synchronize()
    }
}
