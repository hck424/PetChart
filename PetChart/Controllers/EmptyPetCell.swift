//
//  EmptyPetCell.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/01.
//

import UIKit

class EmptyPetCell: UIView {

    var didSelectedClosure:((_ selData:Any?, _ index:Int) ->())? {
        didSet {
//            self.selIndex = didSelectedItemWithClosure!.selIndex
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }

    @IBAction func actionAddPet(_ sender: UIButton) {
        self.didSelectedClosure?(nil, 0)
    }
    
    class func initWithFromNib() -> EmptyPetCell {
        let xib: EmptyPetCell =  Bundle.main.loadNibNamed("EmptyPetCell", owner: nil, options: nil)?.first as! EmptyPetCell
        return xib
    }
}
