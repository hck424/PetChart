//
//  MyPetViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/05.
//

import UIKit

class MyPetViewController: BaseViewController {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var btnAddPet: CButton!
    
    var arrMyPet: NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "내 반려동물", nil)
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tblView.bounds.width, height: 16))
        headerView.backgroundColor = UIColor.clear
        tblView.tableHeaderView = headerView
        tblView.tableFooterView = footerView
        
        self.makeTestData()
        tblView.reloadData()
    }
    
    func requestMypetList() {
        
    }
    
    func makeTestData() {
        var itemDic = NSMutableDictionary()
        itemDic["userName"] = "레오"
        itemDic["petName"] = "비숑프리제"
        itemDic["animalGender"] = "M"
        arrMyPet.add(itemDic)

        itemDic = NSMutableDictionary()
        itemDic["userName"] = "우리"
        itemDic["petName"] = "렉돌"
        itemDic["animalGender"] = "W"
        arrMyPet.add(itemDic)
    }
    @IBAction func onClickedButtonActions(_ sender: UIButton) {
        if sender == btnAddPet {
            let vc = AddAnimalNameViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension MyPetViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrMyPet.count > 0 {
            return arrMyPet.count
        }
        else {
            return 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if arrMyPet.count > 0 {
            var myPetCell = tableView.dequeueReusableCell(withIdentifier: "MyPetCell") as? MyPetCell
            if myPetCell == nil {
                myPetCell = Bundle.main.loadNibNamed("MyPetCell", owner: self, options: nil)?.first as? MyPetCell
            }
            
            let itemDic = arrMyPet[indexPath.row] as? Dictionary<String, Any>
            myPetCell?.configurationData(itemDic)
            myPetCell?.didClickedActionClosure = ({(selData, actionIndex) ->() in
                if selData != nil {
                    if actionIndex == 1 {
                        //TODO:: 메인노출 액션
                    }
                    else if actionIndex == 2 {
                        let vc = AnimalModifyInfoViewController.init()
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            })
            cell = myPetCell
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "MyPetEmptyCell") as? MyPetEmptyCell
            if cell == nil {
                cell = Bundle.main.loadNibNamed("MyPetEmptyCell", owner: self, options: nil)?.first as? MyPetEmptyCell
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tblView.deselectRow(at: indexPath, animated: false)
    }
}
