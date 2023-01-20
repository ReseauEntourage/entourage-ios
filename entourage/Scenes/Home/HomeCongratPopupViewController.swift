//
//  HomeCongratPopupViewController.swift
//  entourage
//
//  Created by Jerome on 20/06/2022.
//

import UIKit
import Lottie

class HomeCongratPopupViewController: UIViewController {

    
    @IBOutlet weak var ui_view_alert: UIView!
    
    @IBOutlet weak var ui_view_list: UIView!
    
    
    @IBOutlet weak var ui_title_1: UILabel!
    @IBOutlet weak var ui_anim_lottie: LottieAnimationView!
    
    @IBOutlet weak var ui_title_2: UILabel!
    
    @IBOutlet weak var ui_view_list_1: UIView!
    @IBOutlet weak var ui_iv_list_1: UIImageView!
    @IBOutlet weak var ui_title_list_1: UILabel!
    
    @IBOutlet weak var ui_view_list_2: UIView!
    @IBOutlet weak var ui_iv_list_2: UIImageView!
    @IBOutlet weak var ui_title_list_2: UILabel!
    
    @IBOutlet weak var ui_view_list_3: UIView!
    @IBOutlet weak var ui_iv_list_3: UIImageView!
    @IBOutlet weak var ui_title_list_3: UILabel!
    
    @IBOutlet weak var ui_view_end: UIView!
    @IBOutlet weak var ui_title_end: UILabel!
    
    weak var delegate:MJCongratControllerDelegate? = nil
    private var parentVC:UIViewController? = nil
    
    let cornerRadius:CGFloat = 20
    
    
    var actions:[HomeAction] = [HomeAction]()
    
    init() {
        super.init(nibName: "HomeCongratPopupViewController", bundle: Bundle(for: HomeCongratPopupViewController.self))
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let starAnimation = LottieAnimation.named("congrat_short_anim")
        ui_anim_lottie.animation = starAnimation
        ui_anim_lottie.loopMode = .playOnce
        
        ui_view_end.isHidden = true
        ui_view_end.alpha = 0
        ui_title_end.text = "home_congrat_title_next".localized
        
        ui_view_list.isHidden = true
        ui_view_list.alpha = 0
        
        ui_view_alert.layer.cornerRadius = cornerRadius
        
        ui_title_1.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrangeClair())
        ui_title_2.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrangeClair())
        
        ui_title_list_1.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_title_list_2.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_title_list_3.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        ui_iv_list_1.layer.cornerRadius = 4
        ui_iv_list_2.layer.cornerRadius = 4
        ui_iv_list_3.layer.cornerRadius = 4
    }
    
    func configureCongrat(actions:[HomeAction], parentVC:UIViewController?) {
        self.parentVC = parentVC
        self.actions = actions
    }
    
    func populateView() {
        guard let ui_title_1 = ui_title_1 else {return}
        let titleSinglePlural = actions.count == 1 ? "home_congrat_title_single".localized : "home_congrat_title_plural".localized
        let titleFormated = String.init(format: titleSinglePlural, actions.count)
        
        ui_title_1.text = titleFormated
        ui_title_2.text = titleFormated
        
        if 1 <= actions.count {
            ui_view_list_2.isHidden = true
            ui_view_list_3.isHidden = true
            ui_title_list_1.text = actions[0].name
            setimage(imgUrl:  actions[0].action_url, imageView: ui_iv_list_1)
        }
        if 2 <= actions.count {
            ui_view_list_2.isHidden = false
            ui_view_list_3.isHidden = true
            ui_title_list_1.text = actions[0].name
            setimage(imgUrl:  actions[0].action_url, imageView: ui_iv_list_1)
            ui_title_list_2.text = actions[1].name
            setimage(imgUrl:  actions[1].action_url, imageView: ui_iv_list_2)
        }
        if 3 <= actions.count {
            ui_view_list_2.isHidden = false
            ui_view_list_3.isHidden = false
            ui_title_list_1.text = actions[0].name
            setimage(imgUrl:  actions[0].action_url, imageView: ui_iv_list_1)
            ui_title_list_2.text = actions[1].name
            setimage(imgUrl:  actions[1].action_url, imageView: ui_iv_list_2)
            ui_title_list_3.text = actions[2].name
            setimage(imgUrl:  actions[2].action_url, imageView: ui_iv_list_3)
        }
        
        
        startAnimation()
    }
    
    private func setimage(imgUrl:String?,imageView:UIImageView) {
        if let imgUrl = imgUrl, let url = URL(string: imgUrl) {
            imageView.sd_setImage(with: url,placeholderImage:UIImage.init(named: "placeholder_action"))
        }
        else {
            imageView.image = UIImage.init(named: "placeholder_action")
        }
    }
    
    private func startAnimation() {
        ui_anim_lottie.play { finish in
            Logger.print("***** finish play")
            self.ui_view_list.isHidden = false
            
            UIView.animate(withDuration: 1.0) {
                self.ui_view_list.alpha = 1
            } completion: { isOk in
                Logger.print("***** after view")
               
                self.addTimerToClose(isEnd: false)
            }
        }
    }
    
    private func addTimerToClose(isEnd:Bool) {
        let selector:Selector = isEnd ? #selector(self.closePop) : #selector(self.showEnd)
        let timeInterval:TimeInterval = isEnd ? 2.5 : 4.0
        let timer = Timer(fireAt: Date().addingTimeInterval(timeInterval), interval: 0, target: self, selector: selector, userInfo: nil, repeats: false)
              
        RunLoop.current.add(timer, forMode: .common)
    }
    
    @objc private func showEnd() {
        ui_view_end.isHidden = false
        
        UIView.animate(withDuration: 1.0) {
            self.ui_view_end.alpha = 1
        } completion: { isOk in
            Logger.print("***** after view")
           
            self.addTimerToClose(isEnd: true)
        }
    }
    
    @objc private func closePop() {
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
    
    @IBAction func action_close_button(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.closePressed()
    }
}

//MARK: - MJAlertControllerDelegate -
protocol MJCongratControllerDelegate: AnyObject {
    func closePressed()
}
