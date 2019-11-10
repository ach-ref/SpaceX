//
//  LaunchesListViewController.swift
//  SpaceX
//
//  Created by Achref Marzouki on 08/11/2019.
//  Copyright © 2019 Achref Marzouki. All rights reserved.
//

import UIKit

class LaunchesListViewController: UITableViewController {

    // MARK: - Private
    
    private let launchCell = "LaunchCell"
    private let circularTransition = CircularTransition()
    private let filterViewBackgroundColor: UIColor = .systemYellow
    
    private var headers: [String] = []
    private var dataSource: [[Launch]] = [[]]
    private var filtredDataSource: [[Launch]] = [[]]
    private var currentDataSource: [[Launch]] {
        return isFiltred ? filtredDataSource : dataSource
    }
    
    private let itemsPerPage = 50
    private var total = -1
    private var currentPage = 1
    private var isFetchingData = false
    
    private var filterOptions: FilterOptions = []
    private var isFiltred: Bool {
        return !filterOptions.isEmpty
    }
    
    private weak var activityIndicatorView: UIActivityIndicatorView!
    private weak var filterButton: UIButton!
    private var filterButtonCenter: CGPoint {
        return filterButton.convert(filterButton.center, to: nil)
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initial setup
        configureView()
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchData {
                DispatchQueue.main.async {
                    self.showLoader(false)
                    self.updateView()
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    // MARK: - Data
    
    private func fetchData(completion: @escaping () -> Void) {
        isFetchingData = true
        let offset = itemsPerPage * (currentPage - 1)
        WSManager.shared.fetchLaunches(limit: itemsPerPage, offset: offset) { (total, launches) in
            self.total = total
            self.dataSource[0].append(contentsOf: launches)
            self.isFetchingData = false
            completion()
        }
    }
    
    private func filtersChanged() {
        
        guard isFiltred else {
            headers = []
            updateView()
            return
        }
        
        var tmpDataSource = dataSource[0], keyPath: KeyPath<Launch, String>?
        
        // filter
        if filterOptions.contains(.showSuccessfulOnly) {
            tmpDataSource = dataSource[0].filter({ $0.successful == true })
        }
        
        // sort by date
        if filterOptions.contains(.launchDateSortAscending) || filterOptions.contains(.launchDateSortDescending) {
            keyPath = \.year
            tmpDataSource = tmpDataSource.sorted(by: Launch.dateCompare)
            if filterOptions.contains(.launchDateSortDescending) {
                tmpDataSource = tmpDataSource.reversed()
            }
        }
        
        // sort by mission name
        if filterOptions.contains(.missionNameSortAscending) || filterOptions.contains(.missionNameSortDescending) {
            keyPath = \.missionNameFirstLetter
            tmpDataSource = tmpDataSource.sorted(by: Launch.missionNameCompare)
            if filterOptions.contains(.missionNameSortDescending) {
                tmpDataSource = tmpDataSource.reversed()
            }
        }
        
        // group
        headers = []
        filtredDataSource = []
        var i = -1
        tmpDataSource.forEach({
            let header = keyPath == nil ? "" : $0[keyPath: keyPath!]
            if !headers.contains(header) {
                headers.append(header)
                filtredDataSource.append([])
                i += 1
            }
            filtredDataSource[i].append($0)
        })
        
        // reload data
        updateView()
    }
    
    // MARK: - UI
    
    private func configureView() {
        // title
        title = NSLocalizedString("launches.title", comment: "")
        // filter button
        let aButton = UIButton(type: .system)
        aButton.setImage(UIImage(named: "settings"), for: .normal)
        aButton.tintColor = .black
        aButton.clipsToBounds = true
        aButton.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: aButton)
        filterButton = aButton
        
        // table view
        let aNib = UINib(nibName: "LaunchTableViewCell", bundle: Bundle(for: type(of: self)))
        tableView.register(aNib, forCellReuseIdentifier: launchCell)

        // laoder
        let indicator = UIActivityIndicatorView(style: .gray)
        tableView.backgroundView = indicator
        activityIndicatorView = indicator
        showLoader(true)
    }
    
    private func showNextaAge() {
        currentPage += 1
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchData {
                DispatchQueue.main.async {
                    self.filtersChanged()
                }
            }
        }
    }
    
    private func updateView() {
        var count = 0
        currentDataSource.forEach({ count += $0.count })
        navigationItem.prompt = "\(count)"
        filterButton.tintColor = filterOptions.isEmpty ? .black : .systemOrange
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

    // MARK: - Actions
    
    @objc
    private func filterButtonTapped(_ sender: UIButton) {
        let filterViewController = storyboard!.instantiateViewController(withIdentifier: "Filter") as! FilterViewController
        filterViewController.closeButtonCenter = filterButtonCenter
        filterViewController.viewBackgroundColor = filterViewBackgroundColor
        filterViewController.filterOptions = filterOptions
        filterViewController.delegate = self
        filterViewController.transitioningDelegate = self
        filterViewController.modalPresentationStyle = .custom
        filterViewController.modalPresentationCapturesStatusBarAppearance = true
        present(filterViewController, animated: true, completion: nil)
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedLaunch = currentDataSource[indexPath.section][indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! LaunchDetailsViewController
                controller.loadViewIfNeeded()
                controller.detailItem = selectedLaunch
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return currentDataSource.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDataSource[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: launchCell, for: indexPath) as! LaunchTableViewCell
        let launch = currentDataSource[indexPath.section][indexPath.row]
        cell.setupContent(launch: launch)
        
        if let stringUrl = launch.missionPatchUrl {
            if ImageCache.shared.isImagePresentInCache(url: stringUrl) {
                cell.setImage(ImageCache.shared.getCachedImage(for: stringUrl))
            }
            else {
                cell.imageIsLoading()
                ImageCache.shared.displayImage(from: stringUrl) { image in
                    if tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                        cell.setImage(image)
                    }
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard isFiltred else { return nil }
        return headers[section]
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return headers
    }
    
    // MARK: - Table View delegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard !isFetchingData else { return }
        guard indexPath.row + 1 == currentDataSource.last?.count, dataSource[0].count < total else {
            // hide loader
            let indicator = tableView.tableFooterView as? UIActivityIndicatorView
            indicator?.stopAnimating()
            tableView.tableFooterView = UIView()
            return
        }
        
        // get next page's data
        showNextaAge()
        
        // show loader
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 50)
        tableView.tableFooterView = indicator
        indicator.startAnimating()
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.textColor = .systemYellow
        header?.textLabel?.font = .boldSystemFont(ofSize: 20)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        guard isFiltred, !headers[section].isEmpty else { return 0 }
        return 40
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: self)
    }
}

// MARK: - View controller transition delegate

extension LaunchesListViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        circularTransition.transitionType = .present
        circularTransition.circleColor = filterViewBackgroundColor
        circularTransition.startingPoint = filterButtonCenter
        return circularTransition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        circularTransition.transitionType = .dismiss
        return circularTransition
    }
}

// MARK: - Filter controller delegate

extension LaunchesListViewController: FilterControllerDelegate {
    
    func filterControllerDidFinish(withOptions options: FilterOptions) {
        self.filterOptions = options
        filtersChanged()
    }
}
