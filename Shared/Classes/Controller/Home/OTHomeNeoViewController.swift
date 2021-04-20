//
//  OTHomeLightViewController.swift
//  entourage
//
//  Created by Jr on 07/04/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit

class OTHomeNeoViewController: UIViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_title: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _message:String = OTLocalisationService.getLocalizedValue(forKey: "home_neo_title")
        let _mess_Orange:String = OTLocalisationService.getLocalizedValue(forKey: "home_neo_title_bold")
        let _title = Utilitaires.formatString(stringMessage: _message, coloredTxt: _mess_Orange, color: .black, colorHighlight: UIColor.appOrange(), fontSize: 30.0, fontWeight: .regular, fontColoredWeight: .regular)
        
        self.ui_title.attributedText = _title
    }
}

extension OTHomeNeoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! OTHomeNeoCell
        
        if indexPath.row == 0 {
            cell.populateCell(cellType: .Orange, title: "home_neo_cell1_title", description: "home_neo_cell1_description", imageNamed: "first_try", buttonTitle: "home_neo_cell1_button")
        }
        else {
            cell.populateCell(cellType: .White, title: "home_neo_cell2_title", description: "home_neo_cell2_description", imageNamed: "agir", buttonTitle: "home_neo_cell2_button")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "HomeNeoFirstHelp") {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "HomeNeoAction") {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
