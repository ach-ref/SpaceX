//
//  LaunchTableViewCell.swift
//  SpaceX
//
//  Created by Achref Marzouki on 09/11/2019.
//  Copyright © 2019 Achref Marzouki. All rights reserved.
//

import UIKit

class LaunchTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet weak var patchImageView: UIImageView!
    @IBOutlet weak var missionNameLabel: UILabel!
    @IBOutlet weak var siteNameLabel: UILabel!
    @IBOutlet weak var missionDateLabel: UILabel!
    
    // MARK: - Private
    
    private let imageDefaultBackgroundColor = UIColor(displayP3Red: 235/255, green: 235/255, blue: 235/255, alpha: 0.8)
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    private lazy var loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .white)
        indicator.center = patchImageView.center
        addSubview(indicator)
        return indicator
    }()
    
    // MARK: - Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initial setup
        configure()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetContent()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        loader.center = patchImageView.center
    }
    
    // MARK: - UI
    
    private func configure() {
        missionNameLabel.numberOfLines = 1
        siteNameLabel.numberOfLines = 2
        missionDateLabel.numberOfLines = 1
        patchImageView.layer.cornerRadius = 10
        patchImageView.layer.masksToBounds = true
        resetContent()
    }
    
    private func resetContent() {
        missionNameLabel.text = ""
        siteNameLabel.text = ""
        missionDateLabel.text = ""
        patchImageView.image = nil
        patchImageView.backgroundColor = imageDefaultBackgroundColor
    }
    
    func setupContent(launch: Launch) {
        missionNameLabel.text = launch.missionName
        siteNameLabel.text = launch.site
        missionDateLabel.text = ""
        if let aDate = launch.date {
            missionDateLabel.text = dateFormatter.string(from: aDate)
        }
    }
    
    func imageIsLoading() {
        loader.startAnimating()
    }
    
    func setImage(_ image: UIImage?) {
        patchImageView.image = image
        patchImageView.backgroundColor = image == nil ? imageDefaultBackgroundColor : .clear
        loader.stopAnimating()
    }
    
    // MARK: - Selection
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if patchImageView.image == nil {
            patchImageView.backgroundColor = imageDefaultBackgroundColor
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if patchImageView.image == nil {
            patchImageView.backgroundColor = imageDefaultBackgroundColor
        }
    }
}
