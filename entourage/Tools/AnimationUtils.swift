import UIKit

class AnimationUtils {
    static func animateCell(_ cell: UICollectionViewCell, index: Int) {
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: 20, y: 0)

        // Use a modulo to create a wave effect without accumulating too much delay for long lists
        // This ensures the first few items cascade, and scrolling reveals items with a slight pop/slide
        let delay = 0.05 * Double(index % 4)

        UIView.animate(withDuration: 0.3, delay: delay, options: [.curveEaseOut, .allowUserInteraction], animations: {
            cell.alpha = 1
            cell.transform = .identity
        }, completion: nil)
    }
}
