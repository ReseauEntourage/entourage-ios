//
//  Extensions.swift
//  entourage
//
//  Created by Jerome on 11/01/2022.
//

import UIKit
import MapKit

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
    
    func matchesRegEx(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    func urlFromString() -> String {
        var urlString = ""
        do {
            try urlString = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            return urlString
        }catch {
            return ""
        }
    }
    
    func extractUrlFromChain()-> URL?{
        let chains = self.split(separator: " ")
        for chain in chains{
            if chain.contains("https"){
                if let url = URL(string: String(chain)){
                    return url
                }
            }
        }
        return nil
    }
}

//MARK: - Date -
extension Date {
    func setStartOfDay() -> Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.minute = 0
        components.second = 0
        components.hour = 0
        
        return calendar.date(from: components)
    }
    
    func setEndOfDay() -> Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.minute = 59
        components.second = 59
        components.hour = 23
        
        return calendar.date(from: components)
    }
    
    func dayNameOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
}

//MARK: - Locale -
extension Locale {
   static func getPreferredLocale() -> Locale {
        guard let preferredIdentifier = Locale.preferredLanguages.first else {
            return Locale.current
        }
        return Locale(identifier: preferredIdentifier)
    }
}

//MARK: - Bundle Extension -
extension Bundle {
    var versionName:String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    }
}

//MARK: - Network Query Helper -
protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {
    /**
     This computed property returns a query parameters string from the given NSDictionary. For
     example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
     string will be @"day=Tuesday&month=January".
     @return The computed parameters string.
     */
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                              String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                              String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
    
}

extension URL {
    /**
     Creates a new URL by adding the given query parameters.
     @param parametersDictionary The query parameter dictionary to add.
     @return A new URL.
    */
    func appendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
        let URLString : String = String(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        return URL(string: URLString)!
    }
    
    var checkAndAddScheme: URL {
        if var components = URLComponents(url: self, resolvingAgainstBaseURL: false) {
            if components.scheme == nil {
                components.scheme = "http"
            }
            return components.url ?? self
        }
        return self
    }
}


//MARK: - Extensions CLLocation -
extension CLLocation {
    func geocode(completion: @escaping (_ placemark: [CLPlacemark]?, _ error: Error?) -> Void)  {
        CLGeocoder().reverseGeocodeLocation(self, completionHandler: completion)
    }
}

//MARK: - MKMap Extension -
extension MKMapView {
    func zoomToLocation(location : CLLocationCoordinate2D,latitudinalMeters:CLLocationDistance = 500,longitudinalMeters:CLLocationDistance = 500) {
        let region = MKCoordinateRegion(center: location, latitudinalMeters: latitudinalMeters, longitudinalMeters: longitudinalMeters)
        setRegion(region, animated: true)
    }
}

//MARK: - DefaultStringInterpolation extension -
//for silent warning "String interpolation produces a debug description ... SO : https://stackoverflow.com/a/42543251"
extension DefaultStringInterpolation {
  mutating func appendInterpolation<T>(_ optional: T?) {
    appendInterpolation(String(describing: optional))
  }
}


extension UIView {
    func addRadiusTopOnly(radius:CGFloat = ApplicationTheme.bigCornerRadius) {
        layer.cornerRadius = radius
        layer.maskedCorners = .radiusTopOnly()
    }
    
    func addRadiusBottomOnly(radius:CGFloat = ApplicationTheme.bigCornerRadius) {
        layer.cornerRadius = radius
        layer.maskedCorners = .radiusBottomOnly()
    }
}

//MARK: - CACornerMask -
extension CACornerMask {
    static func radiusTopOnly() -> CACornerMask {
        return [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    static func radiusBottomOnly() -> CACornerMask {
        return [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
}

//MARK: - UILabel -

extension UILabel {
    func setupFontAndColor(style:MJTextFontColorStyle) {
        font = style.font
        textColor = style.color
    }
}

extension UIView {
    @IBInspectable var cradius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

extension UILabel {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

extension UITextField {
    func setupFontAndColor(style:MJTextFontColorStyle) {
        font = style.font
        textColor = style.color
    }
}
extension UITextView {
    func setupFontAndColor(style:MJTextFontColorStyle) {
        font = style.font
        textColor = style.color
    }
}

extension UIButton {
    func setupFontAndColor(style:MJTextFontColorStyle) {
        titleLabel?.font = style.font
        setTitleColor(style.color, for: .normal)
    }
}

extension Double {
    
    func displayDistance() -> String {
        var distString = ""
        if self < 1 {
            let distance_in_meter = 100 * self
            distString = String.init(format: "Atm".localized, distance_in_meter.rounded())
            return distString
        }else{
            return String.init(format: "AtKm".localized, self.rounded())
        }
    }
    
    func displayBaseStringDistance()-> String {
        var distString = ""
        if self < 1 {
            let distance_in_meter = 100 * self
            distString = String(format: "%.0f m", distance_in_meter.rounded())
            return distString
        }else{
            distString = String(format: "%.0f km", self.rounded())
            return distString
        }
    }
}


extension UIView {
    func setVisibilityGone(){
        self.isHidden = true
        self.heightAnchor.constraint(equalToConstant: 0).isActive = true
    }
    func setVisibilityVisible(height:CGFloat) {
        self.isHidden = false
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
}
