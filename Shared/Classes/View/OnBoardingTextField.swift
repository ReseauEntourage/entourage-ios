import UIKit
import libPhoneNumber_iOS
import JVFloatLabeledTextField

class OnBoardingTextField: JVFloatLabeledTextField, Validable {
  @objc var inputIsValid: (String?) -> (Bool) = { text in
    return text != nil && !(text!.isEmpty)
  }
  @objc var inputValidationChanged: ((Bool) -> (Void))?

  override func awakeFromNib() {
    super.awakeFromNib()

    if let placeholder = placeholder {
      let attributes = [NSAttributedString.Key.foregroundColor: UIColor.appTextFieldPlaceholder(),
                        NSAttributedString.Key.font: UIColor.appTextFieldPlaceholderFont()] as [NSAttributedString.Key : Any]
      attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
    }
    registerForNotifications()
    floatingLabelTextColor = tintColor
    autocorrectionType = .no
    autocapitalizationType = .none
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  private func registerForNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(textDidChange),
                                           name: UITextField.textDidChangeNotification, object: self)
  }

  @objc func textDidChange() {
    let isValid = inputIsValid(text)
    inputValidationChanged?(isValid)
  }
}

class OnBoardingCodeTextField: OnBoardingTextField {
  override func awakeFromNib() {
    super.awakeFromNib()
    inputIsValid = { text in
      return text?.count == 6
    }
  }
}

class OnBoardingNumberTextField: NBTextField {
  override func awakeFromNib() {
    super.awakeFromNib()

    if let placeholder = placeholder {
      let attributes = [NSAttributedString.Key.foregroundColor: UIColor.appTextFieldPlaceholder(),
                        NSAttributedString.Key.font: UIColor.appTextFieldPlaceholderFont()] as [NSAttributedString.Key : Any]
      attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
    }
  }
}

class OnBoardingButton: UIButton {

  override func awakeFromNib() {
    super.awakeFromNib()

    if let customImage = self.image(for: UIControl.State.normal) {
        let customImageWithTint = customImage.withRenderingMode(.alwaysTemplate)
        self.setImage(customImageWithTint, for: .normal)
        self.backgroundColor = UIColor.white
        self.tintColor = ApplicationTheme.shared().backgroundThemeColor
    }
  }

  override var isEnabled: Bool {
    didSet {
      alpha = isEnabled ? 1 : 0.7
    }
  }

}

@objc protocol Validable {
  var inputIsValid: (String?) -> (Bool) { get set }
  var inputValidationChanged: ((Bool) -> (Void))? { get set }
}

class NBTextField: JVFloatLabeledTextField, Validable {
  // MARK: Options/Variables for phone number formatting

  var phoneNumberUtility: NBPhoneNumberUtil = NBPhoneNumberUtil()
  var phoneNumberFormatter: NBAsYouTypeFormatter!
  @objc var inputIsValid: (String?) -> (Bool) = { _ in return true }
  @objc var inputValidationChanged: ((Bool) -> (Void))?

  var countryCode: String = "ro" {
    didSet {
      phoneNumberFormatter = NBAsYouTypeFormatter(regionCode: countryCode)
      numberTextDidChange()
    }
  }


  // MARK: Initialization

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    registerForNotifications()
    phoneNumberFormatter = NBAsYouTypeFormatter(regionCode: countryCode)
    inputIsValid = { text in
      return self.textIsValidMobilePhoneNumber(text: text)
    }
    keepBaseline = true
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }


  // MARK: UITextField input managing

  override open func deleteBackward() {
    if let myText=text, myText.last == " " {
        let indexNumberWithWhiteSpace = myText.index(myText.endIndex, offsetBy: -1)
        text = String(myText[..<indexNumberWithWhiteSpace])
        return
    }
    super.deleteBackward()
  }


  // MARK: Notification for "UITextFieldTextDidChangeNotification"

  fileprivate func registerForNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(NBTextField.numberTextDidChange),
                                           name: UITextField.textDidChangeNotification, object: self)
  }

  @objc func numberTextDidChange() {
    //let numbersOnly:Bool = phoneNumberUtility.isViablePhoneNumber(text)
    //text = phoneNumberFormatter.inputStringAndRememberPosition(numbersOnly)

    //var isValid = inputIsValid(numbersOnly)
    let isValid:Bool = true
    inputValidationChanged?(isValid)
  }

  func textIsValidMobilePhoneNumber(text: String?) -> Bool {
    do {
      let number = try phoneNumberUtility.parse(withPhoneCarrierRegion: text)
        if phoneNumberUtility.isValidNumber(number) {// && phoneNumberUtility.getNumberType(number) == .MOBILE {
        return true
      } else {
        return false
      }
    } catch {
      return false
    }
  }
}
