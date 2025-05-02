import UIKit

private var linkHandlerKey: UInt8 = 0
extension UILabel {
    var linkHandler: ((URL) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &linkHandlerKey) as? (URL) -> Void
        }
        set {
            objc_setAssociatedObject(self, &linkHandlerKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func setTextWithLinksDetected(_ text: String, andLinkHandler linkHandler: @escaping (URL) -> Void) {
        self.linkHandler = linkHandler
        
        let dataDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSRange(location: 0, length: text.utf16.count)
        let attributedString = NSMutableAttributedString(string: text)
        
        if let dataDetector = dataDetector {
            dataDetector.enumerateMatches(in: text, options: [], range: range) { (result, _, _) in
                if let result = result, let url = result.url {
                    let linkAttributes: [NSAttributedString.Key: Any] = [
                        .foregroundColor: UIColor.appOrange,
                        .underlineColor: UIColor.appOrange,
                        .underlineStyle: NSUnderlineStyle.single.rawValue
                    ]
                    attributedString.addAttributes(linkAttributes, range: result.range)
                    
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
                    tapGesture.numberOfTapsRequired = 1
                    tapGesture.numberOfTouchesRequired = 1
                    tapGesture.accessibilityLabel = url.absoluteString
                    self.addGestureRecognizer(tapGesture)
                    self.isUserInteractionEnabled = true
                }
            }
        }
        
        self.attributedText = attributedString
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        guard let urlString = sender.accessibilityLabel, let url = URL(string: urlString) else {
            return
        }

        let layoutManager = NSLayoutManager()
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(size: self.bounds.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        layoutManager.addTextContainer(textContainer)

        let locationOfTouchInLabel = sender.location(in: self)
        let characterIndex = layoutManager.characterIndex(for: locationOfTouchInLabel, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        let glyphRange = layoutManager.glyphRange(forCharacterRange: NSRange(location: characterIndex, length: 1), actualCharacterRange: nil)
        let lineRect = layoutManager.lineFragmentRect(forGlyphAt: characterIndex, effectiveRange: nil)

        let relativePoint = CGPoint(x: locationOfTouchInLabel.x - lineRect.minX, y: locationOfTouchInLabel.y - lineRect.minY)
        let indexOfCharacter = layoutManager.characterIndex(for: relativePoint, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)        
        if let _url = self.text?.word(at: indexOfCharacter){
            linkHandler?(_url)
        }
    }

}

extension String {
    func word(at index: Int) -> URL? {
        let words = self.split(separator: " ")
        for word in words {
            if word.startIndex.encodedOffset <= index && word.endIndex.encodedOffset >= index {
                if let url = URL(string: String(word)), word.contains("https") {
                    return url
                } else {
                    return nil
                }
            }
        }
        return nil
    }
}


extension UILabel {
    func setFontTitle(size: CGFloat) {
        self.font = UIFont(name: "Quicksand-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
    
    func setFontBody(size: CGFloat) {
        self.font = UIFont(name: "NunitoSans-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
