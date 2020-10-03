//
//  ChartCellView.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/03.
//

import UIKit

class ChartCellView: UIView {
    
    @IBOutlet weak var btnMark: UIButton!
    @IBOutlet weak var vwGraph: UIView!
    @IBOutlet weak var svGraph: UIStackView!
    
    var data:Dictionary<String, Any>? = nil
    var type:PetHealth = .drink
    var category:String? = nil
    var graph:GraphView? = nil
    
    var didClickedClosure:((_ selDate: Any?, _ category: String?, _ type:PetHealth, _ index:Int) -> ())? {
        didSet {
        }
    }
    
    func configurationData(category: String?, type: PetHealth, data:Dictionary<String, Any>?) {
        self.data = data
        self.type = type
        self.category = category
        
        let ivMark = btnMark.viewWithTag(1)
        if let ivMark = ivMark as? UIImageView {
            if let imgMark = type.markImage() {
                ivMark.image = imgMark
            }
            else {
                ivMark.image = nil
            }
        }
        
        var color = UIColor.black
        if let ccolor = type.colorType() {
            color = ccolor
        }
        
        let lbMark = btnMark.viewWithTag(2)
        if let lbMark = lbMark as? UILabel {
            lbMark.text = type.koreanValue()
            lbMark.textColor = color
        }
        
        if graph == nil {
            for subview in svGraph.subviews {
                subview.removeFromSuperview()
            }
            graph = GraphView.initWithFromNib()
            svGraph.addArrangedSubview(graph!)
        }
        graph?.configurationGraph(type: .day, colorGraph: color, data: nil);
        
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnMark {
            didClickedClosure?(data, category, type, 0)
        }
    }
}
