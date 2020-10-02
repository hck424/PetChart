//
//  CDatePickerViw.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/30.
//

import UIKit

typealias PickerColuser = (String, Date) ->Void
enum PickerType: Int {
    case year
    case month
    case yearMonth
    case yearMonthDay
}
class MyDatePickerView: UIView {
    
    @IBOutlet var xib: UIView!
    @IBOutlet weak var btnFullClose: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var btnOk: UIButton!
    
    var minDate: Date? = nil
    var maxDate: Date? = nil
    var apointDate: Date? = nil;
    var completion: PickerColuser?
    
    convenience init?(type: PickerType, minDate: Date?, maxDate: Date?, apointDate: Date?, completion:PickerColuser?) {
        self.init(frame: UIScreen.main.bounds)
        self.minDate = minDate
        self.maxDate = maxDate
        self.apointDate = apointDate
        self.completion = completion
        
        self.loadXib()
    }
    override class func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func loadXib() {
        xib = Bundle(for: Swift.type(of: self)).loadNibNamed("MyDatePickerView", owner: self, options: nil)?.first as? UIView
        
        self.addSubview(xib)
        xib.translatesAutoresizingMaskIntoConstraints = false
        xib.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        xib.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        xib.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        xib.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
    }
    
    func show() {
        self.backgroundColor = UIColor.clear
        let window = AppDelegate.instance()?.window
        window?.addSubview(self)
        
        if let minDate = minDate {
            datePicker.minimumDate = minDate
        }
        if let maxDate = maxDate {
            datePicker.maximumDate = maxDate
        }
        
        if let apointDate = apointDate {
            datePicker.setDate(apointDate, animated: true)
        }
        datePicker.calendar = Calendar(identifier: .gregorian)
        datePicker.locale = Locale(identifier: "ko_KR")
        
    }
    
    func dismiss() {
        self.completion = nil
        self.removeFromSuperview()
    }
    
    @IBAction func onClickedButtonActions(_ sender: UIButton) {
        
    }
    
    //DatePickerActions
    @IBAction func datepickerValueChangeActions(_ sender: UIDatePicker) {
        
    }
    @IBAction func datePickerTouchupInside(_ sender: UIDatePicker) {
    }
}


