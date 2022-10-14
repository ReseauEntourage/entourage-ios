//
//  OTLoginNextViewController.swift
//  entourage
//
//  Created by Jr on 15/07/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit
import IHProgressHUD
import GooglePlaces

class OTLoginNextViewController: UIViewController {

    @IBOutlet weak var ui_container: UIView!
     @IBOutlet weak var ui_bt_next: UIButton!
    
    @IBOutlet weak var ui_progress: OTProgressBarView!
    
    var temporaryGooglePlace:GMSPlace? = nil
    var temporaryLocation:CLLocation? = nil
    var temporaryAddressName:String? = nil
    
    var currentUser:User? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateProgress()
    }
    
    //MARK: - Methods
    
    func goMain() {
//        if currentUser?.goal == nil || currentUser?.goal?.count == 0 {
//            let message =  "login_info_pop_action".localized
//            let alertvc = UIAlertController.init(title:  "login_pop_information".localized, message: message, preferredStyle: .alert)
//            
//            let action = UIAlertAction.init(title: "login_info_pop_validate".localized, style: .default, handler: { (action) in
//                self.goalRealMain()
//            })
//            
//            alertvc.addAction(action)
//            
//            DispatchQueue.main.async {
//                self.present(alertvc, animated: true, completion: nil)
//            }
//           
//            return
//        }
        
        goalRealMain()
    }
    
    func goalRealMain() {
        AppState.continueFromLoginVC()
    }
    
    @IBAction func action_next(_ sender: Any) {
        sendAddAddress()
    }
    
    //MARK: - Network
    
    func sendAddAddress() {
//        OTLogger.logEvent(Action_Login_Action_Zone_Submit)
        if let _place = temporaryGooglePlace, let placeid = _place.placeID {
            IHProgressHUD.show()
            //MARK: faire
            UserService.updateUserAddressWith(placeId: placeid, isSecondaryAddress: false) { [weak self] error in
                IHProgressHUD.dismiss()
                self?.goMain()
            }
        }
        else if let _lat = self.temporaryLocation?.coordinate.latitude, let _long = self.temporaryLocation?.coordinate.longitude {
            IHProgressHUD.show()
            let addressName = temporaryAddressName == nil ? "default" : temporaryAddressName!
            //MARK: faire
            UserService.updateUserAddressWith(name: addressName, latitude: _lat, longitude: _long, isSecondaryAddress: false) { [weak self] error in
                IHProgressHUD.dismiss()
                self?.goMain()
            }
        }
    }
    
    //MARK: - Navigate
    func changeController() {
        ui_bt_next.isEnabled = false
        let _storyboard = UIStoryboard.init(name: StoryboardName.intro, bundle: nil)
        if  let vc = _storyboard.instantiateViewController(withIdentifier: "Login_place") as? OTLoginPlaceViewController {
            vc.delegate = self
            add(asChildViewController: vc)
        }
        updateProgress()
    }
    
    func updateProgress() {
        ui_progress.progressPercent = ui_progress.bounds.size.width
        ui_progress.setNeedsDisplay()
    }
    
    private func add(asChildViewController viewController: UIViewController) {
           if children.count > 0 {
               let oldChild = children[0]
               swapViewControllers(oldViewController: oldChild, toViewController: viewController)
               return;
           }
           
           if self.children.count > 0 {
               while children.count > 0 {
                   remove(asChildViewController: children[0])
               }
           }
           
           addChild(viewController)
           
           ui_container.addSubview(viewController.view)
           
           viewController.view.frame = ui_container.bounds
           viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
           
           viewController.didMove(toParent: self)
       }
       
       private func remove(asChildViewController viewController: UIViewController) {
           
           viewController.willMove(toParent: nil)
           
           viewController.view.removeFromSuperview()
           
           viewController.removeFromParent()
       }
       
       func swapViewControllers(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
           oldViewController.willMove(toParent: nil)
           newViewController.view.translatesAutoresizingMaskIntoConstraints = false
           
           self.addChild(newViewController)
           self.addSubViewController(subView: newViewController.view, toView:self.ui_container)
           
           newViewController.view.alpha = 0
           newViewController.view.layoutIfNeeded()
           
           UIView.animate(withDuration: 0.3, delay: 0.1, options: .showHideTransitionViews, animations: {
               newViewController.view.alpha = 1
               oldViewController.view.alpha = 0
           }) { (finished) in
               self.remove(asChildViewController: oldViewController)
           }
       }
       
       private func addSubViewController(subView:UIView, toView parentView:UIView) {
           self.view.layoutIfNeeded()
           parentView.addSubview(subView)
           
           subView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
           subView.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
           subView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
           subView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive  = true
       }
    
}

extension OTLoginNextViewController: LoginDelegate {
    func updateNewAddress(googlePlace:GMSPlace?,gpsLocation:CLLocation?,addressName:String?) {
        
        self.temporaryGooglePlace = googlePlace
        self.temporaryLocation = gpsLocation
        self.temporaryAddressName = addressName
        
        if googlePlace != nil || gpsLocation != nil {
            updateButtonNext(isValid: true)
        }
        else {
            updateButtonNext(isValid: false)
        }
    }
    
    func updateButtonNext(isValid: Bool) {
        ui_bt_next.isEnabled = isValid
    }
}

//MARK: - Protocol -
protocol LoginDelegate:AnyObject {
    func updateNewAddress(googlePlace:GMSPlace?,gpsLocation:CLLocation?,addressName:String?)
    func updateButtonNext(isValid: Bool)
}
