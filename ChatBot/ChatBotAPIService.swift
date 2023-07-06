//
//  ChatBotAPIService.swift
//  ChatBot
//
//  Created by Quang Bao on 05/07/2023.
//

import Foundation

class ChatBotAPIService {
    private let apiKey: String
    
    private var urlRequest: URLRequest {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        header.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
            
            print("Value: " + value)
            print("Key: " + key)
            print("---------")
        }
        return urlRequest
    }
    
    private var header: [String: String] {
        [
            "Content-Type" : "application/json",
            "Authorization" : "Bearer \(apiKey)"
        ]
    }
    
    private let model: String = "gpt-3.5-turbo"
    private var messages: [String: String] = [
        "role": "user",
        "content": "Say this is a test!"
    ]
    private var temperature: Double = 0.7
    
    private let jsonDecoder = JSONDecoder()
    private let basePrompt = "You are ChatGPT, ...."
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    private func generateChatGPTPrompt(from text: String) -> String {
        return basePrompt + "User: \(text)\n\n\nChatGPT:"
    }
    
    //"model" : "text-chat-davinci-002-20221122"
    func jsonBody(text: String, stream: Bool = true) throws -> Data {
        let jsonBody: [String: Any] = [
            "model" : "text-chat-davinci-003",
            "prompt": generateChatGPTPrompt(from: text),
            "max_tokens": 1024,
            "temperature": 0.8,
            "stop": [
                "\n\n\n",
                "<|im_end|>"
            ],
            "stream": stream
        ]
        
        return try JSONSerialization.data(withJSONObject: jsonBody)
    }
    
    func sendMessageStream(text: String) async throws -> AsyncThrowingStream<String, Error> {
        
        var urlRequest = self.urlRequest
        urlRequest.httpBody = try jsonBody(text: text)
        
        let (data, response) = try await URLSession.shared.bytes(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse.description
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.badResponse(int: httpResponse.statusCode).description
        }
        
        return AsyncThrowingStream<String, Error> { continuation in
            Task(priority: .userInitiated) {
                do {
                    for try await line in data.lines {
                        if line.hasPrefix("data: "),
                           let data = line.dropFirst(6).data(using: .utf8),
                           let response = try? self.jsonDecoder.decode(CompletionResponse.self, from: data),
                           let text = response.choices.first?.text {
                            continuation.yield(text)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
