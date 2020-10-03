//
//  ChartDetailViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/03.
//

import UIKit

class ChartDetailViewController: BaseViewController {
    @IBOutlet weak var vwBgContainer: UIView!
    @IBOutlet weak var lbGraphTitle: UILabel!
    @IBOutlet weak var lbTypeTitle: UILabel!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var svGraph: UIStackView!
    
    @IBOutlet weak var lbMsg: UILabel!
    @IBOutlet weak var lbBottomTitle: UILabel!
    @IBOutlet weak var lbBottomMsg: UILabel!
    @IBOutlet weak var btnOtherChart: UIButton!
    @IBOutlet weak var btnOtherPet: UIButton!
    @IBOutlet weak var btnSafety: UIButton!
   
    var graphType: GraphType = .day
    var type: PetHealth = .eat
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawTitle(self, "차트 상세", nil)
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        
        vwBgContainer.layer.cornerRadius = 20
        vwBgContainer.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: true, BR: true)
        
        if Utility.isIphoneX() == false {
            btnSafety.isHidden = true
        }
        
        lbTypeTitle.text = type.koreanValue()
        svGraph.isLayoutMarginsRelativeArrangement = true
        svGraph.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 20)
        self.view.layoutIfNeeded()
        
        let graph = GraphView.initWithFromNib()
        svGraph.addArrangedSubview(graph)
        if graphType == .day {
            lbGraphTitle.text = "일간 그래프"
        }
        else if graphType == .week  {
            lbGraphTitle.text = "주간 그래프"
        }
        else if graphType == .month {
            lbGraphTitle.text = "년간 그래프"
        }
        graph.colorSeperator = RGB(217, 217, 217)
        graph.colorTextColor = RGB(136, 136, 136)
        graph.colorBackground = UIColor.clear
        graph.configurationGraph(type: graphType, colorGraph: RGB(87, 97, 125), data: nil)
        
        self.view.layoutIfNeeded()
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnShare {
            
        }
        else if sender == btnOtherPet {
            //커뮤니티 방으로 이동
            
        }
        else if sender == btnOtherChart {
            
            SharedData.instance.arrType.remove(type)
            if SharedData.instance.arrType.count == 0 {
                AlertView.showWithCancelAndOk(title: "차트", message: "차트를 다보았습니다.\n이페이지 나가시겠습니까?") { (index) in
                    if index == 1 {
                        let vcs:Array = self.navigationController!.viewControllers as Array
                        var findIndex:Int = 0
                        for index in stride(from: vcs.count-1, to: 0, by: -1) {
                            let vc = vcs[index]
                            if vc.isKind(of: self.classForCoder) == false {
                                findIndex = index
                                break
                            }
                        }
                        self.navigationController?.popToViewController(vcs[findIndex], animated: true)
                    }
                }
            }
            else {
                let vc = ChartDetailViewController.init()
                vc.graphType = graphType
                vc.type = (SharedData.instance.arrType.firstObject as? PetHealth)!
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
    }
}
