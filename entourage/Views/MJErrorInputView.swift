//
//  MJErrorInputView.swift
//  entourage
//
//  Created by Jerome on 22/03/2022.
//

import UIKit

@IBDesignable
class MJErrorInputView: UIView {
    
    @IBOutlet var tap_gesture_view_content: UITapGestureRecognizer!
    @IBOutlet weak var constraint_tralling: NSLayoutConstraint!
    @IBOutlet weak var constraint_leading: NSLayoutConstraint!
    @IBOutlet var ui_content_view: UIView!
    @IBOutlet weak var ui_view_bubble: UIView!
    
    @IBOutlet weak var ui_title: UILabel!
    
    @IBOutlet weak var ui_image: UIImageView!
    
    private var timerFadeOutTrigger:Double = 3.0 //Seconds
    private var fadeInTime = TimeInterval(0.2) //In second
    private var fadeOutTime = TimeInterval(0.2) //In second
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialInit()
    }
    
    private func initialInit() {
        Bundle.main.loadNibNamed("MJErrorInputView", owner: self)
        addSubview(ui_content_view)
        ui_content_view.frame = self.bounds
        ui_view_bubble.layer.cornerRadius = ui_view_bubble.frame.height / 2
    }
    
    func populateView(title:String? = nil,imageName:String? = nil,margin:CGFloat? = 26, radius:CGFloat? = 13, erroViewcolor:UIColor? = nil, backgroundColor:UIColor? = nil) {
        changeTitleAndImage(title: title, imageName: imageName)
        
        if let margin = margin {
            constraint_leading.constant = margin
            constraint_tralling.constant = margin
        }
        
        if let radius = radius {
            ui_view_bubble.layer.cornerRadius = radius
        }
        
        if let erroViewcolor = erroViewcolor {
            ui_view_bubble.backgroundColor = erroViewcolor
        }
        
        if let backgroundColor = backgroundColor {
            ui_content_view.backgroundColor = backgroundColor
        }
    }
    
    func changeTitleAndImage(title:String? = nil,imageName:String? = nil) {
        ui_title.text = title
        
        if let imageName = imageName {
            ui_image.image = UIImage.init(named: imageName)
        }
    }
    
    func show(timerFadeOutTrigger:Double? = nil, fadeInTime:TimeInterval? = nil, fadeOutTime:TimeInterval? = nil, autoHide:Bool = true) {
        tap_gesture_view_content.isEnabled = !autoHide
        self.timerFadeOutTrigger = timerFadeOutTrigger ?? self.timerFadeOutTrigger
        self.fadeInTime = fadeInTime ?? self.fadeInTime
        self.fadeOutTime = fadeOutTime ?? self.fadeOutTime
        
        
        UIView.animate(withDuration: TimeInterval(self.fadeInTime), delay: 0, options: .curveEaseIn) {
            self.ui_content_view.isHidden = false
            self.ui_content_view.alpha = 1
        } completion: { ok in
            Logger.print("Fini")
            if autoHide {
                DispatchQueue.main.asyncAfter(deadline: .now() + self.timerFadeOutTrigger) {
                    self.hide()
                }
            }
        }
    }
    
    func hide() {
        if ui_content_view.alpha == 0 { return }
        UIView.animate(withDuration: TimeInterval(fadeOutTime), delay: 0, options: .curveEaseOut) {
            self.ui_content_view.alpha = 0
        } completion: { ok in
            Logger.print("Fini")
            self.ui_content_view.isHidden = true
        }
    }
    
    @IBAction func action_tap(_ sender: Any) {
        hide()
    }
}
