import UIKit
import MapKit
import GooglePlaces
import CoreLocation

struct ZoneChoiceResult {
    let place: GMSPlace?
    let coordinate: CLLocationCoordinate2D?
    let label: String?
    let radiusKm: Int
}

enum ZoneChoiceNextStep {
    case onboardingEnd
    case associationOnboarding
}

protocol ZoneChoiceViewControllerDelegate: AnyObject {
    func zoneChoiceConfirmed(result: ZoneChoiceResult)
    func zoneChoiceCancelled()
}

final class ZoneChoiceViewController: UIViewController, GMSAutocompleteViewControllerDelegate {

    var initialCoordinate: CLLocationCoordinate2D?
    var initialLabel: String?
    var initialRadiusKm: Int = 20

    weak var delegate: ZoneChoiceViewControllerDelegate?

    private let nextStep: ZoneChoiceNextStep
    private var onConfirmClosure: ((ZoneChoiceResult) -> Void)?
    private var onCancelClosure: (() -> Void)?

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private let cityButton = UIButton(type: .system)

    private let radiusTitleLabel = UILabel()
    private let radiusValueLabel = UILabel()
    private let slider = UISlider()

    private let mapContainerView = UIView()
    private let mapView = MKMapView()

    private let bottomBar = UIView()
    private let previousButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let buttonsStack = UIStackView()

    private var selectedCoord: CLLocationCoordinate2D?
    private var selectedPlace: GMSPlace?
    private var selectedLabel: String?
    private var currentRadiusKm: Int = 20

    init(
        initialCoordinate: CLLocationCoordinate2D? = nil,
        initialLabel: String? = nil,
        initialRadiusKm: Int = 20,
        delegate: ZoneChoiceViewControllerDelegate? = nil,
        nextStep: ZoneChoiceNextStep = .onboardingEnd,
        onConfirm: ((ZoneChoiceResult) -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
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
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        view.addSubview(bottomBar)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor)
        ])

        scrollView.alwaysBounceVertical = true

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
        titleLabel.text = NSLocalizedString("onboarding_zone_title", comment: "")
        titleLabel.font = UIFont(name: "Quicksand-Bold", size: 20)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor(white: 0.1, alpha: 1.0)

        subtitleLabel.text = NSLocalizedString("onboarding_zone_subtitle", comment: "")
        subtitleLabel.font = UIFont(name: "NunitoSans-Regular", size: 15)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }

    private func setupCitySection() {
        let label = (initialLabel ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let isPlaceholder = label.isEmpty
        let buttonTitle = isPlaceholder ? "Ex. : Valence" : label

        cityButton.setTitle(buttonTitle, for: .normal)
        cityButton.setTitleColor(isPlaceholder ? .secondaryLabel : .label, for: .normal)
        cityButton.titleLabel?.font = UIFont(name: "NunitoSans-Regular", size: 15)
        cityButton.contentHorizontalAlignment = .left
        cityButton.contentVerticalAlignment = .center
        cityButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        cityButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)

        cityButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        cityButton.tintColor = UIColor(white: 0.7, alpha: 1.0)

        cityButton.backgroundColor = .white
        cityButton.layer.cornerRadius = 12
        cityButton.layer.borderWidth = 1
        cityButton.layer.borderColor = UIColor(white: 0.92, alpha: 1.0).cgColor

        cityButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        cityButton.addTarget(self, action: #selector(openAutocomplete), for: .touchUpInside)

        contentView.addSubview(cityButton)
        cityButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cityButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            cityButton.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor),
            cityButton.trailingAnchor.constraint(equalTo: subtitleLabel.trailingAnchor)
        ])
    }

    private func setupRadiusSection() {
        radiusTitleLabel.text = NSLocalizedString("onboarding_zone_radius_title", comment: "")
        radiusTitleLabel.textColor = .secondaryLabel
        radiusTitleLabel.font = UIFont(name: "NunitoSans-Regular", size: 15)

        radiusValueLabel.font = UIFont(name: "NunitoSans-Regular", size: 15)
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
            radiusTitleLabel.topAnchor.constraint(equalTo: cityButton.bottomAnchor, constant: 20),
            radiusTitleLabel.leadingAnchor.constraint(equalTo: cityButton.leadingAnchor),

            radiusValueLabel.centerYAnchor.constraint(equalTo: radiusTitleLabel.centerYAnchor),
            radiusValueLabel.trailingAnchor.constraint(equalTo: cityButton.trailingAnchor),

            slider.topAnchor.constraint(equalTo: radiusTitleLabel.bottomAnchor, constant: 20),
            slider.leadingAnchor.constraint(equalTo: cityButton.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: cityButton.trailingAnchor)
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

            mapContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    private func setupBottomBar() {
        bottomBar.backgroundColor = .clear

        buttonsStack.axis = .horizontal
        buttonsStack.alignment = .fill
        buttonsStack.distribution = .fillEqually
        buttonsStack.spacing = 12

        bottomBar.addSubview(buttonsStack)
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            buttonsStack.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 12),
            buttonsStack.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -20),
            buttonsStack.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor, constant: -12),
            bottomBar.heightAnchor.constraint(greaterThanOrEqualToConstant: 74)
        ])

        configureWhiteButton(previousButton, withTitle: "previous".localized)
        configureOrangeButton(nextButton, withTitle: "next".localized)

        previousButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        previousButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        buttonsStack.addArrangedSubview(previousButton)
        buttonsStack.addArrangedSubview(nextButton)

        updateNextButtonEnabled(false)
    }

    private func configureOrangeButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.appOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
    }

    private func configureWhiteButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.appOrange.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
    }

    private func setupInitialState() {
        currentRadiusKm = initialRadiusKm
        slider.value = Float(initialRadiusKm)
        updateRadiusValueLabel()

        if let c = initialCoordinate {
            selectedCoord = c
            selectedLabel = initialLabel
            if let label = initialLabel, !label.isEmpty {
                cityButton.setTitle(label, for: .normal)
                cityButton.setTitleColor(.label, for: .normal)
            }
            centerMap()
            drawCircle()
            updateNextButtonEnabled(true)
        } else {
            let franceCenter = CLLocationCoordinate2D(latitude: 46.5, longitude: 2.2)
            let region = MKCoordinateRegion(center: franceCenter, span: MKCoordinateSpan(latitudeDelta: 6.0, longitudeDelta: 6.0))
            mapView.setRegion(region, animated: false)
            updateNextButtonEnabled(false)
        }
    }

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

        delegate?.zoneChoiceConfirmed(result: result)
        onConfirmClosure?(result)

        updateNextButtonEnabled(false)

        AuthService.updateTravelDistance(currentRadiusKm) { [weak self] error in
            guard let self = self else { return }

            guard error == nil else {
                self.updateNextButtonEnabled(true)
                self.showZoneError()
                return
            }

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
        let message = NSLocalizedString(messageKey, comment: "")
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        present(alert, animated: true)
    }

    private func goToOnboardingEnd() {
        let storyboard = UIStoryboard(name: StoryboardName.onboarding, bundle: nil)
        if let endVC = storyboard.instantiateViewController(withIdentifier: "OnboardingEndViewController") as? OnboardingEndViewController {
            if let nav = navigationController {
                nav.pushViewController(endVC, animated: true)
            } else {
                endVC.modalPresentationStyle = .fullScreen
                present(endVC, animated: true)
            }
        }
    }

    private func goToAssociationOnboarding() {
        let associationVC = AssociationOnboardingViewController(
            initialAddress: selectedLabel ?? initialLabel,
            initialCoordinate: selectedCoord
        )

        if let nav = navigationController {
            nav.pushViewController(associationVC, animated: true)
        } else {
            associationVC.modalPresentationStyle = .fullScreen
            present(associationVC, animated: true)
        }
    }

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

    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        selectedPlace = place
        selectedCoord = place.coordinate

        let label = place.name ?? place.formattedAddress ?? ""
        selectedLabel = label
        initialLabel = label

        cityButton.setTitle(label, for: .normal)
        cityButton.setTitleColor(.label, for: .normal)

        centerMap()
        drawCircle()
        updateNextButtonEnabled(true)

        viewController.dismiss(animated: true)
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        viewController.dismiss(animated: true)
    }

    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        viewController.dismiss(animated: true)
    }
}

extension ZoneChoiceViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
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

extension UIViewController {
    func presentZoneChoiceSwiftUI(
        initialCoordinate: CLLocationCoordinate2D? = nil,
        initialLabel: String? = nil,
        initialRadiusKm: Int = 20,
        nextStep: ZoneChoiceNextStep = .onboardingEnd,
        onConfirm: @escaping (ZoneChoiceResult) -> Void,
        onCancel: @escaping () -> Void
    ) {
        let vc = ZoneChoiceViewController(
            initialCoordinate: initialCoordinate,
            initialLabel: initialLabel,
            initialRadiusKm: initialRadiusKm,
            delegate: nil,
            nextStep: nextStep,
            onConfirm: onConfirm,
            onCancel: onCancel
        )

        vc.modalPresentationStyle = .fullScreen
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            present(vc, animated: true)
        }
    }
}
