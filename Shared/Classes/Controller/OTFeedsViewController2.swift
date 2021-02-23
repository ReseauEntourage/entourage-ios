//
//  OTFeedsTourViewController2.swift
//  entourage
//
//  Created by Jr on 18/02/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit

class OTFeedsViewController2: UIViewController {

    let MAX_DISTANCE_FOR_MAP_CENTER_MOVE_ANIMATED_METERS = 100.0
    let TABLEVIEW_BOTTOM_INSET:CGFloat = 86.0
    let MAPVIEW_HEIGHT:CGFloat = 224.0
    let FEEDS_TABLEVIEW_FOOTER_HEIGHT:CGFloat = 4.0
    
    @IBOutlet weak var ui_tableView: UITableView!
    @IBOutlet weak var noDataBehavior:OTNoDataBehavior!
    @IBOutlet weak var ui_button_filters: UIButton!
    @IBOutlet weak var ui_button_map_list: UIButton!
    
    @IBOutlet weak var ui_button_launch: UIButton!
    @IBOutlet weak var ui_button_stop: UIButton!
    
    
    @IBOutlet weak var mapDelegateProxy:OTMapDelegateProxyBehavior!
    @IBOutlet weak var overlayFeeder:OTOverlayFeederBehavior!
    
    @IBOutlet weak var ui_waiting: UIActivityIndicatorView!
    @IBOutlet weak var ui_collectionView: UICollectionView!
    
    var mapView:OTMapView!
    
    
    var emptyFooterView:UIView!
    var lblEmptyTableReason:UILabel!
    var tapGestureRecognizer:UITapGestureRecognizer!
    
    var isShowMap = false
    var mapWasCenteredOnUserLocation = false
    
    var currentFilters = OTNewsFeedsFilter()
    
    var lastOkCoordinate:CLLocationCoordinate2D? = nil
    var currentCoordinate:CLLocationCoordinate2D!
    
    var feedNews = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ui_waiting.isHidden = true
        setup()
        setupButtons()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showCurrentLocation), name: NSNotification.Name(rawValue:  kNotificationShowFeedsMapCurrentLocation), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showUserProfile), name: NSNotification.Name("showUserProfileFromFeed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showMenuFromFeed), name: NSNotification.Name("showMenuFromFeed"), object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getNewsFeed()
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
        self.title = OTLocalisationService.getLocalizedValue(forKey: "title_new_gds")?.uppercased()
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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Notification Methods -
    
    @objc func showCurrentLocation() {
        OTLogger.logEvent("RecenterMapClick")
        
        if let _man = OTLocationManager.sharedInstance(), !_man.isAuthorized {
            OTLocationManager.sharedInstance()?.showGeoLocationNotAllowedMessage(OTLocalisationService.getLocalizedValue(forKey: "ask_permission_location_recenter_map"))
        }
        else if let _man = OTLocationManager.sharedInstance(), _man.currentLocation == nil  {
            OTLocationManager.sharedInstance()?.showLocationNotFoundMessage(OTLocalisationService.getLocalizedValue(forKey: "no_location_recenter_map"))
        }
        else {
            zoomToCurrentLocation()
        }
    }
    
    func zoomMapToLocation(location:CLLocation?) {
        if let location = location {
            let locationMap = MKMapPoint(self.mapView.centerCoordinate)
            let distance = locationMap.distance(to: MKMapPoint(location.coordinate))
            let animatedSetCenter:Bool = distance < MAX_DISTANCE_FOR_MAP_CENTER_MOVE_ANIMATED_METERS
            
            self.mapView.setCenter(location.coordinate, animated: animatedSetCenter)
        }
    }
    
    @objc func showUserProfile(notification: Notification) {
        Logger.print("***** Show profile : \(notification)")
        if let userId = notification.object as? NSNumber {
            Logger.print("***** Show profile : --> number : \(userId)")
            
            let sb = UIStoryboard.init(name: "UserProfile", bundle: nil)
            if let navVc = sb.instantiateInitialViewController() as? UINavigationController {
                if let vc = navVc.topViewController as? OTUserViewController {
                    vc.userId = userId
                    self.navigationController?.present(navVc, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func showMenuFromFeed(notification: Notification) {
        Logger.print("***** Show detail feed : \(notification)")
        if let feedItem = notification.object as? OTFeedItem {
            Logger.print("***** Show detail feed : --> feedItem : \(feedItem)")
            //TODO: voir pour afficher menu !
            
            self.performSegue(withIdentifier: "SegueChangeState", sender: feedItem)
        }
    }
    
    //MARK: - network
    func getNewsFeed() {
        self.currentFilters.distance = 10 //TODO: Radius
        
        let loadFilterString = self.currentFilters.description
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.ui_waiting.isHidden = false
        //TODO: -> pageToken + location
        let pageToken = ""
        currentCoordinate = CLLocationCoordinate2D.init(latitude: 48.8314408, longitude: 2.32556839999998)
        let filterDict = currentFilters.toDictionary(withPageToken: pageToken, andLocation: currentCoordinate)
        
        Logger.print("***** get data newsFeed - params : \(filterDict)")
        
        OTFeedsService.init().getAllFeeds(withParameters: filterDict as! [AnyHashable : Any], success: { (arrayFeeds, nextPageToken) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.ui_waiting.isHidden = true
            self.lastOkCoordinate = self.currentCoordinate
            
            Logger.print("***** return get news feed \(arrayFeeds)")
            
            if self.currentFilters.description == loadFilterString {
                //TODO: fill datas + reload tableview
                Logger.print("***** return ici ? ")
                if let _array = arrayFeeds {
                    self.feedNews = [Any]()
                    Logger.print("***** return ici2 ? \(_array.count) ")
                    for _item in _array {
                        Logger.print("***** return inside loop : \(_item)")
                        self.feedNews.append(_item)
                    }
                    Logger.print("***** return ici2 feeds ? \(self.feedNews.count)")
                    self.ui_tableView.reloadData()
                    self.updateMap()
                   
                }
            }
            
        }, failure: { (error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.ui_waiting.isHidden = true
            Logger.print("Error - \(error)")
        })
        
    }
    
    //MARK: - Setups -
    func setup() {
        
        self.lblEmptyTableReason = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
        self.lblEmptyTableReason.font = UIFont(name: "SFUItext-Semibold", size: 16)
        self.lblEmptyTableReason.textAlignment = .center
        self.lblEmptyTableReason.numberOfLines = 0
        self.lblEmptyTableReason.text = OTAppAppearance.extendMapSearchParameterDescription()
        
      //  self.solidarityFilter = OTGuideFilters() //TODO: init filters
        self.mapView = OTMapView()
        self.mapView.delegate = self
        
        self.mapDelegateProxy.mapView = self.mapView
        self.overlayFeeder.mapView = self.mapView
        self.mapDelegateProxy.initialize()
        
        
        
        self.ui_tableView?.delegate = self
        self.ui_tableView?.dataSource = self
        self.ui_tableView?.estimatedRowHeight = 140
        configureTableviewWithMap()
        
        self.noDataBehavior.initialize()
        self.noDataBehavior.switchedToGuide()
        
        configureMapView()
        
       // self.showMap(animated: false)
        self.showList(animated: false)
        
        changeButtonsState()
        
        self.mapDelegateProxy.delegates.add(self)
    }
    
    func configureTableviewWithMap() {
        let _frame = CGRect(x: 0, y: 0, width: self.ui_tableView.bounds.size.width, height: TABLEVIEW_BOTTOM_INSET)
        self.emptyFooterView = UIView(frame: _frame)
        self.ui_tableView?.tableFooterView = self.emptyFooterView
        
        self.ui_tableView.tableHeaderView = headerViewWithMap(mapHeight: MAPVIEW_HEIGHT)
        if let center = self.ui_tableView.tableHeaderView?.center {
            mapView.center = center
        }
        mapView.isScrollEnabled = false
        self.ui_tableView.isScrollEnabled = true
    }
    
    func headerViewWithMap(mapHeight:CGFloat) -> UIView {
        let mainScreenWidth = UIScreen.main.bounds.size.width
        let mapActualHeight = UIScreen.main.bounds.size.height
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: mainScreenWidth, height: mapHeight))
        
        mapView.frame = CGRect(x: 0, y: (mapHeight - mapActualHeight) / 2, width: headerView.bounds.size.width, height: mapActualHeight)
        let headerMapMask = CALayer()
        headerMapMask.backgroundColor = UIColor.black.cgColor
        headerMapMask.frame = CGRect(x: 0, y: headerView.frame.size.height - mapView.frame.size.height, width: headerView.frame.size.width, height: mapView.frame.size.height)
        headerView.layer.mask = headerMapMask
        
        let buttonSize:CGFloat = 42
        let marginOffset:CGFloat = 20;
        var y:CGFloat = marginOffset + 64 + 30;
        
        if #available(iOS 11.0, *) {
            y = self.ui_tableView.safeAreaInsets.top + marginOffset * 3
        }
        
        let x = UIScreen.main.bounds.size.width - buttonSize - marginOffset - 8
        let showCurrentLocationButton = UIButton(frame: CGRect(x: x, y: y, width: buttonSize, height: buttonSize))
        
        showCurrentLocationButton.setImage(UIImage.init(named: "geoloc"), for: .normal)
        showCurrentLocationButton.backgroundColor = .white
        showCurrentLocationButton.clipsToBounds = true
        showCurrentLocationButton.layer.cornerRadius = buttonSize / 2
        
        showCurrentLocationButton.layer.shadowColor = UIColor.black.cgColor
        showCurrentLocationButton.layer.shadowOpacity = 0.5
        showCurrentLocationButton.layer.shadowRadius = 4.0
        showCurrentLocationButton.layer.masksToBounds = false
        showCurrentLocationButton.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        
        showCurrentLocationButton.addTarget(self, action: #selector(requestCurrentLocation), for: .touchUpInside)
        
        headerView.addSubview(mapView)
        headerView.addSubview(showCurrentLocationButton)
        headerView.bringSubviewToFront(showCurrentLocationButton)
        headerView.sendSubviewToBack(mapView)
        
        return headerView
    }
    
    func setupButtons() {
        addEffectToButton(customButton:  self.ui_button_filters)
        addEffectToButton(customButton: self.ui_button_map_list)
    }
    
    func addEffectToButton(customButton:UIView) {
        customButton.layer.cornerRadius = customButton.frame.size.height / 2
        customButton.layer.shadowColor = UIColor.black.cgColor
        customButton.layer.shadowOpacity = 0.5
        customButton.layer.shadowRadius = 4.0
        customButton.layer.shadowOffset = CGSize.init(width: 0, height: 1.0)
    }
    
    func changeButtonsState() {
        var usFilterDefault = true //TODO: a faire le filtre par defaut : solidarityFilter.isDefaultFilters()
        if  usFilterDefault {
            ui_button_filters.setTitle(OTLocalisationService.getLocalizedValue(forKey: "home_button_filters")?.uppercased(), for: .normal)
        }
        else {
            ui_button_filters.setTitle(OTLocalisationService.getLocalizedValue(forKey: "home_button_filters_on")?.uppercased(), for: .normal)
        }
    }
    
    //MARK: - Map setup
    func getMapHeight() -> CLLocationDistance {
        let mpTopRight = MKMapPoint(x: self.mapView.visibleMapRect.origin.x + self.mapView.visibleMapRect.size.width, y: self.mapView.visibleMapRect.origin.y)
        let mpBottomRioght = MKMapPoint(x: self.mapView.visibleMapRect.origin.x + self.mapView.visibleMapRect.size.width, y: self.mapView.visibleMapRect.origin.y + self.mapView.visibleMapRect.size.height)
        
        let vDist = mpTopRight.distance(to: mpBottomRioght) / 1000.0
        return vDist
    }
    
    func configureMapView() {
        self.mapView.showsPointsOfInterest = false
        self.mapView.showsUserLocation = true
        self.mapView.isPitchEnabled = false
        self.mapView.showsBuildings = false
        self.mapView.showsTraffic = false
        
        guard let currentUser = UserDefaults.standard.currentUser else {
            return
        }
        var mapCenter:CLLocationCoordinate2D
        
        if currentUser.hasActionZoneDefined() {
            mapCenter = currentUser.addressPrimary.location.coordinate
        }
        else if let _coord = OTLocationManager.sharedInstance()?.currentLocation {
            mapCenter =  _coord.coordinate
        }
        else {
            mapCenter = CLLocationCoordinate2DMake(PARIS_LAT, PARIS_LON)
        }
        
        let region = MKCoordinateRegion(center: mapCenter, latitudinalMeters: CLLocationDistance(MAPVIEW_REGION_SPAN_X_METERS), longitudinalMeters: CLLocationDistance(MAPVIEW_REGION_SPAN_Y_METERS))
        
        self.mapView.setRegion(region, animated: false)
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        self.mapView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    //MARK: - Actions -
    
    @objc func requestCurrentLocation() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationShowFeedsMapCurrentLocation), object: nil)
    }
    
    @objc func handleTap(gesture:UITapGestureRecognizer) {
        Logger.print("Handle Tap ? \(gesture.state.rawValue) -- \(UIGestureRecognizer.State.ended.rawValue)")
        if gesture.state == .ended {
            if !self.isShowMap {
                Logger.print("***** show Map")
                showMap(animated: false)
            }
        }
    }
    
    
    //MARK: - Methods -
    
    func showMap(animated:Bool) {
        OTLogger.logEvent(Action_guide_showMap)
        self.ui_tableView?.isScrollEnabled = false
        self.mapView.isScrollEnabled = true
        
        var mapFrame = self.mapView.frame
        mapFrame.size.height = self.view.bounds.size.height;
        self.mapView.frame = mapFrame
        
        let duration = animated ? TimeInterval(floatLiteral: 0.25) : TimeInterval(floatLiteral: 0.0)
        UIView.animate(withDuration: duration) {
            let region = MKCoordinateRegion(center: self.mapView.centerCoordinate, latitudinalMeters: CLLocationDistance(MAPVIEW_REGION_SPAN_X_METERS), longitudinalMeters: CLLocationDistance(MAPVIEW_REGION_SPAN_Y_METERS))
            self.mapView.setRegion(region, animated: animated)
            self.ui_tableView.tableHeaderView = self.headerViewWithMap(mapHeight: mapFrame.size.height)
            
            self.ui_tableView?.scrollRectToVisible(.init(x: 0, y: 0, width: 1, height: 1), animated: animated)
        }
        
        self.isShowMap = true
        changeButtonRightTitle()
    }
    
    func showList(animated:Bool) {
        OTLogger.logEvent(Action_guide_showList)
        
        self.ui_tableView?.isScrollEnabled = true
        self.mapView.isScrollEnabled = false
        
        self.ui_tableView.tableHeaderView = headerViewWithMap(mapHeight: MAPVIEW_HEIGHT)
        
        self.isShowMap = false
        changeButtonRightTitle()
    }
    
    func changeButtonRightTitle() {
        if self.isShowMap {
            ui_button_map_list.setTitle(OTLocalisationService.getLocalizedValue(forKey: "home_button_list")?.uppercased(), for: .normal)
        }
        else {
            ui_button_map_list.setTitle(OTLocalisationService.getLocalizedValue(forKey: "home_button_map")?.uppercased(), for: .normal)
        }
        changeFilterButton()
    }
    
    func changeFilterButton() {
        if currentFilters.isDefaultFilters() {
            ui_button_filters.setTitle(OTLocalisationService.getLocalizedValue(forKey: "home_button_filters")?.uppercased(), for: .normal)
        }
        else {
            ui_button_filters.setTitle(OTLocalisationService.getLocalizedValue(forKey: "home_button_filters_on")?.uppercased(), for: .normal)
        }
    }
    
    func zoomToCurrentLocation() {
        let currentLocation = OTLocationManager.sharedInstance()?.currentLocation
        zoomMapToLocation(location: currentLocation)
    }
    
    //MARK: - IBActions -
    
    @IBAction func action_map_list(_ sender: Any) {
        if self.isShowMap {
            self.showList(animated: false)
        }
        else {
            self.showMap(animated: false)
        }
    }
    
    
    @IBAction func action_filters(_ sender: Any) {
        let sb = UIStoryboard.init(name: "FeedItemFilters", bundle: nil)
        if let navVc = sb.instantiateInitialViewController() as? UINavigationController {
            if let vc = navVc.topViewController as? OTFeedItemFiltersViewController {
                vc.filterDelegate = self
                self.navigationController?.present(navVc, animated: true, completion: nil)
            }
        }
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueChangeState" {
            if let _sender = sender as? OTFeedItem {
                if let vc = segue.destination as? OTChangeStateViewController {
                    vc.feedItem = _sender
                    vc.delegate = self
                    vc.shouldShowTabBarOnClose = true //TODO: a voir
                    //vc.editEntourageBehavior // =: self.editEntourageBehavior
                }
            }
        }
        
    }
    
}

extension OTFeedsViewController2:OTStatusChangedProtocol {
    func joinFeedItem() {
        Logger.print("***** joinFeeditem")
    }
    
    func stoppedFeedItem() {
        Logger.print("***** STOPFeeditem")
    }
    
    func closedFeedItem(with reason: OTCloseReason) {
        Logger.print("***** CLOSEFeeditem")
    }
    
    func quitedFeedItem() {
        Logger.print("***** QUITFeeditem")
    }
    
    func cancelledJoinRequest() {
        Logger.print("***** CANCELLEDFeeditem")
    }
    
    
}

//MARK: - OTFeedItemsFilterDelegate
extension OTFeedsViewController2: OTFeedItemsFilterDelegate {
   
    var currentFilter: OTFeedItemFilters! {
        Logger.print("***** CurrentFilter :")
        return self.currentFilters
    }

    var encounterFilter: OTFeedItemFilters! {
        Logger.print("***** encounterFilter : ")
        return self.currentFilters
    }

    var isEncounterSelected: Bool {
        Logger.print("***** isEncounterSelected : ")
        return true
    }
    
    func filterChanged(_ filter: OTFeedItemFilters!) {
        Logger.print("***** filterChanged : \(filter)")
        
        if filter == nil {
            // discard the changes if user pressed close button
            //self.currentFilter = [OTNewsFeedsFilter new];
            return
        }
        Logger.print("***** ici change filters avant: \(self.currentFilters)")
        self.currentFilters = filter as! OTNewsFeedsFilter
        Logger.print("***** ici change filters après: \(self.currentFilters)")
        
        //self.forceReloadingFeeds = NO;
       //        [NSUserDefaults standardUserDefaults].savedNewsfeedsFilter = [OTSavedFilter fromNewsFeedsFilter:self.currentFilter];

       
        self.changeFilterButton()
        //[self reloadFeeds];
        getNewsFeed()
    }
    
    
}

//MARK: - Tableview datasource / Delegate
extension OTFeedsViewController2: UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        Logger.print("***** return Tableview section count \(self.feedNews.count) ")
        if self.feedNews.count == 0 {
            self.ui_tableView.backgroundView = self.lblEmptyTableReason
        }
        else {
            self.ui_tableView.backgroundView = nil
        }
        return self.feedNews.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView =  UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: FEEDS_TABLEVIEW_FOOTER_HEIGHT))
        
        footerView.backgroundColor = .clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return FEEDS_TABLEVIEW_FOOTER_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = feedNews[indexPath.section]
        
        if let _item = item as? OTAnnouncement {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OTAnnouncementTableViewCellIdentifier", for: indexPath) as! OTAnnouncementCell
            cell.configure(with: _item, completion: nil)
            return cell
        }
        else {
            if let _item = item as? OTFeedItem {
                Logger.print("***** return otFeedItem cell")
                let cell = tableView.dequeueReusableCell(withIdentifier: "OTNewsFeedTableViewCellIdentifier", for: indexPath) as! OTNewsFeedCell
                cell.configure(with: _item)
                return cell
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OTNewsFeedTableViewCellIdentifier", for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = feedNews[indexPath.section]
        
        if let _item = item as? OTAnnouncement, let url = URL.init(string: _item.url) {
            UIApplication.shared.openURL(url)
        }
        else {
            if let _item = item as? OTFeedItem {
                self.showFeedInfo(feedItem: _item)
            }
           
        }
        
//         else {
//            if (self.feedItemsDelegate != nil && [self.feedItemsDelegate respondsToSelector:@selector(showFeedInfo:)])
//                [self.feedItemsDelegate showFeedInfo:selectedItem];
//                if([selectedItem isKindOfClass:[OTEntourage class]]
//                   && [[selectedItem joinStatus] isEqualToString:@"not_requested"])
//                {
//                    NSNumber *rank = @(indexPath.section);
//                    [[OTEntourageService new] retrieveEntourage:(OTEntourage *)selectedItem
//                                                       fromRank:rank
//                                                        success:nil
//                                                        failure:nil];
//                }
//
//        }
    }
    
    func showFeedInfo(feedItem:OTFeedItem) {
        var bool0 = false
        if let _bool =  OTFeedItemFactory.create(for: feedItem) {
            if let _bool1 = _bool.getStateInfo?() {
                bool0 = _bool1.isPublic()
            }
        }
       

        if bool0 {
            //TODO: [OTLogger logEvent:@"OpenEntouragePublicPage"]
            if feedItem.isTour() {
                //PublicFeedItemDetailsSegue
                let vc0 = UIStoryboard.init(name: "PublicFeedItem", bundle: nil)
                let vc = vc0.instantiateInitialViewController() as! OTPublicFeedItemViewController
                vc.feedItem = feedItem
                self.navigationController?.pushViewController(vc, animated: true)
                
                
                
                //OTPublicFeedItemViewController *controller = (OTPublicFeedItemViewController *)destinationViewController;
//                controller.feedItem = self.selectedFeedItem;
            }
            else {
                //pushDetailFeedNew
                let vc = UIStoryboard.init(name: "PublicFeedDetailNew", bundle: nil).instantiateInitialViewController() as! OTDetailActionEventViewController
                vc.feedItem = feedItem
                self.navigationController?.pushViewController(vc, animated: true)
                
                //OTDetailActionEventViewController *controller = (OTDetailActionEventViewController *) destinationViewController;
//                controller.feedItem = self.selectedFeedItem;
            }
        }
        else {
            //TODO:  [OTLogger logEvent:@"OpenEntourageActivePage"];
            //ActiveFeedItemDetailsSegue
            
            if let vc = UIStoryboard.init(name: "ActiveFeedItem", bundle: nil).instantiateInitialViewController() as? OTActiveFeedItemViewController {
                vc.feedItem = feedItem
                vc.inviteBehaviorTriggered = false //TODO: a voir ?
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}

//MARK: - CollectionView Datasource / Delegate
extension OTFeedsViewController2: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath)
        
        return cell
    }
}


//MARK: -MKMapViewDelegate-
extension OTFeedsViewController2: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView:MKAnnotationView? = nil
        
        if let _annot = annotation as? OTCustomAnnotation {
            if let _annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: _annot.annotationIdentifier()) {
                annotationView = _annotationView
            }
            else {
                annotationView = _annot.annotationView()
            }
            annotationView?.annotation = annotation
        }
        return annotationView;
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        self.noDataBehavior.hideNoData()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        getNewsFeed()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        //TODO: voir si did select utilisé dans la maraude
        if let _ = view.annotation as? MKUserLocation {
            return
        }
       
        if let _annot = view.annotation as? OTCustomAnnotation, let _poi = _annot.poi {
            DispatchQueue.main.async {
              //  self.showPoiDetails(_poi)
            }
        }
    }
    
    //BaseMapDelegate
    func locationUpdated(notification:NSNotification) {
        if !self.mapWasCenteredOnUserLocation {
            let currentUser = UserDefaults.standard.currentUser
            if currentUser?.hasActionZoneDefined() ?? false && currentUser?.addressPrimary.location != nil {
                self.mapWasCenteredOnUserLocation = true
                zoomMapToLocation(location: currentUser?.addressPrimary.location)
            }
            else {
                if let locations = notification.readLocations(), locations.count > 0 {
                    self.mapWasCenteredOnUserLocation = true
                    zoomToCurrentLocation()
                }
            }
        }
    }
    
    
    func updateMap() {
        var feedItems = [Any]()
        
        for item in feedNews {
            if item is OTAnnouncement {}
            else {
                feedItems.append(item)
            }
        }
        var annotations = [Any]()
        Logger.print("***** ICI nb feeds news ? \(feedItems)")
        self.overlayFeeder.updateOverlays(feedItems)
        
        for item in feedItems {
            if let _item = item as? OTEntourage {
                if OTAppConfiguration.shouldShowPOIsOnFeedsMap() {
                    if _item.isNeighborhood() {
                        if let entFeedAnnot = OTNeighborhoodAnnotation.init(entourage: _item) {
                            annotations.append(entFeedAnnot)
                        }
                    }
                    else if _item.isPrivateCircle() {
                        if let entFeedAnnot = OTPrivateCircleAnnotation.init(entourage: _item) {
                            annotations.append(entFeedAnnot)
                        }
                    }
                }
                if _item.isOuting() {
                    if let entFeedAnnot = OTOutingAnnotation.init(entourage: _item) {
                        annotations.append(entFeedAnnot)
                    }
                }
            }
        }
        Logger.print("***** nb mkannts ? \(annotations)")
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations as! [MKAnnotation])
    }
}
