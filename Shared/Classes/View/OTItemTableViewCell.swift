//
//  OTItemTableViewCell.swift
//  entourage
//
//  Created by Veronica on 02/05/2018.
//  Copyright © 2018 Entourage. All rights reserved.
//

import Foundation

final class OTItemTableViewCell: UITableViewCell {
    let view = OTMenuCellView()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Private Functions
    private func setupUI() {
        addSubview(view)
        
        view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
