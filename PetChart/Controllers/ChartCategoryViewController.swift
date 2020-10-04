//
//  ChartCategoryViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/03.
//

import UIKit

class ChartCategoryViewController: BaseViewController {
    @IBOutlet weak var vwBgContainer: UIView!
    @IBOutlet weak var lbYearMonth: UILabel!
    @IBOutlet var arrSvTopWeekDay: [UIStackView]!
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var btnDetail: UIButton!
    @IBOutlet weak var btnSafety: UIButton!
    
    @IBOutlet weak var btnMark: UIButton!
    @IBOutlet weak var btnDay: UIButton!
    @IBOutlet weak var btnWeek: UIButton!
    @IBOutlet weak var btnMonth: UIButton!
    
    @IBOutlet weak var vwGraph: UIView!
    @IBOutlet weak var svGraph: UIStackView!
    
    let TAG_UNDER_LINE: Int = 1234567
    
    var vcTitle:String?
    var type:PetHealth?
    var data: Dictionary<String, Any>?
    var graphType: GraphType = .day
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var title = ""
        if let tt = vcTitle {
            title = tt
        }
        CNavigationBar.drawTitle(self, title, nil)
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        
        vwBgContainer.layer.cornerRadius = 20
        vwBgContainer.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        vwGraph.layer.borderWidth = 1.0
        vwGraph.layer.borderColor = RGB(239, 239, 239).cgColor
        
        if Utility.isIphoneX() == false {
            btnSafety.isHidden = true
        }
        arrSvTopWeekDay = arrSvTopWeekDay.sorted(by: { (sv1, sv2) -> Bool in
            return sv1.tag < sv2.tag
        })
        
        self.underLineSelected(btnDay)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configurationUI()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func configurationUI() {
        btnMark.setImage(type?.markImage(), for: .normal)
        btnMark.setTitle(type?.koreanValue(), for: .normal)
        
        var graphColor = type?.colorType()
        if graphColor == nil {
            graphColor = UIColor.black
        }
    
        let curDate = Date()
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.locale = Locale.init(identifier: "ko_KR")
        let arrDays = calendar.daysWithSameWeekOfYear(as: curDate)
        
        let df = CDateFormatter()
        df.dateFormat = "yyyy.MM"
        let strYearMonth = df.string(from: curDate)
        lbYearMonth.text = strYearMonth
        
        //top 날짜 매핑
        for i in 0..<arrDays.count {
            let day = arrDays[i]
            //stackview 에서 tag로 찾아 데이터 매핑
            var findStackView: UIStackView? = nil
            for svTop in arrSvTopWeekDay  {
                if svTop.tag == i+1 {
                    findStackView = svTop
                    break
                }
            }
            
            if let svTop = findStackView {
                if let btnDay = svTop.viewWithTag(2) as? UIButton {
                    let strTitle = String(format: "%02d", day.getDay())
                    btnDay.setTitle(strTitle, for: .normal)
                    btnDay.setTitleColor(UIColor.black, for: .normal)
                    btnDay.titleLabel?.font = UIFont.systemFont(ofSize: (btnDay.titleLabel?.font.pointSize)!, weight: .regular)
                    
                    btnDay.setBackgroundImage(nil, for: .normal)
                    
                    if day.getMonth() == curDate.getMonth()
                        && day.getDay() == curDate.getDay() {
                        btnDay.titleLabel?.font = UIFont.systemFont(ofSize: (btnDay.titleLabel?.font.pointSize)!, weight: .bold)
                        btnDay.setTitleColor(ColorDefault, for: .normal)
                        btnDay.setBackgroundImage(UIImage(named: "circle_curent_day"), for: .normal)
                    }
                }
            }
        }
        
        
        //그래프 그리기
        for subview in svGraph.subviews {
            subview.removeFromSuperview()
        }
        let graph = GraphView.initWithFromNib()
        svGraph.addArrangedSubview(graph)
        
        if graphType == .day {
            graph.configurationGraph(type: .day, colorGraph: graphColor, data: nil)
        }
        else if graphType == .week {
            graph.configurationGraph(type: .week, colorGraph: graphColor, data: nil)
        }
        else if graphType == .month {
            graph.configurationGraph(type: .month, colorGraph: graphColor, data: nil)
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnDay {
            graphType = .day
            self.configurationUI()
            self.underLineSelected(sender)
        }
        else if sender == btnWeek {
            graphType = .week
            self.configurationUI()
            self.underLineSelected(sender)
        }
        else if sender == btnMonth {
            graphType = .month
            self.configurationUI()
            self.underLineSelected(sender)
        }
        else if sender == btnDetail {
            
            SharedData.instance.arrType.addObjects(from: [PetHealth.drink, PetHealth.eat, PetHealth.weight, PetHealth.feces, PetHealth.walk, PetHealth.medical])
            
            let vc = ChartDetailViewController.init(nibName: "ChartDetailViewController", bundle: nil)
            vc.graphType = graphType
            vc.type = type!
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnRecord {
            var vc: UIViewController? = nil
            if type == .drink {
                vc = ChartRecordDrinkViewController.init()
            }
            else if type == .eat {
                vc = ChartRecordEatViewController.init()
            }
            else if type == .weight {
                vc = ChartRecordWeightViewController.init()
            }
            else if type == .feces {
                vc = ChartRecordFecesViewController.init()
            }
            else if type == .walk {
                vc = ChartRecordWalkViewController.init()
            }
            else if type == .medical {
                vc = ChartRecordMedicalViewController.init()
            }
            
            if let vc = vc  {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func removeUnderlineView(_ sender: UIButton) {
        if let view = sender.viewWithTag(TAG_UNDER_LINE) {
            view.removeFromSuperview()
        }
        sender.titleLabel?.font = UIFont.systemFont(ofSize: sender.titleLabel?.font.pointSize ?? 15, weight: .regular)
        sender.setTitleColor(RGB(145, 145, 145), for: .normal)
    }
    func underLineSelected(_ sender: UIButton) {
        self.removeUnderlineView(btnDay)
        self.removeUnderlineView(btnWeek)
        self.removeUnderlineView(btnMonth)
        
        let underline = UIView.init(frame: CGRect(x: (sender.bounds.width - 20)/2, y: sender.bounds.height/2 + 3, width: 20, height: 8))
        underline.backgroundColor = RGBA(233, 95, 94, 0.5)
        underline.tag = TAG_UNDER_LINE
        sender.addSubview(underline)
        
        sender.titleLabel?.font = UIFont.systemFont(ofSize: sender.titleLabel?.font.pointSize ?? 15, weight: .bold)
        sender.setTitleColor(UIColor.black, for: .normal)
    }
}
