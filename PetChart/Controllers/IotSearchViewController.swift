//
//  IotSearchViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/05.
//

import UIKit

class IotSearchViewController: BaseViewController {

    @IBOutlet weak var lbIotSearchStatus: UILabel!
    @IBOutlet weak var tblView: UITableView!
    
    let arrDevice: Array<Any>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "기기설정", nil)
        
        
        tblView.layer.cornerRadius = 20
        tblView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
    }
    
}
extension IotSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let arrDevice = arrDevice {
            return arrDevice.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "IotDeviceCell") as? IotDeviceCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("IotDeviceCell", owner: self, options: nil)?.first as? IotDeviceCell
        }
        
        return cell!

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}
