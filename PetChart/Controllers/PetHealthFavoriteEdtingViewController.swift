//
//  PetHealthFavoriteEdtingViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/02.
//

import UIKit
enum CategoryType:Int {
    case graphHome
    case chartSmart
    case chartToal
}

class PetHealthFavoriteEdtingViewController: BaseViewController {
    
    @IBOutlet weak var tblView: UITableView!
    var catergory: CategoryType = .graphHome
    var data:Array<PetHealth>?
    var tblData: NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        var vcTitle = ""
        if catergory == .graphHome {
            vcTitle = "즐겨찾기 편집"
        }
        else if catergory == .chartSmart {
            vcTitle = "스마트차트 설정"
        }
        else if catergory == .chartToal {
            vcTitle = "전체차트 설정"
        }
        CNavigationBar.drawTitle(self, vcTitle, nil)
        
        self.tblView.delegate = self
        self.tblView.dataSource = self
        
        let footerView = UIView()
        tblView.tableFooterView = footerView
        
        self.makeTblData()
        self.tblView.reloadData()
    }
    
    func makeTblData() {
        guard let data = data else {
            return
        }
        
        let dfs = UserDefaults.standard
        for type in data {
            let item: NSMutableDictionary = NSMutableDictionary()
            item["type"] = type
            if catergory == .graphHome {
                if type == .drink {
                    item["key"] = kDrink
                    if dfs.object(forKey: kDrink) != nil {
                        item["selected"] = true
                    }
                }
                else if type == .eat {
                    item["key"] = kEat
                    if dfs.object(forKey: kEat) != nil {
                        item["selected"] = true
                    }
                }
                else if type == .weight {
                    item["key"] = kWeight
                    if dfs.object(forKey: kWeight) != nil {
                        item["selected"] = true
                    }
                }
                else if type == .feces {
                    item["key"] = kFeces
                    if dfs.object(forKey: kFeces) != nil {
                        item["selected"] = true
                    }
                }
                else if type == .walk {
                    item["key"] = kWalk
                    if dfs.object(forKey: kWalk) != nil {
                        item["selected"] = true
                    }
                }
                else if type == .medical {
                    item["key"] = kMedical
                    if dfs.object(forKey: kMedical) != nil {
                        item["selected"] = true
                    }
                }
                tblData.add(item)
            }
            else if catergory == .chartSmart {
                if type == .drink {
                    item["key"] = kSmartChartDrink
                    if dfs.object(forKey: kSmartChartDrink) != nil {
                        item["selected"] = true
                    }
                }
                else if type == .eat {
                    item["key"] = kSmartChartEat
                    if dfs.object(forKey: kSmartChartEat) != nil {
                        item["selected"] = true
                    }
                }
                tblData.add(item)
            }
            else if catergory == .chartToal {
                if type == .drink {
                    item["key"] = kTotalChartDrink
                    if dfs.object(forKey: kTotalChartDrink) != nil {
                        item["selected"] = true
                    }
                }
                else if type == .eat {
                    item["key"] = kTotalChartEat
                    if dfs.object(forKey: kTotalChartEat) != nil {
                        item["selected"] = true
                    }
                }
                else if type == .weight {
                    item["key"] = kTotalChartWeight
                    if dfs.object(forKey: kTotalChartWeight) != nil {
                        item["selected"] = true
                    }
                }
                else if type == .feces {
                    item["key"] = kTotalChartFeces
                    if dfs.object(forKey: kTotalChartFeces) != nil {
                        item["selected"] = true
                    }
                }
                else if type == .walk {
                    item["key"] = kTotalChartWalk
                    if dfs.object(forKey: kTotalChartWalk) != nil {
                        item["selected"] = true
                    }
                }
                else if type == .medical {
                    item["key"] = kTotalChartMedical
                    if dfs.object(forKey: kTotalChartMedical) != nil {
                        item["selected"] = true
                    }
                }
                tblData.add(item)
            }
        }
    }
    
    func saveUserDefalutData(_ data: Dictionary<String, Any>, _ selected: Bool) {
        guard let type = data["type"] else {
            return
        }
        guard let key = data["key"]  else {
            return
        }
        if let _ = type as? PetHealth, let key = key as? String {
            let dfs = UserDefaults.standard
            if selected {
                dfs.setValue("Y", forKey: key)
            }
            else {
                dfs.removeObject(forKey: key)
            }
            dfs.synchronize()
        }
    }
}

extension PetHealthFavoriteEdtingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tblData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "PetHealthFavoriteCell") as? PetHealthFavoriteCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("PetHealthFavoriteCell", owner: self, options: nil)?.first as? PetHealthFavoriteCell
        }
        
        let item = tblData[indexPath.row]
        cell?.confifurationData(item as! Dictionary<String, Any>)
        cell?.didClickedClourse = ({(selData: Dictionary<String, Any>? , selected:Bool) -> () in
            if let selData = selData {
                self.saveUserDefalutData(selData, selected)
            }
            
        })
        return cell!
    }
    
    
}
