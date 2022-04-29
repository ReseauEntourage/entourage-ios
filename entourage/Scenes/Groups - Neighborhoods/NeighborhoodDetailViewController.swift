//
//  NeighborhoodDetailViewController.swift
//  entourage
//
//  Created by Jerome on 27/04/2022.
//

import UIKit

class NeighborhoodDetailViewController: UIViewController {
    
    @IBOutlet weak var ui_container_view: UIView!
    @IBOutlet weak var ui_viewtop_white_round: UIView!
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_top_view: MJNavBackView!

    var neighborhoodId:Int = 0
    var neighborhood:Neighborhood? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_container_view.addRadiusTopOnly(radius: ApplicationTheme.bigCornerRadius)
        
        ui_viewtop_white_round.addRadiusTopOnly(radius: ApplicationTheme.bigCornerRadius)
        
        ui_top_view.backgroundColor = .clear
        ui_top_view.populateCustom(title: nil, titleFont: nil, titleColor: nil, imageName: nil, backgroundColor: .clear, delegate: self, showSeparator: false, cornerRadius: nil, isClose: false, marginLeftButton: nil)
        
        getNeighborhoodDetail()
    }

    func getNeighborhoodDetail() {
        NeighborhoodService.getNeighborhoodDetail(id: neighborhoodId) { group, error in
            if let _ = error {
                self.goBack()
            }
            
            self.neighborhood = group
            self.ui_tableview.reloadData()
        }
    }
    
    @IBAction func action_show_params(_ sender: Any) {
        //TODO: a faire
        Logger.print("***** Show params")
    }
}

//MARK: - UITableViewDataSource / Delegate -
extension NeighborhoodDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellTop", for: indexPath) as! NeighborhoodDetailTopCell
        
        cell.populateCell(neighborhood: self.neighborhood, delegate: self)
        
        return cell
    }
}

//MARK: - NeighborhoodDetailTopCellDelegate -
extension NeighborhoodDetailViewController: NeighborhoodDetailTopCellDelegate {
    func showMembers() {
        //TODO: a faire
        Logger.print("***** show membres")
    }
    
    func joinLeave() {
        //TODO: a faire
        Logger.print("***** join / leave")
    }
}

//MARK: - MJNavBackViewDelegate -
extension NeighborhoodDetailViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.dismiss(animated: true)
    }
}
