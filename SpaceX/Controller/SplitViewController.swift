//
//  SplitViewController.swift
//  SpaceX
//
//  Created by Achref Marzouki on 09/11/2019.
//  Copyright © 2019 Achref Marzouki. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initial setup
        delegate = self
    }
    
    // MARK: - Split view controller delegate
    
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
