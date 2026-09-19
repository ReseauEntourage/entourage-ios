import UIKit
import CoreLocation
import GooglePlaces
import SwiftUI

class EventCreatePhase3ViewController: UIViewController {
    
    weak var pageDelegate: EventCreateMainDelegate? = nil
    var currentEvent: Event? = nil
    let viewModel = EventCreatePhase3ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if pageDelegate?.isEdit() ?? false {
            currentEvent = pageDelegate?.getCurrentEvent()
        }
        
        viewModel.onShowSelectLocation = { [weak self] in
            self?.showSelectLocation()
        }

        viewModel.load(currentEvent: currentEvent, delegate: pageDelegate)

        let hostingController = UIHostingController(rootView: EventCreatePhase3View(viewModel: self.viewModel))

        addChild(hostingController)
        view.addSubview(hostingController.view)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        hostingController.didMove(toParent: self)
    }
}

//MARK: - Location Selection Delegate -
extension EventCreatePhase3ViewController: PlaceViewControllerDelegate {
    func showSelectLocation() {
        AnalyticsLoggerManager.logEvent(name: Action_NewGroup_AddLocation)
        let sb = UIStoryboard.init(name: StoryboardName.profileParams, bundle: nil)
        
        if let vc = sb.instantiateViewController(withIdentifier: "place_choose_vc") as? ParamsChoosePlaceViewController {
            vc.placeVCDelegate = self
            vc.isFromEvent = true
            self.present(vc, animated: true)
        }
    }
    
    func modifyPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?) {
        // UPDATE: On passe l'adresse aux deux (UI et Back) quand ça vient de la carte
        viewModel.setLocation(
            currentlocation: currentlocation,
            displayAddress: currentLocationName,
            backEndAddress: currentLocationName,
            googlePlace: googlePlace
        )
    }
}
