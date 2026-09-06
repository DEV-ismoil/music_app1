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
        
        // Grant permissions to access local files and storage
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        config.setValue(true, forKey: "allowUniversalAccessFromFileURLs")

        let webView = WKWebView(frame: .zero, configuration: config)

        if let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "WebAssets") {
            // Grant access to the entire root directory so audio files and storage load safely
            let assetDir = url.deletingLastPathComponent()
            webView.loadFileURL(url, allowingReadAccessTo: assetDir)
        } else if let url = URL(string: "https://groove.ismail.works") {
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
