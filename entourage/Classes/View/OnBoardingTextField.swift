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
      let attributes = [NSForegroundColorAttributeName: UIColor.appTextFieldPlaceholder(),
                        NSFontAttributeName: UIColor.appTextFieldPlaceholderFont()] as [String : Any]
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
                                           name: NSNotification.Name.UITextFieldTextDidChange, object: self)
  }

  func textDidChange() {
    let isValid = inputIsValid(text)
    inputValidationChanged?(isValid)
  }
}

class OnBoardingCodeTextField: OnBoardingTextField {
  override func awakeFromNib() {
    super.awakeFromNib()
    inputIsValid = { text in
      return text?.characters.count == 6
    }
  }
}

class OnBoardingNumberTextField: NBTextField {
  override func awakeFromNib() {
    super.awakeFromNib()

    if let placeholder = placeholder {
      let attributes = [NSForegroundColorAttributeName: UIColor.appTextFieldPlaceholder(),
                        NSFontAttributeName: UIColor.appTextFieldPlaceholderFont()] as [String : Any]
      attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
    }
  }
}

class OnBoardingButton: UIButton {

  override func awakeFromNib() {
    super.awakeFromNib()
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
    if text?.characters.last == " " {
      if let indexNumberWithWhiteSpace = text?.characters.index((text?.endIndex)!, offsetBy: -1) {
        text = text?.substring(to: indexNumberWithWhiteSpace)
      }
      return
    }
    super.deleteBackward()
  }


  // MARK: Notification for "UITextFieldTextDidChangeNotification"

  fileprivate func registerForNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(NBTextField.numberTextDidChange),
                                           name: NSNotification.Name.UITextFieldTextDidChange, object: self)
  }

  func numberTextDidChange() {
    let numbersOnly = phoneNumberUtility.normalizePhoneNumber(text)
    //text = phoneNumberFormatter.inputStringAndRememberPosition(numbersOnly)

    var isValid = inputIsValid(numbersOnly)
    isValid = true
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
