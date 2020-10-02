//
//  MrStep1ViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/29.
//

import UIKit

class MrStep1ViewController: BaseViewController, UITextFieldDelegate {

    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    @IBOutlet weak var bgCornerView: UIView!
    @IBOutlet weak var tfName: CTextField!
    @IBOutlet weak var btnMen: UIButton!
    @IBOutlet weak var btnFemail: UIButton!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnSafty: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "회원가입", nil)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHander(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHander(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func onclickedButtonActions(_ sender: UIButton) {
        if sender == btnMen {
            
        }
        else if sender == btnFemail {
            
        }
        else if sender == btnOk {
            
        }
    }
    
    @objc func notificationHander(_ notification: Notification) {
        
        
    }
}
