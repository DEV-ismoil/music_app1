import SwiftUI
import WebKit
import AVFoundation

struct ContentView: View {
    var body: some View {
        WebView()
            .ignoresSafeArea()
    }
}

struct WebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set AVAudioSession category: \(error)")
        }

        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: config)

        if let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "WebAssets") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else if let url = URL(string: "https://groove.ismail.works") {
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
