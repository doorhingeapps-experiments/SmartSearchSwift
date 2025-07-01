//
// SmartSearch
// AIResponse.swift
//
// Created on 6/30/25
//
// Copyright ©2025 DoorHinge Apps.
//


import Foundation
import FoundationModels

func searchSummary(inputPrompt: String, completion: @escaping (String) -> Void) {
    var model = SystemLanguageModel.default
    
    switch model.availability {
    case .available:
        Task {
            let instructions = """
You will be given a prompt. This prompt is the main thing you will give information about. It could be a question or just a statement. Your job is to provide an overview of that topic and explain it in a simple to understand way that provides depth. 

Along with the prompt, you will be given several summaries of things directly relating to the prompt. In your response, you will cite which of these summaries you pulled each section of information from. To cite one summary, you use brackets with the index number of that summary like this: {1}. For multiple summaries, separate with commas like this: {1,3,5}. The summaries will also be provided with the index in brackets like this: {1}. 

Your response should be formatted in basic markdown and use bullet points and sentences where appropriate.
"""
            
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
