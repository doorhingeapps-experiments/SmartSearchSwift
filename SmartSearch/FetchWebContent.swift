//
// SmartSearch
// FetchWebContent.swift
//
// Created on 6/30/25
//
// Copyright ©2025 DoorHinge Apps.
//


import Foundation
import SwiftSoup

func fetchDuckDuckGoResults(query: String, completion: @escaping ([String]) -> Void) {
    let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let urlString = "https://html.duckduckgo.com/html/?q=\(encoded)"
    guard let url = URL(string: urlString) else {
        completion([])
        return
    }

    URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data, error == nil else {
            completion([])
            return
        }

        let html = String(decoding: data, as: UTF8.self)
        do {
            let doc = try SwiftSoup.parse(html)
            let anchors = try doc.select("a.result__a").array()
            var results = [String]()

            for anchor in anchors.prefix(5) {
                let href = try anchor.attr("href")
                let full = href.hasPrefix("http") ? href : "https://duckduckgo.com\(href)"
                if let comps = URLComponents(string: full),
                   let uddg = comps.queryItems?.first(where: { $0.name == "uddg" })?.value,
                   let decoded = uddg.removingPercentEncoding {
                    results.append(decoded)  // decoded real URL
                }
                if results.count == 10 { break }
            }

            completion(results)
        } catch {
            completion([])
        }
    }.resume()
}

func fetchHTML(from urlString: String, completion: @escaping (Result<String, Error>) -> Void) {
    // Validate the URL
    guard let url = URL(string: urlString) else {
        completion(.failure(URLError(.badURL)))
        return
    }
    
    // Create URL request with timeout
    var request = URLRequest(url: url)
    request.timeoutInterval = 30
    request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
    
    // Create data task
    URLSession.shared.dataTask(with: request) { data, response, error in
        // Check for network error
        if let error = error {
            completion(.failure(error))
            return
        }
        
        // Check for data
        guard let data = data else {
            completion(.failure(URLError(.cannotDecodeContentData)))
            return
        }
        
        // Check for HTTP response status
        if let httpResponse = response as? HTTPURLResponse {
            guard 200...299 ~= httpResponse.statusCode else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
        }
        
        // Convert data to string, trying different encodings
        if let htmlString = String(data: data, encoding: .utf8) {
            completion(.success(htmlString))
        } else if let htmlString = String(data: data, encoding: .ascii) {
            completion(.success(htmlString))
        } else {
            completion(.failure(URLError(.cannotDecodeContentData)))
        }
    }.resume()
}

func fetchHTMLForMultipleURLs(_ urlStrings: [String], completion: @escaping ([String: Result<String, Error>]) -> Void) {
    var results: [String: Result<String, Error>] = [:]
    let dispatchGroup = DispatchGroup()
    let queue = DispatchQueue(label: "html-fetch-queue", attributes: .concurrent)
    
    for urlString in urlStrings {
        dispatchGroup.enter()
        
        queue.async {
            fetchHTML(from: urlString) { result in
                queue.async(flags: .barrier) {
                    results[urlString] = result
                    dispatchGroup.leave()
                }
            }
        }
    }
    
    dispatchGroup.notify(queue: .main) {
        completion(results)
    }
}


