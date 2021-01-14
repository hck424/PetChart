//
//  WkWebViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/12.
//

import UIKit
import WebKit

enum WebViewType {
    case normal, localHtmlAddressSearch
}

class WkWebViewController: UIViewController {
    @IBOutlet weak var baseView: UIView!
    
    var strUrl: String = ""
    var vcTitle: String = ""
    var type: WebViewType = .normal
    
    var webView: WKWebView?
    var popupWebView: WKWebView?
//    var webServer:GCDWebServer?
    
    var didFinishSelectedAddressClourse:((_ selData: [String:Any]?) ->())? {
        didSet {
            
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawBackButton(self, nil, #selector(onClickedBtnAction(_ :)))
        if vcTitle.isEmpty == false {
            CNavigationBar.drawTitle(self, vcTitle, nil)
        }
        
        
        let webConfig = WKWebViewConfiguration()
        let userController = WKUserContentController()
        let wkProcessPool = WKProcessPool()
        let wkPreference = WKPreferences()
        wkPreference.javaScriptEnabled = true
        wkPreference.javaScriptCanOpenWindowsAutomatically = true
        
        let wkUserScript = WKUserScript(source: self.getZoomDisableScript(), injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userController.addUserScript(wkUserScript)
        
        userController.add(self, name: "callbackHandler")
        
        webConfig.userContentController = userController
        webConfig.processPool = wkProcessPool
        webConfig.preferences = wkPreference
        webConfig.preferences.javaScriptCanOpenWindowsAutomatically = true
        webConfig.mediaTypesRequiringUserActionForPlayback = .all
        webConfig.allowsPictureInPictureMediaPlayback = true
        
        self.view.layoutIfNeeded()
        self.webView = WKWebView(frame: baseView.bounds, configuration: webConfig)
        self.baseView.addSubview(webView!)
        webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        webView?.isOpaque = false
        webView?.backgroundColor = UIColor.white
        webView?.uiDelegate = self
        webView?.navigationDelegate = self
        webView?.scrollView.zoomScale = 1.0
        webView?.scrollView.maximumZoomScale = 1.0
        webView?.scrollView.minimumZoomScale = 1.0
        webView?.scrollView.contentInset = .zero
        webView?.scrollView.contentInsetAdjustmentBehavior = .automatic
        
        webView?.evaluateJavaScript("navigator.userAgent", completionHandler: { (result, error) in
            let userAgent = result
            let newAgent = "\(String(describing: userAgent)) APP_PETCHART_IOS"
            self.webView?.customUserAgent = newAgent
        })
        
//        if type == .localHtmlAddressSearch {
//            webServer = GCDWebServer()
//            //로컬 웹서버를 만든다.
//            webServer?.addDefaultHandler(forMethod: "GET", request: GCDWebServerRequest.classForCoder(), processBlock: { (reqeust) -> GCDWebServerResponse? in
//                let filePath = Bundle.main.path(forResource: "index", ofType: "html")
//                let htmlString = try? String(contentsOfFile: filePath!, encoding: .utf8)
//                if let html = htmlString {
//                    return GCDWebServerDataResponse(html: html)
//                }
//                else {
//                    return GCDWebServerDataResponse(html: "<html><body><p>Hello World</p></body></html>")
//                }
//            })
//        }
//        else
        if strUrl.isEmpty == false {
            let req = NSMutableURLRequest(url: URL(string: strUrl)!)
            self.webView?.load(req as URLRequest)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if type == .localHtmlAddressSearch {
//            webServer?.start(withPort: 8080, bonjourName: "GCD Web Server")
//            print("server url visit \(String(describing: webServer?.serverURL))")
//            let urlStr = webServer?.serverURL?.absoluteString
//            if var urlStr = urlStr {
//                urlStr.append("index.html")
//                let req = NSMutableURLRequest(url: URL(string: urlStr)!)
//                print("===== url: \(String(describing: req.url))")
//                self.webView?.load(req as URLRequest)
//            }
//        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        if let webServer = webServer {
//            webServer.stop()
//        }
    }
    func getZoomDisableScript() ->String {
        return "var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable= 0');document.getElementsByTagName('head')[0].appendChild(meta);"
    }
    func getCreateWebScript() ->String {
        return "var originalWindowClose=window.close;window.close=function(){var iframe=document.createElement('IFRAME');iframe.setAttribute('src','back://'),document.documentElement.appendChild(iframe);originalWindowClose.call(window)};"
    }
    
    @objc func onClickedBtnAction(_ sender: UIButton) {
        if sender.tag == TAG_NAVI_BACK {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
extension WkWebViewController : WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message)
        if message.name == "callbackHandler" {
            guard let body = message.body as? [String: Any]  else {
                return
            }
            guard let data = body["data"] as? [String : Any], let funcName = body["func"] as? String else {
                return
            }
    
            if funcName == "searchAddress" {
                self.didFinishSelectedAddressClourse?(data)
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
}
extension WkWebViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        decisionHandler(.allow, preferences)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        AppDelegate.instance()?.startIndicator()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            AppDelegate.instance()?.stopIndicator()
        }
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        AppDelegate.instance()?.stopIndicator()
        print("didFinish")
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        AppDelegate.instance()?.stopIndicator()
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {

        let webConfig = WKWebViewConfiguration()
        let userController = WKUserContentController()
        let wkProcessPool = WKProcessPool()
        let wkPreference = WKPreferences()
        wkPreference.javaScriptEnabled = true
        wkPreference.javaScriptCanOpenWindowsAutomatically = true
        
        let wkUserScript = WKUserScript(source: self.getZoomDisableScript(), injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userController.addUserScript(wkUserScript)
        userController.add(self, name: "callbackHandler")
        
        webConfig.userContentController = userController
        webConfig.processPool = wkProcessPool
        webConfig.preferences = wkPreference
        webConfig.preferences.javaScriptCanOpenWindowsAutomatically = true
        webConfig.mediaTypesRequiringUserActionForPlayback = .all
        webConfig.allowsPictureInPictureMediaPlayback = true
        
        self.popupWebView = WKWebView(frame: baseView.bounds, configuration: configuration)
        popupWebView?.allowsBackForwardNavigationGestures = true
        popupWebView?.uiDelegate = self
        popupWebView?.navigationDelegate = self
        
        baseView.addSubview(popupWebView!)
        popupWebView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        popupWebView?.evaluateJavaScript("navigator.userAgent", completionHandler: { (result, error) in
            let userAgent = result
            let newAgent = "\(String(describing: userAgent)) APP_PETCHART_IOS"
            self.webView?.customUserAgent = newAgent
        })
        
        return popupWebView
    }
    func webViewDidClose(_ webView: WKWebView) {
        if webView == popupWebView {
            popupWebView?.removeFromSuperview()
            popupWebView = nil
        }
    }
}
extension WkWebViewController : WKUIDelegate {
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            completionHandler()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            completionHandler(false)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            completionHandler(defaultText)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            completionHandler(nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}



