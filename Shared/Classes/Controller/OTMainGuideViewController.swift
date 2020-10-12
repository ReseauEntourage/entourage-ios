//
//  OTMainGuideViewController.swift
//  entourage
//
//  Created by Jr on 14/09/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit
import SVProgressHUD

class OTMainGuideViewController: UIViewController {
    
    let MAX_DISTANCE_FOR_MAP_CENTER_MOVE_ANIMATED_METERS = 100.0
    let TABLEVIEW_BOTTOM_INSET:CGFloat = 86.0
    let MAPVIEW_HEIGHT:CGFloat = 224.0
    let FEEDS_TABLEVIEW_FOOTER_HEIGHT:CGFloat = 4.0
    
    @IBOutlet weak var ui_tableView: UITableView!
    @IBOutlet weak var noDataBehavior:OTNoDataBehavior!
    @IBOutlet weak var ui_button_filters: UIButton!
    @IBOutlet weak var ui_button_map_list: UIButton!
    @IBOutlet weak var ui_view_top_info_gds: UIView!
    @IBOutlet weak var ui_label_info_web_gds: UILabel!
    @IBOutlet weak var ui_constraint_height_view_topinfo: NSLayoutConstraint!
    
    //Use to show / hide pop info on top of view
    var hasToShowTopInformationGDS = false
    
    var mapView:OTMapView!
    var clusteringController:KPClusteringController!
    var solidarityFilter:OTGuideFilters!
    var emptyFooterView:UIView!
    var lblEmptyTableReason:UILabel!
    var tapGestureRecognizer:UITapGestureRecognizer!
    var categories = [OTPoiCategory]()
    var pois = [OTPoi]()
    var markers = [OTCustomAnnotation]()
    var mapWasCenteredOnUserLocation = false
    var noDataDisplayed = false
    var isShowMap = false
    
    //MARK: - LifeCycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        setupButtons()
        fillCategories()
        getPoiList()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showCurrentLocation), name: NSNotification.Name(rawValue:  kNotificationShowFeedsMapCurrentLocation), object: nil)
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
        
        if self.hasToShowTopInformationGDS {
            let txt_underline = Utilitaires.formatStringUnderline(stringMessage: OTLocalisationService.getLocalizedValue(forKey: "Pop_info_web_alert_GDS"), underlineTxt: OTLocalisationService.getLocalizedValue(forKey: "Pop_info_web_alert_GDS_underline"), color: .white, colorHighlight: .white, fontSize: 14,fontWeight: .regular)
            
            self.ui_label_info_web_gds.attributedText = txt_underline
            self.ui_view_top_info_gds.isHidden = false
        }
        else {
            self.ui_constraint_height_view_topinfo.constant = 0
            self.ui_view_top_info_gds.isHidden = true
        }
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
    
    func fillCategories() {
        self.categories = [OTPoiCategory]()
        for i in 0...8 {
            let cat = OTPoiCategory()
            cat.sid = NSNumber(integerLiteral: i)
            cat.updateInfos()
            self.categories.append(cat)
        }
        for i in 40...43 {
            let cat = OTPoiCategory()
            cat.sid = NSNumber(integerLiteral: i)
            cat.updateInfos()
            self.categories.append(cat)
        }
        for i in 60...61 {
            let cat = OTPoiCategory()
            cat.sid = NSNumber(integerLiteral: i)
            cat.updateInfos()
            self.categories.append(cat)
        }
    }
    
    //MARK: - Notification Methods -
    
    @objc func showCurrentLocation() {
        Logger.print("***** showCurrent location ***")
        
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
    
    //MARK: - Setups -
    func setup() {
        
        self.lblEmptyTableReason = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
        self.lblEmptyTableReason.font = UIFont(name: "SFUItext-Semibold", size: 16)
        self.lblEmptyTableReason.textAlignment = .center
        self.lblEmptyTableReason.numberOfLines = 0
        self.lblEmptyTableReason.text = OTAppAppearance.extendMapSearchParameterDescription()
        
        self.solidarityFilter = OTGuideFilters()
        self.mapView = OTMapView()
        self.mapView.delegate = self
        
        self.ui_tableView?.delegate = self
        self.ui_tableView?.dataSource = self
        self.ui_tableView?.estimatedRowHeight = 140
        configureTableviewWithMap()
        
        self.noDataBehavior.initialize()
        self.noDataBehavior.switchedToGuide()
        
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
        
        self.clusteringController = KPClusteringController(mapView: self.mapView)
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
    
    //MARK: - Network -
    func getPoiList() {
        self.noDataBehavior.hideNoData()
        SVProgressHUD.show()
        
        guard let _dict = self.solidarityFilter.toDictionary(distance: getMapHeight(), location: mapView.centerCoordinate) else {
            Logger.print("***** Error get filter to dict ****")
            return
        }
        var newDict = _dict
        newDict["v"] = "2"
        OTPoiService().pois(withParameters: (newDict), success: { (_, pois) in
            
            if let _pois = pois as? [OTPoi] {
                self.pois = _pois
            }
            
            self.ui_tableView?.reloadData()
            self.feedMap()
            
            if self.pois.count == 0 {
                if !self.noDataDisplayed {
                    self.noDataBehavior.showNoData()
                    self.noDataDisplayed = true
                }
            }
            
            SVProgressHUD.dismiss()
        }) { (error) in
            if self.pois.count == 0 {
                self.noDataBehavior.showNoData()
            }
            SVProgressHUD.dismiss()
        }
    }
    
    //MARK: - Methods -
    
    func feedMap() {
        self.markers.removeAll()
        
        for poi in pois {
            if let annot = OTCustomAnnotation(poi: poi) {
                self.markers.append(annot)
            }
        }
        
        self.clusteringController.setAnnotations(self.markers)
        self.clusteringController.refresh(true, force: true)
    }
    
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
        Logger.print("***** change filterbutton \(self.solidarityFilter.isDefaultFilters())")
        if self.solidarityFilter.isDefaultFilters() {
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
    
    @IBAction func action_filters(_ sender:Any) {
        OTLogger.logEvent(Action_guide_showFilters)
        OTAppState.showFilteringOptions(from: self, withFullMapVisible: true)
    }
    
    @IBAction func showProposalPoi(_ sender:Any) {
        
        if let _BaseUrl = OTHTTPRequestManager.sharedInstance()?.baseURL?.absoluteString, let token = UserDefaults.standard.currentUser.token {
            
            let url = String.init(format: PROPOSE_STRUCTURE_URL, _BaseUrl,token)
            
            OTSafariService.launchInAppBrowser(withUrlString: url, viewController: self.navigationController)
        }
    }
    
    @IBAction func action_tap_info_web(_ sender:Any) {
        if let url = URL.init(string: GDS_INFO_ALERT_WEB_LINK) {
            UIApplication.shared.openURL(url)
        }
    }
    
    //MARK: - Navigate -
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SolidarityGuideFiltersSegue" {
            if let navController = segue.destination as? UINavigationController {
                if let _controller = navController.topViewController as? OTGuideFiltersViewController {
                    _controller.filterDelegate = self
                }
            }
        }
    }
    
    func categoryById(sid:NSNumber?) -> OTPoiCategory? {
        
        if sid == nil {
            return nil
        }
        
        for cat in self.categories {
            if let _sid = cat.sid, _sid.isEqual(to: sid!) {
                return cat
            }
        }
        return nil;
    }
    
    func showPoiDetails(_ poi: OTPoi!) {
        OTLogger.logEvent(Action_guideMap_POI)
        if poi.partnerId != nil {
            let navVc = UIStoryboard.init(name: "AssociationDetails", bundle: nil).instantiateInitialViewController() as? UINavigationController
            if let vc = navVc?.topViewController as? OTAssociationDetailViewController {
                vc.associationId = poi.partnerId.intValue
                vc.changeColor = true
                DispatchQueue.main.async {
                    self.present(navVc!, animated: true, completion: nil)
                }
            }
        }
        else {
            DispatchQueue.main.async {
                let navVc = UIStoryboard.init(name: "GuideSolidarity", bundle: nil).instantiateInitialViewController() as? UINavigationController
                
                if let _controller = navVc?.topViewController as? OTGuideDetailPoiViewController {
                    _controller.poi = poi
                    self.present(navVc!, animated: true, completion: nil)
                }
            }
        }
    }
    
    func displayPoiDetailsFromAnnotationView(_ view:MKAnnotationView) {
        if let kpAnnot = view.annotation as? KPAnnotation {
            var annot:OTCustomAnnotation? = nil
            for (_,v) in kpAnnot.annotations.enumerated() {
                if let _annot = v as? OTCustomAnnotation {
                    annot = _annot
                    break
                }
            }
            guard let _poi = annot?.poi else {
                return
            }
            
            self.showPoiDetails(_poi)
        }
    }
}

//MARK: -UitableviewDelegate / Datasource-
extension OTMainGuideViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "OTSolidarityGuideTableViewCellIdentifier", for: indexPath) as! OTSolidarityGuideCell
        let poi = self.pois[indexPath.section]
        cell.configure(with: poi)
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
extension OTMainGuideViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView:MKAnnotationView? = nil
        let currentZoomScale = mapView.bounds.size.width / CGFloat(mapView.visibleMapRect.size.width)
        
        if let _annot = annotation as? KPAnnotation {
            if currentZoomScale < 0.244113 && _annot.isCluster() && _annot.annotations.count > 3 {
                if let _annotView = mapView.dequeueReusableAnnotationView(withIdentifier: "cluster") as? MKPinAnnotationView {
                    annotationView = _annotView
                }
                else {
                    _annot.title = String.init(format: "%d", _annot.annotations.count)
                    annotationView = MKPinAnnotationView(annotation: _annot, reuseIdentifier: "cluster")
                    annotationView?.image = UIImage.init(named: "poi_cluster")
                }
            }
            else {
                if let _customAnnot = _annot.annotations.first as? OTCustomAnnotation {
                    if let _annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: _customAnnot.annotationIdentifier()) {
                        annotationView = _annotationView
                    }
                    else {
                        annotationView = _customAnnot.annotationView()
                    }
                    annotationView?.annotation = annotation
                }
            }
        }
        return annotationView;
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        
        for view in views {
            let annot = view.annotation
            
            if let _annot = annot as? KPAnnotation {
                if _annot.isCluster() && _annot.annotations.count > 3 {
                    if view.subviews.count != 0 {
                        let subView = view.subviews[0]
                        subView.removeFromSuperview()
                    }
                    let viewRect = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
                    let _count = UILabel(frame: viewRect)
                    _count.text = "\(_annot.annotations.count)"
                    _count.textColor = UIColor.white
                    _count.textAlignment = .center
                    view.addSubview(_count)
                }
            }
        }
        mapView.setNeedsDisplay()
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        self.noDataBehavior.hideNoData()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        getPoiList()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        mapView.deselectAnnotation(view.annotation, animated: false)
        
        let currentZoomScale:MKZoomScale = mapView.bounds.size.width / CGFloat(mapView.visibleMapRect.size.width)
        if let _ = view.annotation as? MKUserLocation {
            return
        }
        
        if let _annot = view.annotation as? KPAnnotation {
            Logger.print("***** ZOom ici *****")
            if !_annot.isCluster() {
                DispatchQueue.main.async {
                    self.displayPoiDetailsFromAnnotationView(view)
                }
            }
            else {
                if currentZoomScale > 0.06 {
                    DispatchQueue.main.async {
                        self.displayPoiDetailsFromAnnotationView(view)
                    }
                }
                else {
                    Logger.print("***** go to zoom map annot \(view)")
                    self.mapView.zoomToLocation(location: _annot.coordinate)
                }
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
}

//MARK: - OTGuideFilterDelegate -
extension OTMainGuideViewController : OTGuideFilterDelegate {
    func getSolidarityFilter() -> OTGuideFilters {
        return self.solidarityFilter
    }
    
    func solidarityFilterChanged(_ filter: OTGuideFilters!) {
        self.solidarityFilter = filter;
        Logger.print("***** save filters inside delegate -> \(filter.isDefaultFilters())")
        changeFilterButton()
        getPoiList()
    }
}

//MARK: - MKMap Extension -
extension MKMapView {
    func zoomToLocation(location : CLLocationCoordinate2D,latitudinalMeters:CLLocationDistance = 500,longitudinalMeters:CLLocationDistance = 500) {
        let region = MKCoordinateRegion(center: location, latitudinalMeters: latitudinalMeters, longitudinalMeters: longitudinalMeters)
        setRegion(region, animated: true)
    }
}
