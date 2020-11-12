//
//  MyPetViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/05.
//

import UIKit
import Toast_Swift

class MyPetViewController: BaseViewController {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var btnAddPet: CButton!
    
    var arrMyPet:Array<Animal>?
    var selAnimal:Animal?
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "내 반려동물", nil)
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tblView.bounds.width, height: 16))
        headerView.backgroundColor = UIColor.clear
        tblView.tableHeaderView = headerView
        tblView.tableFooterView = footerView
        
        self.requestMypetList()
    }
    
    func requestMypetList() {
        ApiManager.shared.requestMyPetList { (response) in
            if let response = response as?[String:Any],
               let data = response["data"] as? [String:Any],
               let pets = data["pets"] as? Array<[String:Any]> {
                if pets.isEmpty == false {
                    self.arrMyPet = Array<Animal>()
                    for pet in pets {
                        let animal:Animal = Animal.init(JSON: pet)!
                        self.arrMyPet?.append(animal)
                    }
                }
                else {
                    self.arrMyPet = nil
                }
            }
            else {
                self.arrMyPet = nil
                self.showErrorAlertView(response)
            }
            self.tblView.reloadData()
        } failure: { (error) in
            self.showErrorAlertView(error)
        }
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
        if let arrMyPet = arrMyPet, arrMyPet.isEmpty == false {
            return arrMyPet.count
        }
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        guard let arrMypet = arrMyPet, arrMyPet?.isEmpty == false else {
            cell = tableView.dequeueReusableCell(withIdentifier: "MyPetEmptyCell") as? MyPetEmptyCell
            if cell == nil {
                cell = Bundle.main.loadNibNamed("MyPetEmptyCell", owner: self, options: nil)?.first as? MyPetEmptyCell
            }
            return cell!
        }
        
        var myPetCell = tableView.dequeueReusableCell(withIdentifier: "MyPetCell") as? MyPetCell
        if myPetCell == nil {
            myPetCell = Bundle.main.loadNibNamed("MyPetCell", owner: self, options: nil)?.first as? MyPetCell
        }
        
        let itemDic = arrMypet[indexPath.row]
        myPetCell?.configurationData(itemDic)
        myPetCell?.didClickedActionClosure = ({(selData, actionIndex) ->() in
            if let selData = selData {
                self.selAnimal = selData
                if actionIndex == 1 {
                    //TODO:: 메인노출 액션
                    let id = selData.id!
                    
                    var enable = "N"
                    if let is_main = selData.is_main, is_main == "Y" {
                        enable = "Y"
                    }
                    
                    let param:[String : Any] = ["pet_id":id, "enable": enable]
                    ApiManager.shared.requestPetMainEnable(param: param) { (response) in
                        if let response = response as? [String:Any],
                           let msg = response["msg"] as? String,
                           let success = response["success"] as? Bool {
                            if success {
                                for animal in self.arrMyPet! {
                                    if animal.id! == self.selAnimal?.id! {
                                        animal.is_main = self.selAnimal?.is_main
                                    }
                                }
                                self.tblView.reloadData()
                                self.view.makeToast(msg)
                            }
                            else {
                                AlertView.showWithOk(title: nil, message: msg) { (index) in
                                    
                                }
                            }
                        }
                    } failure: { (error) in
                        self.showErrorAlertView(error)
                    }

                }
                else if actionIndex == 2 {
                    let vc = AnimalModifyInfoViewController.init()
                    vc.animal = self.selAnimal
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        })
        cell = myPetCell
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tblView.deselectRow(at: indexPath, animated: false)
    }
}
