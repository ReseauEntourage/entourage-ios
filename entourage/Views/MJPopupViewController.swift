//
//  MJPopupViewController.swift
//  entourage
//
//  Created by Jerome on 04/07/2022.
//

import UIKit

class MJPopupViewController: UIViewController {
    
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_subtitle: UILabel!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_view_alert: UIView!
    
    private var parentVC:UIViewController? = nil
    let cornerRadius:CGFloat = 20
    
    var titlePop:String? = nil
    var subtitlePop:String? = nil
    var imageNamedPop:String? = nil
    
    init() {
        super.init(nibName: "MJPopupViewController", bundle: Bundle(for: MJPopupViewController.self))
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_view_alert.layer.cornerRadius = cornerRadius
        
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange())
        ui_subtitle.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        ui_title.text = "Title"
        ui_subtitle.text = "Subtitle"
        ui_image.image = UIImage.init(named: "placeholder_entourage_generic-1")
    }
    
    func setupAlertInfos(parentVC:UIViewController?,title:String?,subtitile:String, imageName:String?) {
        self.parentVC = parentVC
        self.titlePop = title
        self.subtitlePop = subtitile
        self.imageNamedPop = imageName
        
    }
    
    private func populateView() {
        self.ui_title.text = titlePop
        self.ui_subtitle.text = subtitlePop
        
        if let imageName = imageNamedPop {
            self.ui_image.image = UIImage.init(named: imageName)
        }
    }
    
    @IBAction func action_close(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func show() {
        if let parentVC = parentVC {
            parentVC.present(self, animated: true, completion: nil)
            populateView()
            return
        }
        
        if #available(iOS 13, *) {
            UIApplication.shared.windows.first?.rootViewController?.present(self, animated: true, completion: nil)
        } else {
            UIApplication.shared.keyWindow?.rootViewController!.present(self, animated: true, completion: nil)
        }
        populateView()
    }
    
}
