import XCTest
@testable import entourage

/// Zone à toucher de 44 pt : élargie autour d'un petit bouton, sans changer sa taille visible.
final class ExpandedHitAreaButtonTests: XCTestCase {

    private func button(size: CGFloat) -> ExpandedHitAreaButton {
        let button = ExpandedHitAreaButton(type: .custom)
        button.frame = CGRect(x: 100, y: 100, width: size, height: size)
        return button
    }

    func testSmallButtonGetsA44PointTouchArea() {
        let button = button(size: 30)
        // 30 pt → 7 pt de chaque côté
        XCTAssertTrue(button.point(inside: CGPoint(x: -7, y: -7), with: nil))
        XCTAssertTrue(button.point(inside: CGPoint(x: 36.9, y: 36.9), with: nil))
        XCTAssertFalse(button.point(inside: CGPoint(x: -7.5, y: 15), with: nil))
        XCTAssertFalse(button.point(inside: CGPoint(x: 15, y: 37.5), with: nil))
    }

    func testVisibleSizeIsUnchanged() {
        let button = button(size: 30)
        XCTAssertEqual(button.frame.size, CGSize(width: 30, height: 30))
        XCTAssertEqual(button.bounds.size, CGSize(width: 30, height: 30))
    }

    func testLargeButtonKeepsItsOwnArea() {
        let button = button(size: 50)
        XCTAssertTrue(button.point(inside: CGPoint(x: 49, y: 49), with: nil))
        XCTAssertFalse(button.point(inside: CGPoint(x: -1, y: 25), with: nil))
        XCTAssertFalse(button.point(inside: CGPoint(x: 25, y: 51), with: nil))
    }

    func testNonSquareButtonOnlyGrowsOnItsShortSide() {
        let button = ExpandedHitAreaButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 80, height: 30)
        XCTAssertTrue(button.point(inside: CGPoint(x: 40, y: -7), with: nil))
        XCTAssertFalse(button.point(inside: CGPoint(x: -1, y: 15), with: nil))
    }
}
