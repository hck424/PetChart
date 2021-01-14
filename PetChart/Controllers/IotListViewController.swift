//
//  IotListViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/05.
//

import UIKit

class IotListViewController: BaseViewController {
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var btnIotRegist: CButton!
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var btnFoceDisConnet: UIButton!
    
    var arrData:Array<[String:Any]>? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "기기등록", nil)
        
        tblView.tableHeaderView = headerView
        tblView.tableFooterView = footerView
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.resuetDeviceList()
    }
    
    func resuetDeviceList() {
        ApiManager.shared.requetDeviceList { (response) in
            if let response = response as? [String:Any],
               let data = response["data"] as?[String:Any] {
                
                if let devices = data["devices"] as? Array<[String:Any]> {
                    self.arrData = devices
                    
                }
                else {
                    self.arrData = nil
                }
                self.tblView.reloadData()
            }
            else {
                self.showErrorAlertView(response)
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnIotRegist {
            let vc = IotSearchViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnFoceDisConnet {
            let vc = IotManagementViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension IotListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let arrData = arrData else {
            return 0
        }
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tblView.dequeueReusableCell(withIdentifier: "IotCell") as? IotCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("IotCell", owner: self, options: nil)?.first as? IotCell
        }
        
        if let item = arrData?[indexPath.row] {
            cell?.configurationData(item)
            
            cell?.didClickedClosure = ({(selData, actionIndex) ->() in
                guard let selData = selData else {
                    return
                }
                
                if actionIndex == 0 {
                    let vc = IotManagementViewController.init()
                    vc.device = selData
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
}
