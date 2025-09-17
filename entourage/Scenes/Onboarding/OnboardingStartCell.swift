import UIKit

class OnboardingStartCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var ui_title_firstname: UILabel!
    @IBOutlet weak var ui_title_lastname: UILabel!
    @IBOutlet weak var ui_title_country: UILabel!
    @IBOutlet weak var ui_title_phone: UILabel!
    @IBOutlet weak var ui_title_email: UILabel!
    @IBOutlet weak var ui_info_mailing: UILabel!
    @IBOutlet weak var ui_info_lastname: UILabel!
    @IBOutlet weak var ui_tf_firstname: UITextField!
    @IBOutlet weak var ui_tf_lastname: UITextField!
    @IBOutlet weak var ui_tf_country: OTCustomTextfield!
    @IBOutlet weak var ui_tf_phone: OTCustomTextfield!
    @IBOutlet weak var ui_tf_email: UITextField!
    @IBOutlet weak var ui_error_firstname: MJErrorInputTextView!
    @IBOutlet weak var ui_error_lastname: MJErrorInputTextView!
    @IBOutlet weak var ui_error_phone: MJErrorInputTextView!
    @IBOutlet weak var ui_error_email: MJErrorInputTextView!
    @IBOutlet weak var ui_iv_check: UIImageView!
    @IBOutlet weak var ui_pickerView: UIPickerView!
    @IBOutlet weak var ui_view_info_mandatory: UIView!
    @IBOutlet weak var ui_label_mandatory: UILabel!
    @IBOutlet weak var ui_stackview: UIStackView!
    @IBOutlet weak var ui_label_title_birthday: UILabel!
    @IBOutlet weak var ui_textfield_birthday: UITextField!

    // MARK: - Properties
    weak var delegate: OnboardingStartDelegate? = nil
    let minimumCharacters = 2
    let minimumPhoneCharacters = 9
    var countryCode: CountryCode = defaultCountryCode
    var tempPhone = ""

    // Data for PickerViews
    let pickerDatas: [CountryCode] = [
        CountryCode(country: "France", code: "+33", flag: "🇫🇷"),
        CountryCode(country: "Belgique", code: "+32", flag: "🇧🇪")
    ]

    let genderOptions = ["Homme", "Femme", "Non binaire"]

    let howWeMetOptions = [
        "Bouche à oreille",
        "Internet",
        "Télévision / média",
        "Réseaux sociaux",
        "Sensibilisation entreprise"
    ]

    let companyOptions = ["Entreprise A", "Entreprise B", "Entreprise C"]
    let eventOptions = ["Atelier 1", "Atelier 2", "Atelier 3"]

    var isChecked = false

    // New UI Elements
    private var genderLabel: UILabel!
    private var genderTextField: UITextField!
    private var genderPickerView: UIPickerView!
    private var howWeMetLabel: UILabel!
    private var howWeMetTextField: UITextField!
    private var howWeMetPickerView: UIPickerView!
    private var companyLabel: UILabel!
    private var companyTextField: UITextField!
    private var companyPickerView: UIPickerView!
    private var eventLabel: UILabel!
    private var eventTextField: UITextField!
    private var eventPickerView: UIPickerView!
    private var datePicker: UIDatePicker!

    // Containers for company and event
    private var companyContainer: UIStackView!
    private var eventContainer: UIStackView!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTitles()
        setupPickerViews()
        setupTextFields()
        setupNewFields()
    }

    // MARK: - Setup
    private func setupTitles() {
        ui_title_firstname.setFontTitle(size: 17)
        ui_title_lastname.setFontTitle(size: 17)
        ui_title_country.setFontTitle(size: 17)
        ui_title_phone.setFontTitle(size: 17)
        ui_info_mailing.font = UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)
        ui_info_lastname.font = UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)
        ui_label_mandatory.font = UIFont(name: "NunitoSans-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        ui_info_lastname.text = "onboard_welcome_info".localized
        ui_title_firstname.text = "onboard_welcome_firstname".localized
        ui_title_lastname.text = "onboard_welcome_lastname".localized
        ui_tf_firstname.placeholder = "onboard_welcome_placeholder_firstname".localized
        ui_tf_lastname.placeholder = "onboard_welcome_placeholder_lastname".localized
        ui_title_country.text = "onboard_welcome_country".localized
        ui_title_phone.text = "onboard_welcome_phone".localized
        ui_title_email.text = "onboard_welcome_mail".localized
        ui_info_mailing.text = "onboard_welcome_consent".localized
        ui_tf_phone.placeholder = "0600000000"
        ui_tf_email.placeholder = "onboard_welcome_placeholder_mail".localized
        ui_label_mandatory.text = "onboard_welcome_info_mandatory".localized
        ui_label_title_birthday.text = "Date d'anniversaire".localized
        ui_label_title_birthday.setFontTitle(size: 17)
        ui_textfield_birthday.placeholder = "Ex. : 22/10/1989".localized
        ui_view_info_mandatory.layer.cornerRadius = 15
    }

    private func setupTextFields() {
        ui_tf_firstname.delegate = self
        ui_tf_lastname.delegate = self
        ui_tf_email.delegate = self
        ui_tf_phone.delegate = self
        ui_textfield_birthday.delegate = self

        ui_tf_firstname.setFontBody(size: 14)
        ui_tf_lastname.setFontBody(size: 14)
        ui_tf_country.setFontBody(size: 14)
        ui_tf_phone.setFontBody(size: 14)
        ui_tf_email.setFontBody(size: 14)
        ui_textfield_birthday.setFontBody(size: 14)

        ui_error_firstname.isHidden = true
        ui_error_lastname.isHidden = true
        ui_error_phone.isHidden = true
        ui_error_email.isHidden = true

        ui_error_firstname.setupView(title: "onboard_error_firstname".localized)
        ui_error_lastname.setupView(title: "onboard_error_lastname".localized)
        ui_error_phone.setupView(title: "onboard_error_phone".localized)
        ui_error_email.setupView(title: "onboard_error_email".localized)

        ui_tf_phone.activateToolBarWithTitle("close".localized)
        ui_tf_country.activateToolBarWithTitle()
        ui_tf_phone.text = tempPhone
        ui_tf_country.text = countryCode.flag
        ui_tf_country.inputView = ui_pickerView

        selectPickerCountry()
    }

    private func setupPickerViews() {
        ui_pickerView.dataSource = self
        ui_pickerView.delegate = self
    }

    private func setupNewFields() {
        // Configure stack view
        ui_stackview.axis = .vertical
        ui_stackview.spacing = 16

        // --- Gender ---
        let genderContainer = createContainerView(topMargin: 20)
        genderLabel = createLabel(text: "Je suis".localized)
        genderTextField = createTextField(placeholder: "Sélectionner dans la liste")
        genderPickerView = createPickerView(tag: 1)
        genderTextField.inputView = genderPickerView
        genderTextField.inputAccessoryView = createToolbar()
        genderContainer.addArrangedSubview(genderLabel)
        genderContainer.addArrangedSubview(genderTextField)

        // --- How We Met ---
        let howWeMetContainer = createContainerView()
        howWeMetLabel = createLabel(text: "Comment vous nous avez connu ?".localized)
        howWeMetTextField = createTextField(placeholder: "Sélectionner dans la liste")
        howWeMetPickerView = createPickerView(tag: 2)
        howWeMetTextField.inputView = howWeMetPickerView
        howWeMetTextField.inputAccessoryView = createToolbar()
        howWeMetContainer.addArrangedSubview(howWeMetLabel)
        howWeMetContainer.addArrangedSubview(howWeMetTextField)

        // --- Company ---
        companyContainer = createContainerView()
        companyLabel = createLabel(text: "Nom de votre entreprise".localized)
        companyTextField = createTextField(placeholder: "Sélectionner une entreprise")
        companyPickerView = createPickerView(tag: 3)
        companyTextField.inputView = companyPickerView
        companyTextField.inputAccessoryView = createToolbar()
        companyContainer.addArrangedSubview(companyLabel)
        companyContainer.addArrangedSubview(companyTextField)

        // --- Event ---
        eventContainer = createContainerView()
        eventLabel = createLabel(text: "Événement auquel vous participez".localized)
        eventTextField = createTextField(placeholder: "Sélectionner un événement")
        eventPickerView = createPickerView(tag: 4)
        eventTextField.inputView = eventPickerView
        eventTextField.inputAccessoryView = createToolbar()
        eventContainer.addArrangedSubview(eventLabel)
        eventContainer.addArrangedSubview(eventTextField)

        // --- Placement dans la stack ---
        // 1) "Je suis" en tout premier
        ui_stackview.insertArrangedSubview(genderContainer, at: 0)

        // 2) "Comment vous nous avez connu ?" à sa position prévue (index 5 si dispo)
        ui_stackview.insertArrangedSubview(howWeMetContainer, at: min(5, ui_stackview.arrangedSubviews.count))

        // 3) Entreprise + Événement juste APRÈS "Comment vous nous avez connu ?"
        if let howIdx = ui_stackview.arrangedSubviews.firstIndex(of: howWeMetContainer) {
            ui_stackview.insertArrangedSubview(companyContainer, at: howIdx + 1)
            ui_stackview.insertArrangedSubview(eventContainer,   at: howIdx + 2)
        } else {
            // Fallback si jamais l'index n'est pas trouvé (rare)
            ui_stackview.addArrangedSubview(companyContainer)
            ui_stackview.addArrangedSubview(eventContainer)
        }

        // Masqués par défaut (on togglera via isHidden + begin/endUpdates)
        companyContainer.isHidden = true
        eventContainer.isHidden = true

        // --- Date Picker pour l'anniversaire ---
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        ui_textfield_birthday.inputView = datePicker
        ui_textfield_birthday.inputAccessoryView = createToolbar()
    }

    private func createContainerView(topMargin: CGFloat = 0) -> UIStackView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 4
        container.layoutMargins = UIEdgeInsets(top: topMargin, left: 30, bottom: 0, right: 30)
        container.isLayoutMarginsRelativeArrangement = true
        return container
    }

    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.setFontTitle(size: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return label
    }

    private func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.setFontBody(size: 14)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return textField
    }

    private func createPickerView(tag: Int) -> UIPickerView {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.tag = tag
        return pickerView
    }

    private func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePicker))
        toolbar.setItems([doneButton], animated: true)
        return toolbar
    }

    private func updateCompanyAndEventVisibility(show: Bool) {
        // >>> Correction: on MASQUE/affiche, on ne supprime PLUS du stack
        companyContainer.isHidden = !show
        eventContainer.isHidden = !show

        // Force layout + recalcul hauteur cellule
        if let table = enclosingTableView() {
            UIView.performWithoutAnimation {
                table.beginUpdates()
                table.endUpdates()
            }
        } else {
            self.contentView.setNeedsLayout()
            self.contentView.layoutIfNeeded()
        }
        // <<<
    }

    @objc private func dateChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        ui_textfield_birthday.text = dateFormatter.string(from: datePicker.date)
    }

    @objc private func donePicker() {
        self.endEditing(true)
    }

    // MARK: - Public Methods
    func populateCell(username: String?, lastname: String?, countryCode: CountryCode?, phone: String?, email: String?, isCheck: Bool, delegate: OnboardingStartDelegate) {
        self.delegate = delegate
        ui_tf_firstname.text = username
        ui_tf_lastname.text = lastname
        ui_tf_phone.text = phone
        ui_tf_email.text = email

        if let countryCode = countryCode {
            self.countryCode = countryCode
        }

        selectPickerCountry()
        _ = checkAndValidateFirstLastnames()
        _ = checkAndValidatePhone()
        _ = checkAndValidateEmail()
        self.isChecked = isCheck
        updateCheckImage()
    }

    private func selectPickerCountry() {
        for i in 0..<pickerDatas.count {
            if pickerDatas[i].code == countryCode.code {
                ui_pickerView.selectRow(i, inComponent: 0, animated: false)
                // optionnel: rafraîchir le champ visuel du code pays
                // ui_tf_country.text = pickerDatas[i].flag
                break
            }
        }
    }

    @IBAction func action_check_unchek(_ sender: Any) {
        isChecked = !isChecked
        updateCheckImage()
        delegate?.validateConsent(isChecked: isChecked)
    }

    private func updateCheckImage() {
        ui_iv_check.image = isChecked ? UIImage(named: "checkbox_checked") : UIImage(named: "checkbox_unchecked")
    }

    // MARK: - Validation
    func checkAndValidateFirstLastnames() -> Bool {
        let firstCount = ui_tf_firstname.text?.count ?? 0
        let lastCount = ui_tf_lastname.text?.count ?? 0

        if firstCount >= minimumCharacters && lastCount >= minimumCharacters {
            ui_error_firstname.isHidden = true
            ui_error_lastname.isHidden = true
            return true
        }

        if firstCount >= minimumCharacters || firstCount == 0 {
            ui_error_firstname.isHidden = true
        } else {
            ui_error_firstname.isHidden = false
        }

        if lastCount >= minimumCharacters || lastCount == 0 {
            ui_error_lastname.isHidden = true
        } else {
            ui_error_lastname.isHidden = false
        }

        return false
    }

    func checkAndValidatePhone() -> Bool {
        if ui_tf_phone.text?.count ?? 0 >= minimumPhoneCharacters {
            ui_error_phone.isHidden = true
            return true
        }

        if ui_tf_phone.text?.count ?? 0 > 0 {
            ui_error_phone.isHidden = false
        }

        return false
    }

    func checkAndValidateEmail() -> Bool {
        if ui_tf_email.text?.isValidEmail ?? false {
            ui_error_email.isHidden = true
            return true
        }

        if ui_tf_email.text?.count ?? 0 > 0 {
            ui_error_email.isHidden = false
        } else {
            ui_error_email.isHidden = true
        }

        return false
    }

    // MARK: - Utils
    private func enclosingTableView() -> UITableView? {
        var view: UIView? = self
        while let v = view {
            if let t = v as? UITableView { return t }
            view = v.superview
        }
        return nil
    }
}

// MARK: - UITextFieldDelegate
extension OnboardingStartCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == ui_tf_firstname || textField == ui_tf_lastname {
            if checkAndValidateFirstLastnames() {
                delegate?.validateFirstLastname(firstName: ui_tf_firstname.text, lastname: ui_tf_lastname.text)
            } else {
                delegate?.validateFirstLastname(firstName: nil, lastname: nil)
            }
        } else if textField == ui_tf_phone {
            if checkAndValidatePhone() {
                delegate?.validatePhoneNumber(prefix: countryCode, phoneNumber: ui_tf_phone.text)
            } else {
                delegate?.validatePhoneNumber(prefix: countryCode, phoneNumber: nil)
            }
        } else if textField == ui_tf_email {
            if checkAndValidateEmail() {
                delegate?.validateEmail(email: ui_tf_email.text)
            } else {
                delegate?.validateEmail(email: nil)
            }
        } else if textField == genderTextField {
            delegate?.validateGender(gender: genderTextField.text)
        } else if textField == howWeMetTextField {
            delegate?.validateHowWeMet(howWeMet: howWeMetTextField.text)
        } else if textField == companyTextField {
            delegate?.validateCompany(company: companyTextField.text)
        } else if textField == eventTextField {
            delegate?.validateEvent(event: eventTextField.text)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == ui_tf_firstname {
            ui_tf_lastname.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            if textField == ui_tf_lastname {
                if checkAndValidateFirstLastnames() {
                    delegate?.validateFirstLastname(firstName: ui_tf_firstname.text, lastname: ui_tf_lastname.text)
                } else {
                    delegate?.validateFirstLastname(firstName: nil, lastname: nil)
                }
            } else if textField == ui_tf_phone {
                if checkAndValidatePhone() {
                    delegate?.validatePhoneNumber(prefix: countryCode, phoneNumber: ui_tf_phone.text)
                } else {
                    delegate?.validatePhoneNumber(prefix: countryCode, phoneNumber: nil)
                }
            } else if textField == ui_tf_email {
                delegate?.validateEmail(email: ui_tf_email.text)
            }
        }
        return true
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension OnboardingStartCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return genderOptions.count
        case 2:
            return howWeMetOptions.count
        case 3:
            return companyOptions.count
        case 4:
            return eventOptions.count
        default:
            return pickerDatas.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return genderOptions[row]
        case 2:
            return howWeMetOptions[row]
        case 3:
            return companyOptions[row]
        case 4:
            return eventOptions[row]
        default:
            return "\(pickerDatas[row].flag) \(pickerDatas[row].country)"
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            genderTextField.text = genderOptions[row]
            delegate?.validateGender(gender: genderOptions[row])
        case 2:
            howWeMetTextField.text = howWeMetOptions[row]
            delegate?.validateHowWeMet(howWeMet: howWeMetOptions[row])

            let shouldShowCompanyAndEvent = howWeMetOptions[row] == "Sensibilisation entreprise"
            updateCompanyAndEventVisibility(show: shouldShowCompanyAndEvent)

        case 3:
            companyTextField.text = companyOptions[row]
            delegate?.validateCompany(company: companyOptions[row])
        case 4:
            eventTextField.text = eventOptions[row]
            delegate?.validateEvent(event: eventOptions[row])
        default:
            ui_tf_country.text = pickerDatas[row].flag
            countryCode = pickerDatas[row]
            _ = checkAndValidatePhone()
            delegate?.validatePhoneNumber(prefix: countryCode, phoneNumber: ui_tf_phone.text)
        }
    }
}

// MARK: - OnboardingStartDelegate
protocol OnboardingStartDelegate: AnyObject {
    func validateFirstLastname(firstName: String?, lastname: String?)
    func validatePhoneNumber(prefix: CountryCode, phoneNumber: String?)
    func validateEmail(email: String?)
    func validateConsent(isChecked: Bool)
    func validateGender(gender: String?)
    func validateHowWeMet(howWeMet: String?)
    func validateCompany(company: String?)
    func validateEvent(event: String?)
}

// MARK: - CountryCode
struct CountryCode {
    var country = ""
    var code = ""
    var flag = ""
}
