//
//  FilterViewController.swift
//  SpaceX
//
//  Created by Achref Marzouki on 09/11/2019.
//  Copyright © 2019 Achref Marzouki. All rights reserved.
//

import UIKit

protocol FilterControllerDelegate: class {
    func filterControllerDidFinish(withOptions options: FilterOptions)
}

struct FilterOptions: OptionSet {
    let rawValue: Int
    
    static let showSuccessfulOnly           = FilterOptions(rawValue: 1 << 0)
    static let launchDateSortAscending      = FilterOptions(rawValue: 1 << 1)
    static let launchDateSortDescending     = FilterOptions(rawValue: 1 << 2)
    static let missionNameSortAscending     = FilterOptions(rawValue: 1 << 3)
    static let missionNameSortDescending    = FilterOptions(rawValue: 1 << 4)
}

class FilterViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var resetButton: UIButton!
    
    // MARK: - Properties
    
    var closeButtonCenter: CGPoint!
    var viewBackgroundColor: UIColor!
    
    var filterOptions: FilterOptions!
    
    weak var delegate: FilterControllerDelegate?
    
    // MARK: - Private
    
    private let filterCell = "FilterCell"
    
    private var titles: [[String]] = []
    private var headers: [String] = []
    private var flags: [[Bool]] = []
    
    private weak var closeButton: UIButton!
    
    // MARK: - Status bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // initial setup
        prepareData()
        configureView()
    }
    
    // MARK: - Data
    
    private func prepareData() {
        // first section titles
        titles.append([])
        titles[0].append(NSLocalizedString("filter.launchSuccess", comment: ""))
        // second section titles
        titles.append([])
        titles[1].append(NSLocalizedString("filter.sort", comment: ""))
        titles[1].append(NSLocalizedString("filter.ascending", comment: ""))
        // third section titles
        titles.append([])
        titles[2].append(NSLocalizedString("filter.sort", comment: ""))
        titles[2].append(NSLocalizedString("filter.ascending", comment: ""))
        // headers
        headers.append(NSLocalizedString("filter.filter", comment: ""))
        headers.append(NSLocalizedString("filter.launchDateSort", comment: ""))
        headers.append(NSLocalizedString("filter.missionNameSort", comment: ""))
        // flags
        flags = flagsFromFilterOptions()
    }
    
    // MARK: - UI
    
    private func configureView() {
        // bakcground color
        view.backgroundColor = viewBackgroundColor
        // close button
        let aButton = UIButton(type: .system)
        aButton.setImage(UIImage(named: "cross"), for: .normal)
        aButton.tintColor = viewBackgroundColor
        aButton.backgroundColor = .white
        aButton.frame.size = CGSize(width: 40, height: 40)
        aButton.layer.cornerRadius = 20
        aButton.layer.shadowColor = UIColor.black.cgColor
        aButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        aButton.layer.shadowRadius = 3
        aButton.layer.shadowOpacity = 0.4
        aButton.clipsToBounds = false
        aButton.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(aButton)
        closeButton = aButton
        closeButton.center = closeButtonCenter
        // title
        titleLabel.text = NSLocalizedString("filter.title", comment: "")
        titleLabel.textColor = .darkGray
        titleLabel.font = .boldSystemFont(ofSize: 30)
        view.addConstraints([
            titleLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 50)
        ])
        // table view
        let aNib = UINib(nibName: "FilterTableViewCell", bundle: Bundle(for: type(of: self)))
        tableview.register(aNib, forCellReuseIdentifier: filterCell)
        tableview.dataSource = self
        tableview.backgroundColor = viewBackgroundColor
        tableview.allowsSelection = false
        // reset button
        resetButton.setTitle(NSLocalizedString("filter.reset", comment: ""), for: .normal)
        resetButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        resetButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        resetButton.addTarget(self, action: #selector(resetButtonTapped(_:)), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc
    private func closeButtonTapped(_ sender: UIButton) {
        delegate?.filterControllerDidFinish(withOptions: filterOptionsFromFlags())
        dismiss(animated: true, completion: nil)
    }
    
    private func switchTapped(_ sender: UISwitch, atIndexPath indexPath: IndexPath, cascadeEvent: Bool) {
        // update flags
        flags[indexPath.section][indexPath.row] = sender.isOn
        
        if indexPath.row == 0, indexPath.section == 1 || indexPath.section == 2 {
            // sort ascending cell state
            let nextCellIndexPath = IndexPath(row: 1, section: indexPath.section)
            let nextCell = tableview.cellForRow(at: nextCellIndexPath) as? FilterTableViewCell
            nextCell?.updateSwitch(isEnabled: sender.isOn)
            
            guard cascadeEvent else { return }
            let otherSection = indexPath.section == 1 ? 2 : 1
            let otherSortCellIndexPath = IndexPath(row: 0, section: otherSection)
            let otherSortcell = tableview.cellForRow(at: otherSortCellIndexPath) as? FilterTableViewCell
            otherSortcell?.disableIfNeeded()
        }
    }
    
    @objc
    private func resetButtonTapped(_ sender: UIButton) {
        // make sure there at least one filter active
        guard !filterOptions.isEmpty else { return }
        
        filterOptions = []
        flags = flagsFromFilterOptions()
        UIView.performWithoutAnimation {
            self.tableview.reloadData()
        }
    }
    
    // MARK: - Helpers
    
    private func switchIsEnabled(forIndexPath indexPath: IndexPath) -> Bool {
        var enabled = true
        if indexPath.section == 1 || indexPath.section == 2 {
            if indexPath.row == 1 {
                enabled = flags[indexPath.section][0]
            }
        }
        return enabled
    }
    
    private func flagsFromFilterOptions() -> [[Bool]] {
        var result = [[false], [false, false], [false, false]]
        
        if filterOptions.contains(.showSuccessfulOnly) { result[0][0] = true }
        
        if filterOptions.contains(.launchDateSortDescending) { result[1][0] = true }
        if filterOptions.contains(.launchDateSortAscending) {
            result[1][0] = true
            result[1][1] = true
        }
        if filterOptions.contains(.missionNameSortDescending) { result[2][0] = true }
        if filterOptions.contains(.missionNameSortAscending) {
            result[2][0] = true
            result[2][1] = true
        }
        
        return result
    }
    
    private func filterOptionsFromFlags() -> FilterOptions {
        
        var result: FilterOptions = []
        
        if flags[0][0] {
            result.insert(.showSuccessfulOnly)
        }
        
        if flags[1][0], flags[1][1] {
            result.insert(.launchDateSortAscending)
        }
        else if flags[1][0] {
            result.insert(.launchDateSortDescending)
        }
        
        if flags[2][0], flags[2][1] {
            result.insert(.missionNameSortAscending)
        }
        else if flags[2][0] {
            result.insert(.missionNameSortDescending)
        }
        
        return result
    }
}

// MARK: - Table view data source

extension FilterViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 2
        case 2: return 2
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: filterCell, for: indexPath) as! FilterTableViewCell
        let title = titles[indexPath.section][indexPath.row]
        let isOn = flags[indexPath.section][indexPath.row]
        let isEnabled = switchIsEnabled(forIndexPath: indexPath)
        cell.setupContent(title: title, isOn: isOn, isEnabled: isEnabled) { (switchButton, cascadeEvent) in
            self.switchTapped(switchButton, atIndexPath: indexPath, cascadeEvent: cascadeEvent)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headers[section]
    }
}
