//
//  NoticeCellView.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/14.
//

import UIKit
enum NoticeCellType {
    case notice, faq
}
class NoticeCellView: UIView {

    @IBOutlet weak var heightContent: NSLayoutConstraint!
    @IBOutlet weak var btnTop: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var btnExpand: CButton!
    @IBOutlet weak var tvContent: UITextView!
    @IBOutlet weak var svContent: UIStackView!
    var type:NoticeCellType = .notice
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    func configurationData(_ data:[String:Any]?) {
        btnExpand.data = data
        btnExpand.isSelected = false
        svContent.isHidden = true
        lbTitle.text = ""
        tvContent.text = ""
        lbDate.text = ""
        tvContent.attributedText = nil
        
        guard let data = data else {
            return
        }
        
        lbDate.isHidden = true
        if let registdata = data["update_date"] as? String {
            lbDate.isHidden = false
            let df = CDateFormatter.init()
            df.dateFormat = "yyyy.MM.dd HH:mm:ss"
            guard let date = df.date(from: registdata) else {
                return
            }
            df.dateFormat = "yyyy.MM.dd"
            let strDate = df.string(from: date)
            lbDate.text = strDate
        }
        
        if let title = data["title"] as? String {
            if type == .faq {
                let tmpStr = "Q."
                let result = "\(tmpStr)\(title)"
                let attr = NSMutableAttributedString.init(string: result)
                attr.addAttribute(.foregroundColor, value: ColorDefault, range: NSMakeRange(0, tmpStr.length))
                attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 18, weight: .regular), range: NSMakeRange(0, tmpStr.length))
                lbTitle.attributedText = attr
            }
            else {
                lbTitle.text = title
            }
        }
        
        if let content = data["content"] as? String {
            tvContent.attributedText = try? NSAttributedString.init(htmlString: content)
        }
        let height = tvContent.sizeThatFits(CGSize(width: tvContent.frame.size.width, height: CGFloat.greatestFiniteMagnitude)).height
        heightContent.constant = height
    }
    
    @IBAction func onClickedButtonAction(_ sender: UIButton) {
        if sender == btnExpand || sender == btnTop {
            btnExpand.isSelected = !btnExpand.isSelected
            if btnExpand.isSelected {
                svContent.isHidden = false
                lbTitle.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            }
            else {
                svContent.isHidden = true
                lbTitle.font = UIFont.systemFont(ofSize: 18, weight: .regular)
            }
        }
    }
}
