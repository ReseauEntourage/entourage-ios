//
//  OTMyActionsViewController.swift
//  entourage
//
//  Created by Jerome on 12/10/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit
import SVProgressHUD

class OTMyActionsViewController: UIViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    var arrayOwned = [OTEntourage]()
    var arrayOwnedSelection = [OTEntourage]()
    
    var isContrib = true
    var isFirstLoad = true
    var selectedSegmentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedSegmentIndex = isContrib ? 0 : 1
        
        if selectedSegmentIndex == 0 {
            self.title = OTLocalisationService.getLocalizedValue(forKey: "myContribs").uppercased()
        }
        else {
            self.title = OTLocalisationService.getLocalizedValue(forKey: "myDemands").uppercased()
        }
        
        OTLogger.logEvent(View_ListActions_Show)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getOwned()
    }
    
    func changeSelectedOwned() {
        arrayOwnedSelection = [OTEntourage]()
        for _feed in self.arrayOwned {
            if !_feed.isOuting() {
                switch self.selectedSegmentIndex {
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
        SVProgressHUD.show()
        OTFeedsService.init().getEntouragesOwnedWithsuccess { entourages in
            self.arrayOwned = [OTEntourage]()
            self.isFirstLoad = false
            SVProgressHUD.dismiss()
            if let _entourages = entourages as? [OTEntourage] {
                self.arrayOwned.append(contentsOf: _entourages)
            }
            self.changeSelectedOwned()
            
        } failure: { error in
            SVProgressHUD.dismiss()
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
            
            let isContrib = self.selectedSegmentIndex == 0
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
