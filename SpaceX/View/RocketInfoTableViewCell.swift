//
//  RocketInfoTableViewCell.swift
//  SpaceX
//
//  Created by Achref Marzouki on 10/11/2019.
//  Copyright © 2019 Achref Marzouki. All rights reserved.
//

import UIKit

class RocketInfoTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentLabel: UILabel!
    
    // MARK: - Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initial setup
        configure()
    }

    // MARK: - UI
    
    private func configure() {
        titleLabel.text = ""
        titleLabel.numberOfLines = 2
        contentLabel.text = ""
        contentLabel.numberOfLines = 0
    }
    
    func setupContent(title: String?, content: String?, textColor: UIColor, isLink: Bool, width: CGFloat = 100) {
        titleLabel.text = title
        contentLabel.text = content
        contentLabel.textColor = textColor
        titleLabelWidthConstraint.constant = width
        if isLink {
            contentLabel.textColor = .systemBlue
        }
    }
}
