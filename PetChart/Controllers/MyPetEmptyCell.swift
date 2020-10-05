//
//  MyPetEmptyCell.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/05.
//

import UIKit

class MyPetEmptyCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 20
        let selBgView = UIView.init()
        selBgView.backgroundColor = UIColor.clear
        self.selectedBackgroundView = selBgView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
