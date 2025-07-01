//
// SmartSearch
// FormatMarkdown.swift
//
// Created on 7/1/25
//
// Copyright ©2025 DoorHinge Apps.
//


import Foundation
import LinkPresentation

/// Replaces Markdown links where the text equals the URL with fetched page titles.
func replaceMarkdownLinksWithFetchedTitles(
    in input: String,
    completion: @escaping (String) -> Void
) {
    // Regex to match [https://example.com](https://example.com)
    let pattern = #"\[(https?://[^\]]+)\]\(\1\)"#
    let regex = try! NSRegularExpression(pattern: pattern)
    let nsInput = input as NSString
    let matches = regex.matches(
        in: input, range: NSRange(location: 0, length: nsInput.length)
    )

    var replacements: [Range<String.Index>: String] = [:]
    let dispatchGroup = DispatchGroup()

    for match in matches {
        let urlRange = match.range(at: 1)
        guard let swiftRange = Range(urlRange, in: input) else { continue }
        let urlString = String(input[swiftRange])
        guard let url = URL(string: urlString) else {
            replacements[swiftRange] = urlString
            continue
        }

        dispatchGroup.enter()
        let provider = LPMetadataProvider()
        provider.startFetchingMetadata(for: url) { metadata, error in
            defer { dispatchGroup.leave() }
            if let title = metadata?.title, !title.isEmpty {
                replacements[swiftRange] = title
            } else {
                replacements[swiftRange] = urlString
            }
        }
    }

    dispatchGroup.notify(queue: .main) {
        var result = input
        // Replace from end to start to keep indices valid
        for (range, title) in replacements.sorted(by: { $0.key.upperBound > $1.key.upperBound }) {
            let url = String(input[range])
            let markdown = "[\(url)](\(url))"
            if let replaceRange = result.range(of: markdown) {
                result.replaceSubrange(
                    replaceRange,
                    with: "[\(title)](\(url))"
                )
            }
        }
        completion(result)
    }
}
