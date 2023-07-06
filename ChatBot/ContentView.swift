//
//  ContentView.swift
//  ChatBot
//
//  Created by Quang Bao on 04/07/2023.
//

import SwiftUI

struct ContentView: View {
    
    let apiKey: String = "YOUR API KEY"
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            Task {
                let api = ChatBotAPIService(apiKey: apiKey)
                
                do {
                    let stream = try await api.sendMessageStream(text: "What is ChatGPT")
                    for try await line in stream {
                        print(line)
                    }
                } catch {
                    print("Error: " + error.localizedDescription)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
