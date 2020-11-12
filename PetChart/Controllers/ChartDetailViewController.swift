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
    @IBOutlet weak var lbAppropriate: UILabel!
    
    let df = CDateFormatter.init()
    var calendar = Calendar.init(identifier: .gregorian)
    
    var graphType: GraphType = .day
    var type: PetHealth = .eat
    var arrChart:[[String:Any]] = [[String:Any]]()
    var arrPickupGraph:[[String:Any]] = [[String:Any]]()
    var maxValue: Int = 0
    var graph: GraphView?
    
    let endDate:Date = Date()
    let healths:[PetHealth] = [.drink, .eat, .weight, .feces, .walk]
    var roopIndex: Int = 0
    var dataDic:[String:Any] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawTitle(self, "차트 상세", nil)
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        calendar.locale = Locale.init(identifier: "ko_KR")
        vwBgContainer.layer.cornerRadius = 20
        vwBgContainer.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: true, BR: true)
        
        if Utility.isIphoneX() == false {
            btnSafety.isHidden = true
        }
        
        lbTypeTitle.text = type.koreanValue()
        svGraph.isLayoutMarginsRelativeArrangement = true
        svGraph.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 20)
        self.view.layoutIfNeeded()
        
        self.graph = GraphView.initWithFromNib()
        svGraph.addArrangedSubview(graph!)
        if graphType == .day {
            lbGraphTitle.text = "일간 그래프"
        }
        else if graphType == .week  {
            lbGraphTitle.text = "주간 그래프"
        }
        else if graphType == .month {
            lbGraphTitle.text = "년간 그래프"
        }
        
        graph?.colorSeperator = RGB(217, 217, 217)
        graph?.colorTextColor = RGB(136, 136, 136)
        graph?.colorBackground = UIColor.clear
        graph?.configurationGraph(type: graphType, colorGraph: RGB(87, 97, 125))
        
        self.view.layoutIfNeeded()
        btnOtherChart.sendActions(for: .touchUpInside)
    }
    
    func requestChartData(from: String, to: String) {
        
        guard let savePetId = UserDefaults.standard.object(forKey: kMainShowPetId) as? Int  else {
            return
        }
        
        ApiManager.shared.requestChartData(health: type, petId: savePetId, type: graphType, stDate:from , edDate: to) { (response) in
            if let response = response as? [String:Any],
               let data = response["data"] as? [String:Any] {
                self.dataDic = data
                self.maxValue = (data["maxValue"] as? Int) ?? 0
                if let charts = data["charts"] as? Array<[String:Any]> {
                    self.arrChart.removeAll()
                    self.arrChart = charts
                    self.configurationUI()
                }
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
        }
    }
    func configurationUI() {
        lbTypeTitle.text = type.koreanValue()
        if arrChart.isEmpty == true {
            return
        }
        let curDate = Date()
        if graphType == .day {
            if let graphData = self.pickupDayGraphDates(count: 5, selDate: endDate, arrData: arrChart) {
                self.arrPickupGraph = graphData
                self.graph?.maxValue = maxValue
                self.graph?.data = graphData
                self.graph?.reloadData()
            }
        }
        else if graphType == .week {
            var index = 0
            self.arrPickupGraph.removeAll()
            var tmpArray:[[String:Any]] = [[String:Any]]()
            for item in arrChart.reversed() {
                if let key = item["key"] as? String {
                    df.dateFormat = "yyyy-MM-dd"
                    if let date = df.date(from: key) {
                        if date < curDate {
                            tmpArray.append(item)
                            index += 1
                        }
                    }
                }
                
                if index > 4 {
                    break;
                }
            }
            self.arrPickupGraph = tmpArray.reversed()
            self.graph?.maxValue = maxValue
            self.graph?.data = arrPickupGraph
            self.graph?.reloadData()
        }
        else if graphType == .month {
            self.arrPickupGraph = arrChart
            self.graph?.maxValue = maxValue
            self.graph?.data = arrPickupGraph
            self.graph?.reloadData()
        }
        
        guard self.arrPickupGraph.isEmpty == false else {
            return
        }
        
        lbMsg.text = ""
        
        guard let petName = SharedData.objectForKey(key: kMainShowPetName) as? String else {
            return
        }
        guard let comparedToPreviousDay = self.dataDic["comparedToPreviousDay"] as? Int else {
            return
        }
//        guard let average = self.dataDic["average"] as? Int else {
//            return
//        }
        guard let appropriate_msg = self.dataDic["appropriate_msg"] as? String else {
            return
        }
        //바탐 메세지
        guard let future_msg = self.dataDic["future_msg"] as? String else {
            lbBottomMsg.text = ""
            return
        }
        
        var tmpStr = "량이"
        if type == .walk {
            tmpStr = "시간이"
        }
        else if type == .medical {
            tmpStr = "가"
        }
        
        var tmpStr2 = "일"
        if graphType == .week {
            tmpStr2 = "주"
        }
        else if graphType == .month {
            tmpStr2 = "월"
        }
        
        var result = "\(petName)의 \(type.koreanValue()!)\(tmpStr)\n전\(tmpStr2) 대비"
        var markStr = ""
        if comparedToPreviousDay > 0 {
            markStr = "\(abs(comparedToPreviousDay))%"
            result.append(" \(markStr) 증가했어요.")
        }
        else if comparedToPreviousDay < 0 {
            markStr = "\(abs(comparedToPreviousDay))%"
            result.append(" \(markStr) 감소했어요.")
        }
        else {
            result.append(" 같습니다.")
        }
        let nsResult = NSString.init(string: result)
        let attr = NSMutableAttributedString.init(string: result)
        attr.addAttribute(.foregroundColor, value: RGB(51, 150, 254), range: NSMakeRange(0, petName.length))
        attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 18.0, weight: .bold), range: NSMakeRange(0, petName.length))
        
        if markStr.isEmpty == false {
            attr.addAttribute(.foregroundColor, value: ColorDefault, range: nsResult.range(of: markStr))
            attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 18.0, weight: .bold), range: nsResult.range(of: markStr))
        }
        
        lbMsg.attributedText = attr
//        let html = "<b>Hello World!</b>"
        let attr1 = try? NSAttributedString.init(htmlString: appropriate_msg)
        lbAppropriate.attributedText = attr1
        
        lbBottomMsg.text = future_msg
    }
    
    func pickupDayGraphDates(count:Int, selDate:Date, arrData:Array<[String:Any]>) -> Array<[String:Any]>? {
        df.dateFormat = "yyyy-MM-dd"
    
        let stDay = selDate.jumpingDay(jumping: -(count-1))!
        let days = datesRange(unit: .day, from: stDay, to: selDate)
        var result:Array<[String:Any]> = Array<[String:Any]>()
        
        for day in days {
            let findDateStr:String = df.string(from: day)
            var isFind = false
            for item in arrData {
                if let key = item["key"] as? String, key == findDateStr {
                    result.append(item)
                    isFind = true
                }
            }
            if isFind == false {
                //create garbage data
                let garbageData:[String:Any] = ["key": findDateStr, "value1": 0, "value2": 0.0, "etc": ""]
                result.append(garbageData)
            }
        }
        return result
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnShare {
            let snapshot:UIImage? = vwBgContainer.snapshot
            let vc = TalkWriteViewController.init()
            vc.snapshot = snapshot
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnOtherPet {
            self.navigationController?.popToRootViewController(animated: true)
            if let mainTabVc: MainTabBarController =  AppDelegate.instance()?.mainTabbarCtrl() {
                mainTabVc.selectedIndex = 2
            }
        }
        else if sender == btnOtherChart {
            
            
            if graphType == .day {
                //서버에서 30개씩 내려준다.
                if let startDate = Date().jumpingDay(jumping: -29) {
                    let from = startDate.stringDateWithFormat("yyyy-MM-dd")
                    let to = endDate.stringDateWithFormat("yyyy-MM-dd")
                    self.requestChartData(from: from, to: to)
                }
            }
            else if graphType == .week {
                graphType = .week
                
                if let stDate = Date().jumpingDay(jumping: -42) {
                    let from = stDate.stringDateWithFormat("yyyy-MM-dd")
                    let to = endDate.stringDateWithFormat("yyyy-MM-dd")
                    self.requestChartData(from: from, to: to)
                }
            }
            else if graphType == .month {
                graphType = .month
                
                //5개월전 .jumpingDay(jumping: -240)!
                var year = endDate.getYear()
                var month = endDate.getMonth()
                let day = endDate.getDay()
                let minusMonth = 4
                if (month - minusMonth) < 1 {
                    year = year - 1
                    month = 12-abs(month-minusMonth)
                }
                else {
                    month = month - minusMonth
                }
                let from = String.init(format: "%04d-%02d-%02d", year, month, day)
                let to = endDate.stringDateWithFormat("yyyy-MM-dd")
                self.requestChartData(from: from, to: to)
            }
            
            roopIndex = healths.firstIndex(of: type)!
            roopIndex += 1
            if roopIndex >= healths.count {
                roopIndex = 0
            }
            self.type = healths[roopIndex]
        }
    }
}

extension ChartDetailViewController: TalkWriteViewControllerDelegate {
    func didfinishWrite(category: String, data: [String : Any]?) {
        print("write ok")
    }
}
