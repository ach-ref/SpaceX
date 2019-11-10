//
//  LaunchDetailsViewController.swift
//  SpaceX
//
//  Created by Achref Marzouki on 08/11/2019.
//  Copyright © 2019 Achref Marzouki. All rights reserved.
//

import UIKit

class LaunchDetailsViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    

    // MARK: - Private
    
    private let launchCell = "LaunchCell"
    private let rocketInfoCell = "RocketInfoCell"
    
    private weak var activityIndicatorView: UIActivityIndicatorView!
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    private lazy var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter
    }()
    
    private var titles: [[String]] = []
    private var contents: [[String]] = []
    private var sections: [String] = []
    private var wikipediaPageUrl: URL?
    
    private var isFetchingData = false
    
    // MARK: - Properties
    
    var detailItem: Launch!

    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initial settings
        configureView()
        DispatchQueue.global(qos: .userInitiated).async {
            self.isFetchingData = true
            self.fetchData {
                self.prepareData()
                self.isFetchingData = false
                DispatchQueue.main.async {
                    self.showLoader(false)
                    self.updateView()
                }
            }
        }
    }
    
    // MARK: - Data
    
    private func fetchData(completion: @escaping () -> Void) {
        
        WSManager.shared.fetchDetailedLaunch(id: detailItem.flightNumber) { launch in
            if let _ = launch {
                self.detailItem = launch!
            }
            completion()
        }
    }
    
    private func prepareData() {
        var info = ""
        titles = [[]]
        contents = [[]]
        sections = [NSLocalizedString("detail.launch", comment: ""), NSLocalizedString("detail.rocketGeneralInfo", comment: "")]
        titles[0].append(NSLocalizedString("detail.name", comment: ""))
        contents[0].append(detailItem.rocket?.name ?? "")
        let active = detailItem.rocket?.active ?? false
        titles[0].append(NSLocalizedString("detail.active", comment: ""))
        contents[0].append(active ? NSLocalizedString("general.yes", comment: "") : NSLocalizedString("general.no", comment: ""))
        titles[0].append(NSLocalizedString("detail.country", comment: ""))
        contents[0].append(detailItem.rocket?.country ?? "")
        titles[0].append(NSLocalizedString("detail.company", comment: ""))
        contents[0].append(detailItem.rocket?.company ?? "")
        titles[0].append(NSLocalizedString("detail.successRate", comment: ""))
        contents[0].append("\(detailItem.rocket?.successRate ?? 0) %")
        titles[0].append(NSLocalizedString("detail.firstFlight", comment: ""))
        info = detailItem.rocket?.firstFlight == nil ? "<N/A>" : dateFormatter.string(from: detailItem.rocket!.firstFlight!)
        contents[0].append(info)
        if let stringUrl = detailItem.rocket?.wikiLink, let url = URL(string: stringUrl) {
            titles[0].append(NSLocalizedString("detail.moreInfo", comment: ""))
            contents[0].append(NSLocalizedString("detail.wikiLink", comment: ""))
            wikipediaPageUrl = url
        }
        
        titles.append([])
        contents.append([])
        sections.append(NSLocalizedString("detail.rocketStructure", comment: ""))
        titles[1].append(NSLocalizedString("detail.stagesNumber", comment: ""))
        contents[1].append("\(detailItem.rocket?.stages ?? 0)")
        titles[1].append(NSLocalizedString("detail.enginesNumber", comment: ""))
        contents[1].append("\(detailItem.rocket?.enginesNumber ?? 0)")
        titles[1].append(NSLocalizedString("detail.landingLegs", comment: ""))
        contents[1].append("\(detailItem.rocket?.landingLegs ?? 0)")
        
        titles.append([])
        contents.append([])
        sections.append(NSLocalizedString("detail.rocketDimensions", comment: ""))
        titles[2].append(NSLocalizedString("detail.height", comment: ""))
        info = numberFormatter.string(from: (detailItem.rocket?.height ?? 0) as NSNumber) ?? "0"
        contents[2].append(info + " m")
        titles[2].append(NSLocalizedString("detail.diameter", comment: ""))
        info = numberFormatter.string(from: (detailItem.rocket?.diameter ?? 0) as NSNumber) ?? "0"
        contents[2].append(info + " m")
        titles[2].append(NSLocalizedString("detail.mass", comment: ""))
        info = numberFormatter.string(from: (detailItem.rocket?.mass ?? 0) as NSNumber) ?? "0"
        contents[2].append(info + " kg")
    }
    
    // MARK: - UI
    
    private func configureView() {
        // title
        title = detailItem?.missionName ?? ""
        // table view
        var aNib = UINib(nibName: "LaunchDetailTableViewCell", bundle: Bundle(for: type(of: self)))
        tableView.register(aNib, forCellReuseIdentifier: launchCell)
        aNib = UINib(nibName: "RocketInfoTableViewCell", bundle: Bundle(for: type(of: self)))
        tableView.register(aNib, forCellReuseIdentifier: rocketInfoCell)
        tableView.dataSource = self
        tableView.delegate = self
        
        // laoder
        let indicator = UIActivityIndicatorView(style: .gray)
        tableView.backgroundView = indicator
        activityIndicatorView = indicator
        showLoader(true)
    }

    private func updateView() {
        // Update the user interface for the detail item.
        title = detailItem.missionName
        tableView.reloadData()
    }
    
    // MARK: - Activity indicator
    
    private func showLoader(_ show: Bool) {
        // update table view separator
        tableView.separatorStyle = show ? .none : .singleLine
        
        guard show else {
            activityIndicatorView.stopAnimating()
            return
        }
        
        activityIndicatorView.startAnimating()
    }
    
    // MARK: - Navigation
    
    private func showBrowserOptionsAlert() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let openInSafari = NSLocalizedString("detail.openInSafari", comment: "")
        let safariAction = UIAlertAction(title: openInSafari, style: .default) { action in
            if UIApplication.shared.canOpenURL(self.wikipediaPageUrl!) {
                UIApplication.shared.open(self.wikipediaPageUrl!, options: [:], completionHandler: nil)
            }
            else {
                self.showSafariAlert()
            }
        }
        alertController.addAction(safariAction)
        
        let inApp = NSLocalizedString("detail.openInApp", comment: "")
        let inAppAction = UIAlertAction(title: inApp, style: .default) { action in
            let webViewController = WebViewController()
            webViewController.url = self.wikipediaPageUrl!
            webViewController.title = NSLocalizedString("detail.wikipedia", comment: "")
            let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem = backButton
            self.navigationController?.pushViewController(webViewController, animated: true)
        }
        alertController.addAction(inAppAction)
        
        let cancel = NSLocalizedString("general.cancel", comment: "")
        let cancelAction = UIAlertAction(title: cancel, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func showSafariAlert() {
        let title = NSLocalizedString("general.warning", comment: "")
        let message = NSLocalizedString("detail.openInSafari.failMessage", comment: "")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("general.ok", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    private func textColor(forIndexPath indexPath: IndexPath) -> UIColor {
        
        guard indexPath.section == 1, indexPath.row == 1 else {
            return .black
        }
        
        let active = detailItem.rocket?.active ?? false
        return active ? .systemGreen : .systemRed
    }
}

// MARK: - Table view data source

extension LaunchDetailsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isFetchingData ? 0 : titles.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard section != 0 else {
            return 1
        }
        
        return titles[section - 1].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard indexPath.section != 0 else {
            let cell = tableView.dequeueReusableCell(withIdentifier: launchCell, for: indexPath) as! LaunchDetailTableViewCell
            cell.setupcontent(launch: detailItem)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: rocketInfoCell, for: indexPath) as! RocketInfoTableViewCell
        let title = titles[indexPath.section - 1][indexPath.row]
        let content = contents[indexPath.section - 1][indexPath.row]
        let textColor = self.textColor(forIndexPath: indexPath)
        let isLink = indexPath.section == 1 && indexPath.row == 6
        cell.setupContent(title: title, content: content, textColor: textColor, isLink: isLink)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
}

// MARK: - Table view delegate

extension LaunchDetailsViewController: UITableViewDelegate {
   
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1 && indexPath.row == 6
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showBrowserOptionsAlert()
    }
}
