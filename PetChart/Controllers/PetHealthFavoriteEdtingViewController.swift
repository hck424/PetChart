//
//  PetHealthFavoriteEdtingViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/02.
//

import UIKit

class PetHealthFavoriteEdtingViewController: BaseViewController {

    @IBOutlet weak var tblView: UITableView!
    var arrData:Array<AnyObject> = Array<AnyObject>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "즐겨찾기 편집", nil)

        self.tblView.delegate = self
        self.tblView.dataSource = self
        
        let footerView = UIView()
        tblView.tableFooterView = footerView
        
        self.makeTblData()
        self.tblView.reloadData()
    }
    
    func makeTblData() {
        let dfs = UserDefaults.standard
        
        var item: NSMutableDictionary = NSMutableDictionary()
        item["type"] = PetHealth.drink
        if dfs.object(forKey: kDrink) != nil {
            item["selected"] = true
        }
        arrData.append(item)
        
        item = NSMutableDictionary()
        item["type"] = PetHealth.eat
        if dfs.object(forKey: kEat) != nil {
            item["selected"] = true
        }
        arrData.append(item)
        
        
        item = NSMutableDictionary()
        item["type"] = PetHealth.weight
        if dfs.object(forKey: kWeight) != nil {
            item["selected"] = true
        }
        arrData.append(item)
        
        item = NSMutableDictionary()
        item["type"] = PetHealth.feces
        if dfs.object(forKey: kFeces) != nil {
            item["selected"] = true
        }
        arrData.append(item)
        
        item = NSMutableDictionary()
        item["type"] = PetHealth.walk
        if dfs.object(forKey: kWalk) != nil {
            item["selected"] = true
        }
        arrData.append(item)
        
        item = NSMutableDictionary()
        item["type"] = PetHealth.medical
        if dfs.object(forKey: kMedical) != nil {
            item["selected"] = true
        }
        arrData.append(item)
    }
}

extension PetHealthFavoriteEdtingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "PetHealthFavoriteCell") as? PetHealthFavoriteCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("PetHealthFavoriteCell", owner: self, options: nil)?.first as? PetHealthFavoriteCell
        }
        
        let item = arrData[indexPath.row]
        cell?.confifurationData(item as! Dictionary<String, Any>)
        
        return cell!
    }
    
    
}
