//
//  String+ParseKeyPath.swift
//  ssh-askpass
//
//  Created by Lukas on 20.09.18.
//  Copyright © 2018 Lukas Zronek. All rights reserved.
//

import Foundation

extension String {
    
    func parseKeyPath(pattern: String) -> String? {
        let regex: NSRegularExpression
        
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
                return nil
        }
            
        if let match = regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)), match.numberOfRanges >= 2 {
            return String(self[Range(match.range(at: 1), in: self)!])
        }
        return nil
    }
}
