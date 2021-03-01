//
//  OTFeedNewsViewController.swift
//  entourage
//
//  Created by Jr on 16/02/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit

class OTFeedNewsViewController: UIViewController {

    @IBOutlet weak var ui_tableview: OTFeedItemsTableView!
    @IBOutlet weak var ui_waiting: UIActivityIndicatorView!
    var newsFilters = OTNewsFeedsFilter()
    
    var arrayAnnouncements = [OTAnnouncement]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_waiting.isHidden = true
        
        newsFilters.setAnnouncementOnly()
        getAnnouncements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let navigationBar = navigationController?.navigationBar
        
        if #available(iOS 13.0, *) {
            let navBarAppear = UINavigationBarAppearance()
            navBarAppear.configureWithOpaqueBackground()
            navBarAppear.backgroundColor = UIColor.white
            navBarAppear.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.appOrange() as Any]
           
            navigationBar?.standardAppearance = navBarAppear
            navigationBar?.scrollEdgeAppearance = navBarAppear
        } else {
            navigationBar?.backgroundColor = UIColor.white
            navigationBar?.tintColor = UIColor.appOrange()
            navigationBar?.barTintColor = UIColor.white
            navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.appOrange() as Any]
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.title = OTLocalisationService.getLocalizedValue(forKey: "announcements")?.uppercased()
       
        changeBackbutton()
       
    }
    
    func changeBackbutton() {
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "backItem"), for: .normal)
        btnLeftMenu.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 34/2, height: 28/2)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
    }

    @objc func onBack() {
        _ = self.navigationController?.popViewController(animated: true)
    }

    func getAnnouncements() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.ui_waiting.isHidden = false
        let location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let filterDict = newsFilters.toDictionary(withPageToken: "", andLocation: location)
        
        OTFeedsService().getAllFeeds(withParameters: filterDict as? [AnyHashable : Any]) { (feeds, nextpageToken) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.ui_waiting.isHidden = true
            self.arrayAnnouncements.removeAll()
            if let _array = feeds as? [OTAnnouncement] {
                self.arrayAnnouncements.append(contentsOf: _array)
                self.ui_tableview.reloadData()
            }
            
        } failure: { (error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.ui_waiting.isHidden = true
        }
    }
}

//MARK: - uitableview Datasource / Delegate
extension OTFeedNewsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayAnnouncements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OTAnnouncementTableViewCellIdentifier", for: indexPath) as! OTAnnouncementCell
        
        let item = arrayAnnouncements[indexPath.row]
        cell.configure(with: item) {}
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = arrayAnnouncements[indexPath.row]
        if let _url = URL.init(string: item.url) {
            UIApplication.shared.openURL(_url)
        }
    }
}
