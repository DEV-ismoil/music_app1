import SwiftUI
import WebKit
import AVFoundation

struct ContentView: View {
    var body: some View {
        GrooveWebView()
            .ignoresSafeArea()
            .onAppear { configureBackgroundAudio() }
            .background(Color(red: 20/255, green: 18/255, blue: 15/255))
    }

    private func configureBackgroundAudio() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true, options: [])
        } catch {
            print("Audio session configuration failed: \(error)")
        }
    }
}

struct GrooveWebView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.websiteDataStore = .default()

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.bounces = false
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 20/255, green: 18/255, blue: 15/255, alpha: 1)
        webView.scrollView.backgroundColor = webView.backgroundColor

        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        let htmlURL = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "WebAssets")
            ?? Bundle.main.url(forResource: "index", withExtension: "html")

        if let url = htmlURL {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            let errorHTML = "<html><body style='background:#111;color:#fff;display:flex;justify-content:center;align-items:center;height:100vh;font-family:sans-serif;'><h2>index.html not found in bundle</h2></body></html>"
            webView.loadHTMLString(errorHTML, baseURL: nil)
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Calculate scale ratio and shrink the web app layout to fit the screen
            let js = """
            var bodyWidth = document.body.scrollWidth || document.documentElement.scrollWidth;
            var screenWidth = window.innerWidth;
            if (bodyWidth > screenWidth) {
                var scale = screenWidth / bodyWidth;
                document.body.style.transform = 'scale(' + scale + ')';
                document.body.style.transformOrigin = 'top left';
                document.body.style.width = (100 / scale) + '%';
            }
            """
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }
}
