//
//  OTGDSSearchViewController.swift
//  entourage
//
//  Created by Jr on 23/11/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit
import IHProgressHUD
//import IQKeyboardManager
import CoreLocation

class GDSSearchViewController: UIViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_tf_search: UITextField!
    @IBOutlet weak var ui_iv_clear: UIImageView!
    @IBOutlet weak var ui_view_shadow: UIView!
    
    let minChars = 3
    
    var isAllreadyCall = false
    
    var distance:CLLocationDistance? = nil
    var location:CLLocationCoordinate2D? = nil
    
    var isFromSearch = false
    
    var pois = [MapPoi]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ui_iv_clear.isHidden = true
        ui_tableview.tableFooterView = UIView(frame: CGRect.zero)
        
        ui_tf_search.becomeFirstResponder()
     //   IQKeyboardManager.shared().isEnableAutoToolbar = false
        
      //  OTLogger.logEvent(Action_guide_searchStart)  //TODO: a faire analytics
        
        self.ui_view_shadow.layer.shadowColor = UIColor.black.cgColor
        self.ui_view_shadow.layer.shadowOpacity = 0.3
        self.ui_view_shadow.layer.shadowRadius = 2.0
        self.ui_view_shadow.layer.masksToBounds = false
        
        let _rect = CGRect(x: 0, y: self.ui_view_shadow.bounds.size.height , width: self.view.frame.size.width, height: self.ui_view_shadow.layer.shadowRadius)
        let _shadowPath = UIBezierPath(rect: _rect).cgPath
        self.ui_view_shadow.layer.shadowPath = _shadowPath
    }
    
    func sendSearch(searchTxt:String) {
        if isAllreadyCall {
            return
        }
        guard let _location = location, let _distance = distance else {
            return
        }
        
        isAllreadyCall = true
        
        IHProgressHUD.show()
        
        let newDict =  ["latitude":"\(_location.latitude)",
                        "longitude":"\(_location.longitude)",
                        "distance":"\(_distance)",
                        "query" : ui_tf_search.text!,
                        "v" : "2"] as [String : String]
        
        
        PoiService.getPois(params: newDict) { [weak self] pois, error in
//            OTLogger.logEvent(Action_guide_searchResults) //TODO: a faire Analytics
            IHProgressHUD.dismiss()
            if let _pois = pois {
                self?.pois = _pois
                self?.isFromSearch = true
                self?.ui_tableview?.reloadData()
                self?.isAllreadyCall = false
            }
            else {
                self?.pois.removeAll()
                self?.isFromSearch = false
                self?.isAllreadyCall = false
                self?.ui_tableview?.reloadData()
            }
        }
    }
    
    //MARK: - IBActions
    @IBAction func action_clear(_ sender: Any) {
        if ui_tf_search.text?.count ?? 0 > 0 {
            ui_tf_search.text = ""
            pois.removeAll()
            self.isFromSearch = false
            ui_tableview.reloadData()
        }
    }
    
    @IBAction func action_back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
       // IQKeyboardManager.shared().isEnableAutoToolbar = true
    }
}

//MARK: - TableView Datasource/Delegate -
extension GDSSearchViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pois.count == 0 && isFromSearch {
            return 1
        }
        return pois.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if pois.count == 0 && isFromSearch {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEmpty", for: indexPath)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SolidarityGuideCell
        
        cell.configure(poi: pois[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if pois.count == 0 {
            return
        }
        
        let poi = pois[indexPath.row]
        if poi.partnerId != nil {
           
            let navVc = UIStoryboard.init(name: "PartnerDetails", bundle: nil).instantiateInitialViewController() as? UINavigationController
            if let vc = navVc?.topViewController as? PartnerDetailViewController {
                vc.partnerId = poi.partnerId!
                DispatchQueue.main.async {
                    self.present(navVc!, animated: true, completion: nil)
                }
            }
        }
        else {
            DispatchQueue.main.async {
                let navVc = UIStoryboard.init(name: "GuideSolidarity", bundle: nil).instantiateInitialViewController() as? UINavigationController
                
                if let _controller = navVc?.topViewController as? GuideDetailPoiViewController {
                    _controller.poi = poi
                    _controller.filtersSelectedFromMap = "TXT"
                    self.present(navVc!, animated: true, completion: nil)
                }
            }
        }
    }
}

//MARK: - Textfield Delegate -
extension GDSSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        if textField.text?.count ?? 0 >= minChars {
            self.sendSearch(searchTxt: textField.text!)
        }
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text?.count ?? 0 > 0 {
            self.ui_iv_clear.isHidden = false
        }
        else {
            self.ui_iv_clear.isHidden = true
        }
    }
}
