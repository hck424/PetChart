//
//  IotViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/05.
//

import UIKit

class IotViewController: BaseViewController {

    @IBOutlet weak var tblView: UITableView!
    var data:[String:Any]?
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "IoT 기기관리", nil)
        
        let footerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tblView.bounds.width, height: 20))
        let seperator = UIView.init(frame: CGRect.init(x: 20, y: 0, width: footerView.bounds.width - 40, height: 0.3))
        seperator.backgroundColor = UIColor.separator
        footerView.addSubview(seperator)
        
        tblView.tableFooterView = footerView
    }
    func openUrl(url: String) {
        AppDelegate.instance()?.openUrl(url, completion: nil)
    }
}

extension IotViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "Cell")
        }
        
        if indexPath.row == 0 {
            cell?.textLabel?.text = "기기구매 바로가기"
        }
        else if indexPath.row == 1 {
            cell?.textLabel?.text = "기기등록/삭제"
        }
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell?.textLabel?.textColor = UIColor.black
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tblView.deselectRow(at: indexPath, animated: false)
        if indexPath.row == 0 {
            if let data = data, let mallUrl = data["mallUrl"] as? String {
                self.openUrl(url: mallUrl)
            }
            else {
                ApiManager.shared.requestAppConfig { (response) in
                    if let response = response as?[String:Any], let data = response["data"] as?[String:Any] {
                        self.data = data
                        if let mallUrl = data["mallUrl"] as? String {
                            self.openUrl(url: mallUrl)
                        }
                    }
                } failure: { (error) in
                    self.showErrorAlertView(error)
                }
            }
        }
        else if indexPath.row == 1 {
            let vc = IotListViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58.0
    }
}
