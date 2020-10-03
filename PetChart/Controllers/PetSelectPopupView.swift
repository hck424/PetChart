//
//  PetSelectPopupView.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/02.
//

import UIKit

class PetSelectPopupView: UIView {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var svContainer: UIStackView!
    var didClickedClosure:((_ selData:Animal?, _ index:Int) ->())? {
        didSet {
            
        }
    }
    var data:Array<Animal>? = nil
    
    func configurationData(_ data:Array<Animal>) {
        self.addShadow(offset: CGSize(width: 3, height: 3), color: RGBA(0, 0, 0, 0.3), raduius: 3, opacity: 0.3)
        bgView.layer.cornerRadius = 20
        bgView.clipsToBounds = true
        
        self.data = data
        var index = 0
        for animal in data {
            let rowView = Bundle.main.loadNibNamed("PetSelectRowView", owner: self, options: nil)?.first as! PetSelectRowView
            svContainer.addArrangedSubview(rowView)
            rowView.btnFull.tag = index
            rowView.btnFull.addTarget(self, action: #selector(onclickedBtnActions(_ :)), for: .touchUpInside)
            
            rowView.ivThumb.layer.cornerRadius = rowView.ivThumb.frame.size.height/2
            rowView.ivThumb.layer.borderWidth = 2.0
            rowView.ivThumb.layer.borderColor = RGB(239, 239, 239).cgColor
            
//            rowView.ivThumb.image =
            rowView.lbPetName.text = animal.name
            index += 1
//            rowView.translatesAutoresizingMaskIntoConstraints = false
//            rowView.heightAnchor.constraint(equalToConstant: 55).isActive = true
        }
    }
    
    @objc func onclickedBtnActions(_ sender: UIButton) {
        let index = sender.tag
        let selAnimal = data?[index]
        didClickedClosure?(selAnimal, index)
    }
}
