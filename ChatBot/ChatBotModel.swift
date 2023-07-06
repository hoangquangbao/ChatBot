//
//  ChatBotModel.swift
//  ChatBot
//
//  Created by Quang Bao on 04/07/2023.
//

import SwiftUI

struct Message: Codable {
    let role: String
    let content: String
}

extension Array where Element == Message {
    var contentCount: Int { reduce(0) {
        $0 + $1.content.count
    }}
}

struct Request: Codable {
    let model: String
    let message: [Message]
    let temperature: Double
    let stream: Bool
}

struct ErrorRootResponse: Decodable {
    let error: ErrorResponse
}

struct ErrorResponse: Decodable {
    let message: String
    let type: String?
}

struct CompletionResponse: Decodable {
    let choices: [Choice]
    let usage: Usage?
}

struct Usage: Decodable {
    let promptTokens: Int?
    let completionTokens: Int?
    let totalTokens: Int?
}

struct Choice: Decodable {
    let message: Message
    let finishReason: String?
    let text: String
}

struct StreamChoice: Decodable {
    let finishReason: String?
    let delta: StreamMessage
}

struct StreamMessage: Decodable {
    let role: String?
    let content: String?
}
