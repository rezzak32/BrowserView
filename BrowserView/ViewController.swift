//
//  ViewController.swift
//  BrowserView
//
//  Created by Rezzak on 20.07.2023.
//

import UIKit
import WebKit

class ViewController: UIViewController,WKNavigationDelegate,UIPopoverPresentationControllerDelegate {
    var webView: WKWebView!
    var progressView: UIProgressView!
    var websites = ["www.google.com","www.netflix.com","www.disneyplus.com"]
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        
        toolbarItems = [progressButton,spacer,refresh]
        navigationController?.isToolbarHidden = false
        

        self.tabBarController?.tabBar.isHidden = false
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress),options: .new, context: nil)
        
        let url = URL(string: "https://" + websites[0])!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    @objc func openTapped( ) {
        let ac = UIAlertController(title: "Open Page..", message: nil, preferredStyle: .actionSheet)
        
        for website in websites {
            ac.addAction(UIAlertAction(title: website, style: .default,handler: openPage))
        }
        
        ac.addAction(UIAlertAction(title: "cancel", style: .cancel))
        //ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        if let popoverController = ac.popoverPresentationController {
            popoverController.delegate = self
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(ac, animated: true, completion: nil)
    }
    
    func openPage(action: UIAlertAction) {
        guard let title = action.title, let url = URL(string: "https://" + title) else {
            return
        }
        webView.load(URLRequest(url: url))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            let url = navigationAction.request.url
            
            if let host = url?.host {
                for website in websites {
                    if host.contains(website) {
                        decisionHandler(.allow)
                        return
                    }
                }
            }
            decisionHandler(.cancel)
        }
}

