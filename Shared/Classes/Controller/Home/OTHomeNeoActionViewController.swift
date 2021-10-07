//
//  OTHomeNeoActionViewController.swift
//  entourage
//
//  Created by Jr on 13/04/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit

class OTHomeNeoActionViewController: UIViewController {
    
    var temporaryNavController:UINavigationController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = OTLocalisationService.getLocalizedValue(forKey: "home_neo_action_title")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

extension OTHomeNeoActionViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! OTHomeNeoCell
            cell.populateAction()
            return cell
        }
        
        var cellIdent = "cell"
        if indexPath.row == 0 || indexPath.row == 2 {
            cellIdent = "cellHeader"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdent, for: indexPath) as! OTHomeActionCell
        cell.populateCell(position: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        
        
        if indexPath.row == 6 {
            if let url = OTSafariService.redirectUrl(withIdentifier: SLUG_ACTION_SCB) {
                OTSafariService.launchInAppBrowser(with: url)
                OTLogger.logEvent(Action_NeoFeedAct_How1Step)
            }
            return
        }
        
        if indexPath.row == 0 {
            showAllActions()
            OTLogger.logEvent(Action_NeoFeedAct_Needs)
            return
        }
        if indexPath.row == 1 {
            showAllEvents()
            OTLogger.logEvent(Action_NeoFeedAct_Events)
            return
        }
        
        var type = ""
        var category = ""
        var _tagAnalytic = ""
        var tagAnalyticName = ""
        
        switch indexPath.row {
        case 2:
            type = "contribution"
            category = "mat_help"
            _tagAnalytic = Action_NeoFeedAct_OfferMaterial
            tagAnalyticName = Action_NeoFeedAct_NameMaterial
        case 3:
            type = "contribution"
            category = "resource"
            _tagAnalytic = Action_NeoFeedAct_OfferService
            tagAnalyticName = Action_NeoFeedAct_NameService
        case 4:
            type = "ask_for_help"
            category = "mat_help"
            _tagAnalytic = Action_NeoFeedAct_RelayNeed
            tagAnalyticName = Action_NeoFeedAct_NameNeeds
        case 5:
            type = "contribution"
            category = "social"
            _tagAnalytic = Action_NeoFeedAct_Coffee
            tagAnalyticName = Action_NeoFeedAct_NameCoffee
        default:
            break
        }
        OTLogger.logEvent(_tagAnalytic)
        let sb = UIStoryboard.init(name: "EntourageEditor", bundle: nil)
        if let navVC = sb.instantiateInitialViewController() as? UINavigationController, let vc = navVC.topViewController as? OTEntourageEditorViewController {
            vc.isEditingEvent = false
            
            let cat = getCat(type: type, category: category)
            vc.entourage = setEmptyEntourage(cat: cat)
            vc.entourageEditorDelegate = self
            vc.isFromHomeNeo = true
            vc.tagNameAnalytic = tagAnalyticName
            temporaryNavController = navVC
            self.navigationController?.present(temporaryNavController!, animated: true, completion: nil)
        }
    }
    
    func setEmptyEntourage(cat:OTCategory) -> OTEntourage {
        
        let entourage = OTEntourage()
        entourage.status = ENTOURAGE_STATUS_OPEN;
        entourage.categoryObject = cat
        entourage.isPublic = true
        entourage.type = cat.entourage_type;
        entourage.category = cat.category
        
        return entourage
    }
    
    func getCat(type:String,category:String) -> OTCategory {
        var cat = OTCategory.init()
        if let _array = OTCategoryFromJsonService.getData() as? [OTCategoryType] {
            
            for item in _array {
                if item.type == type {
                    for _item2 in item.categories {
                        if let _cat = _item2 as? OTCategory {
                            if _cat.category == category {
                                cat = _cat
                                break
                            }
                        }
                    }
                    break
                }
            }
        }
        return cat
    }
}

extension OTHomeNeoActionViewController : EntourageEditorDelegate {
    func didEdit(_ entourage: OTEntourage!) {
        temporaryNavController?.dismiss(animated: true, completion: {
            self.temporaryNavController = nil
            self.showAllActions()
        })
    }
    
    func showAllEvents() {
        let sb = UIStoryboard.init(name: "Main2", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "OTMain0")  as! OTFeedsViewController
        vc.isFromEvent = true
        vc.titleFrom = OTLocalisationService.getLocalizedValue(forKey: "outings_title_home")
        OTLogger.logEvent(View_FeedView_Events)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showAllActions() {
        let sb = UIStoryboard.init(name: "Main2", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "OTMain0") as! OTFeedsViewController
        vc.isFromEvent = false
        vc.isFromNeoCourse = true
        OTLogger.logEvent(View_FeedView_Asks)
        vc.titleFrom = OTLocalisationService.getLocalizedValue(forKey: "entourage_ask_for_helps_title_home")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - OTHomeActionCell -
class OTHomeActionCell: UITableViewCell {
    
    @IBOutlet weak var ui_mainview: UIView!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_title_top: UILabel?
    @IBOutlet weak var ui_picto: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_mainview.layer.cornerRadius = 4
    }
    
    func populateCell(position:Int) {
        var titleTxt = ""
        var titleTopTxt = ""
        var pictoTxt = ""
        
        switch position {
        case 0:
            titleTopTxt = OTLocalisationService.getLocalizedValue(forKey: "home_neo_action_title_top1")
            titleTxt = OTLocalisationService.getLocalizedValue(forKey: "home_neo_action_title1")
            pictoTxt = "picto_action_1"
        case 1:
            titleTxt = OTLocalisationService.getLocalizedValue(forKey: "home_neo_action_title2")
            pictoTxt = "picto_action_2"
        case 2:
            titleTopTxt = OTLocalisationService.getLocalizedValue(forKey: "home_neo_action_title_top3")
            titleTxt = OTLocalisationService.getLocalizedValue(forKey: "home_neo_action_title3")
            pictoTxt = "picto_action_3"
        case 3:
            titleTxt = OTLocalisationService.getLocalizedValue(forKey: "home_neo_action_title4")
            pictoTxt = "picto_action_4"
        case 4:
            titleTxt = OTLocalisationService.getLocalizedValue(forKey: "home_neo_action_title5")
            pictoTxt = "picto_action_5"
        case 5:
            titleTxt = OTLocalisationService.getLocalizedValue(forKey: "home_neo_action_title6")
            pictoTxt = "picto_action_6"
        default:
            break
        }
        
        ui_title_top?.text = titleTopTxt
        ui_title.text = titleTxt
        ui_picto.image = UIImage.init(named: pictoTxt)
    }
}
