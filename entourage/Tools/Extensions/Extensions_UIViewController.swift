//
//  Extensions_UIViewController.swift
//  entourage
//
//  Created by Jerome on 21/01/2022.
//

import Foundation


extension UINavigationController {
    func presentTransparentNavigationBar() {
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.isTranslucent = true
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.backgroundColor = .clear
        self.setNavigationBarHidden(false, animated: true)
    }
    
    func hideTransparentNavigationBar() {
        self.navigationBar.setBackgroundImage(UINavigationBar.appearance().backgroundImage(for: .default), for: .default)
        self.navigationBar.isTranslucent = UINavigationBar.appearance().isTranslucent
        self.navigationBar.shadowImage = UINavigationBar.appearance().shadowImage
        self.setNavigationBarHidden(true, animated: true)
    }
}

//MARK: uiviewController
extension UIViewController {
    func addCloseButtonLeftWithWhiteColorBar(closeImageName:String = "close_new_orange") {
        setupNavigationBarColor()
        var img:UIImage?
        if #available(iOS 13.0, *) {
            img = (UIImage.init(named: closeImageName)?.withTintColor(UIColor.appOrange, renderingMode: .alwaysTemplate))
        } else {
            img = UIImage.init(named: closeImageName)
            img = img?.withRenderingMode(.alwaysTemplate)
        }
        
        let closeButton = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(ClosePopDelegate.close))
        self.navigationItem.setLeftBarButton(closeButton, animated: false)
        closeButton.tintColor = UIColor.appOrange
    }
    
    func setupNavigationBarColor() {
        let mainColor = UIColor.white
        let secondaryColor = UIColor.appOrange
        
        UINavigationBar.appearance().backgroundColor = mainColor
        UINavigationBar.appearance().barTintColor = mainColor
        UINavigationBar.appearance().tintColor = secondaryColor
        
        let navBar = navigationController?.navigationBar
        
        if #available(iOS 13.0, *) {
            let navBarAppear = UINavigationBarAppearance()
            navBarAppear.configureWithOpaqueBackground()
            navBarAppear.backgroundColor = mainColor
            let txtAttributes = [NSAttributedString.Key.foregroundColor: UIColor.appGreyishBrown]
            navBarAppear.titleTextAttributes = txtAttributes
            navBarAppear.largeTitleTextAttributes = txtAttributes
            navBar?.standardAppearance = navBarAppear
            navBar?.scrollEdgeAppearance = navBarAppear
        } else {
            navBar?.backgroundColor = mainColor
            navBar?.tintColor = secondaryColor
            navBar?.barTintColor = mainColor
        }
    }
}


extension UIPageViewController {
    var isPagingEnabled: Bool {
        get {
            return scrollView?.isScrollEnabled ?? false
        }
        set {
            scrollView?.isScrollEnabled = newValue
        }
    }

    var scrollView: UIScrollView? {
        return view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView
    }
}
