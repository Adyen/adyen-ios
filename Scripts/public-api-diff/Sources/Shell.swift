//
//  Shell.swift
//  
//
//  Created by Alexander Guretzki on 17/06/2024.
//

import Foundation

enum Shell {
    
    static func execute(_ commands: [String]) {
        commands.forEach { print(execute($0)) }
    }
    
    @discardableResult
    static func execute(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/zsh"
        task.standardInput = nil
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        print(output)
        return output
    }
}
