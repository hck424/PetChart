//
//  TalkDetailViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/04.
//

import UIKit

class TalkDetailViewController: BaseViewController {
//hederview outlet
    
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var ivThumb: UIImageView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var cornerBgView: UIView!
    @IBOutlet weak var lbTalkUserNicName: UILabel!
    @IBOutlet weak var lbTalkUserInfo: UILabel!
    @IBOutlet weak var lbTalkTitle: UILabel!
    @IBOutlet weak var lbCategory: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnReport: UIButton!
    @IBOutlet weak var lbTalkContent: UILabel!
    @IBOutlet weak var heightContent: NSLayoutConstraint!
    
//end
    @IBOutlet weak var tblView: UITableView!
    var heightHeaderView: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblView.estimatedRowHeight = 80
        self.tblView.rowHeight = UITableView.automaticDimension
        self.configurationHeaderViewUI()
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.headerUpdateLayout()
    }
    
    func headerUpdateLayout() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        let hContent = lbTalkContent.sizeThatFits(CGSize.init(width: tblView.frame.width - 40, height: CGFloat.greatestFiniteMagnitude)).height
        heightContent?.constant = hContent
        
        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        heightHeaderView = headerView.heightAnchor.constraint(equalToConstant: height)
        heightHeaderView?.priority = UILayoutPriority(rawValue: 800)
        heightHeaderView?.isActive = true
        headerView.widthAnchor.constraint(equalToConstant: tblView.frame.size.width).isActive = true
    }
    
    func configurationHeaderViewUI() {
        self.tblView.tableHeaderView = headerView
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        ivProfile.layer.borderWidth = 2.0
        ivProfile.layer.borderColor = RGB(239, 239, 239).cgColor
        ivProfile.layer.cornerRadius = ivProfile.bounds.height/2
        
        cornerBgView.layer.cornerRadius = 20
        cornerBgView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        
        self.tblView.reloadData()
        
    }
    @IBAction func onClickedButtonActions(_ sender: UIButton) {
        if sender == btnBack {
            self.navigationController?.popViewController(animated: true)
        }
        else if sender == btnLike {
            
        }
        else if sender == btnReport {
            
        }
    }
}

extension TalkDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "TalkDetailCell") as? TalkDetailCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("TalkDetailCell", owner: self, options: nil)?.first as? TalkDetailCell
        }
        
        cell?.configurationData(nil)
        cell?.didSelectActionClosure = ({(selData, index) -> () in
            
        })
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
}
