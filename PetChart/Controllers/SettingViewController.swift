//
//  SettingViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/05.
//

import UIKit

class SettingViewController: BaseViewController {
    @IBOutlet weak var tblView: UITableView!
    
    let arrData = [["title":"앱 알림 설정", "identify": "push"],
                   ["title":"버전과리", "identify":"version"],
                   ["title":"개인정보 처리방침", "identify":"privacy_policy"],
                   ["title":"이용약관", "identify":"terms"],
                   ["title":"회원탈퇴", "identify": "withdraw"],
                   ["title":"로그아웃", "identify": "logout"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "설정", nil)
        
        tblView.reloadData()
    }
    
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MyInfoCell") as? MyInfoCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("MyInfoCell", owner: self, options: nil)?.first as? MyInfoCell
        }
        let item = arrData[indexPath.row]
        let identify = item["identify"]
        
        cell?.lbTitle.text  = item["title"]
        cell?.lbSubTitle.isHidden = true
        
        if identify == "version" {
            cell?.lbSubTitle.isHidden = false
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let item = arrData[indexPath.row]
        let identify = item["identify"]
        
        if identify == "push" {
            let vc = PushViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if identify == "version" {
            
        }
        else if identify == "privacy_policy" {
            
        }
        else if identify == "terms" {
            
        }
        else if identify == "withdraw" {
            let vc = WithdrawViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if identify == "logout" {
            AlertView.showWithCancelAndOk(title: "로그아웃", message: "로그아웃 하시겠습니까?") { (index) in
                if index == 1 {
                    //TODO:: 로그아웃 처리
                }
            }
        }
    }
    
}
