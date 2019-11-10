//
//  WebViewController.swift
//  SpaceX
//
//  Created by Achref Marzouki on 10/11/2019.
//  Copyright © 2019 Achref Marzouki. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    // MARK: - Properties
    
    var url: URL!
    
    // MARK: - Private
    
    private var webView: WKWebView!
    
    // MARK: - View life cycle
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initial setup
        configureView()
    }
    
    // MARK: - UI
    
    private func configureView() {
        // navigation bar
        navigationItem.largeTitleDisplayMode = .never
        // refresh button
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reload(_:)))
        navigationItem.rightBarButtonItem = refreshButton
        // request
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    // MARK: - Actions
    
    @objc
    private func reload(_ sender: UIBarButtonItem) {
        webView.reloadFromOrigin()
    }
}
