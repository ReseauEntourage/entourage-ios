//
//  ZoneChoiceViewController.swift
//  entourage
//

import UIKit
import MapKit
import GooglePlaces
import CoreLocation

// MARK: - Result

struct ZoneChoiceResult {
    let place: GMSPlace?
    let coordinate: CLLocationCoordinate2D?
    let label: String?
    let radiusKm: Int
}

// MARK: - Next Step

enum ZoneChoiceNextStep {
    case onboardingEnd
    case associationOnboarding
}

// MARK: - Delegate

protocol ZoneChoiceViewControllerDelegate: AnyObject {
    func zoneChoiceConfirmed(result: ZoneChoiceResult)
    func zoneChoiceCancelled()
}

// MARK: - ViewController

final class ZoneChoiceViewController: UIViewController, GMSAutocompleteViewControllerDelegate {

    // MARK: - Public API

    var initialCoordinate: CLLocationCoordinate2D?
    var initialLabel: String?
    var initialRadiusKm: Int = 20

    weak var delegate: ZoneChoiceViewControllerDelegate?

    /// Indique ce qui doit se passer après la sauvegarde de la zone.
    private let nextStep: ZoneChoiceNextStep

    // callbacks optionnels (API par closures)
    private var onConfirmClosure: ((ZoneChoiceResult) -> Void)?
    private var onCancelClosure: (() -> Void)?

    // MARK: - UI

    private let contentContainerView = UIView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private let cityTitleLabel = UILabel()
    private let cityButton = UIButton(type: .system)
    private let cityConfidentialLabel = UILabel()

    private let radiusTitleLabel = UILabel()
    private let radiusValueLabel = UILabel()
    private let slider = UISlider()

    private let mapContainerView = UIView()
    private let mapView = MKMapView()

    private let bottomBar = UIView()
    private let bottomSeparator = UIView()
    private let previousButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)

    // MARK: - State

    private var selectedCoord: CLLocationCoordinate2D?
    private var selectedPlace: GMSPlace?
    private var selectedLabel: String?
    private var currentRadiusKm: Int = 20

    // MARK: - Init

    init(initialCoordinate: CLLocationCoordinate2D? = nil,
         initialLabel: String? = nil,
         initialRadiusKm: Int = 20,
         delegate: ZoneChoiceViewControllerDelegate? = nil,
         nextStep: ZoneChoiceNextStep = .onboardingEnd,
         onConfirm: ((ZoneChoiceResult) -> Void)? = nil,
         onCancel: (() -> Void)? = nil) {

        self.initialCoordinate = initialCoordinate
        self.initialLabel = initialLabel
        self.initialRadiusKm = initialRadiusKm
        self.delegate = delegate
        self.nextStep = nextStep
        self.onConfirmClosure = onConfirm
        self.onCancelClosure = onCancel
        self.currentRadiusKm = initialRadiusKm

        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        setupLayout()
        setupHeader()
        setupCitySection()
        setupRadiusSection()
        setupMap()
        setupBottomBar()
        setupInitialState()
    }

    // MARK: - Setup UI

    private func setupLayout() {
        view.addSubview(contentContainerView)
        view.addSubview(bottomBar)

        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Bottom bar collée en bas
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            // Contenu au-dessus de la bottom bar
            contentContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor)
        ])

        bottomBar.backgroundColor = .systemBackground

        // Scroll dans le container
        contentContainerView.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor)
        ])

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func setupHeader() {
        titleLabel.text = NSLocalizedString("onboarding_zone_title",
                                            comment: "Votre localisation")
        titleLabel.setFontTitle(size: 24) // même taille que les autres steps
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor(white: 0.1, alpha: 1.0)

        subtitleLabel.text = NSLocalizedString(
            "onboarding_zone_subtitle",
            comment: "Cette information nous permet d’affiner les actions proches de chez vous."
        )
        subtitleLabel.setFontBody(size: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }

    private func setupCitySection() {
        // Label "Ville" supprimé
        cityTitleLabel.text = ""
        cityTitleLabel.isHidden = true

        // Placeholder si aucune ville sélectionnée
        let cityTitle: String
        if let label = initialLabel, !label.isEmpty {
            cityTitle = label
        } else {
            cityTitle = "Ex. : Valence"
        }
        cityButton.setTitle(cityTitle, for: .normal)
        cityButton.setTitleColor(.label, for: .normal)
        cityButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        cityButton.tintColor = UIColor(white: 0.7, alpha: 1.0)
        cityButton.contentHorizontalAlignment = .left
        cityButton.contentVerticalAlignment = .center
        cityButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        cityButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)

        // Fond blanc, bordure légère
        cityButton.backgroundColor = .white
        cityButton.layer.cornerRadius = 10
        cityButton.layer.borderWidth = 1
        cityButton.layer.borderColor = UIColor(white: 0.92, alpha: 1.0).cgColor

        cityButton.setFontBody(size: 16)
        cityButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        cityButton.addTarget(self, action: #selector(openAutocomplete), for: .touchUpInside)

        // Texte "L'adresse est confidentielle..." supprimé
        cityConfidentialLabel.text = ""
        cityConfidentialLabel.isHidden = true

        contentView.addSubview(cityTitleLabel)
        contentView.addSubview(cityButton)
        contentView.addSubview(cityConfidentialLabel)

        cityTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        cityButton.translatesAutoresizingMaskIntoConstraints = false
        cityConfidentialLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cityTitleLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            cityTitleLabel.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor),
            cityTitleLabel.trailingAnchor.constraint(equalTo: subtitleLabel.trailingAnchor),

            cityButton.topAnchor.constraint(equalTo: cityTitleLabel.bottomAnchor, constant: 8),
            cityButton.leadingAnchor.constraint(equalTo: cityTitleLabel.leadingAnchor),
            cityButton.trailingAnchor.constraint(equalTo: cityTitleLabel.trailingAnchor),

            cityConfidentialLabel.topAnchor.constraint(equalTo: cityButton.bottomAnchor, constant: 6),
            cityConfidentialLabel.leadingAnchor.constraint(equalTo: cityTitleLabel.leadingAnchor),
            cityConfidentialLabel.trailingAnchor.constraint(equalTo: cityTitleLabel.trailingAnchor)
        ])
    }

    private func setupRadiusSection() {
        radiusTitleLabel.text = NSLocalizedString("onboarding_zone_radius_title",
                                                  comment: "Dans un rayon de")
        // Texte en gris (vs bleu)
        radiusTitleLabel.textColor = .secondaryLabel
        radiusTitleLabel.setFontBody(size: 14)

        radiusValueLabel.setFontBody(size: 14)
        radiusValueLabel.textAlignment = .right
        radiusValueLabel.textColor = UIColor(white: 0.2, alpha: 1.0)

        slider.minimumValue = 1
        slider.maximumValue = 100
        slider.value = Float(initialRadiusKm)
        slider.minimumTrackTintColor = UIColor.appOrange
        slider.maximumTrackTintColor = UIColor(white: 0.85, alpha: 1.0)
        slider.thumbTintColor = .white
        slider.layer.shadowColor = UIColor.black.cgColor
        slider.layer.shadowOpacity = 0.15
        slider.layer.shadowRadius = 3
        slider.layer.shadowOffset = CGSize(width: 0, height: 1)
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)

        contentView.addSubview(radiusTitleLabel)
        contentView.addSubview(radiusValueLabel)
        contentView.addSubview(slider)

        radiusTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        radiusValueLabel.translatesAutoresizingMaskIntoConstraints = false
        slider.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            radiusTitleLabel.topAnchor.constraint(equalTo: cityConfidentialLabel.bottomAnchor, constant: 20),
            radiusTitleLabel.leadingAnchor.constraint(equalTo: cityConfidentialLabel.leadingAnchor),

            radiusValueLabel.centerYAnchor.constraint(equalTo: radiusTitleLabel.centerYAnchor),
            radiusValueLabel.trailingAnchor.constraint(equalTo: cityConfidentialLabel.trailingAnchor),

            slider.topAnchor.constraint(equalTo: radiusTitleLabel.bottomAnchor, constant: 12),
            slider.leadingAnchor.constraint(equalTo: radiusTitleLabel.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: radiusValueLabel.trailingAnchor)
        ])
    }

    private func setupMap() {
        mapContainerView.backgroundColor = .clear
        mapContainerView.layer.cornerRadius = 12
        mapContainerView.layer.borderWidth = 1
        mapContainerView.layer.borderColor = UIColor(white: 0.92, alpha: 1.0).cgColor
        mapContainerView.clipsToBounds = true

        mapView.delegate = self
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false

        contentView.addSubview(mapContainerView)
        mapContainerView.addSubview(mapView)

        mapContainerView.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mapContainerView.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 20),
            mapContainerView.leadingAnchor.constraint(equalTo: slider.leadingAnchor),
            mapContainerView.trailingAnchor.constraint(equalTo: slider.trailingAnchor),
            mapContainerView.heightAnchor.constraint(equalToConstant: 220),

            mapView.topAnchor.constraint(equalTo: mapContainerView.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: mapContainerView.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: mapContainerView.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: mapContainerView.bottomAnchor),

            // Important pour que le scroll ait une hauteur complète
            mapContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    private func setupBottomBar() {
        bottomBar.addSubview(bottomSeparator)
        bottomSeparator.translatesAutoresizingMaskIntoConstraints = false
        bottomSeparator.backgroundColor = UIColor(white: 0.92, alpha: 1.0)
        // Ligne masquée selon ta nouvelle UI
        bottomSeparator.isHidden = true

        previousButton.setTitle(NSLocalizedString("onboard_bt_back", comment: "Précédent"), for: .normal)
        previousButton.setTitleColor(.black, for: .normal)
        previousButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        previousButton.layer.cornerRadius = 22
        previousButton.layer.borderWidth = 1
        previousButton.layer.borderColor = UIColor.appOrange.cgColor
        previousButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        nextButton.setTitle(NSLocalizedString("onboard_bt_next", comment: "Suivant"), for: .normal)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        nextButton.backgroundColor = .appOrange
        nextButton.layer.cornerRadius = 22
        nextButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        bottomBar.addSubview(previousButton)
        bottomBar.addSubview(nextButton)

        previousButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bottomSeparator.topAnchor.constraint(equalTo: bottomBar.topAnchor),
            bottomSeparator.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor),
            bottomSeparator.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 1),

            previousButton.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 24),
            previousButton.topAnchor.constraint(equalTo: bottomSeparator.bottomAnchor, constant: 16),
            previousButton.heightAnchor.constraint(equalToConstant: 44),

            nextButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -24),
            nextButton.centerYAnchor.constraint(equalTo: previousButton.centerYAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: 44),

            previousButton.trailingAnchor.constraint(equalTo: bottomBar.centerXAnchor, constant: -8),
            nextButton.leadingAnchor.constraint(equalTo: bottomBar.centerXAnchor, constant: 8),

            nextButton.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor, constant: -16)
        ])
    }

    private func setupInitialState() {
        currentRadiusKm = initialRadiusKm
        updateRadiusValueLabel()

        if let c = initialCoordinate {
            selectedCoord = c
            selectedLabel = initialLabel
            if let label = initialLabel {
                cityButton.setTitle(label, for: .normal)
            }
            centerMap()
            drawCircle()
            updateNextButtonEnabled(true)
        } else {
            // Carte initiale : France
            let franceCenter = CLLocationCoordinate2D(latitude: 46.5, longitude: 2.2)
            let region = MKCoordinateRegion(center: franceCenter,
                                            span: MKCoordinateSpan(latitudeDelta: 6.0,
                                                                   longitudeDelta: 6.0))
            mapView.setRegion(region, animated: false)
            updateNextButtonEnabled(false)
        }
    }

    // MARK: - Actions

    @objc private func sliderChanged() {
        currentRadiusKm = Int(slider.value.rounded())
        if currentRadiusKm < 1 { currentRadiusKm = 1 }
        slider.value = Float(currentRadiusKm)
        updateRadiusValueLabel()
        drawCircle()
        centerMap()
    }

    private func updateRadiusValueLabel() {
        radiusValueLabel.text = "\(currentRadiusKm) km"
    }

    private func updateNextButtonEnabled(_ enabled: Bool) {
        nextButton.isEnabled = enabled
        nextButton.alpha = enabled ? 1.0 : 0.5
        nextButton.backgroundColor = enabled ? .appOrange : .appOrange.withAlphaComponent(0.5)
    }

    @objc private func openAutocomplete() {
        let ac = GMSAutocompleteViewController()
        ac.delegate = self
        // On demande explicitement les champs utiles
        ac.placeFields = [.name, .formattedAddress, .coordinate, .placeID]
        present(ac, animated: true)
    }

    @objc private func cancelTapped() {
        delegate?.zoneChoiceCancelled()
        onCancelClosure?()

        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func confirmTapped() {
        guard let coord = selectedCoord else {
            showZoneError(messageKey: "onboarding_zone_pick_location_first")
            return
        }

        let result = ZoneChoiceResult(
            place: selectedPlace,
            coordinate: coord,
            label: selectedLabel ?? initialLabel,
            radiusKm: currentRadiusKm
        )

        // On remonte le choix avant le réseau
        delegate?.zoneChoiceConfirmed(result: result)
        onConfirmClosure?(result)

        updateNextButtonEnabled(false)

        // 1) travel_distance
        AuthService.updateTravelDistance(currentRadiusKm) { [weak self] error in
            guard let self = self else { return }

            guard error == nil else {
                self.updateNextButtonEnabled(true)
                self.showZoneError()
                return
            }

            // 2) adresse primaire
            let googlePlaceId = self.selectedPlace?.placeID
            AuthService.updatePrimaryAddress(
                googlePlaceId: googlePlaceId,
                coordinate: coord,
                label: self.selectedLabel ?? self.initialLabel
            ) { [weak self] error2 in
                guard let self = self else { return }

                self.updateNextButtonEnabled(true)

                guard error2 == nil else {
                    self.showZoneError()
                    return
                }

                // 3) Navigation interne selon nextStep
                switch self.nextStep {
                case .onboardingEnd:
                    self.goToOnboardingEnd()
                case .associationOnboarding:
                    self.goToAssociationOnboarding()
                }
            }
        }
    }

    private func showZoneError(messageKey: String = "user_action_zone_send_failed") {
        let message = NSLocalizedString(messageKey,
                                        comment: "Erreur lors de l’envoi de la zone")
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("OK", comment: "OK"),
                style: .default,
                handler: nil
            )
        )
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Navigation

    private func goToOnboardingEnd() {
        let storyboard = UIStoryboard(name: StoryboardName.onboarding, bundle: nil)
        if let endVC = storyboard.instantiateViewController(
            withIdentifier: "OnboardingEndViewController"
        ) as? OnboardingEndViewController {
            if let nav = navigationController {
                nav.pushViewController(endVC, animated: true)
            } else {
                endVC.modalPresentationStyle = .fullScreen
                present(endVC, animated: true, completion: nil)
            }
        }
    }

    private func goToAssociationOnboarding() {
        let associationVC = AssociationOnboardingViewController()
        if let nav = navigationController {
            nav.pushViewController(associationVC, animated: true)
        } else {
            associationVC.modalPresentationStyle = .fullScreen
            present(associationVC, animated: true, completion: nil)
        }
    }

    // MARK: - Map helpers

    private func centerMap() {
        guard let c = selectedCoord else { return }

        let region = MKCoordinateRegion(
            center: c,
            latitudinalMeters: Double(currentRadiusKm) * 2200,
            longitudinalMeters: Double(currentRadiusKm) * 2200
        )
        mapView.setRegion(region, animated: true)
    }

    private func drawCircle() {
        mapView.removeOverlays(mapView.overlays)
        guard let c = selectedCoord else { return }

        let circle = MKCircle(center: c, radius: Double(currentRadiusKm) * 1000)
        mapView.addOverlay(circle)
    }

    // MARK: - GMSAutocompleteViewControllerDelegate

    func viewController(_ viewController: GMSAutocompleteViewController,
                        didAutocompleteWith place: GMSPlace) {
        print("✅ didAutocompleteWith place:", place.name ?? "nil", place.coordinate)
        selectedPlace = place
        selectedCoord = place.coordinate

        let label = place.name ?? place.formattedAddress ?? ""
        selectedLabel = label
        initialLabel = label

        cityButton.setTitle(label, for: .normal)
        centerMap()
        drawCircle()
        updateNextButtonEnabled(true)

        viewController.dismiss(animated: true)
    }

    func viewController(_ viewController: GMSAutocompleteViewController,
                        didFailAutocompleteWithError error: Error) {
        print("❌ didFailAutocompleteWithError:", error.localizedDescription)
        viewController.dismiss(animated: true)
    }

    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("ℹ️ Autocomplete wasCancelled")
        viewController.dismiss(animated: true)
    }
}

// MARK: - MKMapViewDelegate

extension ZoneChoiceViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView,
                 rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circle = overlay as? MKCircle else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKCircleRenderer(circle: circle)
        renderer.strokeColor = UIColor.appOrange
        renderer.fillColor = UIColor.appOrange.withAlphaComponent(0.25)
        renderer.lineWidth = 1
        return renderer
    }
}

// MARK: - UIButton font helper

private extension UIButton {
    func setFontBody(size: CGFloat) {
        titleLabel?.setFontBody(size: size)
    }
}

// MARK: - Helper pour présenter depuis l’onboarding

extension UIViewController {
    func presentZoneChoiceSwiftUI(initialCoordinate: CLLocationCoordinate2D? = nil,
                                  initialLabel: String? = nil,
                                  initialRadiusKm: Int = 20,
                                  nextStep: ZoneChoiceNextStep = .onboardingEnd,
                                  onConfirm: @escaping (ZoneChoiceResult) -> Void,
                                  onCancel: @escaping () -> Void) {

        let vc = ZoneChoiceViewController(
            initialCoordinate: initialCoordinate,
            initialLabel: initialLabel,
            initialRadiusKm: initialRadiusKm,
            delegate: nil,
            nextStep: nextStep,
            onConfirm: onConfirm,
            onCancel: onCancel
        )

        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
}
