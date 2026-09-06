import SwiftUI
import WebKit
import AVFoundation

struct ContentView: View {
    var body: some View {
        GrooveWebView()
            .onAppear { configureBackgroundAudio() }
            .background(Color(red: 20/255, green: 18/255, blue: 15/255))
    }

    /// This is the one thing a website can never do for itself: declare a
    /// real playback audio session. Combined with the UIBackgroundModes
    /// "audio" capability (set in Info.plist via project.yml), this is what
    /// actually unlocks indefinite background/locked-screen playback.
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
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        // Let audio/video play without a tap gate, and inline rather than
        // popping into a system player — same as any normal app.
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        // Default (non-ephemeral) data store, so IndexedDB (your library,
        // playlists, settings) actually persists between launches.
        config.websiteDataStore = .default()

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.bounces = false
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 20/255, green: 18/255, blue: 15/255, alpha: 1)
        webView.scrollView.backgroundColor = webView.backgroundColor

        // Look for index.html both inside a WebAssets subfolder and at the
        // bundle root — XcodeGen's folder-reference behavior can vary, and
        // since index.html only ever references its sibling files with
        // plain relative paths, this works correctly either way as long as
        // they all land in the same directory together.
        let htmlURL = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "WebAssets")
            ?? Bundle.main.url(forResource: "index", withExtension: "html")

        if let url = htmlURL {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
