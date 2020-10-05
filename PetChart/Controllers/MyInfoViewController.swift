//
//  MyInfoViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/05.
//

import UIKit

class MyInfoViewController: BaseViewController {

    @IBOutlet var headerView: UIView!
    @IBOutlet weak var lbHeaderTitle: UILabel!
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var btnMyPet: UIButton!
    @IBOutlet weak var btnIot: UIButton!
    @IBOutlet weak var heightHeaderTitle: NSLayoutConstraint!
    
    @IBOutlet weak var tblView: UITableView!
    
    var heightHeaderView: NSLayoutConstraint?
    var userName = "신소민"
    let arrData = [["title":"로그인 정보 수정", "identify": "member_modify"],
                   ["title":"공지사항", "identify":"notice"],
                   ["title":"자주묻는 질문", "identify":"faq"],
                   ["title":"1:1문의", "identify":"question"],
                   ["title":"설정", "identify": "setting"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "마이페이지", nil)
        
        self.configurationUI()
        
        tblView.estimatedRowHeight = 58
        tblView.rowHeight = UITableView.automaticDimension
        self.tblView.reloadData()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.hearderUpdateConstraint()
    }
    func hearderUpdateConstraint() {
        headerView.widthAnchor.constraint(equalToConstant: tblView.frame.size.width).isActive = true
        let hTitle = lbHeaderTitle.sizeThatFits(CGSize.init(width: tblView.frame.size.width - 92, height: CGFloat.infinity)).height
        heightHeaderTitle.constant = hTitle

        if heightHeaderView != nil {
            tblView.removeConstraint(heightHeaderView!)
        }
        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        heightHeaderView = headerView.heightAnchor.constraint(equalToConstant: height)
        heightHeaderView?.priority = UILayoutPriority(rawValue: 900)
        heightHeaderView?.isActive = true
    }
    
    func configurationUI() {
        self.tblView.tableHeaderView = headerView
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let str1: String = "\(userName) 님,\n오늘도 "
        
        let img = UIImage(named: "logo_red")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        let attchment = NSTextAttachment.init(image: img!)
        
        attchment.bounds = CGRect.init(x: 0, y: -1, width: img!.size.width, height: img!.size.height)
        let attr = NSMutableAttributedString.init(attachment: attchment)
        attr.addAttribute(NSAttributedString.Key.foregroundColor, value: ColorDefault, range:NSRange(location: 0, length: attr.length))
        
        let resultAttr = NSMutableAttributedString.init(string: str1)
        resultAttr.append(attr)
        resultAttr.append(NSAttributedString.init(string: " 하세요!"))
        lbHeaderTitle.attributedText = resultAttr
        
        btnMyPet.layer.cornerRadius = 20
        btnMyPet.layer.maskedCorners = CACornerMask(TL: true, TR: false, BL: false, BR: false)
        btnIot.layer.cornerRadius = 20
        btnIot.layer.maskedCorners = CACornerMask(TL: false, TR: true, BL: false, BR: false)
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
    }
    
    @IBAction func onClickedButtonActions(_ sender: UIButton) {
     
        if sender == btnMyPet {
            let vc = MyPetViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnIot {
            let vc = IotViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnHome {
            if let mainTabVc: MainTabBarController =  AppDelegate.instance()?.mainTabbarCtrl() {
                mainTabVc.selectedIndex = 0
            }
            self.navigationController?.popViewController(animated: false)
        }
    }
}

extension MyInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MyInfoCell") as? MyInfoCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("MyInfoCell", owner: self, options: nil)?.first as? MyInfoCell
        }
        let item = arrData[indexPath.row]
        cell?.lbTitle.text  = item["title"]
        cell?.lbSubTitle.isHidden = true
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let item = arrData[indexPath.row]
        let identify = item["identify"]

        if identify == "member_modify" {
            let vc = MemberInfoModifyViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if identify == "notice" {
            let vc = NoticeViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if identify == "faq" {
            let vc = FAQViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if identify == "question" {
            let vc = QuestionViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if identify == "setting" {
            let vc = SettingViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
