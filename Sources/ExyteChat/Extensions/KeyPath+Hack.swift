//
//  KeyPath+Hack.swift
//  Chat
//
//  Created by Alisa Mylnikova on 25.03.2025.
//

#if swift(>=6.0)
extension KeyPath: @unchecked @retroactive Sendable { }
#else
extension KeyPath: @unchecked Sendable { }
#endif
