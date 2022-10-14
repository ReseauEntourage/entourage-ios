//
//  EventCreatePhase2ViewController.swift
//  entourage
//
//  Created by Jerome on 21/06/2022.
//

import UIKit

class EventCreatePhase2ViewController: UIViewController {
    
    weak var pageDelegate:EventCreateMainDelegate? = nil
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    var startDateSelected:Date? = nil
    var endDateSelected:Date? = nil
    var recurrenceSelected:EventRecurrence = .once
    
    var currentEvent:Event? = nil
    
    var hasCurrentRecurrency = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        ui_tableview.rowHeight = UITableView.automaticDimension
        ui_tableview.estimatedRowHeight = 50
        
        if pageDelegate?.isEdit() ?? false {
            currentEvent = pageDelegate?.getCurrentEvent()
            hasCurrentRecurrency = pageDelegate?.hasCurrentRecurrency() ?? false
        }
    }
}

//MARK: - UITableView datasource / Delegate -
extension EventCreatePhase2ViewController:UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hasCurrentRecurrency ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDate", for: indexPath) as! EventDatesCell
            
            let startD = startDateSelected != nil ? startDateSelected : currentEvent?.getStartEndDate().startDate
            let endD = endDateSelected != nil ? endDateSelected : currentEvent?.getStartEndDate().endDate
            
            cell.populateCell(startDate:startD, endDate:endD, delegate: self, hasRecurrency: hasCurrentRecurrency,recurrency: currentEvent?.recurrence)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSelector", for: indexPath) as! EventRecurrenceCell
        let recur = currentEvent != nil ? currentEvent!.recurrence : recurrenceSelected
        
        cell.populateCell(recurrence:recur, delegate: self)
        return cell
    }
}

//MARK: - EventCreateDateCellDelegate -
extension EventCreatePhase2ViewController: EventCreateDateCellDelegate {
    func addDateStart(dateStart: Date?) {
        startDateSelected = dateStart
        pageDelegate?.addDateStart(dateStart: dateStart)
    }
    
    func addDateEnd(dateEnd: Date?) {
        endDateSelected = dateEnd
        pageDelegate?.addDateEnd(dateEnd: dateEnd)
    }
    
    func addRecurrence(recurrence: EventRecurrence) {
        recurrenceSelected = recurrence
        pageDelegate?.addRecurrence(recurrence: recurrence)
    }
    
    func setDateChanged() {
        pageDelegate?.setDateChanged()
    }
}
