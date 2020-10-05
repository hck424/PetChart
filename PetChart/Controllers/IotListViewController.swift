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
    
    var arrData: NSMutableArray = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "기기등록", nil)
        
        tblView.tableFooterView = footerView
        
        self.makeSectionData()
        self.tblView.reloadData()
    }
    
    func makeSectionData() {
        
        let secInfo = ["sec_name":"등록된 기기", "sec_list":[["deviceName":"레오의 식사시간", "deviceModel":"모델: abcdefg1234", "deviceStatus":"연결중"]]] as [String : Any]
        
        arrData.add(secInfo)
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnIotRegist {
            let vc = IotSearchViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension IotListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrData.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let secInfo = arrData[section] as? [String: Any], let arrSec = secInfo["sec_list"] as? [[String:Any]] {
            return arrSec.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tblView.dequeueReusableCell(withIdentifier: "IotCell") as? IotCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("IotCell", owner: self, options: nil)?.first as? IotCell
        }
        
        if let secInfo = arrData[indexPath.section] as? [String: Any] {
            if let arrSec = secInfo["sec_list"] as? [[String: Any]] {
                let item = arrSec[indexPath.row]
                cell?.configurationData(item)
            }
        }
        
        cell?.didClickedClosure = ({(selData, actionIndex) ->() in
            if selData != nil {
                if actionIndex == 0 {
                    let vc = IotManagementViewController.init()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        })
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 58
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.bounds.width, height: 60))
        header.backgroundColor = UIColor.clear
        
        let lbSecTitle = UILabel.init(frame: CGRect.init(x: 20, y: 30, width: tblView.bounds.width - 40, height: 20))
        lbSecTitle.backgroundColor = UIColor.clear
        lbSecTitle.textColor = RGB(136, 136, 136)
        lbSecTitle.font = UIFont.systemFont(ofSize: 13)
        header.addSubview(lbSecTitle)
        lbSecTitle.text = ""
        if let secInfo = arrData[section] as? [String: Any], let name = secInfo["sec_name"] as? String {
            lbSecTitle.text = name
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
}
