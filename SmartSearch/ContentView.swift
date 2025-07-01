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

struct ContentView: View {
    let query = "Hello world"
    
    @State var searchResults: [String] = []
    @State var urlIndexMap: [String: Int] = [:]
    
    @State var htmlResults: [String: String] = [:]
    
    @State var parsedTextResults: [String: String] = [:]
    
    @State var simplifiedResults: [String: String] = [:]
    
    @State var finalResult = ""
    
    @State var currentTab: Int = 0
    var body: some View {
        TabView(selection: $currentTab) {
            Tab(value: 0) {
                step1
            } label: {
                Label("Step 1", systemImage: "circle")
            }
            
            Tab(value: 1) {
                step2
            } label: {
                Label("Step 2", systemImage: "circle")
            }
            
            Tab(value: 2) {
                step3
            } label: {
                Label("Step 3", systemImage: "circle")
            }
            
            Tab(value: 3) {
                step4
            } label: {
                Label("Step 4", systemImage: "circle")
            }
            
            Tab(value: 4) {
                step5
            } label: {
                Label("Step 5", systemImage: "circle")
            }
        }.onAppear() {
            fetchDuckDuckGoResults(query: query) { urls in
                searchResults = urls
                urlIndexMap = Dictionary(uniqueKeysWithValues:
                                    urls.enumerated().map { ($1, $0 + 1) })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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

//                                        for (url, text) in textResults {
//                                            simplify(inputPrompt: text) { result in
//                                                DispatchQueue.main.async {
//                                                    simplifiedResults[url] = result
//                                                }
//                                            }
//                                        }
                                        runSimplificationStep(input: textResults) {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                currentTab = 4
                                                
//                                                let numbered = simplifiedResults
//                                                    .sorted { (urlIndexMap[$0.key] ?? .max) <
//                                                        (urlIndexMap[$1.key] ?? .max) }
//                                                    .compactMap { kv -> String? in
//                                                        guard let n = urlIndexMap[kv.key] else { return nil }
//                                                        return "{\(n)}\n\(kv.value)"
//                                                    }
//                                                    .joined(separator: "\n\n")
                                                
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
    }
    
    var step1: some View {
        VStack {
            ForEach(searchResults, id:\.self) { result in
                Text(result)
                Divider()
            }
        }
    }
    
    var step2: some View {
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
    
    var step3: some View {
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
    
    var step4: some View {
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
    
    @State var thing = false
    
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
        }.background {
            LinearGradient(colors: [Color.blue, Color.purple], startPoint: .bottomLeading, endPoint: .topTrailing)
                .opacity(0.5)
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

