//
//  OTOnboardingSearchAssoViewController.swift
//  entourage
//
//  Created by Jr on 26/05/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit
import SVProgressHUD

class OTOnboardingSearchAssoViewController: UIViewController {
    @IBOutlet weak var ui_bt_validate: UIButton!
    @IBOutlet weak var ui_bt_cancel: UIButton!
    @IBOutlet weak var ui_et_search: OTCustomTextfield!
    @IBOutlet weak var ui_tableview: UITableView!
    
    weak var delegate:ValidateAssoDelegate? = nil
    
    var arrayAssos = [OTAssociation]()
    var arrayAssosFiltered = [OTAssociation]()
    
    var rowSelected = -1
    var isFiltered = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_et_search.placeholder = OTLocalisationService.getLocalizedValue(forKey: "onboard_asso_search")
        ui_tableview.tableFooterView = UIView.init(frame: .zero)
        getList()
    }
    
    deinit {
        delegate = nil
    }
    
    func getList() {
        SVProgressHUD.show()
        OTAssociationsService().getAllAssociations(success: { (array) in
           SVProgressHUD.dismiss()
            
            if let _array = array as? [OTAssociation] {
                self.arrayAssos.removeAll()
                self.arrayAssos.append(contentsOf: _array)
                self.ui_tableview.reloadData()
            }
        }) { (error) in
            self.action_cancel(nil)
        }
    }
    
    //MARK: - IBActions -
    @IBAction func action_validate(_ sender: Any) {
        if rowSelected < 0 {
            return
        }
        delegate?.validate(asso: isFiltered ? arrayAssosFiltered[rowSelected] : arrayAssos[rowSelected])
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func action_cancel(_ sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITableView DataSource-Delegate -
extension OTOnboardingSearchAssoViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltered ? arrayAssosFiltered.count : arrayAssos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearch", for: indexPath) as! OTAssoSearchTableViewCell
        
        let isSelected = indexPath.row == rowSelected
        let asso = isFiltered ? arrayAssosFiltered[indexPath.row] : arrayAssos[indexPath.row]
        
        cell.populateCell(asso: asso, isSelected: isSelected)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowSelected = indexPath.row
        tableView.reloadData()
    }
}

//MARK: - UITextFieldDelegate -
extension OTOnboardingSearchAssoViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if arrayAssos.count == 0 {
            return false
        }
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        search(txtSearch: textField.text)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        search(txtSearch: textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func search(txtSearch:String?) {
        guard let _txt = txtSearch, _txt.count > 0 else {
            rowSelected = -1
            isFiltered = false
            ui_tableview.reloadData()
            return
        }
        isFiltered = true
        rowSelected = -1
        arrayAssosFiltered.removeAll()
        arrayAssosFiltered = arrayAssos.filter { (asso) -> Bool in
            return asso.name.lowercased().contains(_txt.lowercased())
        }
        if arrayAssosFiltered.count == 0 {
            let asso = OTAssociation()
            asso.name = _txt
            asso.isCreation = true
            arrayAssosFiltered.append(asso)
        }
        ui_tableview.reloadData()
    }
}
//MARK: - Protocol -
protocol ValidateAssoDelegate:class {
    func validate(asso:OTAssociation)
}
