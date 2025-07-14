//
// SmartSearch
// TitleFetching.swift
//
// Created on 7/14/25
//
// Copyright ©2025 DoorHinge Apps.
//


import SwiftUI
import LinkPresentation

struct URLTitleFetcher {
    
    /// Fetches the title of a webpage from a given URL string using LinkPresentation
    /// - Parameter urlString: The URL as a string
    /// - Returns: The webpage title, or an error message if fetching fails
    static func fetchTitle(from urlString: String) async -> String {
        // Validate URL
        guard let url = URL(string: urlString) else {
            return "Invalid URL"
        }
        
        return await withCheckedContinuation { continuation in
            let metadataProvider = LPMetadataProvider()
            
            metadataProvider.startFetchingMetadata(for: url) { metadata, error in
                if let error = error {
                    continuation.resume(returning: "Error: \(error.localizedDescription)")
                    return
                }
                
                guard let metadata = metadata else {
                    continuation.resume(returning: "No metadata found")
                    return
                }
                
                let title = metadata.title ?? "No title found"
                continuation.resume(returning: title)
            }
        }
    }
}


struct URLTitleView: View {
    let url: String
    @State private var title: String = ""
    
    var body: some View {
        Text(displayText)
            .task {
                let fetchedTitle = await URLTitleFetcher.fetchTitle(from: url)
                
                // If title is empty, an error message, or indicates no title found, keep showing URL
                if fetchedTitle.isEmpty ||
                   fetchedTitle.hasPrefix("Error:") ||
                   fetchedTitle.hasPrefix("Invalid") ||
                   fetchedTitle.hasPrefix("Network error") ||
                   fetchedTitle.hasPrefix("No title found") ||
                   fetchedTitle.hasPrefix("No metadata found") {
                    title = ""
                } else {
                    title = fetchedTitle
                }
            }
            .animation(.easeInOut, value: displayText)
    }
    
    private var displayText: String {
        return title.isEmpty ? url : title
    }
}
