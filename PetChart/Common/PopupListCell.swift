//
//  PopupListCell.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/02.
//

import UIKit

class PopupListCell: UITableViewCell {
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var ivThumb: UIImageView!
    @IBOutlet weak var heightThumb: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let view = UIView()
        view.backgroundColor = RGBA(233, 95, 94, 0.2)
        self.selectedBackgroundView = view
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
