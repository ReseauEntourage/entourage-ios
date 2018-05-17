//
//  OTLogoutViewCell.swift
//  pfp
//
//  Created by Veronica on 02/05/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

import Foundation

final class OTLogoutViewCell: UITableViewCell {
    let logoutButton = UIButton()
    
    // MARK: - Init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Private Functions
    @objc private func signout() {
        NotificationCenter.default.post(name: Notification.Name("loginFailureNotification"), object: self)
    }
    
    private func setupUI() {
        addSubview(logoutButton)
        
        backgroundColor = UIColor.pfpTableBackground()
        logoutButton.apply(style: .whiteRounded)
        logoutButton.layer.cornerRadius = 24.5
        logoutButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        
        logoutButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(3)
            $0.height.equalTo(40)
            $0.width.equalTo(200)
            $0.bottom.equalToSuperview().inset(3)
        }
        
        logoutButton.addTarget(self, action: #selector(signout), for: .touchUpInside)
    }
}
