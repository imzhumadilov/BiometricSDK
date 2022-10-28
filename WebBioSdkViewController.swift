//
//  WebBioSdkViewController.swift
//
//  Created by Biometric on 17.04.2022.
//  Copyright © 2022 BIOMETRIC. All rights reserved.
//

import UIKit
import WebKit

protocol WebBioSdkDelegate {
    func provideResult(success: Bool)
}

final class WebBioSdkViewController: UIViewController {
    
    // MARK: - UIElements
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: UIScreen.main.bounds, configuration: config)
        return webView
    }()
    
    // MARK: - Props
    private var url = "https://test.biometric.kz/"
    private var apiKey: String = ""
    public var delegate: WebBioSdkDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupComponents()
        self.configureSubviews()
        self.configureConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        self.applyStyles()
    }
    
    // MARK: - Setup functions
    private func setupComponents() {
        var url = self.url
        if !self.apiKey.isEmpty { url = self.url + "?api_key=" + self.apiKey }
        
        guard let url = URL(string: url) else { return }
        self.webView.load(URLRequest(url: url))
        self.webView.navigationDelegate = self
    }
    
    private func applyStyles() {
        self.view.backgroundColor = UIColor.white
    }
    
    private func configureSubviews() {
        self.view.addSubview(self.webView)
    }
    
    private func configureConstraints() {
        self.webView.frame = self.view.frame
    }
    
    // MARK: - Module functions
}

// MARK: - WKNavigationDelegate
extension WebBioSdkViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if let urlString = webView.url?.absoluteString, urlString.contains("test-ok") {
            self.dismiss(animated: true)
            self.delegate?.provideResult(success: true)
            
        } else if let urlString = webView.url?.absoluteString, urlString.contains("test-fail") {
            self.delegate?.provideResult(success: false)
        }
    }
}
