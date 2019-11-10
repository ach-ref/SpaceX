//
//  FilterTableViewCell.swift
//  SpaceX
//
//  Created by Achref Marzouki on 09/11/2019.
//  Copyright © 2019 Achref Marzouki. All rights reserved.
//

import UIKit

class FilterTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var switchButton: UISwitch!
    
    // MARK: - Private
    
    private var handler: ((UISwitch, Bool) -> Void)!
    
    // MARK: - Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initial settings
        configure()
    }
    
    // MARK: - UI
    
    private func configure() {
        // tile label
        titleLabel.numberOfLines = 2
        // switch
        switchButton.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
    }
    
    func setupContent(title: String, isOn: Bool, isEnabled: Bool, handler: @escaping (UISwitch, Bool) -> Void) {
        titleLabel.text = title
        switchButton.setOn(isOn, animated: false)
        switchButton.isEnabled = isEnabled
        self.handler = handler
    }
    
    func updateSwitch(isEnabled: Bool) {
        switchButton.isEnabled = isEnabled
    }
    
    func disableIfNeeded() {
        guard switchButton.isOn else { return }
        switchButton.setOn(false, animated: true)
        self.handler(switchButton, false)
    }
    
    // MARK: - Switch
    
    @objc
    private func valueChanged(_ sender: UISwitch) {
        self.handler(switchButton, true)
    }
}
