//
//  WebKitView.swift
//  EkaMedicalRecordsUI
//

import SwiftUI
import WebKit

struct WebKitView: UIViewRepresentable {
  let url: URL

  func makeUIView(context: Context) -> WKWebView {
    let config = WKWebViewConfiguration()
    // Treat loaded HTML as untrusted by default and disable script execution.
    config.defaultWebpagePreferences.allowsContentJavaScript = false
    
    // Apply pre-compiled content rules if already available from a prior call
    if let rules = WebKitView.cachedContentRules {
      config.userContentController.add(rules)
    }
    let webView = WKWebView(frame: .zero, configuration: config)
    webView.navigationDelegate = context.coordinator
    webView.allowsLinkPreview = false
    // Prevent swipe gestures from navigating the web view's history
    webView.allowsBackForwardNavigationGestures = false
    // Kick off content-rule compilation so future instances are fully protected
    WebKitView.compileContentRulesIfNeeded()
    return webView
  }

  func updateUIView(_ uiView: WKWebView, context: Context) {
    // allowingReadAccessTo is scoped to the parent folder only — no broader FS access
    uiView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
  }

  func makeCoordinator() -> Coordinator {
    Coordinator()
  }
}

// MARK: - Navigation policy

extension WebKitView {
  /// Only allows the initial programmatic file load; cancels everything else —
  /// link clicks, JS redirects, form submits, back/forward, and any external URL.
  final class Coordinator: NSObject, WKNavigationDelegate {
    func webView(
      _ webView: WKWebView,
      decidePolicyFor navigationAction: WKNavigationAction,
      decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
      let isInitialLoad = navigationAction.navigationType == .other
                       && navigationAction.request.url?.isFileURL == true
      decisionHandler(isInitialLoad ? .allow : .cancel)
    }
  }
}

// MARK: - Content rules (block external network requests from JS)

extension WebKitView {
  /// Cached compiled rule list — shared across all WebKitView instances.
  private static var cachedContentRules: WKContentRuleList?

  /// Compiles a WKContentRuleList that blocks all http/https requests originating
  /// inside the web view (fetch, XHR, image src, etc.), preventing JS-based data
  /// exfiltration. Result is cached so only one compilation ever runs per session.
  static func compileContentRulesIfNeeded() {
    guard cachedContentRules == nil else { return }
    let rules = """
    [{"trigger":{"url-filter":"https?://.*"},"action":{"type":"block"}}]
    """
    WKContentRuleListStore.default().compileContentRuleList(
      forIdentifier: "EkaDocumentViewerBlockExternal",
      encodedContentRuleList: rules
    ) { list, _ in
      cachedContentRules = list
    }
  }
}

// MARK: - Preview

#Preview {
  if let url = Bundle.module.url(forResource: "test_document", withExtension: "html") {
    WebKitView(url: url)
  } else {
    Text("test_document.html not found in bundle")
  }
}
