//
//  OTMainGuideViewController.swift
//  entourage
//
//  Created by Jr on 14/09/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit
import IHProgressHUD
import MapKit

class MainGuideViewController: UIViewController {
    
    let MAX_DISTANCE_FOR_MAP_CENTER_MOVE_ANIMATED_METERS = 100.0
    let TABLEVIEW_BOTTOM_INSET:CGFloat = 86.0
    let MAPVIEW_HEIGHT:CGFloat = 224.0
    let FEEDS_TABLEVIEW_FOOTER_HEIGHT:CGFloat = 4.0
    
    @IBOutlet weak var ui_tableView: UITableView!
    @IBOutlet weak var ui_button_filters: UIButton!
    @IBOutlet weak var ui_button_map_list: UIButton!
    @IBOutlet weak var ui_view_top_info_gds: UIView!
    @IBOutlet weak var ui_label_info_web_gds: UILabel!
    @IBOutlet weak var ui_constraint_height_view_topinfo: NSLayoutConstraint!
    
    //Use to show / hide pop info on top of view
    var hasToShowTopInformationGDS = false
    
    var mapView:MKMapView!
    var solidarityFilter:GuideFilters!
    var emptyFooterView:UIView!
    var lblEmptyTableReason:UILabel!
    var tapGestureRecognizer:UITapGestureRecognizer!
    var categories = [PoiCategory]()
    var pois = [MapPoi]()
    var markers = [MKAnnotation]()
    var mapWasCenteredOnUserLocation = false
    var isShowMap = false
    var isFirstLaunch = true
    
    @objc var isFromDeeplink = false
     let kNotificationShowFeedsMapCurrentLocation = "NotificationFeedsMapCurrentLocation"
    
    //MARK: - LifeCycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        setupButtons()
        fillCategories()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showCurrentLocation), name: NSNotification.Name(rawValue:  kNotificationShowFeedsMapCurrentLocation), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let navigationBar = navigationController?.navigationBar
        
        if #available(iOS 13.0, *) {
            let navBarAppear = UINavigationBarAppearance()
            navBarAppear.configureWithOpaqueBackground()
            navBarAppear.backgroundColor = UIColor.white
            navBarAppear.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black as Any]
           
            navigationBar?.standardAppearance = navBarAppear
            navigationBar?.scrollEdgeAppearance = navBarAppear
        } else {
            navigationBar?.backgroundColor = UIColor.white
            navigationBar?.tintColor = UIColor.appOrange
            navigationBar?.barTintColor = UIColor.white
            navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black as Any]
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.title = "title_new_gds".localized.uppercased()
        changeBackbutton()
        
        if self.hasToShowTopInformationGDS {
            let txt_underline = Utils.formatStringUnderline(textString: "Pop_info_web_alert_GDS".localized, textUnderlineString: "Pop_info_web_alert_GDS_underline".localized, textColor: .white, underlinedColor: .white, fontSize: 14,fontWeight: .regular)
            
            self.ui_label_info_web_gds.attributedText = txt_underline
            self.ui_view_top_info_gds.isHidden = false
        }
        else {
            self.ui_constraint_height_view_topinfo.constant = 0
            self.ui_view_top_info_gds.isHidden = true
        }
        if isFirstLaunch {
            showMap(animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstLaunch {
            getPoiList()
            isFirstLaunch = false
        }
        
        if isFromDeeplink {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                DispatchQueue.main.async {
                    self.showMap(animated: false)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isFromDeeplink {
            let navigationBar = navigationController?.navigationBar
            
            if #available(iOS 13.0, *) {
                let navBarAppear = UINavigationBarAppearance()
                navBarAppear.configureWithOpaqueBackground()
                navBarAppear.backgroundColor = UIColor.appOrange
                navBarAppear.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white as Any]
                
                navigationBar?.standardAppearance = navBarAppear
                navigationBar?.scrollEdgeAppearance = navBarAppear
            } else {
                navigationBar?.backgroundColor = UIColor.appOrange
                navigationBar?.tintColor = UIColor.white
                navigationBar?.barTintColor = UIColor.appOrange
                navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white as Any]
            }
        }
    }
    
    func changeBackbutton() {
//        let btnLeftMenu: UIButton = UIButton()
//        btnLeftMenu.setImage(UIImage(named: "backItem"), for: .normal)
//        btnLeftMenu.addTarget(self, action: #selector(onBack), for: .touchUpInside)
//        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 34/2, height: 28/2)
//        let barButton = UIBarButtonItem(customView: btnLeftMenu)
//        self.navigationItem.leftBarButtonItem = barButton
        
        let btnRightMenu: UIButton = UIButton()
        btnRightMenu.setImage(UIImage(named: "search_new_orange"), for: .normal)
        btnRightMenu.addTarget(self, action: #selector(showSearch), for: .touchUpInside)
        btnRightMenu.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        let barButtonRight = UIBarButtonItem(customView: btnRightMenu)
        self.navigationItem.rightBarButtonItem = barButtonRight
    }

    @objc func onBack() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @objc func showSearch() {
        let sb = UIStoryboard.init(name: "GuideSolidarity", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "vcSearch") as! GDSSearchViewController
        vc.modalPresentationStyle = .fullScreen
        vc.distance = getMapHeight()
        vc.location = mapView.centerCoordinate
        
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func fillCategories() {
        self.categories = [PoiCategory]()
        for i in 0...8 {
            var cat = PoiCategory()
            cat.sid = i
            cat.updateInfos()
            self.categories.append(cat)
        }
        for i in 40...43 {
            var cat = PoiCategory()
            cat.sid = i
            cat.updateInfos()
            self.categories.append(cat)
        }
        for i in 60...61 {
            var cat = PoiCategory()
            cat.sid = i
            cat.updateInfos()
            self.categories.append(cat)
        }
    }
    
    //MARK: - Notification Methods -
    
    @objc func showCurrentLocation() {
        AnalyticsLoggerManager.logEvent(name:"RecenterMapClick")
        
        if LocationManger.sharedInstance.getAuthorizationStatus() != .authorizedAlways && LocationManger.sharedInstance.getAuthorizationStatus() != .authorizedWhenInUse {
            LocationManger.sharedInstance.showGeolocationNotAllowedMessage(message: "ask_permission_location_recenter_map".localized)
        }
        else if LocationManger.sharedInstance.getCurrentLocation() == nil {
            LocationManger.sharedInstance.showGeolocationNotFound(message: "no_location_recenter_map".localized)
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
    
    //MARK: - Setups -
    func setup() {
        
        self.lblEmptyTableReason = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
        self.lblEmptyTableReason.font = UIFont(name: "SFUItext-Semibold", size: 16)
        self.lblEmptyTableReason.textAlignment = .center
        self.lblEmptyTableReason.numberOfLines = 0
//        self.lblEmptyTableReason.text = OTAppAppearance.extendMapSearchParameterDescription()//TODO: a faire
        
        self.solidarityFilter = GuideFilters()
//        self.mapView = OTMapView()
        self.mapView = MKMapView()
        self.mapView.delegate = self
        
        self.ui_tableView?.delegate = self
        self.ui_tableView?.dataSource = self
        self.ui_tableView?.estimatedRowHeight = 140
        configureTableviewWithMap()
        configureMapView()
        self.showMap(animated: false)
        
        changeButtonsState()
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
        if solidarityFilter.isDefaultFilters() {
            ui_button_filters.setTitle("home_button_filters".localized.uppercased(), for: .normal)
        }
        else {
            ui_button_filters.setTitle("home_button_filters_on".localized.uppercased(), for: .normal)
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
        self.mapView.delegate = self
        self.mapView.showsPointsOfInterest = false
        self.mapView.showsUserLocation = true
        self.mapView.isPitchEnabled = false
        self.mapView.showsBuildings = false
        self.mapView.showsTraffic = false
        
        guard let currentUser = UserDefaults.currentUser else {
            return
        }
        var mapCenter:CLLocationCoordinate2D
        Logger.print("***** ici configure map on a une Zone ? : \(currentUser.hasActionZoneDefined())")
        
        if currentUser.hasActionZoneDefined(), let addr = currentUser.addressPrimary, let location = addr.location {
            mapCenter = location.coordinate
            Logger.print("***** ici configure map on a une Zone : \(addr.location?.coordinate.latitude) - long : \(addr.location?.coordinate.longitude)")
        }
        else if let _coord = LocationManger.sharedInstance.getCurrentLocation() {
            mapCenter =  _coord.coordinate
            Logger.print("***** ici configure map on a une CurrentLocation : \(_coord.coordinate)?")
        }
        else {
            mapCenter = CLLocationCoordinate2DMake(PARIS_LAT, PARIS_LON)
            Logger.print("***** ici configure map on a Rien center : \(mapCenter)")
        }
        
        let region = MKCoordinateRegion(center: mapCenter, latitudinalMeters: CLLocationDistance(MAPVIEW_REGION_LIGHT_SPAN_X_METERS), longitudinalMeters: CLLocationDistance(MAPVIEW_REGION_LIGHT_SPAN_Y_METERS))
        
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
    
    var isAllreadyCall = false
    //MARK: - Network -
    func getPoiList() {
        if isAllreadyCall {
            return
        }
        isAllreadyCall = true
        IHProgressHUD.show()
        
        Logger.print("***** get poi List mapview coord ? \(mapView.centerCoordinate)")
        
        guard let _dict = self.solidarityFilter.toDictionary(distance: getMapHeight(), location: mapView.centerCoordinate) else {
            Logger.print("***** Error get filter to dict ****")
            return
        }
        var newDict = _dict
        newDict["v"] = "2"
        
        PoiService.getPois(params: newDict) { [weak self] pois, error in
            Logger.print("***** return get Pois here \(pois?.count)")
            IHProgressHUD.dismiss()
           
            if let _ = error {
                self?.isAllreadyCall = false
                return
            }
            
            if let _pois = pois {
                self?.pois = _pois
            }
            
            self?.ui_tableView?.reloadData()
            self?.feedMap()
        }
    }
    
    //MARK: - Methods -
    
    func feedMap() {
        self.mapView.removeAnnotations(self.markers)
        self.markers.removeAll()
        
        for poi in pois {
            let annot = CustomAnnotation(poi: poi)
            Logger.print("***** feedMap create poi : \(annot.annotationView)")
           
            self.markers.append(annot)
        }
        Logger.print("***** feedMap nb markers : \(markers.count)")
        self.mapView.addAnnotations(self.markers)
        isAllreadyCall = false
    }
    
    func showMap(animated:Bool) {
        AnalyticsLoggerManager.logEvent(name:Action_guide_showMap)
        self.ui_tableView?.isScrollEnabled = false
        self.mapView.isScrollEnabled = true
        
        var mapFrame = self.mapView.frame
        mapFrame.size.height = self.view.bounds.size.height;
        self.mapView.frame = mapFrame
        
        let duration = animated ? TimeInterval(floatLiteral: 0.25) : TimeInterval(floatLiteral: 0.0)
        UIView.animate(withDuration: duration) {
            let region = MKCoordinateRegion(center: self.mapView.centerCoordinate, latitudinalMeters: CLLocationDistance(MAPVIEW_REGION_LIGHT_SPAN_X_METERS), longitudinalMeters: CLLocationDistance(MAPVIEW_REGION_LIGHT_SPAN_Y_METERS))
            self.mapView.setRegion(region, animated: animated)
            self.ui_tableView.tableHeaderView = self.headerViewWithMap(mapHeight: mapFrame.size.height)
            
            self.ui_tableView?.scrollRectToVisible(.init(x: 0, y: 0, width: 1, height: 1), animated: animated)
        }
        
        self.isShowMap = true
        changeButtonRightTitle()
    }
    
    func showList(animated:Bool) {
        AnalyticsLoggerManager.logEvent(name:Action_guide_showList)
        
        self.ui_tableView?.isScrollEnabled = true
        self.mapView.isScrollEnabled = false
        
        self.ui_tableView.tableHeaderView = headerViewWithMap(mapHeight: MAPVIEW_HEIGHT)
        
        self.isShowMap = false
        changeButtonRightTitle()
    }
    
    func changeButtonRightTitle() {
        if self.isShowMap {
            ui_button_map_list.setTitle("home_button_list".localized.uppercased(), for: .normal)
        }
        else {
            ui_button_map_list.setTitle("home_button_map".localized.uppercased(), for: .normal)
        }
        changeFilterButton()
    }
    
    func changeFilterButton() {
        Logger.print("***** change filterbutton \(self.solidarityFilter.isDefaultFilters())")
        if self.solidarityFilter.isDefaultFilters() {
            ui_button_filters.setTitle("home_button_filters".localized.uppercased(), for: .normal)
        }
        else {
            ui_button_filters.setTitle("home_button_filters_on".localized.uppercased(), for: .normal)
        }
    }
    
    func zoomToCurrentLocation() {
        let currentLocation = LocationManger.sharedInstance.getCurrentLocation()
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
    
    @IBAction func action_filters(_ sender:Any) {
        AnalyticsLoggerManager.logEvent(name:Action_guide_showFilters)
        let navVC = storyboard?.instantiateViewController(withIdentifier: "SolidarityGuideFiltersNav") as! UINavigationController
        let vc = navVC.topViewController as! GuideFiltersViewController
        vc.filterDelegate = self
        
        self.navigationController?.present(navVC, animated: true)
    }
    
    @IBAction func showProposalPoi(_ sender:Any) {
        if let token = UserDefaults.currentUser?.token {
            let _BaseUrl = NetworkManager.sharedInstance.getBaseUrl()
            let url = String.init(format: PROPOSE_STRUCTURE_URL, _BaseUrl,token)

            if let _url = URL(string: url) {
                SafariWebManager.launchUrlInApp(url: _url, viewController: self.navigationController)
            }
        }
    }
    
    @IBAction func action_tap_info_web(_ sender:Any) {
        if let url = URL.init(string: GDS_INFO_ALERT_WEB_LINK) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    //MARK: - Navigate -
    
    func categoryById(sid:Int?) -> PoiCategory? {
        
        if sid == nil {
            return nil
        }
        
        for cat in self.categories {
            if let _sid = cat.sid, _sid == sid! {
                return cat
            }
        }
        return nil;
    }
    
    func showPoiDetails(_ poi: MapPoi!) {
        AnalyticsLoggerManager.logEvent(name: Action_guideMap_POI)
        if poi.partnerId != nil {
            let navVc = UIStoryboard.init(name: "PartnerDetails", bundle: nil).instantiateInitialViewController() as? UINavigationController
            
            if let vc = navVc?.topViewController as? PartnerDetailViewController {
                vc.partnerId = poi.partnerId ?? 0
                DispatchQueue.main.async {
                    self.present(navVc!, animated: true, completion: nil)
                }
            }
        }
        else {
            DispatchQueue.main.async {
                let navVc = UIStoryboard.init(name: "GuideSolidarity", bundle: nil).instantiateInitialViewController() as? UINavigationController
                
                if let _controller = navVc?.topViewController as? GuideDetailPoiViewController {
                    _controller.poi = poi
                    if self.solidarityFilter.isDefaultFilters() {
                        _controller.filtersSelectedFromMap = "ALL"
                    }
                    else {
                        _controller.filtersSelectedFromMap = self.solidarityFilter.getActiveFilters()
                    }
                    
                    self.present(navVc!, animated: true, completion: nil)
                }
            }
        }
    }
}

//MARK: -UitableviewDelegate / Datasource-
extension MainGuideViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.pois.count == 0 {
            self.ui_tableView.backgroundView = self.lblEmptyTableReason
        }
        else {
            self.ui_tableView.backgroundView = nil
        }
        return self.pois.count
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "guideCell", for: indexPath) as! SolidarityGuideCell
        let poi = self.pois[indexPath.section]
        cell.configure(poi: poi)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.pois.count == 0 {
            return
        }
        
        let poi = self.pois[indexPath.section]
        
        self.showPoiDetails(poi)
    }
}

//MARK: -MKMapViewDelegate-
extension MainGuideViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView:MKAnnotationView? = nil
        Logger.print("***** MapView viewFor annot : \(annotation)")
        if let _annot = annotation as? CustomAnnotation {
            if let _annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: _annot.annotationIdentifier) {
                annotationView = _annotationView
            }
            else {
                annotationView = _annot.getAnnotationView()
            }
            annotationView?.annotation = annotation
        }
        return annotationView;
    }
    
    func mapView(_ mapView: MKMapView,
                 didAdd views: [MKAnnotationView]) {
        Logger.print("***** MapView did add views ? \(views.count)")
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {

    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        Logger.print("***** MapView region did change ? \(mapView.annotations.count)")
        if !isFirstLaunch {
            getPoiList()
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        
        if let _ = view.annotation as? MKUserLocation {
            return
        }
       
        if let _annot = view.annotation as? CustomAnnotation, let _poi = _annot.poi {
            DispatchQueue.main.async {
                self.showPoiDetails(_poi)
            }
        }
    }
    
    //BaseMapDelegate
    func locationUpdated(notification:NSNotification) {
        if !self.mapWasCenteredOnUserLocation {
            let currentUser = UserDefaults.currentUser
            if currentUser?.hasActionZoneDefined() ?? false && currentUser?.addressPrimary?.location != nil {
                self.mapWasCenteredOnUserLocation = true
                zoomMapToLocation(location: currentUser?.addressPrimary?.location)
            }
            else {
                let arrayLocations = notification.userInfo?[kNotificationLocationUpdatedInfoKey] as? [Any]
                if let locations = arrayLocations, locations.count > 0 {
                    self.mapWasCenteredOnUserLocation = true
                    zoomToCurrentLocation()
                }
            }
        }
    }
}

//MARK: - OTGuideFilterDelegate -
extension MainGuideViewController : GuideFilterDelegate {
    func getSolidarityFilter() -> GuideFilters {
        return self.solidarityFilter
    }
    
    func solidarityFilterChanged(_ filter: GuideFilters!) {
        self.solidarityFilter = filter;
        Logger.print("***** save filters inside delegate -> \(filter.isDefaultFilters())")
        changeFilterButton()
        getPoiList()
    }
}
