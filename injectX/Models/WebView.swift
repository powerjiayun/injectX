//
//  WebView.swift
//  injectX
//
//  Created by BliZzard on 2024/12/5.
//

import Foundation
import WebKit
import SwiftUI

// WebView 实现
struct WebView: NSViewRepresentable {
    var htmlURL: String
    @Binding var isLoading: Bool
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        loadAndParseXML(webView)
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
    }
    
    // 添加一个日期格式化的辅助函数
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z" // 解析原始格式
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return dateFormatter.string(from: date)
        }
        return dateString // 如果解析失败，返回原始字符串
    }

    private func loadAndParseXML(_ webView: WKWebView) {
        guard let url = URL(string: htmlURL) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            
            var releases: [ReleaseInfo] = []
            
            do {
                let xmlDoc = try XMLDocument(data: data, options: .documentTidyXML)
                if let items = try xmlDoc.nodes(forXPath: "//item") as? [XMLElement] {
                    for item in items {
                        let version = item.elements(forName: "sparkle:version").first?.stringValue ?? ""
                        let shortVersion = item.elements(forName: "sparkle:shortVersionString").first?.stringValue ?? ""
                        let dateString = item.elements(forName: "pubDate").first?.stringValue ?? ""
                        let description = item.elements(forName: "description").first?.stringValue ?? ""
                        
                        // 格式化日期
                        let formattedDate = formatDate(dateString)
                        
                        // 清理描述中的 CDATA 和 HTML 标签
                        let cleanDescription = description
                            .replacingOccurrences(of: "<![CDATA[", with: "")
                            .replacingOccurrences(of: "]]>", with: "")
                        
                        releases.append(ReleaseInfo(
                            version: version,
                            shortVersion: shortVersion,
                            date: formattedDate, // 使用格式化后的日期
                            description: cleanDescription
                        ))
                    }
                    
                    // 生成 HTML
                    let html = formatReleasesToHTML(releases)
                    
                    DispatchQueue.main.async {
                        webView.loadHTMLString(html, baseURL: nil)
                    }
                }
            } catch {
                print("Error parsing XML: \(error)")
                DispatchQueue.main.async {
                    let errorHTML = """
                    <!DOCTYPE html>
                    <html>
                    <body>
                        <h1>Error loading release notes</h1>
                        <p>Failed to load or parse the release notes. Please try again later.</p>
                    </body>
                    </html>
                    """
                    webView.loadHTMLString(errorHTML, baseURL: nil)
                }
            }
        }.resume()
    }

    private func formatReleasesToHTML(_ releases: [ReleaseInfo]) -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <style>
                :root {
                    --primary-color: #007AFF;
                    --secondary-color: #5856D6;
                    --gradient-start: #007AFF;
                    --gradient-end: #5856D6;
                }
                body {
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                    line-height: 1.4;
                    margin: 0;
                    padding: 15px;
                    background-color: #f8f9fa;
                    color: #2c3e50;
                    background: linear-gradient(135deg, #f8f9fa 0%, #ffffff 100%);
                    min-height: 100vh;
                }
                .container {
                    max-width: 800px;
                    margin: 0 auto;
                }
                .release {
                    background-color: white;
                    border-radius: 12px;
                    box-shadow: 0 4px 12px rgba(0,0,0,0.03);
                    margin-bottom: 20px;
                    padding: 20px;
                    border: 1px solid rgba(0,0,0,0.05);
                    backdrop-filter: blur(10px);
                    transition: transform 0.2s ease, box-shadow 0.2s ease;
                }
                .release:hover {
                    transform: translateY(-2px);
                    box-shadow: 0 6px 16px rgba(0,0,0,0.06);
                }
                .version {
                    font-size: 16px;
                    font-weight: 600;
                    color: var(--primary-color);
                    margin-bottom: 4px;
                    display: flex;
                    align-items: center;
                }
                .version::before {
                    content: '';
                    display: inline-block;
                    width: 8px;
                    height: 8px;
                    background: linear-gradient(135deg, var(--gradient-start), var(--gradient-end));
                    border-radius: 50%;
                    margin-right: 8px;
                }
                .date {
                    color: #666;
                    font-size: 12px;
                    margin-bottom: 12px;
                    padding-bottom: 12px;
                    border-bottom: 1px solid #eee;
                }
                .description {
                    color: #444;
                    font-size: 13px;
                    line-height: 1.6;
                }
                ul {
                    margin: 8px 0;
                    padding-left: 20px;
                    list-style-type: none;
                }
        
                li {
                        margin: 6px 0;
                        position: relative;
                        padding-left: 16px;
                        line-height: 1.5;
                    }
                li::before {
                        content: '';
                        position: absolute;
                        left: 0;
                        top: 50%;
                        transform: translateY(-50%);
                        width: 4px;
                        height: 4px;
                        background-color: var(--primary-color);
                        border-radius: 50%;
                }
                code {
                    background-color: #f6f8fa;
                    border-radius: 4px;
                    padding: 2px 6px;
                    font-family: "SF Mono", Monaco, monospace;
                    font-size: 0.9em;
                    color: var(--primary-color);
                }
                @media (prefers-color-scheme: dark) {
                    :root {
                        --primary-color: #0A84FF;
                        --secondary-color: #5E5CE6;
                        --gradient-start: #0A84FF;
                        --gradient-end: #5E5CE6;
                    }
                    body {
                        background-color: #1a1a1a;
                        color: #e0e0e0;
                        background: linear-gradient(135deg, #1a1a1a 0%, #2d2d2d 100%);
                    }
                    .release {
                        background-color: rgba(45, 45, 45, 0.8);
                        border-color: rgba(255,255,255,0.1);
                    }
                    .version {
                        color: var(--primary-color);
                    }
                    .date {
                        color: #999;
                        border-bottom-color: rgba(255,255,255,0.1);
                    }
                    .description {
                        color: #ccc;
                    }
                    li::before {
                        background-color: var(--primary-color);
                    }
                    code {
                        background-color: rgba(0,0,0,0.2);
                        color: var(--primary-color);
                    }
                }
            </style>
        </head>
        <body>
            <div class="container">
                \(releases.map { release in """
                    <div class="release">
                        <div class="version">Version \(release.shortVersion) (\(release.version))</div>
                        <div class="date">\(release.date)</div>
                        <div class="description">\(release.description)</div>
                    </div>
                """
                }.joined(separator: "\n"))
            </div>
        </body>
        </html>
        """
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var isLoading: Bool
        
        init(isLoading: Binding<Bool>) {
            _isLoading = isLoading
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            isLoading = false
        }
    }
}
