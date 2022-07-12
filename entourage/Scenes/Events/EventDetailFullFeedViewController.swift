//
//  EventDetailFullFeedViewController.swift
//  entourage
//
//  Created by Jerome on 12/07/2022.
//

import UIKit

class EventDetailFullFeedViewController: UIViewController {

    @IBOutlet weak var ui_top_view: MJNavBackView!
    
    var event:Event? = nil
    var eventId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_top_view.backgroundColor = .clear
        ui_top_view.populateCustom(title: "En construction ;)", titleFont: nil, titleColor: nil, imageName: nil, backgroundColor: .clear, delegate: self, showSeparator: false, cornerRadius: nil, isClose: false, marginLeftButton: nil)
    }
}

//MARK: - MJNavBackViewDelegate -
extension EventDetailFullFeedViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.dismiss(animated: true)
    }
}
