//
//  TalkViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/26.
//

import UIKit


class TalkViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tfSearch: CTextField!
    @IBOutlet var arrBtnPet: [UIButton]!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnWrite: UIButton!
    @IBOutlet weak var cornerBgView: UIView!
    
    @IBOutlet weak var btnFooterMore: UIButton!
    @IBOutlet var footerView: UIView!
    var selCategory:String = "전체"
    let TAG_UNDER_LINE: Int = 1234567
    
    var searchTxt: String? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawTitle(self, "차트톡", nil)
        CNavigationBar.drawProfile(self, #selector(onclickedButtonActins(_:)))
        
        tfSearch.delegate = self
        
        cornerBgView.layer.cornerRadius = 20
        cornerBgView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        arrBtnPet = arrBtnPet.sorted(by: { (btn1, btn2) -> Bool in
            return btn1.tag < btn2.tag
        })
        
        for btn in arrBtnPet {
            btn.addTarget(self, action: #selector(onclickedButtonActins(_:)), for: .touchUpInside)
        }
        
        arrBtnPet.first?.sendActions(for: .touchUpInside)
        
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tblView.bounds.width, height: 8))
        tblView.tableHeaderView = headerView
        tblView.estimatedRowHeight = 100
        tblView.rowHeight = UITableView.automaticDimension
        
        tblView.tableFooterView = footerView
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureHandler(_ :)))
//        self.view.addGestureRecognizer(tap)
//
        self.tblView.delegate = self
        self.tblView.dataSource = self
       
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tblView.reloadData()
    }
    
    func removeUnderline(_ sender: UIButton) {
        if let view = sender.viewWithTag(TAG_UNDER_LINE) {
            view.removeFromSuperview()
        }
        sender.titleLabel?.font = UIFont.systemFont(ofSize: sender.titleLabel?.font.pointSize ?? 15, weight: .regular)
        sender.setTitleColor(RGB(145, 145, 145), for: .normal)
    }
    
    func addUnderLine(_ sender: UIButton) {
        let width = sender.bounds.width * 0.6
        let underline = UIView.init(frame: CGRect(x: (sender.bounds.width - width)/2, y: sender.bounds.height/2 + 3, width: width, height: 8))
        underline.backgroundColor = RGBA(233, 95, 94, 0.5)
        underline.tag = TAG_UNDER_LINE
        sender.addSubview(underline)

        sender.titleLabel?.font = UIFont.systemFont(ofSize: sender.titleLabel?.font.pointSize ?? 15, weight: .bold)
        sender.setTitleColor(UIColor.black, for: .normal)
    }
    
    func dataRest() {
        
    }
    func addData() {
        
    }
    
    func requestComunityList() {
        
    }
    //FIXME:: cumstom btn action
    @objc func tapGestureHandler(_ gesture: UITapGestureRecognizer) {
        if gesture.view == self.view {
            self.view.endEditing(true)
        }
    }
    @objc @IBAction func onclickedButtonActins(_ sender: UIButton) {
        if sender.tag == TAG_NAVI_USER {
            let vc = MyInfoViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnWrite {
            let vc = TalkWriteViewController.init()
            self.navigationController?.pushViewController(vc, animated: false)
        }
        else if arrBtnPet.contains(sender) {
            for btn in arrBtnPet {
                self.removeUnderline(btn)
            }
            self.addUnderLine(sender)
            
            if sender.tag == 1 {
                selCategory = "전체"
            }
            else if sender.tag == 2 {
                selCategory = "강아지"
            }
            else if sender.tag == 3 {
                selCategory = "고양이"
            }
            else if sender.tag == 4 {
                selCategory = "기타"
            }
            
            self.dataRest()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "TalkCell") as? TalkCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("TalkCell", owner: self, options: nil)?.first as? TalkCell
        }
        
        cell?.configurationData(nil)
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let vc = TalkDetailViewController.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


extension TalkViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}

extension TalkViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.isEmpty == false {
            self.requestComunityList()
        }
        
        self.view.endEditing(true)
        return true
    }
}
