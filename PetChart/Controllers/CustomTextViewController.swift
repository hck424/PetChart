//
//  CustomTextViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/11/08.
//

import UIKit

class CustomTextViewController: BaseViewController {
    @IBOutlet weak var textView: UITextView!
    var vcTitle:String = ""
    var content:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawTitle(self, vcTitle, nil)
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        
        textView.contentInset = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        textView.attributedText = try? NSAttributedString.init(htmlString: content)
    }
}
