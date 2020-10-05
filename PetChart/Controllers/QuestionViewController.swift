//
//  QuestionViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/05.
//

import UIKit

class QuestionViewController: BaseViewController {
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    @IBOutlet weak var heightTextView: NSLayoutConstraint!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var safetyView: UIView!
    @IBOutlet weak var textView: CTextView!
    @IBOutlet weak var tblView: UITableView!
    
    var arrData = NSMutableArray()
    var tmpCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "1:1문의", nil)
        
        if Utility.isIphoneX() == false {
            safetyView.isHidden = true
        }
        textView.delegate = self
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGestuerHandler(_ :)))
        self.view.addGestureRecognizer(tap)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func tapGestuerHandler(_ gesture: UITapGestureRecognizer) {
        if gesture.view == self.view {
            self.view.endEditing(true)
        }
    }
    @IBAction func onClickedBtnAction(_ sender: UIButton) {
        
        if sender == btnSend {
            guard let text = textView.text else {
                return
            }
            let df = CDateFormatter.init()
            df.dateFormat = "yyyyMMdd HH:mm:ss"
            let dateStr = df.string(from: Date())
            var type = "send"
            if tmpCount % 2 == 0 {
                type = "receive"
            }
            arrData.add(["content": text, "writeDate": dateStr, "type": type])
            tblView.reloadData {
                if self.tblView.contentSize.height > self.tblView.bounds.size.height {
                    self.tblView.contentOffset = CGPoint(x: 0, y: self.tblView.contentSize.height - self.tblView.frame.size.height)
                }
            }
            tmpCount += 1
            textView.text = ""
            self.textViewDidChange(textView)
            
        }
    }
    @objc func notificationHandler(_ notification: Notification) {
            
        let heightKeyboard = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
        let duration = CGFloat((notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.0)
 
        if notification.name == UIResponder.keyboardWillShowNotification {
            let bottomSafety: CGFloat = AppDelegate.instance()?.window?.safeAreaInsets.bottom ?? 0
            bottomContainer.constant = heightKeyboard - bottomSafety
            UIView.animate(withDuration: TimeInterval(duration)) {
                self.view.layoutIfNeeded()
            }
        }
        else if notification.name == UIResponder.keyboardWillHideNotification {
            bottomContainer.constant = 0
            UIView.animate(withDuration: TimeInterval(duration)) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension QuestionViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("text: \(text)")
        if text == "\n" {
            var height = textView.sizeThatFits(CGSize.init(width: textView.bounds.width - textView.contentInset.left - textView.contentInset.right, height: CGFloat.infinity)).height
            height = height + textView.contentInset.top + textView.contentInset.bottom
            heightTextView.constant = height
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let textView = textView as? CTextView {
            textView.placeholderLabel?.isHidden = !textView.text.isEmpty
        }
        
        var height = textView.sizeThatFits(CGSize.init(width: textView.bounds.width - textView.contentInset.left - textView.contentInset.right, height: CGFloat.infinity)).height
        height = height + textView.contentInset.top + textView.contentInset.bottom
        heightTextView.constant = height
    }
}

extension QuestionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ChattingCell") as? ChattingCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("ChattingCell", owner: self, options: nil)?.first as? ChattingCell
        }
        let data = arrData[indexPath.row]
        cell?.configurationData(data as? Dictionary<String, Any>)
        return cell!
    }
    
    
}
