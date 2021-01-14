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
    var maxValue: Float = 1.0
    var average: Float = 0.0
    var graph: GraphView?
    
    var endDate:Date = Date()
    let healths:[PetHealth] = [.drink, .eat, .weight, .feces, .walk]
//    var roopIndex: Int = 0
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
        self.requestData()
    }
    func requestData() {
        if graphType == .day {
            //서버에서 30개씩 내려준다.
            let startDate = endDate.jumpingDay(jumping: -5)
            let from = startDate.stringDateWithFormat("yyyy-MM-dd")
            let to = endDate.stringDateWithFormat("yyyy-MM-dd")
            self.requestChartData(from: from, to: to)
        }
        else if graphType == .week {
            graphType = .week
            let stDate = endDate.jumpingDay(jumping: -35)
            let from = stDate.stringDateWithFormat("yyyy-MM-dd")
            let to = endDate.stringDateWithFormat("yyyy-MM-dd")
            self.requestChartData(from: from, to: to)
        }
        else if graphType == .month {
            graphType = .month
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
    }
    func requestChartData(from: String, to: String) {
        
        guard let savePetId = UserDefaults.standard.object(forKey: kMainShowPetId) as? Int  else {
            return
        }
        
        ApiManager.shared.requestChartData(health: type, petId: savePetId, type: graphType, stDate:from , edDate: to) { (response) in
            if let response = response as? [String:Any],
               let data = response["data"] as? [String:Any] {
                self.dataDic = data
                if let maxValue = data["maxValue"] as? NSNumber {
                    self.maxValue = maxValue.floatValue
                }
                if let average = data["average"] as? NSNumber {
                    self.average =  average.floatValue
                }
                print("maxvalue: \(self.maxValue)")
                print("average: \(self.average)")
                
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
//        let curDate = Date()
        graph?.healthType = type
        graph?.showAverage = true
        
        if graphType == .day {
            if let graphData = self.pickupDayGraphDates(count: 5, selDate: endDate, arrData: arrChart) {
                self.arrPickupGraph = graphData
                self.graph?.maxValue = maxValue
                self.graph?.data = graphData
                self.graph?.edDate = endDate
                self.graph?.average = average
                self.graph?.reloadData()
            }
        }
        else if graphType == .week {
            var index = 0
            self.arrPickupGraph.removeAll()
//            var tmpArray:[[String:Any]] = [[String:Any]]()
            for item in arrChart {
                self.arrPickupGraph.append(item)
                index += 1
                if index > 4 {
                    break;
                }
            }
            self.graph?.maxValue = maxValue
            self.graph?.data = arrPickupGraph
            self.graph?.edDate = endDate
            self.graph?.average = average
            self.graph?.reloadData()
        }
        else if graphType == .month {
            self.arrPickupGraph = arrChart
            self.graph?.maxValue = maxValue
            self.graph?.data = arrPickupGraph
            self.graph?.average = average
            self.graph?.edDate = endDate
            self.graph?.reloadData()
        }
        
        guard self.arrPickupGraph.isEmpty == false else {
            return
        }
        
        lbMsg.text = ""
        
        guard let petName = SharedData.objectForKey(key: kMainShowPetName) as? String else {
            return
        }
//        guard var comparedToPreviousDay:Float = self.dataDic["comparedToPreviousDay"] as? Float else {
//            return
//        }
//        guard let appropriate_msg = self.dataDic["appropriate_msg"] as? String else {
//            return
//        }
        //바탐 메세지
//        guard let future_msg = self.dataDic["future_msg"] as? String else {
//            lbBottomMsg.text = ""
//            return
//        }
        
        var tmpStr = "량이"
        if type == .walk {
            tmpStr = "시간이"
        }
        else if type == .feces {
            tmpStr = "횟수가"
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
        
        var todayValue: Float = 0.0
        var preValue : Float = 0.0
        if graphType == .day || graphType == .month {
            if let todayDic = arrPickupGraph.last, let value = todayDic["value1"] as? NSNumber  {
                todayValue = value.floatValue
            }
            if let preDic = arrPickupGraph[arrPickupGraph.count-2] as? [String:Any], let value1 = preDic["value1"] as? NSNumber {
                preValue = value1.floatValue
            }
        }
        else if graphType == .week {
            var calendar = Calendar.init(identifier: .gregorian)
            calendar.locale = Locale.init(identifier: "ko_KR")
            let componets = calendar.dateComponents([.month, .weekdayOrdinal, .weekOfYear, .weekOfMonth], from: endDate)
            let week:Int = componets.weekdayOrdinal ?? 1
            if let todayDic = arrPickupGraph[week-1] as? [String:Any], let value = todayDic["value1"] as? NSNumber  {
                todayValue = value.floatValue
            }
            if week > 1 {
                if let preDic = arrPickupGraph[week-2] as? [String:Any], let value1 = preDic["value1"] as? NSNumber {
                    preValue = value1.floatValue
                }
            }
        }
  
//        오늘-전일 / 전일 * 100
        var result = "\(petName)의 \(type.koreanValue()!)\(tmpStr)\n"
        
        var markStr = ""
        if preValue > 0 {
            result.append("전\(tmpStr2) 대비")
            let percent = ((todayValue - preValue)/preValue) * 100
            
            if percent > 0 {
                markStr = "\(Utility.numberToString(num: percent))%"
                result.append(" \(markStr) 증가했어요.")
            }
            else if percent < 0 {
                markStr = "\(Utility.numberToString(num: abs(percent)))%"
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
        }
        else {
            markStr = "전\(tmpStr2) 데이터가 존재하지 않습니다."
            result.append(markStr)
            
            let attr = NSMutableAttributedString.init(string: result)
            attr.addAttribute(.foregroundColor, value: RGB(51, 150, 254), range: NSMakeRange(0, petName.length))
            attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 18.0, weight: .bold), range: NSMakeRange(0, petName.length))
            lbMsg.attributedText = attr
        }
        if let appropriate_msg = self.dataDic["appropriate_msg"] as? String {
            print("\(appropriate_msg)")
            let attr1 = try? NSMutableAttributedString.init(htmlString: appropriate_msg)
            if let attr1 = attr1 {
                attr1.addAttribute(.font, value: lbAppropriate.font!, range: NSRange(location: 0, length: attr1.string.length))
                lbAppropriate.attributedText = attr1
            }
        }
        if let future_msg = self.dataDic["future_msg"] as? String {
            lbBottomMsg.text = future_msg
        }
    }
    
    func pickupDayGraphDates(count:Int, selDate:Date, arrData:Array<[String:Any]>) -> Array<[String:Any]>? {
        df.dateFormat = "yyyy-MM-dd"
    
        let stDay = selDate.jumpingDay(jumping: -(count-1))
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
            self.view.layoutIfNeeded()
            DispatchQueue.main.async {
                guard let mainTabCtrl = AppDelegate.instance()?.mainTabbarCtrl() else {
                    return
                }
                mainTabCtrl.selectedIndex = 2
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) { [self] in
                    let snapshot:UIImage = self.vwBgContainer.snapshot
                    mainTabCtrl.communityVc.gotoTalkWriteVc(snapshot)
                }
            }
            self.navigationController?.popToRootViewController(animated: false)
        }
        else if sender == btnOtherPet {
            self.navigationController?.popToRootViewController(animated: false)
            AppDelegate.instance()?.mainTabbarCtrl()?.changeTabMenuIndex(2, 4)
            
        }
        else if sender == btnOtherChart {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
