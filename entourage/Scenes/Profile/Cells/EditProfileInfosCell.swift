//
//  EditProfileInfosCell.swift
//  entourage
//
//  Created by Jerome on 18/03/2022.
//

import UIKit

class EditProfileInfosCell: UITableViewCell {
    
    let minRadius:Float = 1
    let maxRadius:Float = 200
    
    @IBOutlet weak var ui_view_firstname: UIView!
    @IBOutlet weak var ui_tf_firstname: UITextField!
    @IBOutlet weak var ui_title_firstname: UILabel!
    
    @IBOutlet weak var ui_title_lastname: UILabel!
    @IBOutlet weak var ui_tf_lastname: UITextField!
    
    @IBOutlet weak var ui_title_phone: UILabel!
    
    @IBOutlet weak var ui_title_email: UILabel!
    @IBOutlet weak var ui_phone: UILabel!
    
    @IBOutlet weak var ui_title_birthday: UILabel!
    @IBOutlet weak var ui_title_bio: UILabel!
    @IBOutlet weak var ui_tf_birthday: UITextField!
    
    @IBOutlet weak var ui_tf_email: UITextField!
    
    @IBOutlet weak var ui_bio_count: UILabel!
    @IBOutlet weak var ui_tv_edit_bio: UITextView!
    
    @IBOutlet weak var ui_title_city_cp: UILabel!
    @IBOutlet weak var ui_city_cp: UILabel!
    
    
    @IBOutlet weak var ui_slider: MJCustomSlider!
    
    @IBOutlet weak var ui_min_km: UILabel!
    @IBOutlet weak var ui_max_km: UILabel!
    @IBOutlet weak var ui_label_km_selected: UILabel!
    @IBOutlet weak var ui_constraint_label_km_selected: NSLayoutConstraint!
    
    @IBOutlet weak var ui_radius_title: UILabel!
    @IBOutlet weak var ui_radius_info: UILabel!
    
    weak var delegate:CellTextDelegate? = nil
    
    var textChanged: ((String) -> Void)?
    
    let placeholderBioTxt = "editUserPlaceholderBio".localized
    let placeholderBioColor = UIColor.lightGray
    let bioColor = UIColor.black
    let maxCharsBioString = "/200"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_tv_edit_bio.delegate = self
        ui_tv_edit_bio.isScrollEnabled = false
        ui_bio_count.text = "0/200"
        
        ui_tf_firstname.delegate = self
        ui_tf_lastname.delegate = self
        ui_tf_birthday.delegate = self
        ui_tf_email.delegate = self
        
        addToolBar(textview: ui_tv_edit_bio)
        ui_tv_edit_bio.text = placeholderBioTxt
        ui_tv_edit_bio.textColor = placeholderBioColor
        ui_tv_edit_bio.font = ApplicationTheme.getFontNunitoRegular(size: 13)
        
        ui_title_firstname.text = "editUserTitleFirstname".localized
        setupTitleStyle(ui_title_firstname)
        ui_title_lastname.text = "editUserTitleLastname".localized
        setupTitleStyle(ui_title_lastname)
        ui_title_bio.text = "editUserTitleBio".localized
        setupTitleStyle(ui_title_bio)
        ui_title_birthday.text = "editUserTitleBirthday".localized
        setupTitleStyle(ui_title_birthday)
        ui_title_phone.text = "editUserTitlePhone".localized
        setupTitleStyle(ui_title_phone)
        ui_title_email.text = "editUserTitleEmail".localized
        setupTitleStyle(ui_title_email)
        ui_title_city_cp.text = "editUserTitleCity".localized
        setupTitleStyle(ui_title_city_cp)
        
        ui_tf_firstname.placeholder = "editUserPlaceholderFirstname".localized
        setupTextFieldStyle(ui_tf_firstname)
        ui_tf_lastname.placeholder = "editUserPlaceholderLastname".localized
        setupTextFieldStyle(ui_tf_lastname)
        ui_tf_birthday.placeholder = "editUserPlaceholderBirthday".localized
        setupTextFieldStyle(ui_tf_birthday)
        ui_tf_email.placeholder = "editUserPlaceholderEMail".localized
        setupTextFieldStyle(ui_tf_email)
        
        ui_radius_title.text = "editUserTitleRadius".localized
        ui_radius_title.textColor = ApplicationTheme.getFontH6().color
        ui_radius_title.font = ApplicationTheme.getFontH6().font
        ui_radius_info.text = "editUserDescRadius".localized
        ui_radius_info.textColor = ApplicationTheme.getFontH6().color
        ui_radius_info.font = ApplicationTheme.getFontH6().font
        
        ui_min_km.text = "\(Int(minRadius))km"
        ui_min_km.font = ApplicationTheme.getFontNunitoRegular(size: 13)
        ui_min_km.textColor = .black
        ui_max_km.text = "\(Int(maxRadius))km"
        ui_max_km.font = ApplicationTheme.getFontNunitoRegular(size: 13)
        ui_max_km.textColor = .black
        ui_label_km_selected.textColor = .appOrange
        ui_label_km_selected.font = ApplicationTheme.getFontNunitoBold(size: 13)
        
        ui_phone.font = ApplicationTheme.getFontNunitoRegular(size: 13)
        ui_phone.textColor = .black
        ui_city_cp.font = ApplicationTheme.getFontNunitoRegular(size: 13)
        ui_city_cp.textColor = .black
    }
    
    private func setupTitleStyle(_ label:UILabel) {
        label.font = ApplicationTheme.getFontH5().font
        label.textColor = ApplicationTheme.getFontH5().color
    }
    
    private func setupTextFieldStyle(_ textfield:UITextField) {
        textfield.font = ApplicationTheme.getFontNunitoRegular(size: 13)
        textfield.textColor = .black
    }
    
    private func addToolBar(textview:UITextView? = nil, textfield:UITextField? = nil) {
        let _widht = UIApplication.shared.delegate?.window??.frame.width ?? contentView.frame.size.width
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: _widht, height: 30))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let buttonDone = UIBarButtonItem(title: "validate".localized, style: .plain, target: self, action: #selector(closeKb(_:)))
        buttonDone.tag = textview.hashValue
        //Custom font and color
        let fontColor = UIColor.appOrange
        let fontName = ApplicationTheme.getFontTextRegular().font
        buttonDone.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: fontColor, NSAttributedString.Key.font: fontName], for: .normal)
        toolbar.setItems([flexSpace, buttonDone], animated: false)
        toolbar.sizeToFit()
        
        textview?.inputAccessoryView = toolbar
        textfield?.inputAccessoryView = toolbar
    }
    
    @objc func closeKb(_ sender:UIBarButtonItem!) {
        let tag = sender.tag
        if tag == ui_tv_edit_bio.hashValue {
            if let txtBio = ui_tv_edit_bio.text {
                let _bio = txtBio == placeholderBioTxt ? "" : txtBio
                delegate?.updateBio(bio: _bio)
            }
            ui_tv_edit_bio.resignFirstResponder()
        }
    }
    
    func populateCell(firstname:String?,lastname:String?, bio:String?,birthdate:String?, email:String?,phone:String?, cityName:String?, radius:Int! = 0,  delegate:CellTextDelegate) {
        self.delegate = delegate
        
        ui_tf_firstname.text = firstname
        ui_tf_lastname.text = lastname
        ui_tf_email.text = email
        ui_tf_birthday.text = birthdate
        ui_city_cp.text = cityName
        ui_phone.text = phone
        
        if let bio = bio, bio.count > 0 {
            ui_tv_edit_bio.text = bio
            ui_bio_count.text = "\(ui_tv_edit_bio.text.count)\(maxCharsBioString)"
            ui_tv_edit_bio.textColor = bioColor
        }
        else {
            ui_tv_edit_bio.text = placeholderBioTxt
            ui_tv_edit_bio.textColor = placeholderBioColor
            ui_bio_count.text = "0\(maxCharsBioString)"
        }
        
        ui_slider.setupSlider(delegate: self, imageThumb: UIImage.init(named: "thumb_orange"), minValue: minRadius, maxValue: maxRadius)
        ui_slider.value = Float(radius)
    }
    
    @IBAction func action_change_location(_ sender: Any) {
        delegate?.showSelectLocation()
    }
}

//MARK: - MJCustomSliderDelegate -
extension EditProfileInfosCell: MJCustomSliderDelegate {
    func updateLabel() {
        let pos = ui_slider.getPercentScreenPosition()
        ui_constraint_label_km_selected.constant = pos - (ui_label_km_selected.intrinsicContentSize.width / 2)
        ui_label_km_selected.text = "\(Int(ui_slider.value)) km"
        delegate?.updateRadius(radius: Int(ui_slider.value))
    }
}

//MARK: - UITextViewDelegate -
extension EditProfileInfosCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //TODO: ON garde quel comportement? avec ou sans retour à la ligne ?
        if text == "\n" {
            delegate?.updateBio(bio: textView.text)
            textView.resignFirstResponder()
            return false
        }
        
        if textView.text.count + text.count > 200 {
            return false
        }
        
        delegate?.updateCellHeight()
        
        ui_bio_count.text = "\(textView.text.count + text.count)\(maxCharsBioString)"
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderBioTxt {
            textView.text = ""
            textView.textColor = bioColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = placeholderBioTxt
            textView.textColor = placeholderBioColor
        }
    }
}

//MARK: - UITextFieldDelegate -
extension EditProfileInfosCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        switch textField {
        case ui_tf_firstname:
            delegate?.updateFirstname(firstname: textField.text)
        case ui_tf_lastname:
            delegate?.updateLastname(lastname: textField.text)
        case ui_tf_birthday:
            delegate?.updateBirthDate(birthdate: textField.text)
        case ui_tf_email:
            delegate?.updateEmail(email: textField.text)
        default:
            break
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == ui_tf_birthday {
            let charSet = NSCharacterSet(charactersIn:"0123456789-").inverted
            let strValidation = string.rangeOfCharacter(from: charSet) == nil
            return strValidation
        }
        
        return true
    }
}

//MARK: - Protocol CellTextDelegate -
protocol CellTextDelegate:AnyObject {
    func updateCellHeight()
    func updateEmail(email:String?)
    func updateBirthDate(birthdate:String?)
    func updateFirstname(firstname:String?)
    func updateLastname(lastname:String?)
    func updateBio(bio:String?)
    func showSelectLocation()
    func updateRadius(radius:Int)
}
