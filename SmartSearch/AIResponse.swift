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
import OpenAI

/*
func searchSummary(inputPrompt: String, completion: @escaping (String) -> Void) {
    var model = SystemLanguageModel.default
    
    switch model.availability {
    case .available:
        Task {
//            let instructions = """
//You will be given a prompt. This prompt is the main thing you will give information about. It could be a question or just a statement. Your job is to provide a simple but comprehensive overview of that topic. 
//
//Along with the prompt, you will be given several summaries of things directly relating to the prompt. In your response, you will cite which of these summaries you pulled each section of information from. To cite one summary, you use brackets with the index number of that summary like this: {1}. For multiple summaries, separate with commas like this: {1,3,5}. This should be done inline with the text. The summaries will be provided with the index in brackets like this: {1}. That is the number you will use when citing.
//
//Use bullet points for your answer. After a set of bullet points, add up to 3 sentences related to them. You will include multiple sections like this to provide a lot of information.
//
//Your response should be formatted in basic markdown. Use line breaks and bullet points extensively.
//"""
//            let instructions = """
//                You will be given a prompt. This prompt is the main topic you will provide information about. It may be a question or a statement. Your job is to write a clear, concise, and informative overview of the topic.
//
//                You will also receive several summaries of sources that relate to the topic. These sources will be labeled with index numbers in **curly brackets**, like this: **{1}**, **{2}**, etc.
//
//                **When you use information from a summary, you must cite it using the index number in curly brackets, inline.**  
//                - Example: *"X is a common interpretation of this event {1}."*  
//                - If citing multiple sources, separate them with commas: *"This theory has multiple variations {2,4,5}."*  
//                - **Do not use parentheses, footnotes, or other citation styles. Only use curly brackets.**
//
//                Summaries will be provided using the same format, e.g., {1}, {2}, etc.
//
//                ### Response Guidelines:
//                - Break the response into short, clear sections (3 sentences max).
//                - Always include bullet points with key information.
//                - Use titles for sections when appropriate.
//                - Avoid long, dense blocks of text.
//                - Use **basic Markdown** for formatting (e.g., `**bold**`, `*italics*`, lists, `# headers`, etc).
//
//                **Strict citation format summary:**  
//                - Use **curly brackets only**: `{1}`, `{2,3}`, etc.  
//                - Place citations **inline with the text**.
//                - Citations are ALWAYS REQUIRED.
//                """
//            let instructions = //Instructions {
//                            """
//                                You will be given a prompt. This prompt is the main topic you will provide information about. It may be a question or a statement. Your task is to write a structured, concise, and informative overview of the topic, in a professional tone similar to a research or search engine result summary—not a chat conversation.
//
//                                You will also be given a set of summaries that relate directly to the topic. Each summary will begin with a **website URL in curly brackets**, such as:  
//                                `{https://example.com/source}`  
//                                That URL identifies the source of the summary and is what you will use for citation.
//
//                                ### USING THE SUMMARIES (REQUIRED):
//                                - You must use the information from the provided summaries.
//                                - You may rephrase or combine ideas, but every factual or specific statement must be based on content from one or more of the summaries.
//                                - Do **not** invent or add any information that is not found in the summaries.
//                                - Each time you include a claim, cite the **exact URL shown at the start of the summary** in **curly brackets**. That is your source.
//
//                                ### CITATION FORMAT (STRICT):
//                                - Cite using the full URL from the summaries in **curly brackets**, inline:  
//                                  Example: `"This process occurs rapidly under certain conditions {https://example.com/page}"`  
//                                - For multiple sources: `{https://a.com, https://b.org}`  
//                                - Do **not use** parentheses, superscripts, footnotes, markdown links, or abbreviations.
//                                - The citation **must exactly match** the curly-bracketed URL provided before the summary.
//
//                                ### FORMAT AND STYLE REQUIREMENTS:
//                                - Break your response into clearly titled **sections**.
//                                - Each section must be:
//                                  - A bullet-point list (**whenever possible**).
//                                - Use bullet points for facts, comparisons, definitions, steps, or lists of features.
//                                - Never write long, uninterrupted blocks of text.
//                                - Maintain a **neutral, professional, and impersonal tone**. Do not use chat-like language or directly address the reader.
//                                - Format everything using markdown (you can use simple headings, lists, styles, and even tables)
//
//                                ### REMEMBER:
//                                - **You must cite every fact** using the full source URL in curly brackets.
//                                - **Only use the provided summaries** as sources. No external or invented information.
//                                - **Use bullets** and short paragraphs. Avoid long prose.
//                                """
            //}
            
            let instructions = """
                You will be given a prompt. This prompt is the main topic you will provide information about. It may be a question or a statement. Your task is to write a structured, concise, and informative overview of the topic, written in a professional, search-engine-summary tone—not a chat.

                You will also receive a set of summaries that relate directly to the prompt. Each summary will begin with a **website URL in curly brackets**, such as:  
                `{https://example.com/source "Source Title"}`  
                The URL and title in quotes identify the source of the summary and are what you’ll use for citations.

                ### USING THE SUMMARIES (REQUIRED):
                - You **must** use information from the provided summaries.
                - You may rephrase or combine ideas, but **every factual or specific statement** must be backed by one or more summaries.
                - Do **not** introduce or invent content not found in the summaries.
                - Each time you make a claim, cite it inline using the **full markdown link** from the summary’s curly braces, e.g.:  
                  > This method is widely adopted by major libraries [“Source Title”](https://example.com/source)  
                - For multiple sources: `[..., ...]` separated by commas.

                ### CITATION FORMAT (STRICT):
                - Always use **markdown link format**: `[Title](URL)` exactly as provided.
                - Inline placement, no superscripts, parentheses, or footnotes.
                - The title and URL inside your citation **must exactly match** the format given in the summary header.

                ### FORMAT AND STYLE REQUIREMENTS:
                - Break your response into clearly titled **sections**.
                - Each section must be a **bullet-list** of key points (preferred) or—if unavoidable—a paragraph of no more than **3 sentences**.
                - Use bullet points for definitions, comparisons, features, etc.
                - Avoid long prose or conversational phrasing. Maintain a formal, neutral, impersonal tone.
                - Use **Markdown** formatting: headings (`#`, `##`), lists (`-`), emphasis (`**`), tables if helpful.

                ### REMEMBER:
                - **Every fact must include a citation** using the exact markdown link from the summary.
                - **Do not use** any external knowledge beyond the summaries.
                - **Always prefer bullets** and concise structure. Avoid long blocks of text.

                """
            
            let session = LanguageModelSession(instructions: instructions)
            session.prewarm()
            
            let fullPrompt = "Make sure to cite ALL of your sources inline in markdown format. " + inputPrompt + "Cite your sources INLINE and with the url for the title and link for example: [https://example.com](https://example.com). This must be done inline and after with the content that came from it. You will provide a natural response and only answer the prompt without fluff."
            
            print(fullPrompt)
            
            let response: String
            do {
                response = try await session.respond(to: fullPrompt).content
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
}*/

func searchSummary(inputPrompt: String, completion: @escaping (String) -> Void) {
    let usesChatGPT = UserDefaults.standard.bool(forKey: "aiSearchWithChatGPT")
    
    if usesChatGPT {
        searchSummaryChatGPT(inputPrompt: inputPrompt, completion: completion)
    } else {
        searchSummaryFoundationModels(inputPrompt: inputPrompt, completion: completion)
    }
}

private func searchSummaryChatGPT(inputPrompt: String, completion: @escaping (String) -> Void) {
    let instructions = """
        You will be given a prompt. This prompt is the main topic you will provide information about. It may be a question or a statement. Your task is to write a structured, concise, and informative overview of the topic, written in a professional, search-engine-summary tone—not a chat.

        You will also receive a set of summaries that relate directly to the prompt. Each summary will begin with a **website URL in curly brackets**, such as:  
        `{https://example.com/source "Source Title"}`  
        The URL and title in quotes identify the source of the summary and are what you'll use for citations.

        ### USING THE SUMMARIES (REQUIRED):
        - You **must** use information from the provided summaries.
        - You may rephrase or combine ideas, but **every factual or specific statement** must be backed by one or more summaries.
        - Do **not** introduce or invent content not found in the summaries.
        - Each time you make a claim, cite it inline using the **full markdown link** from the summary's curly braces, e.g.:  
          > This method is widely adopted by major libraries ["Source Title"](https://example.com/source)  
        - For multiple sources: `[..., ...]` separated by commas.

        ### CITATION FORMAT (STRICT):
        - Always use **markdown link format**: `[Title](URL)` exactly as provided.
        - Inline placement, no superscripts, parentheses, or footnotes.
        - The title and URL inside your citation **must exactly match** the format given in the summary header.

        ### FORMAT AND STYLE REQUIREMENTS:
        - Break your response into clearly titled **sections**.
        - Each section must be a **bullet-list** of key points (preferred) or—if unavoidable—a paragraph of no more than **3 sentences**.
        - Use bullet points for definitions, comparisons, features, etc.
        - Avoid long prose or conversational phrasing. Maintain a formal, neutral, impersonal tone.
        - Use **Markdown** formatting: headings (`#`, `##`), lists (`-`), emphasis (`**`), tables if helpful.

        ### REMEMBER:
        - **Every fact must include a citation** using the exact markdown link from the summary.
        - **Do not use** any external knowledge beyond the summaries.
        - **Always prefer bullets** and concise structure. Avoid long blocks of text.
        """
    
    let fullPrompt = "Make sure to cite ALL of your sources inline in markdown format. " + inputPrompt + "Cite your sources INLINE and with the url for the title and link for example: [https://example.com](https://example.com). This must be done inline and after with the content that came from it. Your response will be formatted as a short research document and will only prevent as such."
    
    let query = ChatQuery(
        messages: [
            .system(.init(content: .textContent(instructions))),
            .user(.init(content: .string(fullPrompt)))
//            .system(.init(content: .string(instructions))),
//            .user(.init(content: .string(fullPrompt)))
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

private func searchSummaryFoundationModels(inputPrompt: String, completion: @escaping (String) -> Void) {
    var model = SystemLanguageModel.default
    
    switch model.availability {
    case .available:
        Task {
            let instructions = """
                You will be given a prompt. This prompt is the main topic you will provide information about. It may be a question or a statement. Your task is to write a structured, concise, and informative overview of the topic, written in a professional, search-engine-summary tone—not a chat.

                You will also receive a set of summaries that relate directly to the prompt. Each summary will begin with a **website URL in curly brackets**, such as:  
                `{https://example.com/source "Source Title"}`  
                The URL and title in quotes identify the source of the summary and are what you'll use for citations.

                ### USING THE SUMMARIES (REQUIRED):
                - You **must** use information from the provided summaries.
                - You may rephrase or combine ideas, but **every factual or specific statement** must be backed by one or more summaries.
                - Do **not** introduce or invent content not found in the summaries.
                - Each time you make a claim, cite it inline using the **full markdown link** from the summary's curly braces, e.g.:  
                  > This method is widely adopted by major libraries ["Source Title"](https://example.com/source)  
                - For multiple sources: `[..., ...]` separated by commas.

                ### CITATION FORMAT (STRICT):
                - Always use **markdown link format**: `[Title](URL)` exactly as provided.
                - Inline placement, no superscripts, parentheses, or footnotes.
                - The title and URL inside your citation **must exactly match** the format given in the summary header.

                ### FORMAT AND STYLE REQUIREMENTS:
                - Break your response into clearly titled **sections**.
                - Each section must be a **bullet-list** of key points (preferred) or—if unavoidable—a paragraph of no more than **3 sentences**.
                - Use bullet points for definitions, comparisons, features, etc.
                - Avoid long prose or conversational phrasing. Maintain a formal, neutral, impersonal tone.
                - Use **Markdown** formatting: headings (`#`, `##`), lists (`-`), emphasis (`**`), tables if helpful.

                ### REMEMBER:
                - **Every fact must include a citation** using the exact markdown link from the summary.
                - **Do not use** any external knowledge beyond the summaries.
                - **Always prefer bullets** and concise structure. Avoid long blocks of text.
                """
            
            let session = LanguageModelSession(instructions: instructions)
            session.prewarm()
            
            let fullPrompt = "Make sure to cite ALL of your sources inline in markdown format. " + inputPrompt + "Cite your sources INLINE and with the url for the title and link for example: [https://example.com](https://example.com). This must be done inline and after with the content that came from it. You will provide a natural response and only answer the prompt without fluff."
            
            print(fullPrompt)
            
            let response: String
            do {
                response = try await session.respond(to: fullPrompt).content
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
