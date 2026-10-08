import UIKit
import SwiftUI

/// Étape 3 « Où et pour qui ? » (SwiftUI : EventCreatePhase3View).
class EventCreatePhase3ViewController: UIViewController {

    weak var pageDelegate: EventCreateMainDelegate? = nil
    private var viewModel: EventCreatePhase3ViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        guard let store = pageDelegate?.formStore else { return }

        let viewModel = EventCreatePhase3ViewModel(store: store)
        self.viewModel = viewModel
        embedSwiftUI(EventCreatePhase3View(store: store, viewModel: viewModel))
    }
}
