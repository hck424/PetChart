//
//  AddressSearchCell.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/13.
//

import UIKit
import SwiftyJSON
class AddressSearchCell: UITableViewCell {

    @IBOutlet weak var svAddress: UIStackView!
    @IBOutlet weak var lbAddressTitle: Clabel!
    @IBOutlet weak var btnAddress: UIButton!
    @IBOutlet weak var lbRoadAddressTitle: Clabel!
    @IBOutlet weak var svRoadAddress: UIStackView!
    @IBOutlet weak var btnRoadAddress: UIButton!
    @IBOutlet weak var btnInput: UIButton!
    
    var data:[String:Any]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnAddress.titleLabel?.numberOfLines = 0
        btnAddress.titleLabel?.lineBreakMode = .byTruncatingTail
        btnRoadAddress.titleLabel?.numberOfLines = 0
        btnRoadAddress.titleLabel?.lineBreakMode = .byTruncatingTail
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configurationData(_ data: [String : Any], _ searchKey:String?) {
        self.data = data
        
        svAddress.isHidden = true
        lbAddressTitle.isHidden = true
        btnAddress.isHidden = true
        lbRoadAddressTitle.isHidden = true
        svRoadAddress.isHidden = true
        btnRoadAddress.isHidden = true
        btnInput.isHidden = true
        
        btnAddress.setAttributedTitle(nil, for: .normal)
        btnRoadAddress.setAttributedTitle(nil, for: .normal)
    
//        {
//          "y" : "37.569300858571",
//          "x" : "127.189468066887",
//          "road_address" : {
//            "building_name" : "미사강변도시13단지",
//            "region_3depth_name" : "망월동",
//            "underground_yn" : "N",
//            "y" : "37.569300858571",
//            "region_1depth_name" : "경기",
//            "main_building_no" : "565",
//            "road_name" : "아리수로",
//            "region_2depth_name" : "하남시",
//            "zone_no" : "12910",
//            "sub_building_no" : "",
//            "x" : "127.189468066887",
//            "address_name" : "경기 하남시 아리수로 565"
//          },
//          "address_name" : "경기 하남시 아리수로 565",
//          "address_type" : "ROAD_ADDR",
//          "address" : {
//            "main_address_no" : "949",
//            "sub_address_no" : "",
//            "region_3depth_name" : "망월동",
//            "h_code" : "4145062000",
//            "y" : "37.569300858571",
//            "mountain_yn" : "N",
//            "region_1depth_name" : "경기",
//            "region_2depth_name" : "하남시",
//            "b_code" : "4145010900",
//            "region_3depth_h_name" : "미사2동",
//            "x" : "127.189468066887",
//            "address_name" : "경기 하남시 망월동 949"
//          }
//        }
        let cellData = JSON(data)
        if cellData["address"].isEmpty == false && cellData["road_address"].isEmpty == false {
            svAddress.isHidden = false
            svRoadAddress.isHidden = false
            
            lbAddressTitle.isHidden = false
            btnAddress.isHidden = false
            var address = cellData["address"]["address_name"].stringValue
            let sub_address_no = cellData["address"]["sub_address_no"].stringValue
            if sub_address_no.isEmpty == false {
                address.append(" \(sub_address_no)")
            }
            let attr = NSAttributedString.init(string: address)
            btnAddress.setAttributedTitle(attr, for: .normal)
            
            lbRoadAddressTitle.isHidden = false
            btnRoadAddress.isHidden = false
            
            var road_address = cellData["road_address"]["address_name"].stringValue
            let building_name = cellData["road_address"]["building_name"].stringValue
            let sub_building_no = cellData["road_address"]["sub_building_no"].stringValue
            if building_name.isEmpty == false {
                road_address.append(" \(building_name)")
            }
            if sub_building_no.isEmpty == false {
                road_address.append(" \(sub_building_no)")
            }
            
            let attrRoad = NSAttributedString.init(string: road_address)
            btnRoadAddress.setAttributedTitle(attrRoad, for: .normal)
            
        }
        else if cellData["address"].isEmpty == false {
            svAddress.isHidden = false
            btnAddress.isHidden = false
            btnInput.isHidden = false
            
            var address = cellData["address"]["address_name"].stringValue
            let sub_address_no = cellData["address"]["sub_address_no"].stringValue
            if sub_address_no.isEmpty == false {
                address.append(" \(sub_address_no)")
            }
            if let searchKey = searchKey {
                let attr = self.getAttrString(address as NSString, sub: searchKey as NSString)
                btnAddress.setAttributedTitle(attr, for: .normal)
            }
            else {
                let attr = NSAttributedString.init(string: address)
                btnAddress.setAttributedTitle(attr, for: .normal)
            }
            
        }
        else if cellData["road_address"].isEmpty == false {
            svRoadAddress.isHidden = false
            btnRoadAddress.isHidden = false
            btnInput.isHidden = false
            
            var road_address = cellData["road_address"]["address_name"].stringValue
            let building_name = cellData["road_address"]["building_name"].stringValue
            let sub_building_no = cellData["address"]["sub_building_no"].stringValue
            
            if building_name.isEmpty == false {
                road_address.append(" \(building_name)")
            }
            if sub_building_no.isEmpty == false {
                road_address.append(" \(sub_building_no)")
            }
            
            if let searchKey = searchKey {
                let attr = self.getAttrString(road_address as NSString, sub: searchKey as NSString)
                btnRoadAddress.setAttributedTitle(attr, for: .normal)
            }
            else {
                let attrRoad = NSAttributedString.init(string: road_address)
                btnRoadAddress.setAttributedTitle(attrRoad, for: .normal)
            }
        }
        else {
            svAddress.isHidden = false
            btnAddress.isHidden = false
            btnInput.isHidden = false
            
            let address = cellData["address_name"].stringValue
            if let searchKey = searchKey {
                let attr = self.getAttrString(address as NSString, sub: searchKey as NSString)
                btnAddress.setAttributedTitle(attr, for: .normal)
            }
            else {
                let attr = NSAttributedString.init(string: address)
                btnAddress.setAttributedTitle(attr, for: .normal)
            }
        }
    }
    func getAttrString(_ full:NSString, sub:NSString) ->NSAttributedString {
        let attr = NSMutableAttributedString.init(string: full as String, attributes:[NSAttributedString.Key.foregroundColor: UIColor.black])
        attr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range:full.range(of: sub as String))
        
        return attr
    }
    @IBAction func onClickedButtonAction(_ sender: UIButton) {
    }
}
