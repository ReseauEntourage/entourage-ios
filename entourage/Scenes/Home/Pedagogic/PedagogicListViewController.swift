//
//  PedagicListViewController.swift
//  entourage
//
//  Created by Jerome on 09/06/2022.
//

import UIKit

class PedagogicListViewController: UIViewController {
    
    @IBOutlet weak var ui_top_view: MJNavBackView!
    @IBOutlet weak var ui_tableview: UITableView!
    
    @IBOutlet weak var ui_view_button_all: UIView!
    @IBOutlet weak var ui_title_button_all: UILabel!
    
    @IBOutlet weak var ui_view_button_understand: UIView!
    @IBOutlet weak var ui_title_button_understand: UILabel!
    
    @IBOutlet weak var ui_view_button_act: UIView!
    @IBOutlet weak var ui_title_button_act: UILabel!
    
    @IBOutlet weak var ui_view_button_inspire: UIView!
    @IBOutlet weak var ui_title_button_inspire: UILabel!
    
    
    var pedagogicViewModel = PedagogicViewModel()
    
    var filterSelected:FilterSelector = .All
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_tableview.delegate = self
        ui_tableview.dataSource = self
        
        ui_top_view.backgroundColor = .clear
        ui_top_view.populateCustom(title: "home_resources_title".localized, titleFont: nil, titleColor: nil, imageName: nil, backgroundColor: .appBeigeClair, delegate: self, showSeparator: true, cornerRadius: nil, isClose: false, marginLeftButton: nil)
        
        pedagogicViewModel.getResources { isOk in
            self.ui_tableview.reloadData()
        }
        AnalyticsLoggerManager.logEvent(name: Pedago_View)

        setupTabview()
    }
    
    func setupTabview() {
        
        ui_title_button_all.text = "resource_all".localized
        ui_title_button_understand.text = "resource_understand".localized
        ui_title_button_act.text = "resource_act".localized
        ui_title_button_inspire.text = "resource_inspire".localized
        
        ui_view_button_all.layer.cornerRadius = ui_view_button_all.frame.height / 2
        ui_view_button_understand.layer.cornerRadius = ui_view_button_understand.frame.height / 2
        ui_view_button_act.layer.cornerRadius = ui_view_button_act.frame.height / 2
        ui_view_button_inspire.layer.cornerRadius = ui_view_button_inspire.frame.height / 2
        
        ui_title_button_all.font = ApplicationTheme.getFontNunitoSemiBold(size: 13)
        ui_title_button_act.font = ApplicationTheme.getFontNunitoSemiBold(size: 13)
        ui_title_button_understand.font = ApplicationTheme.getFontNunitoSemiBold(size: 13)
        ui_title_button_inspire.font = ApplicationTheme.getFontNunitoSemiBold(size: 13)
        changeButtonTapBar()
    }
    
    @IBAction func action_tap_bar(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            filterSelected = .All
        case 2:
            filterSelected = .Understand
        case 3:
            filterSelected = .Act
        case 4:
            filterSelected = .Inspire
        default:
            break
        }
        changeButtonTapBar()
        self.ui_tableview.reloadData()
    }
    
    func changeButtonTapBar() {
        switch filterSelected {
        case .All:
            setColors(view: ui_view_button_all,text: ui_title_button_all, isOn: true)
            setColors(view: ui_view_button_understand,text: ui_title_button_understand, isOn: false)
            setColors(view: ui_view_button_act, text: ui_title_button_act, isOn: false)
            setColors(view: ui_view_button_inspire, text: ui_title_button_inspire, isOn: false)
        case .Understand:
            setColors(view: ui_view_button_all,text: ui_title_button_all, isOn: false)
            setColors(view: ui_view_button_understand,text: ui_title_button_understand, isOn: true)
            setColors(view: ui_view_button_act, text: ui_title_button_act, isOn: false)
            setColors(view: ui_view_button_inspire, text: ui_title_button_inspire, isOn: false)
        case .Act:
            setColors(view: ui_view_button_all,text: ui_title_button_all, isOn: false)
            setColors(view: ui_view_button_understand,text: ui_title_button_understand, isOn: false)
            setColors(view: ui_view_button_act, text: ui_title_button_act, isOn: true)
            setColors(view: ui_view_button_inspire, text: ui_title_button_inspire, isOn: false)
        case .Inspire:
            setColors(view: ui_view_button_all,text: ui_title_button_all, isOn: false)
            setColors(view: ui_view_button_understand,text: ui_title_button_understand, isOn: false)
            setColors(view: ui_view_button_act, text: ui_title_button_act, isOn: false)
            setColors(view: ui_view_button_inspire, text: ui_title_button_inspire, isOn: true)
        }
    }
    
    func setColors(view:UIView,text:UILabel, isOn:Bool) {
        view.layer.borderColor = UIColor.appOrange.cgColor
        view.layer.borderWidth = 1
        view.backgroundColor = isOn ? .appOrange : .white//.appOrangeLight.withAlphaComponent(0.25)
        text.textColor = isOn ? .white : .appOrange
    }
    
    enum FilterSelector {
        case All
        case Understand
        case Act
        case Inspire
    }
}

//MARK: - Tableview Datasource/delegate -
extension PedagogicListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if filterSelected == .All {
            return pedagogicViewModel.allResources.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch filterSelected {
        case .Understand:
            return pedagogicViewModel.understandResources.resources.count + 1
        case .Act:
            return pedagogicViewModel.actResources.resources.count + 1
        case .Inspire:
            return pedagogicViewModel.inspireResources.resources.count + 1
        case .All:
            return pedagogicViewModel.allResources[section].resources.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            var resourceTitle:String
            
            switch filterSelected {
            case .Understand:
                resourceTitle = pedagogicViewModel.understandResources.title
            case .Act:
                resourceTitle = pedagogicViewModel.actResources.title
            case .Inspire:
                resourceTitle = pedagogicViewModel.inspireResources.title
            case .All:
                resourceTitle = pedagogicViewModel.allResources[indexPath.section].title
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSection", for: indexPath) as! PedagogicSectionCell
            cell.populateCell(title: resourceTitle)
            return cell
        }
        
        var isLastCell:Bool
        
        var pedagogic:PedagogicResource
        
        switch filterSelected {
        case .Understand:
            isLastCell = indexPath.row == pedagogicViewModel.understandResources.resources.count
            pedagogic = pedagogicViewModel.understandResources.resources[indexPath.row - 1]
        case .Act:
            isLastCell = indexPath.row == pedagogicViewModel.actResources.resources.count
            pedagogic = pedagogicViewModel.actResources.resources[indexPath.row - 1]
        case .Inspire:
            isLastCell = indexPath.row == pedagogicViewModel.inspireResources.resources.count
            pedagogic = pedagogicViewModel.inspireResources.resources[indexPath.row - 1]
        case .All:
            isLastCell = indexPath.row == pedagogicViewModel.allResources[indexPath.section].resources.count
            pedagogic = pedagogicViewModel.allResources[indexPath.section].resources[indexPath.row - 1]
        }
        
        let cellId = isLastCell ? "cellActionEnd" : "cellAction"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PedagogicCell
        cell.populateCell(title: pedagogic.title, imageUrl: pedagogic.imageUrl, isRead: pedagogic.isRead)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 { return }
        
        var pedagogic:PedagogicResource
        switch filterSelected {
        case .Understand:
            AnalyticsLoggerManager.logEvent(name: Pedago_View_understand_tag)
            pedagogic = pedagogicViewModel.understandResources.resources[indexPath.row - 1]
        case .Act:
            AnalyticsLoggerManager.logEvent(name: Pedago_View_act_tag)
            pedagogic = pedagogicViewModel.actResources.resources[indexPath.row - 1]
        case .Inspire:
            AnalyticsLoggerManager.logEvent(name: Pedago_View_inspire_tag)
            pedagogic = pedagogicViewModel.inspireResources.resources[indexPath.row - 1]
        case .All:
            AnalyticsLoggerManager.logEvent(name: Pedago_View_all_tag)
            pedagogic = pedagogicViewModel.allResources[indexPath.section].resources[indexPath.row - 1]
        }
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "pedagoDetailVC") as? PedagogicDetailViewController {
            vc.urlWebview = pedagogic.url
            vc.resourceId = pedagogic.id
            vc.delegate = self
            vc.isRead = pedagogic.isRead
            vc.htmlBody = pedagogic.bodyHtml
            AnalyticsLoggerManager.logEvent(name: Pedago_View_card)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - PedagogicReadDelegate -
extension PedagogicListViewController: PedagogicReadDelegate {
    func markReadPedogicResource(id: Int) {
        pedagogicViewModel.markReadResourceId(id) { isOk in
            self.ui_tableview.reloadData()
        }
    }
}

//MARK: - MJNavBackViewDelegate -
extension PedagogicListViewController: MJNavBackViewDelegate {
    func goBack() {
        //  self.dismiss(animated: true)
        self.navigationController?.dismiss(animated: true)
    }
}


