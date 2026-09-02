import Foundation
import UIKit
import MapKit

class MainFilterTagItem {
    var id: String
    var title: String
    var subtitle: String
    
    init(id: String, title: String, subtitle: String) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
    }
}

enum MainFilterDTO {
    case titleCell(title: String)
    case sectionCell(content: String, numberOfItem: Int)
    case eventTypeCell
    case formatCell
    case tagCell(choice: MainFilterTagItem)
    case localisationCell(address: String)
    case radiusCell(radius: Int)
}

enum MainFilterMode {
    case group
    case event
    case action
}

// Ids exchanged with the events list / network layer for the "type" and "format" event filters.
enum MainFilterEventTypeID {
    static let entourage = "entourage"
    static let reservedFemale = "reserved_female"
}

enum MainFilterFormatID {
    static let onSite = "onsite"
    static let online = "online"
}

protocol MainFilterDelegate: AnyObject {
    func didUpdateFilter(selectedItems: [String: Bool], radius: Float?, coordinate: CLLocationCoordinate2D?, adressTitle: String, eventTypes: Set<String>, format: String?)
}

class MainFilter: UIViewController, MainFilterLocationCellDelegate {
    
    weak var delegate: MainFilterDelegate?
    
    // Outlet
    @IBOutlet weak var ui_tableview: UITableView!
    
    // Variable
    var tableDTO = [MainFilterDTO]()
    var mod: MainFilterMode = .action
    var selectedItems = [String: Bool]()
    var selectedItemsAction = [String: Bool]()
    var selectedEventTypes = Set<String>()
    var selectedFormat: String?
    var locationCellHeight: CGFloat = 70 // Default height
    var selectedAdress: CLLocationCoordinate2D?
    var selectedRadius: Int = 40
    var selectedAdressTitle: String = ""
    private let stickyFooterHeight: CGFloat = 85

    override func viewDidLoad() {
        super.viewDidLoad()
        ui_tableview.delegate = self
        ui_tableview.dataSource = self
        
        // Register cell
        ui_tableview.register(UINib(nibName: "MainFilterTitleCell", bundle: nil), forCellReuseIdentifier: "MainFilterTitleCell")
        ui_tableview.register(UINib(nibName: "MainFilterSectionTitleCell", bundle: nil), forCellReuseIdentifier: "MainFilterSectionTitleCell")
        ui_tableview.register(UINib(nibName: "MainFilterTagCell", bundle: nil), forCellReuseIdentifier: "MainFilterTagCell")
        ui_tableview.register(MainFilterChipsCell.self, forCellReuseIdentifier: MainFilterChipsCell.identifier)
        ui_tableview.register(UINib(nibName: "MainFilterLocationCell", bundle: nil), forCellReuseIdentifier: "MainFilterLocationCell")
        ui_tableview.register(UINib(nibName: "MainFilterDistanceCell", bundle: nil), forCellReuseIdentifier: "MainFilterDistanceCell")
        setupStickyFooter()
        self.constructFilter()
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Add tap gesture to back button
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onBackButtonClick))
        // self.view.addGestureRecognizer(tapGesture) // Cette ligne est commentée car elle ne semble pas correcte
    }
    
    // Floats the Valider/Réinitialiser buttons over the bottom of the screen, in a Liquid Glass
    // container on iOS 26+ so the table content is visible (blurred) through it while scrolling,
    // falling back to a plain opaque bar on older versions. The table itself keeps its full-height
    // storyboard constraints — a bottom content inset makes room for the floating footer instead.
    private func setupStickyFooter() {
        guard let buttonCell = Bundle.main.loadNibNamed("EnahancedOnboardingButtonCell", owner: nil, options: nil)?.first as? EnahancedOnboardingButtonCell else {
            return
        }
        buttonCell.delegate = self
        buttonCell.configureForMainFilter()
        buttonCell.translatesAutoresizingMaskIntoConstraints = false

        let footerContainer: UIView

        if #available(iOS 26.0, *) {
            buttonCell.makeBackgroundTransparent()
            let glassEffect = UIGlassEffect(style: .regular)
            glassEffect.isInteractive = true
            let glassView = UIVisualEffectView(effect: glassEffect)
            glassView.contentView.addSubview(buttonCell)
            NSLayoutConstraint.activate([
                buttonCell.leadingAnchor.constraint(equalTo: glassView.contentView.leadingAnchor),
                buttonCell.trailingAnchor.constraint(equalTo: glassView.contentView.trailingAnchor),
                buttonCell.topAnchor.constraint(equalTo: glassView.contentView.topAnchor),
                buttonCell.bottomAnchor.constraint(equalTo: glassView.contentView.bottomAnchor)
            ])
            footerContainer = glassView
        } else {
            let plainContainer = UIView()
            plainContainer.backgroundColor = .white
            plainContainer.addSubview(buttonCell)
            NSLayoutConstraint.activate([
                buttonCell.leadingAnchor.constraint(equalTo: plainContainer.leadingAnchor),
                buttonCell.trailingAnchor.constraint(equalTo: plainContainer.trailingAnchor),
                buttonCell.topAnchor.constraint(equalTo: plainContainer.topAnchor),
                buttonCell.bottomAnchor.constraint(equalTo: plainContainer.bottomAnchor)
            ])
            footerContainer = plainContainer
        }

        footerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(footerContainer)

        NSLayoutConstraint.activate([
            footerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            footerContainer.heightAnchor.constraint(equalToConstant: stickyFooterHeight)
        ])

        let baseInset = UIEdgeInsets(top: 0, left: 0, bottom: stickyFooterHeight, right: 0)
        ui_tableview.contentInset = baseInset
        ui_tableview.scrollIndicatorInsets = baseInset
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height + 100, right: 0) // Ajuster le décalage pour voir plus de suggestions
        ui_tableview.contentInset = contentInsets
        ui_tableview.scrollIndicatorInsets = contentInsets
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let baseInset = UIEdgeInsets(top: 0, left: 0, bottom: stickyFooterHeight, right: 0)
        ui_tableview.contentInset = baseInset
        ui_tableview.scrollIndicatorInsets = baseInset
    }
    
    func constructFilter() {
        tableDTO.removeAll() // Vider le tableau avant de le remplir à nouveau

        switch self.mod {
        case .group, .event:
            let interestChoices = [
                MainFilterTagItem(id: "sport", title: NSLocalizedString("filter_groupevent_sport", comment: ""), subtitle: " (" + TagsUtils.showSubTagTranslated("sport") + ")"),
                MainFilterTagItem(id: "animaux", title: NSLocalizedString("filter_groupevent_animals", comment: ""), subtitle: " (" + TagsUtils.showSubTagTranslated("animaux") + ")"),
                MainFilterTagItem(id: "marauding", title: NSLocalizedString("filter_groupevent_social_marauding", comment: ""), subtitle: " (" + TagsUtils.showSubTagTranslated("marauding") + ")"),
                MainFilterTagItem(id: "cuisine", title: NSLocalizedString("filter_groupevent_cooking", comment: ""), subtitle: " (" + TagsUtils.showSubTagTranslated("cuisine") + ")"),
                MainFilterTagItem(id: "jeux", title: NSLocalizedString("filter_groupevent_games", comment: ""), subtitle: " (" + TagsUtils.showSubTagTranslated("jeux") + ")"),
                MainFilterTagItem(id: "activites", title: NSLocalizedString("filter_groupevent_handicrafts", comment: ""), subtitle: " (" + TagsUtils.showSubTagTranslated("activites") + ")"),
                MainFilterTagItem(id: "bien-etre", title: NSLocalizedString("filter_groupevent_wellbeing", comment: ""), subtitle: " (" + TagsUtils.showSubTagTranslated("bien-etre") + ")"),
                MainFilterTagItem(id: "nature", title: NSLocalizedString("filter_groupevent_nature", comment: ""), subtitle: " (" + TagsUtils.showSubTagTranslated("nature") + ")"),
                MainFilterTagItem(id: "culture", title: NSLocalizedString("filter_groupevent_art_and_culture", comment: ""), subtitle: " (" + TagsUtils.showSubTagTranslated("culture") + ")")
            ]
            
            tableDTO.append(.titleCell(title: NSLocalizedString("filter_groupevent_filters", comment: "")))
            if mod == .event {
                tableDTO.append(.sectionCell(content: NSLocalizedString("filter_event_by_type", comment: ""), numberOfItem: 0))
                tableDTO.append(.eventTypeCell)
                tableDTO.append(.sectionCell(content: NSLocalizedString("filter_event_by_format", comment: ""), numberOfItem: 0))
                tableDTO.append(.formatCell)
            }
            tableDTO.append(.sectionCell(content: NSLocalizedString("filter_groupevent_by_theme", comment: ""), numberOfItem: selectedItems.values.filter { $0 }.count))
            for interestChoice in interestChoices {
                if selectedItems[interestChoice.id] == nil {
                    selectedItems[interestChoice.id] = false
                }
                tableDTO.append(.tagCell(choice: interestChoice))
            }
            tableDTO.append(.sectionCell(content: NSLocalizedString("filter_groupevent_by_location", comment: ""), numberOfItem: 0))
            tableDTO.append(.localisationCell(address: self.selectedAdressTitle))
            tableDTO.append(.radiusCell(radius: self.selectedRadius))

        case .action:
            let actionChoices = [
                MainFilterTagItem(id: "social", title: NSLocalizedString("filter_groupevent_sharing_time", comment: ""), subtitle: " (Café, activité...)"),
                MainFilterTagItem(id: "services", title: NSLocalizedString("filter_groupevent_services", comment: ""), subtitle: " (Lessive, impression de documents...)"),
                MainFilterTagItem(id: "clothes", title: NSLocalizedString("filter_groupevent_clothes", comment: ""), subtitle: " (Chaussures, manteau...)"),
                MainFilterTagItem(id: "equipment", title: NSLocalizedString("filter_groupevent_equipment", comment: ""), subtitle: " (Téléphone, duvet...)"),
                MainFilterTagItem(id: "hygiene", title: NSLocalizedString("filter_groupevent_hygiene_products", comment: ""), subtitle: " (Savon, protection hygiénique, couches...)"),
            ]
            tableDTO.append(.titleCell(title: NSLocalizedString("filter_groupevent_filters", comment: "")))
            tableDTO.append(.sectionCell(content: NSLocalizedString("filter_groupevent_by_category", comment: ""), numberOfItem: selectedItemsAction.values.filter { $0 }.count))
            for actionChoice in actionChoices {
                if selectedItemsAction[actionChoice.id] == nil {
                    selectedItemsAction[actionChoice.id] = false
                }
                tableDTO.append(.tagCell(choice: actionChoice))
            }
            tableDTO.append(.sectionCell(content: NSLocalizedString("filter_groupevent_by_location", comment: ""), numberOfItem: 0))
            tableDTO.append(.localisationCell(address: selectedAdressTitle))
            tableDTO.append(.radiusCell(radius: self.selectedRadius))
        }
        
        loadDTO()
    }

    
    func loadDTO() {
        ui_tableview.reloadData()
    }
    
    // MainFilterLocationCellDelegate method
    // MainFilterLocationCellDelegate method
    func onSearchIncreaseSize(size: CGFloat) {
        let minHeight: CGFloat = 70 // Hauteur minimale
        self.locationCellHeight = max(size, minHeight)
        print("size ", size)
        UIView.animate(withDuration: 0.3) {
            self.ui_tableview.beginUpdates()
            self.ui_tableview.endUpdates()
        }
    }


    func onAddressClick(coordinate: CLLocationCoordinate2D, adressTitle: String) {
        self.selectedAdress = coordinate
        self.selectedAdressTitle = adressTitle
    }
    
    func onKeyboardWillShow(for cell: MainFilterLocationCell) {
        guard let indexPath = ui_tableview.indexPath(for: cell) else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.ui_tableview.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    // Method to reset the filter view to its initial state
    func resetFilters() {
        self.selectedItems.removeAll()
        self.selectedItemsAction.removeAll()
        self.selectedEventTypes.removeAll()
        self.selectedFormat = nil
        self.selectedAdress = nil
        self.selectedRadius = 40
        self.selectedAdressTitle = ""
        self.locationCellHeight = 70 // Reset to default height
        if let _user = UserDefaults.currentUser {
            self.selectedAdress = CLLocationCoordinate2D(latitude: _user.addressPrimary?.latitude ?? 0, longitude: _user.addressPrimary?.longitude ?? 0)
            self.selectedAdressTitle = _user.addressPrimary?.displayAddress ?? ""
            self.selectedRadius = _user.radiusDistance ?? 0
        }
        self.constructFilter()
    }

    @objc func onBackButtonClick() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension MainFilter: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDTO.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableDTO[indexPath.row] {
        case .titleCell(let title):
            if let cell = ui_tableview.dequeueReusableCell(withIdentifier: "MainFilterTitleCell") as? MainFilterTitleCell {
                cell.selectionStyle = .none
                cell.delegate = self
                cell.configure(title: title)
                return cell
            }
        case .sectionCell(let content, let numberOfItem):
            if let cell = ui_tableview.dequeueReusableCell(withIdentifier: "MainFilterSectionTitleCell") as? MainFilterSectionTitleCell {
                cell.selectionStyle = .none
                cell.configure(content: content, numberOfItem: numberOfItem)
                return cell
            }
        case .eventTypeCell:
            if let cell = ui_tableview.dequeueReusableCell(withIdentifier: MainFilterChipsCell.identifier) as? MainFilterChipsCell {
                cell.selectionStyle = .none
                cell.delegate = self
                var items = [
                    MainFilterChipItem(id: MainFilterEventTypeID.entourage, title: NSLocalizedString("filter_event_type_entourage", comment: ""), iconName: "ic_entoutou_logo_little", accentColor: .appOrange)
                ]
                if UserDefaults.currentUser?.isFemale() == true {
                    items.append(MainFilterChipItem(id: MainFilterEventTypeID.reservedFemale, title: NSLocalizedString("filter_event_type_reserved_female", comment: ""), iconName: "ic_entoutou_logo_woman", accentColor: .appViolet))
                }
                cell.configure(items: items, selectedIds: selectedEventTypes, style: .toggle)
                return cell
            }
        case .formatCell:
            if let cell = ui_tableview.dequeueReusableCell(withIdentifier: MainFilterChipsCell.identifier) as? MainFilterChipsCell {
                cell.selectionStyle = .none
                cell.delegate = self
                let items = [
                    MainFilterChipItem(id: MainFilterFormatID.onSite, title: NSLocalizedString("filter_event_format_onsite", comment: ""), iconName: nil, accentColor: .appOrange),
                    MainFilterChipItem(id: MainFilterFormatID.online, title: NSLocalizedString("filter_event_format_online", comment: ""), iconName: nil, accentColor: .appOrange)
                ]
                let selected = selectedFormat.map { Set([$0]) } ?? Set<String>()
                cell.configure(items: items, selectedIds: selected, style: .radio)
                return cell
            }
        case .tagCell(let choice):
            if let cell = ui_tableview.dequeueReusableCell(withIdentifier: "MainFilterTagCell") as? MainFilterTagCell {
                cell.selectionStyle = .none
                let isSelected: Bool
                if mod == .action {
                    isSelected = selectedItemsAction[choice.id] ?? false
                } else {
                    isSelected = selectedItems[choice.id] ?? false
                }
                cell.configure(choice: choice, isSelected: isSelected)
                return cell
            }
        case .localisationCell(let address):
            if let cell = ui_tableview.dequeueReusableCell(withIdentifier: "MainFilterLocationCell") as? MainFilterLocationCell {
                cell.selectionStyle = .none
                cell.delegate = self
                cell.configure(address: address)
                return cell
            }
        case .radiusCell(let radius):
            if let cell = ui_tableview.dequeueReusableCell(withIdentifier: "MainFilterDistanceCell") as? MainFilterDistanceCell {
                cell.selectionStyle = .none
                cell.delegate = self
                cell.configure(distance: radius)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableDTO[indexPath.row] {
        case .localisationCell:
            return locationCellHeight
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableDTO[indexPath.row] {
        case .tagCell(let choice):
            let selectedCount: Int
            if mod == .action {
                selectedItemsAction[choice.id]?.toggle()
                selectedCount = selectedItemsAction.values.filter { $0 }.count
            } else {
                selectedItems[choice.id]?.toggle()
                selectedCount = selectedItems.values.filter { $0 }.count
            }

            // Find the header directly above this tag (its index shifts depending on mode/
            // sections present, e.g. "Type d'événement"/"Format" pushed it down for .event).
            if let sectionRow = (0..<indexPath.row).reversed().first(where: {
                if case .sectionCell = tableDTO[$0] { return true }
                return false
            }), case .sectionCell(let content, _) = tableDTO[sectionRow] {
                tableDTO[sectionRow] = .sectionCell(content: content, numberOfItem: selectedCount)
                tableView.reloadRows(at: [IndexPath(row: sectionRow, section: 0)], with: .automatic)
            }

            tableView.reloadRows(at: [indexPath], with: .automatic)
        default:
            break
        }
    }
}

extension MainFilter: MainFilterChipsCellDelegate {
    func mainFilterChipsCell(_ cell: MainFilterChipsCell, didSelect id: String) {
        switch id {
        case MainFilterFormatID.onSite, MainFilterFormatID.online:
            selectedFormat = (selectedFormat == id) ? nil : id
        default:
            if selectedEventTypes.contains(id) {
                selectedEventTypes.remove(id)
            } else {
                selectedEventTypes.insert(id)
            }
        }
        guard let indexPath = ui_tableview.indexPath(for: cell) else { return }
        ui_tableview.reloadRows(at: [indexPath], with: .none)
    }
}

extension MainFilter: MainFilterDistanceCellDelegate {
    func onRadiusChanged(radius: Float) {
        self.selectedRadius = Int(radius)
    }
}

extension MainFilter: EnhancedOnboardingButtonDelegate {
    func onConfigureLaterClick() {
        resetFilters() // Reset filters to initial state
    }
    func onNextClick() {
        print("selected address", selectedAdress)
        print("selected address title", selectedAdressTitle)
        print("selected radius", selectedRadius)
        if mod == .action {
            delegate?.didUpdateFilter(selectedItems: selectedItemsAction, radius: Float(selectedRadius), coordinate: selectedAdress, adressTitle: self.selectedAdressTitle, eventTypes: [], format: nil)
        } else {
            delegate?.didUpdateFilter(selectedItems: selectedItems, radius: Float(selectedRadius), coordinate: selectedAdress, adressTitle: self.selectedAdressTitle, eventTypes: selectedEventTypes, format: selectedFormat)
        }
        dismiss(animated: true, completion: nil)
    }
}

extension MainFilter {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            view.endEditing(true)
    }
}

extension MainFilter: MainFilterTitleCellDelegate {
    func onBackClick() {
        self.dismiss(animated: true, completion: nil)
    }
}
