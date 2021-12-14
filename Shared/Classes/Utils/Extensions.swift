//
//  UIColor+Extensions.swift
//  entourage
//
//  Created by Jr on 23/04/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import Foundation

//MARK: - Extensions UIColor -
extension UIColor {
    static var appBlack30: UIColor {
        return UIColor(red: 30 / 255.0, green: 30 / 255.0, blue: 30 / 255.0, alpha: 1.0)
    }
    static var appWhite246: UIColor {
        return UIColor(red: 246 / 255.0, green: 246 / 255.0, blue: 246 / 255.0, alpha: 1.0)
    }
    static var appGrey165: UIColor {
        return UIColor(red: 165 / 255.0, green: 165 / 255.0, blue: 156 / 255.0, alpha: 1.0)
    }
    static var appGrey151: UIColor {
        return UIColor(red: 151 / 255.0, green: 151 / 255.0, blue: 151 / 255.0, alpha: 1.0)
    }
}

//MARK: - Extensions String -
extension String {
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}

//MARK: - Extensions CLLocation -
extension CLLocation {
    func geocode(completion: @escaping (_ placemark: [CLPlacemark]?, _ error: Error?) -> Void)  {
        CLGeocoder().reverseGeocodeLocation(self, completionHandler: completion)
    }
}

//MARK: uiviewController
extension UIViewController {
    func addCloseButtonLeftWithWhiteColorBar() {
        OTAppConfiguration.configureNavigationControllerAppearance(self.navigationController, withMainColor: UIColor.white, andSecondaryColor: UIColor.appOrange())
        var img:UIImage?
        if #available(iOS 13.0, *) {
            img = (UIImage.init(named: "close")?.withTintColor(UIColor.appOrange(), renderingMode: .alwaysTemplate))
        } else {
            img = UIImage.init(named: "close")
            img = img?.withRenderingMode(.alwaysTemplate)
        }
        
        let closeButton = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(ClosePopDelegate.close))
        self.navigationItem.setLeftBarButton(closeButton, animated: false)
        closeButton.tintColor = UIColor.appOrange()
    }
}

@objc protocol ClosePopDelegate {
    func close()
}
