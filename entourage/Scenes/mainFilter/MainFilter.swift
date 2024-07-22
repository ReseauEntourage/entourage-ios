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
    case tagCell(choice: MainFilterTagItem)
    case localisationCell(address: String)
    case radiusCell(radius: Int)
    case buttonCell
}

enum MainFilterMode {
    case group
    case event
    case action
}

protocol MainFilterDelegate: AnyObject {
    func didUpdateFilter(selectedItems: [String: Bool], radius: Float?, coordinate: CLLocationCoordinate2D?, adressTitle: String)
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
    var locationCellHeight: CGFloat = 70 // Default height
    var selectedAdress: CLLocationCoordinate2D?
    var selectedRadius: Int = 40
    var selectedAdressTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_tableview.delegate = self
        ui_tableview.dataSource = self
        
        // Register cell
        ui_tableview.register(UINib(nibName: "EnahancedOnboardingButtonCell", bundle: nil), forCellReuseIdentifier: "buttonCell")
        ui_tableview.register(UINib(nibName: "MainFilterTitleCell", bundle: nil), forCellReuseIdentifier: "MainFilterTitleCell")
        ui_tableview.register(UINib(nibName: "MainFilterSectionTitleCell", bundle: nil), forCellReuseIdentifier: "MainFilterSectionTitleCell")
        ui_tableview.register(UINib(nibName: "MainFilterTagCell", bundle: nil), forCellReuseIdentifier: "MainFilterTagCell")
        ui_tableview.register(UINib(nibName: "MainFilterLocationCell", bundle: nil), forCellReuseIdentifier: "MainFilterLocationCell")
        ui_tableview.register(UINib(nibName: "MainFilterDistanceCell", bundle: nil), forCellReuseIdentifier: "MainFilterDistanceCell")
        self.constructFilter()

        // Add tap gesture to back button
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onBackButtonClick))

    }
    
    func constructFilter() {
        tableDTO.removeAll() // Vider le tableau avant de le remplir à nouveau

        switch self.mod {
        case .group, .event:
            let interestChoices = [
                MainFilterTagItem(id: "sport", title: "Sport", subtitle: ""),
                MainFilterTagItem(id: "animaux", title: "Animaux", subtitle: ""),
                MainFilterTagItem(id: "marauding", title: "Maraudes sociales", subtitle: ""),
                MainFilterTagItem(id: "cuisine", title: "Cuisine", subtitle: ""),
                MainFilterTagItem(id: "jeux", title: "Jeux", subtitle: ""),
                MainFilterTagItem(id: "activites", title: "Activités manuelles", subtitle: ""),
                MainFilterTagItem(id: "bien-etre", title: "Bien-être", subtitle: ""),
                MainFilterTagItem(id: "nature", title: "Nature", subtitle: ""),
                MainFilterTagItem(id: "culture", title: "Art & Culture", subtitle: ""),
                MainFilterTagItem(id: "other", title: "Autre", subtitle: "")
            ]
            
            tableDTO.append(.titleCell(title: "Filtres"))
            tableDTO.append(.sectionCell(content: "Par thématique", numberOfItem: selectedItems.values.filter { $0 }.count))
            for interestChoice in interestChoices {
                if selectedItems[interestChoice.id] == nil {
                    selectedItems[interestChoice.id] = false
                }
                tableDTO.append(.tagCell(choice: interestChoice))
            }
            tableDTO.append(.sectionCell(content: "Par localisation", numberOfItem: 0))
            tableDTO.append(.localisationCell(address: self.selectedAdressTitle))
            tableDTO.append(.radiusCell(radius: self.selectedRadius))
            tableDTO.append(.buttonCell)

        case .action:
            let actionChoices = [
                MainFilterTagItem(id: "services", title: "Service", subtitle: " (lessive, impression de documents...)"),
                MainFilterTagItem(id: "clothes", title: "Vêtement", subtitle: " (chaussures, manteau...)"),
                MainFilterTagItem(id: "material_donations", title: "Équipement", subtitle: " (téléphone, duvet...)"),
                MainFilterTagItem(id: "hygiene", title: "Produit d’hygiène", subtitle: " (savon, protection hygiénique, couches...)"),
                MainFilterTagItem(id: "social", title: "Temps de partage", subtitle: " (café, activité...)")
            ]
            tableDTO.append(.titleCell(title: "Filtres"))
            tableDTO.append(.sectionCell(content: "Par catégorie", numberOfItem: selectedItemsAction.values.filter { $0 }.count))
            for actionChoice in actionChoices {
                if selectedItemsAction[actionChoice.id] == nil {
                    selectedItemsAction[actionChoice.id] = false
                }
                tableDTO.append(.tagCell(choice: actionChoice))
            }
            tableDTO.append(.sectionCell(content: "Par localisation", numberOfItem: 0))
            tableDTO.append(.localisationCell(address: selectedAdressTitle))
            tableDTO.append(.radiusCell(radius: self.selectedRadius))
            tableDTO.append(.buttonCell)
        }
        
        loadDTO()
    }
    
    func loadDTO() {
        ui_tableview.reloadData()
    }
    
    // MainFilterLocationCellDelegate method
    func onSearchIncreaseSize(size: CGFloat) {
        self.locationCellHeight = size
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
    
    // Method to reset the filter view to its initial state
    func resetFilters() {
        self.selectedItems.removeAll()
        self.selectedItemsAction.removeAll()
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
        case .buttonCell:
            if let cell = ui_tableview.dequeueReusableCell(withIdentifier: "buttonCell") as? EnahancedOnboardingButtonCell {
                cell.selectionStyle = .none
                cell.delegate = self
                cell.configureForMainFilter()
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
            if mod == .action {
                // Mettre à jour l'état de sélection
                selectedItemsAction[choice.id]?.toggle()
                // Calculer le nombre de filtres sélectionnés
                let selectedCount = selectedItemsAction.values.filter { $0 }.count

                // Mettre à jour la deuxième cellule de section avec le nouveau nombre de filtres sélectionnés
                if tableDTO.count > 1, case .sectionCell(let content, _) = tableDTO[1] {
                    tableDTO[1] = .sectionCell(content: content, numberOfItem: selectedCount)
                    tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                }

                // Recharger la cellule sélectionnée pour refléter le changement
                tableView.reloadRows(at: [indexPath], with: .automatic)
            } else {
                // Mettre à jour l'état de sélection
                selectedItems[choice.id]?.toggle()
                // Calculer le nombre de filtres sélectionnés
                let selectedCount = selectedItems.values.filter { $0 }.count

                // Mettre à jour la deuxième cellule de section avec le nouveau nombre de filtres sélectionnés
                if tableDTO.count > 1, case .sectionCell(let content, _) = tableDTO[1] {
                    tableDTO[1] = .sectionCell(content: content, numberOfItem: selectedCount)
                    tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                }

                // Recharger la cellule sélectionnée pour refléter le changement
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        default:
            break
        }
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
            delegate?.didUpdateFilter(selectedItems: selectedItemsAction, radius: Float(selectedRadius), coordinate: selectedAdress, adressTitle: self.selectedAdressTitle)
        } else {
            delegate?.didUpdateFilter(selectedItems: selectedItems, radius: Float(selectedRadius), coordinate: selectedAdress, adressTitle: self.selectedAdressTitle)
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

extension MainFilter:MainFilterTitleCellDelegate{
    func onBackClick() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
