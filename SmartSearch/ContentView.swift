//
// SmartSearch
// ContentView.swift
//
// Created on 6/29/25
//
// Copyright ©2025 DoorHinge Apps.
//

import SwiftUI
import WebKit
import SwiftSoup
import MarkdownUI
import Combine

struct ContentView: View {
    @State var query = ""//"What is special about the mantis shrimp?"
    
    @State var searchResults: [String] = []
    @State var urlIndexMap: [String: Int] = [:]
    
    @State var htmlResults: [String: String] = [:]
    
    @State var parsedTextResults: [String: String] = [:]
    
    @State var simplifiedResults: [String: String] = [:]
    
    @State var finalResult = ""
    
    @State var currentTab: Int = 0
    @State var actualCurrentTab: Int = 0
    @State var continueButton = false
    
    // Fixed: Added .autoconnect() and changed to .common run loop mode
    let shuffleTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Updated: Using 9 colors for smoother 3x3 mesh gradient animation
    @State var gradientColors = [
        Color(hex: "A472FF"),
        Color(hex: "5AADF0"),
        Color(hex: "5775F8"),
        Color(hex: "A69AF8"),
        Color(hex: "5775F8"),
        Color(hex: "A472FF"),
        Color(hex: "5AADF0"),
        Color(hex: "A472FF"),
        Color(hex: "A69AF8")
    ]
    
    @AppStorage("aiSearchWithChatGPT") var useChatGPT = false
    
    var body: some View {
        ZStack {
            VStack {
                if continueButton {
//                    TabView(selection: $actualCurrentTab) {
//                        Tab(value: 0) {
//                            step1
//                        } label: {
//                            Label("Step 1", systemImage: "circle")
//                        }
//                        
//                        Tab(value: 1) {
//                            step2
//                        } label: {
//                            Label("Step 2", systemImage: "circle")
//                        }
//                        
//                        Tab(value: 2) {
//                            step3
//                        } label: {
//                            Label("Step 3", systemImage: "circle")
//                        }
//                        
//                        Tab(value: 3) {
//                            step4
//                        } label: {
//                            Label("Step 4", systemImage: "circle")
//                        }
//                        
//                        Tab(value: 4) {
//                            step5
//                        } label: {
//                            Label("Step 5", systemImage: "circle")
//                        }
//                    }
                    step1
                    .onAppear() {
                        fetchDuckDuckGoResults(query: query) { urls in
                            searchResults = urls
                            urlIndexMap = Dictionary(uniqueKeysWithValues:
                                                        urls.enumerated().map { ($1, $0 + 1) })
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                currentTab = 1
                                
                                fetchHTMLForMultipleURLs(urls) { results in
                                    // Extract successful HTML content into dictionary
                                    for (url, result) in results {
                                        switch result {
                                        case .success(let html):
                                            htmlResults[url] = html
                                        case .failure(let error):
                                            print("Failed to fetch HTML for \(url): \(error.localizedDescription)")
                                        }
                                    }
                                    print("Successfully fetched HTML for \(htmlResults.count) URLs")
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        currentTab = 2
                                        
                                        DispatchQueue.global(qos: .userInitiated).async {
                                            var textResults: [String: String] = [:]
                                            for (url, html) in htmlResults {
                                                if let text = try? SwiftSoup.parse(html).text() {
                                                    textResults[url] = text
                                                } else {
                                                    textResults[url] = "Failed to parse text."
                                                }
                                            }
                                            
                                            DispatchQueue.main.async {
                                                parsedTextResults = textResults
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    currentTab = 3
                                                    
                                                    runSimplificationStep(input: textResults) {
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                            currentTab = 4
                                                            
                                                            let formatted = simplifiedResults
                                                                .sorted { (urlIndexMap[$0.key] ?? .max) < (urlIndexMap[$1.key] ?? .max) }
                                                                .map { kv in
                                                                    return "{\(kv.key)}\n\(kv.value)"
                                                                }
                                                                .joined(separator: "\n\n")
                                                            
                                                            searchSummary(
                                                                inputPrompt:
                                                        """
                                                        Prompt: \(query)
                                                        
                                                        \(formatted)
                                                        """
                                                            ) { result in
                                                                replaceMarkdownLinksWithFetchedTitles(in: result) { result2 in
                                                                    finalResult = result2
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    // Fixed: Changed animation to match working BrowseForMe pattern
                    .onReceive(shuffleTimer) { _ in
                        withAnimation(.linear(duration: 1)) {
                            gradientColors.shuffle()
                        }
                    }
                }
                else {
                    TextField("Enter a search query", text: $query)
                        .padding(20)
                    
                    Toggle(isOn: $useChatGPT) {
                        Label("Use ChatGPT", systemImage: "circle.fill")
                    }
                    
                    Button {
                        continueButton = true
                    } label: {
                        Text("Continue")
                    }
                }
            }
        }
    }
    
    var step1: some View {
        ZStack {
            background
            
            ScrollView {
                VStack {
                    HStack {
                        Markdown(finalResult)
                            .markdownTextStyle(\.text) {
                                FontFamilyVariant(.normal)
                                FontFamily(.system(.rounded))
                                ForegroundColor(Color.white)
                            }
                            .markdownTextStyle(\.link) {
                                FontFamilyVariant(.normal)
                                FontFamily(.system(.rounded))
                                UnderlineStyle(.single)
                                ForegroundColor(Color.white)
                            }
                        
                        Spacer()
                    }.padding(20)
                    
                    if !finalResult.isEmpty {
                        Spacer()
                            .frame(height: 50)
                    }
                    
                    VStack(spacing: 10) {
                        HStack {
                            HStack {
                                Text(currentTab == 0 ? "Searching": currentTab == 1 ? "Checking Websites": currentTab == 2 ? "Parsing Content": currentTab == 3 ? "Analysing": finalResult.isEmpty ? "Summarizing": "Sources")
                                    .animation(.easeInOut)
                            }
                            .padding(.horizontal, 20)
                            .frame(height: 50)
                            .background {
                                Color("Inverted Label").opacity(0.5)
                                    .cornerRadius(25)
                                    .animation(.easeInOut)
                            }
                            
                            Spacer()
                        }.frame(height: 50)
                        
                        ForEach(searchResults, id: \.self) { result in
                            HStack {
                                Link(destination: URL(string: result) ?? URL(string: "https://google.com")!) {
                                    HStack {
                                        Favicon(url: result)
                                        
                                        URLTitleView(url: result)
                                            .foregroundStyle(Color(.label))
                                    }.frame(height: 50)
                                        .padding(.horizontal, 20)
                                        .background {
                                            Color("Inverted Label").opacity(0.5)
                                                .cornerRadius(25)
                                                .animation(.easeInOut)
                                        }
                                }
                                
                                Spacer()
                                    .frame(height: 50)
                            }
                        }
                    }
                    .frame(height: CGFloat(searchResults.count * 60))
                }.animation(.default, value: searchResults)
                    .padding(20)
            }
        }
    }
    
    private func fetchTitle(from urlString: String) async -> String {
        return await URLTitleFetcher.fetchTitle(from: urlString)
    }
    
    var step2: some View {
        ZStack {
            background
            VStack {
                ScrollView {
                    ForEach(Array(htmlResults.keys), id: \.self) { url in
                        VStack(alignment: .leading) {
                            Text(url)
                                .font(.headline)
                                .padding(.bottom, 2)
                            
                            Text(htmlResults[url] ?? "")
                                .font(.caption)
                                .lineLimit(10)
                            
                            Divider()
                        }
                        .padding()
                    }
                }
            }
        }
    }
    
    var step3: some View {
        ZStack {
            background
            ScrollView {
                ForEach(parsedTextResults.keys.sorted(), id: \.self) { url in
                    VStack(alignment: .leading) {
                        Text(url).font(.headline)
                        Text(parsedTextResults[url] ?? "").font(.caption).lineLimit(10)
                        Divider()
                    }
                    .padding()
                }
            }
        }
    }
    
    var step4: some View {
        ZStack {
            background
            ScrollView {
                ForEach(simplifiedResults.keys.sorted(), id: \.self) { url in
                    VStack(alignment: .leading) {
                        Text(url).font(.headline)
                        Text(simplifiedResults[url] ?? "").font(.body)
                        Divider()
                    }
                    .padding()
                }
            }
        }
    }
    
    @State var thing = true
    
    let demoMarkdown = """
        # Heading 1
        ## Heading 2
        ### Heading 3
        #### Heading 4
        ##### Heading 5
        ###### Heading 6
        
        Paragraph text
        
        ## **Bold Heading 2**
        
        `print("Code Block")`
        
        - Bullet 1
        - Bullet 2
            - Sub-bullet 1
        
        > Quote
        """
    
    var step5: some View {
        ZStack {
            background
            GeometryReader { geo in
                ScrollView {
                    Toggle("Thing", isOn: $thing)
                    HStack {
                        if thing {
                            Markdown(finalResult)
                                .markdownTextStyle(\.text) {
                                    FontFamilyVariant(.normal)
                                    FontFamily(.system(.rounded))
                                    ForegroundColor(Color.white)
                                }
                                .markdownTextStyle(\.link) {
                                    FontFamilyVariant(.normal)
                                    FontFamily(.system(.rounded))
                                    UnderlineStyle(.single)
                                    ForegroundColor(Color.white)
                                }
                        }
                        else {
                            Text(finalResult)
                        }
                        
                        Spacer()
                    }.padding(20)
                }.frame(width: geo.size.width)
            }
        }
    }
    
    
    var background: some View {
        ZStack {
            if #available(iOS 18.0, *) {
                MeshGradient(width: 3, height: 3, points: [
                    .init(0, 0), .init(0.5, 0), .init(1, 0),
                    .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                    .init(0, 1), .init(0.5, 1), .init(1, 1)
                ], colors: gradientColors)
                .ignoresSafeArea()
            } else {
                // Fallback for older iOS versions
                LinearGradient(colors: Array(gradientColors.prefix(4)), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            }
            
            Color.white.opacity(0.25)
                .ignoresSafeArea()
        }
    }
    
    private func parseAllHTML() {
        DispatchQueue.global(qos: .userInitiated).async {
            var parsed: [String: String] = [:]
            for (url, html) in htmlResults {
                if let text = try? SwiftSoup.parse(html).text() { parsed[url] = text }
            }
            DispatchQueue.main.async {
                parsedTextResults = parsed
            }
        }
    }
    
    func runSimplificationStep(input: [String: String], completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        for (url, text) in input {
            group.enter()
            simplify(inputPrompt: text) { result in
                DispatchQueue.main.async {
                    simplifiedResults[url] = result
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
}
