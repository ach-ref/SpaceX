//
//  LaunchDetailTableViewCell.swift
//  SpaceX
//
//  Created by Achref Marzouki on 10/11/2019.
//  Copyright © 2019 Achref Marzouki. All rights reserved.
//

import UIKit

class LaunchDetailTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet weak var missionImageView: UIImageView!
    @IBOutlet weak var successfulLaunchLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var siteLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: - Private
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    // MARK: - Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initial settings
        configure()
    }

    // MARK: - UI
    
    private func configure() {
        // image view
        missionImageView.layer.cornerRadius = 10
        missionImageView.clipsToBounds = false
        missionImageView.backgroundColor = .lightGray
        // info
        successfulLaunchLabel.text = "--"
        successfulLaunchLabel.font = .systemFont(ofSize: 17, weight: .medium)
        dateLabel.text = "--"
        siteLabel.text = "--"
        descriptionLabel.text = "--"
    }
    
    func setupcontent(launch: Launch) {
        // image
        setImage(fromUrl: launch.missionPatchUrl)
        // info
        let wasSuccessful = NSLocalizedString(launch.successful ? "detail.success" : "detail.fail", comment: "")
        successfulLaunchLabel.text = wasSuccessful
        successfulLaunchLabel.textColor = launch.successful ? .systemGreen : .systemRed
        dateLabel.text = launch.date == nil ? "<N/A>" : dateFormatter.string(from: launch.date!)
        siteLabel.text = String(format: NSLocalizedString("detail.site %@", comment: ""), launch.site)
        descriptionLabel.text = launch.details
    }
    
    private func setImage(fromUrl url: String?) {
        
        guard let imageUrl = url else {
            missionImageView.backgroundColor = .lightGray
            return
        }
        
        ImageCache.shared.displayImage(from: imageUrl) { image in
            self.missionImageView.image = image
            self.missionImageView.backgroundColor = .clear
        }
    }
}
