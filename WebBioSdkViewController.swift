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
    func provideSessionData(data: Data?, dict: [String: Any]?, error: Error?)
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
    private var url = "https://dev.biometric.kz"
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
        if !self.apiKey.isEmpty { url = self.url + "/short" + "?api_key=" + self.apiKey + "&webview=true" }
        
        guard let url = URL(string: url) else { return }
        self.webView.load(URLRequest(url: url))
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
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
        
        if let urlString = webView.url?.absoluteString,
           let urlComponents = URLComponents(string: urlString),
           let value = urlComponents.queryItems?.first(where: { $0.name == "session" })?.value,
           let url = URL(string: self.url + "/v1/main/session/" + value + "/") {
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let statusCode = (response as? HTTPURLResponse)?.statusCode,
                   statusCode < 400, let data = data {
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                        let json = jsonData as? [String: Any]
                        self.delegate?.provideSessionData(data: data, dict: json, error: nil)
                    } catch let error {
                        self.delegate?.provideSessionData(data: nil, dict: nil, error: error)
                    }
                } else if let data = data {
                    self.delegate?.provideSessionData(data: data, dict: nil, error: nil)
                } else {
                    self.delegate?.provideSessionData(data: nil, dict: nil, error: error)
                }
            }.resume()
        }
        
        if let urlString = webView.url?.absoluteString, urlString.contains("test-ok") {
            self.dismiss(animated: true)
            self.delegate?.provideResult(success: true)
            
        } else if let urlString = webView.url?.absoluteString, urlString.contains("test-fail") {
            self.delegate?.provideResult(success: false)
        }
    }
}


// MARK: - WKUIDelegate
extension WebBioSdkViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo) async -> Bool {
        return true
    }
}
