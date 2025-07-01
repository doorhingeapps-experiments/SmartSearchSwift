//
// SmartSearch
// AISimplification.swift
//
// Created on 6/30/25
//
// Copyright ©2025 DoorHinge Apps.
//


import Foundation
import FoundationModels

func simplify(inputPrompt: String, completion: @escaping (String) -> Void) {
    var model = SystemLanguageModel.default
    
    switch model.availability {
    case .available:
        Task {
            let instructions = "Your job is to take the text from a website and find the main points. You will write 3 sentences with key details. The user has also provided you with a prompt. Adapt the main points you extract to be as relevant to that prompt as possible."
            
            let session = LanguageModelSession(instructions: instructions)
            
            let response: String
            do {
                response = try await session.respond(to: inputPrompt).content
                completion(response)
            } catch {
                completion("Error: \(error.localizedDescription)")
            }
        }
        
    case .unavailable(.deviceNotEligible):
        completion("Warning: Device not eligible for Apple Intelligence.")
    case .unavailable(.appleIntelligenceNotEnabled):
        completion("Warning: Apple Intelligence is disabled.")
    case .unavailable(.modelNotReady):
        completion("Warning: Apple Intelligence model not installed.")
    case .unavailable(_):
        completion("Warning: Apple Intelligence unavailable for an unknown reason.")
    }
}

