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
import OpenAI

// MARK: - Configuration
let openAI = OpenAI(apiToken: "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")

// MARK: - Simplify Function
func simplify(inputPrompt: String, completion: @escaping (String) -> Void) {
    let usesChatGPT = UserDefaults.standard.bool(forKey: "aiSearchWithChatGPT")
    
    if usesChatGPT {
        simplifyChatGPT(inputPrompt: inputPrompt, completion: completion)
    } else {
        simplifyFoundationModels(inputPrompt: inputPrompt, completion: completion)
    }
}

private func simplifyChatGPT(inputPrompt: String, completion: @escaping (String) -> Void) {
    let instructions = "Your job is to take the text from a website and find the main points. You will write 3 sentences with key details. The user has also provided you with a prompt. Adapt the main points you extract to be as relevant to that prompt as possible."
    
    let query = ChatQuery(
        messages: [
            .system(.init(content: .textContent(instructions))),
            .user(.init(content: .string(inputPrompt)))
//            .system(.init(content: instructions)),
//            .user(.init(content: inputPrompt))
        ],
        model: .gpt4_o
    )
    
    Task {
        do {
            let result = try await openAI.chats(query: query)
            if let content = result.choices.first?.message.content {
                completion(content)
            } else {
                completion("Error: No response from ChatGPT")
            }
        } catch {
            completion("Error: \(error.localizedDescription)")
        }
    }
}

private func simplifyFoundationModels(inputPrompt: String, completion: @escaping (String) -> Void) {
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

// MARK: - Attribution Function
func attribution(inputPrompt: String, completion: @escaping (String) -> Void) {
    let usesChatGPT = UserDefaults.standard.bool(forKey: "aiSearchWithChatGPT")
    
    if usesChatGPT {
        attributionChatGPT(inputPrompt: inputPrompt, completion: completion)
    } else {
        attributionFoundationModels(inputPrompt: inputPrompt, completion: completion)
    }
}

private func attributionChatGPT(inputPrompt: String, completion: @escaping (String) -> Void) {
    let instructions = "Your job is to examine text from a website and provide attribution details to cite the source. This should be brief while including as much relevant information as possible."
    
    let query = ChatQuery(
        messages: [
            .system(.init(content: .textContent(instructions))),
            .user(.init(content: .string(inputPrompt)))
//            .system(.init(content: .string(instructions))),
//            .user(.init(content: .string(inputPrompt)))
        ],
        model: .gpt4_o
    )
    
    Task {
        do {
            let result = try await openAI.chats(query: query)
            if let content = result.choices.first?.message.content {
                completion(content)
            } else {
                completion("Error: No response from ChatGPT")
            }
        } catch {
            completion("Error: \(error.localizedDescription)")
        }
    }
}

private func attributionFoundationModels(inputPrompt: String, completion: @escaping (String) -> Void) {
    var model = SystemLanguageModel.default
    
    switch model.availability {
    case .available:
        Task {
            let instructions = "Your job is to examine text from a website and provide attribution details to cite the source. This should be brief while including as much relevant information as possible."
            
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
