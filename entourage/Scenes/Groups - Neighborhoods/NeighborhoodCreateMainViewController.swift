//
//  NeighborhoodMainViewController.swift
//  entourage
//
//  Created by Jerome on 01/04/2022.
//

import UIKit

class NeighborhoodCreateMainViewController: UIViewController {

    @IBOutlet weak var ui_top_view: MJNavBackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.modalPresentationStyle = .fullScreen
        
        ui_top_view.populateCustom(imageName: "back_button_white", backgroundColor: .clear, delegate: self, showSeparator: false)
    }
    


}

//MARK: - MJNavBackViewDelegate -
extension NeighborhoodCreateMainViewController: MJNavBackViewDelegate {
    func goBack() {
        self.dismiss(animated: true)
    }
}
