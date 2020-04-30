//
//  PfpStartupViewController.swift
//  entourage
//
//  Created by Smart Care on 11/09/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

import UIKit

class PfpStartupViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var footer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = ""
        self.navigationController?.presentTransparentNavigationBar()
        
        self.loginButton.setTitleColor(ApplicationTheme.shared().backgroundThemeColor, for: UIControlState.normal)
        self.loginButton.layer.borderColor = ApplicationTheme.shared().backgroundThemeColor.cgColor
        self.loginButton.layer.borderWidth = 1.5
        
        self.signupButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        self.signupButton.backgroundColor = ApplicationTheme.shared().backgroundThemeColor
        self.signupButton.layer.borderColor = ApplicationTheme.shared().backgroundThemeColor.cgColor
        self.signupButton.layer.borderWidth = 1.5
        
        self.setupScrollView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.hideTransparentNavigationBar()
        
        UserDefaults.standard.temporaryUser = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        OTAppConfiguration.configureNavigationControllerAppearance(self.navigationController)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.presentTransparentNavigationBar()
    }
    
    @IBAction func showLogin() {
        OTAppState.continue(fromStartupScreen: self, creatingUser: false)
    }
    
    @IBAction func signupLogin() {
        OTAppState.continue(fromStartupScreen: self, creatingUser: true)
    }
    
    func setupScrollView () {
        self.pageControl.backgroundColor = UIColor.clear
        self.pageControl.currentPageIndicatorTintColor = UIColor.white
        
        let topOffset:CGFloat = 230
        let height: CGFloat = UIScreen.main.bounds.size.height - topOffset
        let width: CGFloat = UIScreen.main.bounds.size.width
        self.scrollView.contentSize = CGSize.init(width: 3*width, height: height)
        
        let imageView1: UIImageView = UIImageView.init(image: UIImage.init(named: "startup1"))
        imageView1.contentMode = UIViewContentMode.top
        imageView1.frame = CGRect.init(x: 0, y: topOffset, width: width, height: height)
        
        let imageView2: UIImageView = UIImageView.init(image: UIImage.init(named: "startup2"))
        imageView2.contentMode = UIViewContentMode.top
        imageView2.frame = CGRect.init(x: width, y: topOffset, width: width, height: height)
        
        let imageView3: UIImageView = UIImageView.init(image: UIImage.init(named: "startup3"))
        imageView3.contentMode = UIViewContentMode.top
        imageView3.frame = CGRect.init(x: 2*width, y: topOffset, width: width, height: height)
        
        self.scrollView.addSubview(imageView1)
        self.scrollView.addSubview(imageView2)
        self.scrollView.addSubview(imageView3)
        
        self.footer.layer.shadowColor = UIColor.black.cgColor
        self.footer.layer.shadowOpacity = 0.5
        self.footer.layer.shadowRadius = 4.0
        self.footer.layer.shadowOffset = CGSize.init(width: 0.0, height: 1.0)
    }
    
    func updateTitlesForIndex(_ index: Int) {
        switch index {
        case 0:
            self.titleLabel.text = "Je tisse des liens"
            self.subtitleLabel.text = "d’amitié avec des personnes senior de mon voisinage"
            break
        case 1:
            self.titleLabel.text = "Je rencontre"
            self.subtitleLabel.text = "les membres de Voisin-Age de mon quartier dans des groupes conviviaux"
            break
        case 2:
            self.titleLabel.text = "Je me coordonne"
            self.subtitleLabel.text = "pour veiller sur mes voisins âgés et enrichir leur quotidien : visites, sorties"
            break
        default:
            break
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index:Int = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        self.pageControl.currentPage = index
        self.updateTitlesForIndex(index)
    }
}
