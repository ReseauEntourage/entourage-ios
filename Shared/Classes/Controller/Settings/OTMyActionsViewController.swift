//
//  OTMyActionsViewController.swift
//  entourage
//
//  Created by Jerome on 12/10/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit

class OTMyActionsViewController: UIViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_top_segmented: UISegmentedControl!
    
    var arrayOwned = [OTEntourage]()
    var arrayOwnedSelection = [OTEntourage]()
    
    var isContrib = true
    var isFirstLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_top_segmented.selectedSegmentIndex = isContrib ? 0 : 1
        setupSegmentedControl()
        
        self.title = OTLocalisationService.getLocalizedValue(forKey: "myActions").uppercased()
        
        OTLogger.logEvent(View_ListActions_Show)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getOwned()
    }
    
    func setupSegmentedControl() {
        ui_top_segmented.setTitleColor(UIColor.appOrange(),state: .selected)
        ui_top_segmented.setTitleColor(UIColor.black,state: .normal)
        
        ui_top_segmented.setTitleFont(UIFont.systemFont(ofSize: 16))
        ui_top_segmented.layer.borderWidth = 2
        ui_top_segmented.layer.borderColor = UIColor.white.cgColor
        ui_top_segmented.layer.backgroundColor = UIColor.white.cgColor
        
        ui_top_segmented.fixBackgroundColor()
    }
    
    func changeSelectedOwned() {
        arrayOwnedSelection = [OTEntourage]()
        for _feed in self.arrayOwned {
            if !_feed.isOuting() {
                switch self.ui_top_segmented.selectedSegmentIndex {
                case 0:
                    if _feed.isContribution() {
                        self.arrayOwnedSelection.append(_feed)
                    }
                case 1:
                    if _feed.isAskForHelp() {
                        self.arrayOwnedSelection.append(_feed)
                    }
                default:
                    break
                }
            }
        }
        
        DispatchQueue.main.async {
            self.ui_tableview.reloadData()
            if self.arrayOwnedSelection.count > 0 {
            self.ui_tableview.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: true)
            }
        }
    }
    
    func getOwned() {
        OTFeedsService.init().getEntouragesOwnedWithsuccess { entourages in
            self.arrayOwned = [OTEntourage]()
            self.isFirstLoad = false
            
            if let _entourages = entourages as? [OTEntourage] {
                self.arrayOwned.append(contentsOf: _entourages)
            }
            self.changeSelectedOwned()
            
        } failure: { error in
            Logger.print("***** Error get owns : \(String(describing: error?.localizedDescription))")
        }
    }
    
    @IBAction func action_change_segment(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            OTLogger.logEvent(Action_ListActions_Switch_Contrib)
        }
        else {
            OTLogger.logEvent(Action_ListActions_Switch_Ask)
        }
        
        changeSelectedOwned()
    }
}


//MARK: - uitableview Datasource / Delegate -
extension OTMyActionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFirstLoad {
            return 0
        }
            
        return arrayOwnedSelection.count > 0 ? arrayOwnedSelection.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if arrayOwnedSelection.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEmpty", for: indexPath) as! OTMyActionEmptyTableViewCell
            
            let isContrib = self.ui_top_segmented.selectedSegmentIndex == 0
            cell.populateCell(isContrib: isContrib)
            
            return cell
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OTMyActionTableViewCell
        
        cell.populateCell(entourage: arrayOwnedSelection[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if arrayOwnedSelection.count == 0 { return }
        
        let sb = UIStoryboard.init(name: "PublicFeedDetailNew", bundle: nil)
        if let vc = sb.instantiateInitialViewController() as? OTDetailActionEventViewController {
            vc.feedItem = arrayOwnedSelection[indexPath.row]
            OTLogger.logEvent(Action_ListActions_Show_Detail)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
