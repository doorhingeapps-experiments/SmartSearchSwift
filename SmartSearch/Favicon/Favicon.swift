//
// Aura 2.0
// Favicon.swift
//
// Created on 6/11/25
//
// Copyright ©2025 DoorHinge Apps.
//


import SwiftUI

struct Favicon: View {
    @State var url: String
    var body: some View {
        AsyncImage(url: URL(string: "https://www.google.com/s2/favicons?domain=\(url)&sz=\(128)".replacingOccurrences(of: "https://www.google.com/s2/favicons?domain=Optional(", with: "https://www.google.com/s2/favicons?domain=").replacingOccurrences(of: ")&sz=", with: "&sz=").replacingOccurrences(of: "\"", with: ""))) { image in
            image
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .cornerRadius(100)
        } placeholder: {
            LoadingAnimations(size: 25, borderWidth: 5.0)
                .padding(.leading, 5)
        }
    }
}
