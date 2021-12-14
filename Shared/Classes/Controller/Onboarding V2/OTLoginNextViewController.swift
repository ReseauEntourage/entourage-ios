//
//  OTLoginNextViewController.swift
//  entourage
//
//  Created by Jr on 15/07/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit
import SVProgressHUD

class OTLoginNextViewController: UIViewController {

    @IBOutlet weak var ui_container: UIView!
     @IBOutlet weak var ui_bt_next: UIButton!
    
    @IBOutlet weak var ui_progress: OTProgressBarView!
    
    var temporaryGooglePlace:GMSPlace? = nil
    var temporaryLocation:CLLocation? = nil
    var temporaryAddressName:String? = nil
    var currentPosition = 0
    
    @objc var fromLink:URL? = nil
    
    var currentUser:OTUser? = nil
    
    var nbOfSteps = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = currentUser {
            if user.addressPrimary != nil || user.addressPrimary?.displayAddress.count ?? 0 > 0 {
                currentPosition = 1
            }
        }
        
        changeController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateProgress()
    }
    
    //MARK: - Methods
    
    func goNext() {
        goMain()
    }
    
    func goMain() {
        if currentUser?.goal == nil || currentUser?.goal?.count == 0 {
            let message = OTLocalisationService.getLocalizedValue(forKey: "login_info_pop_action")
            let alertvc = UIAlertController.init(title: OTLocalisationService.getLocalizedValue(forKey: "login_pop_information"), message: message, preferredStyle: .alert)
            
            let action = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey:"login_info_pop_validate"), style: .default, handler: { (action) in
                self.goalRealMain()
            })
            
            alertvc.addAction(action)
            
            self.present(alertvc, animated: true, completion: nil)
            return
        }
        
        goalRealMain()
    }
    
    func goalRealMain() {
        OTAppState.continueFromLoginVC()
        
        if (self.fromLink != nil) {
            OTDeepLinkService.init().handleDeepLink(self.fromLink)
            self.fromLink = nil;
        }
    }
    
    @IBAction func action_next(_ sender: Any) {
        sendAddAddress()
    }
    
    //MARK: - Network
    
    func sendAddAddress() {
        OTLogger.logEvent(Action_Login_Action_Zone_Submit)
        if let _place = temporaryGooglePlace {
            SVProgressHUD.show()
            OTAuthService.updateUserAddress(withPlaceId: _place.placeID, isSecondaryAddress: false) { (error) in
                SVProgressHUD.dismiss()
                self.goNext()
            }
        }
        else if let _lat = self.temporaryLocation?.coordinate.latitude, let _long = self.temporaryLocation?.coordinate.longitude {
            SVProgressHUD.show()
            let addressName = temporaryAddressName == nil ? "default" : temporaryAddressName!
            OTAuthService.updateUserAddress(withName: addressName, andLatitude: NSNumber.init(value: _lat), andLongitude: NSNumber.init(value: _long), isSecondaryAddress: false) { (error) in
                SVProgressHUD.dismiss()
                self.goNext()
            }
        }
    }
    
    //MARK: - Navigate
    func changeController() {
        ui_bt_next.isEnabled = false
        let _storyboard = UIStoryboard.init(name: "Intro", bundle: nil)
        if  let vc = _storyboard.instantiateViewController(withIdentifier: "Login_place") as? OTLoginPlaceViewController {
            vc.delegate = self
            add(asChildViewController: vc)
        }
        updateProgress()
    }
    
    func updateProgress() {
        let percent = (ui_progress.bounds.size.width / CGFloat(nbOfSteps)) * CGFloat(currentPosition + 1)
        ui_progress.progressPercent = percent
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
protocol LoginDelegate:class {
    func updateNewAddress(googlePlace:GMSPlace?,gpsLocation:CLLocation?,addressName:String?)
    func updateButtonNext(isValid: Bool)
}
