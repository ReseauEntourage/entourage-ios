//
//  MainHomeViewController.swift
//  entourage
//
//  Created by Jerome on 14/03/2022.
//

import UIKit

class MainHomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        MetadatasService.getMetadatas { error in
            Logger.print("***** return get metadats ? \(error)")
        }
    }
}
