//
//  OTHomeTooltipView.swift
//  entourage
//
//  Created by Jr on 10/07/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit

class OTHomeTooltipView: UIView {

    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var ui_view_bubble_top: UIView!
    @IBOutlet weak var ui_view_bubble_top_inside: UIView!
    @IBOutlet weak var ui_view_bubble_bottom: UIView!
    @IBOutlet weak var ui_view_bubble_bottom_inside: UIView!
    
    @IBOutlet weak var ui_iv_arrow_guide: UIImageView!
    @IBOutlet weak var ui_iv_arrow_plus: UIImageView!
    
    @IBOutlet weak var ui_view_plus: UIView!
    @IBOutlet weak var ui_view_guide: UIView!
    
    @IBOutlet weak var ui_label_ignore: UILabel!
    @IBOutlet weak var ui_button_filter: UIButton!
    
    @IBOutlet weak var ui_label_top: UILabel!
    @IBOutlet weak var ui_bt_top: UIButton!
    @IBOutlet weak var ui_top_step: UILabel!
    
    @IBOutlet weak var ui_label_bottom_title: UILabel!
    @IBOutlet weak var ui_label_bottom_subtitle: UILabel!
    @IBOutlet weak var ui_bottom_step: UILabel!
    @IBOutlet weak var ui_bt_bottom: UIButton!
    
    var stepNb = 0
    
    override init(frame: CGRect) {
           super.init(frame: frame)
           setupInitial()
       }
       
       required init?(coder aDecoder: NSCoder) {
           super.init(coder: aDecoder)
           setupInitial()
       }
       
    func setupInitial() {
        contentView = loadViewFromNib()
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
        
        setupViews()
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "HomeToolTipsView", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func setupViews() {
        ui_view_bubble_bottom.isHidden = true
        ui_view_plus.isHidden = true
        ui_view_guide.isHidden = true
        ui_iv_arrow_plus.isHidden = true
        ui_iv_arrow_guide.isHidden = true
        ui_top_step.text = String.init(format: OTLocalisationService.getLocalizedValue(forKey: "tooltip_step_format"),"1")
        ui_label_top.text = OTLocalisationService.getLocalizedValue(forKey: "tooltip_desc1")
        
        ui_button_filter.setTitle(OTLocalisationService.getLocalizedValue(forKey: "home_button_filters_on")?.uppercased(), for: .normal)
        
        ui_bt_top.setTitle(OTLocalisationService.getLocalizedValue(forKey: "next"), for: .normal)
        ui_bt_bottom.setTitle(OTLocalisationService.getLocalizedValue(forKey: "next"), for: .normal)
        
        ui_bt_bottom.layer.cornerRadius = 8
        ui_bt_top.layer.cornerRadius = 8
        ui_button_filter.layer.cornerRadius = ui_button_filter.frame.height / 2
        ui_view_guide.layer.cornerRadius = ui_view_guide.frame.height / 2
        ui_view_plus.layer.cornerRadius = ui_view_plus.frame.height / 2
        
        ui_view_bubble_top_inside.layer.cornerRadius = 5
        ui_view_bubble_bottom_inside.layer.cornerRadius = 5
    }

    @IBAction func action_close(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideToolTip"), object: nil)
        if stepNb == 0 {
            OTLogger.logEvent(EVENT_ACTION_TOOLTIP_FILTER_CLOSE)
        }
        else if stepNb == 1 {
            OTLogger.logEvent(EVENT_ACTION_TOOLTIP_GUIDE_CLOSE)
        }
        else {
            OTLogger.logEvent(EVENT_ACTION_TOOLTIP_PLUS_CLOSE)
        }
    }
    
    @IBAction func action_next_top(_ sender: Any) {
        stepNb = 1
        ui_button_filter.isHidden = true
        ui_bottom_step.text = String.init(format: OTLocalisationService.getLocalizedValue(forKey: "tooltip_step_format"),"2")
        ui_view_bubble_top.isHidden = true
        ui_view_bubble_bottom.isHidden = false
        ui_view_guide.isHidden = false
        ui_iv_arrow_plus.isHidden = true
        ui_iv_arrow_guide.isHidden = false
        ui_label_bottom_title.text = OTLocalisationService.getLocalizedValue(forKey: "tooltip_title2")
        ui_label_bottom_subtitle.text = OTLocalisationService.getLocalizedValue(forKey: "tooltip_desc2")
        OTLogger.logEvent(EVENT_ACTION_TOOLTIP_FILTER_NEXT)
    }
    
    @IBAction func action_next_bottom(_ sender: Any) {
        if stepNb == 1 {
            stepNb = 2
            ui_bottom_step.text = String.init(format: OTLocalisationService.getLocalizedValue(forKey: "tooltip_step_format"),"3")
            ui_iv_arrow_plus.isHidden = false
            ui_iv_arrow_guide.isHidden = true
            ui_view_guide.isHidden = true
            ui_view_plus.isHidden = false
            ui_label_bottom_title.text = OTLocalisationService.getLocalizedValue(forKey: "tooltip_title3")
            ui_label_bottom_subtitle.text = OTLocalisationService.getLocalizedValue(forKey: "tooltip_desc3")
            OTLogger.logEvent(EVENT_ACTION_TOOLTIP_GUIDE_NEXT)
        }
        else {
            OTLogger.logEvent(EVENT_ACTION_TOOLTIP_PLUS_NEXT)
            action_close(sender)
        }
    }
}
