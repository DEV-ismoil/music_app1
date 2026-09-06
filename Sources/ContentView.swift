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
        
        // Enable vertical scrolling so you can reach bottom playback controls
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = true
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 20/255, green: 18/255, blue: 15/255, alpha: 1)
        webView.scrollView.backgroundColor = webView.backgroundColor

        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

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
            // Ensure full height visibility for play/pause/skip bar
            let js = """
            document.body.style.minHeight = '100vh';
            document.body.style.paddingBottom = '40px';
            """
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }
}
