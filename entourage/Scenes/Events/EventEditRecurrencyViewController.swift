//
//  EventEditRecurrencyViewController.swift
//  entourage
//
//  Created by Jerome on 27/07/2022.
//

import UIKit
import IHProgressHUD

class EventEditRecurrencyViewController: UIViewController {
    
    @IBOutlet weak var ui_main_container_view: UIView!
    @IBOutlet weak var ui_bt_previous: UIButton!
    @IBOutlet weak var ui_bt_next: UIButton!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    @IBOutlet weak var ui_tableview: UITableView!
    
    var event:Event? = nil
    
    var selectedRecurrence:EventRecurrence = .once
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedRecurrence = event?.recurrence ?? .once
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        ui_tableview.rowHeight = UITableView.automaticDimension
        ui_tableview.estimatedRowHeight = 50
        
        ui_bt_previous.layer.cornerRadius = ui_bt_previous.frame.height / 2
        ui_bt_previous.layer.borderColor = UIColor.appOrange.cgColor
        ui_bt_previous.layer.borderWidth = 1
        ui_bt_previous.backgroundColor = .clear
        ui_bt_previous.setTitleColor(.appOrange, for: .normal)
        ui_bt_previous.titleLabel?.font = ApplicationTheme.getFontNunitoBold(size: 15)
        ui_bt_previous.setTitle("event_edit_recurrency_back".localized, for: .normal)
        
        ui_bt_next.layer.cornerRadius = ui_bt_next.frame.height / 2
        ui_bt_next.backgroundColor = .appOrange
        ui_bt_next.setTitleColor(.white, for: .normal)
        ui_bt_next.titleLabel?.font = ApplicationTheme.getFontNunitoBold(size: 15)
        ui_bt_next.setTitle("event_edit_recurrency_next".localized, for: .normal)
        
        ui_main_container_view.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        
        ui_tableview.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        
        self.modalPresentationStyle = .fullScreen
        
        ui_top_view.populateCustom(title: "event_edit_recurrency_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 24), titleColor: .white, imageName: "back_button_white", backgroundColor: .clear, delegate: self, showSeparator: false)
    }
    
    func sendUpdateRecurrency() {
        if hasNoInput() {
            IHProgressHUD.showSuccesswithStatus("event_mod_ok".localized)
            self.goEnd()
            return
        }
        
        guard let event = event else {
            return
        }
        
        var _recurrency = 0
        
        switch selectedRecurrence {
        case .once:
            _recurrency = 0
        case .week:
            _recurrency = 7
        case .every2Weeks:
            _recurrency = 14
        case .month:
            _recurrency = 31
        }
        
        IHProgressHUD.show()
        EventService.updateEventRecurrency(eventId: event.uid, recurrency: _recurrency) { event, error in
            IHProgressHUD.dismiss()
            if error != nil {
                IHProgressHUD.showError(withStatus: "event_mod_nok".localized)
            }
            else {
                self.goEnd()
            }
        }
    }
    
    private func goEnd() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationEventUpdate), object: nil)
        
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
    
    private func hasNoInput() -> Bool {
        return selectedRecurrence == event?.recurrence
    }
    
    //MARK: - IBActions -
    @IBAction func action_validate(_ sender: Any) {
        self.sendUpdateRecurrency()
    }
    
    @IBAction func action_back(_ sender: Any) {
        goBack()
    }
}

//MARK: - UITableView datasource / Delegate -
extension EventEditRecurrencyViewController:UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSelector", for: indexPath) as! EventRecurrenceCell
        
        cell.populateCell(recurrence:selectedRecurrence, delegate: self, isEditRecurrency: true, date: event?.getMetadateStartDate())
        return cell
    }
}

//MARK: - EventCreateDateCellDelegate -
extension EventEditRecurrencyViewController: EventCreateDateCellDelegate {
    func addDateStart(dateStart: Date?) {}
    
    func addDateEnd(dateEnd: Date?) {}
    
    func addRecurrence(recurrence: EventRecurrence) {
        selectedRecurrence = recurrence
    }
    
    func setDateChanged() {}
}

//MARK: - MJNavBackViewDelegate -
extension EventEditRecurrencyViewController: MJNavBackViewDelegate {
    func goBack() {
        self.dismiss(animated: true)
    }
}
