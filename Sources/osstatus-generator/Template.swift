//
//  Template.swift
//  osstatus-generator
//
//  Created by Ryan Lovelett on 12/23/22.
//

import Security

struct Template {
    let date = "12/22/22"
    let cases: String
    let initRawValue: String
    let rawValue: String
    let descriptionCase: String
    let debugDescription: String
    let localizedDescription: String

    init<S: Sequence>(
        statuses: S,
        defaultComment: String = "No comment provided in SecBase.h"
    )
        where S.Element == Status
    {
        // "    /// \(comment ?? defaultComment)\n    case \(caseName) = \(digit)"
        self.cases = statuses.map({ (status) in
            "    /// \(status.description ?? defaultComment)\n    case \(status.name)"
        }).joined(separator: "\n\n")

        self.initRawValue = statuses.map({ (status) in
            "        case \(status.code):\n            self = .\(status.name)"
        }).joined(separator: "\n")

        self.rawValue = statuses.map({ (status) in
            "        case .\(status.name):\n            return \(status.code)"
        }).joined(separator: "\n")

        self.descriptionCase = statuses.map({ (status) in
            "        case .\(status.name):\n            return \"\(status.description ?? defaultComment)\""
        }).joined(separator: "\n")

        self.debugDescription = statuses.map({ (status) in
            "        case .\(status.name):\n            return \"\(status.description ?? defaultComment) <OSStatusError.\(status.name): \(status.code)>\""
        }).joined(separator: "\n")

        self.localizedDescription = statuses.map({ (status) in
            "        case .\(status.name):\n            return \"\(status.description ?? defaultComment) <OSStatusError.\(status.name): \(status.code)>\""
        }).joined(separator: "\n")
    }
}

// MARK: - CustomStringConvertible

extension Template: CustomStringConvertible {
    /// A textual representation of this instance.
    ///
    /// A
    var description: String {
        return #"""
//
// OSStatusError.swift
//
//
// Created by OSStatusGenerator on \(date)
// ⚠️ This file is automatically generated and should not be edited by hand. ⚠️
//

import Security

enum OSStatusError {
\#(cases)

    /// Unknown OSStatus to SecBase.h
    case unknown(OSStatus)

    init(status: OSStatus) {
        if let known = OSStatusError(rawValue: status) {
            self = known
        } else {
            self = .unknown(status)
        }
    }
}

// MARK: - RawRepresentable

extension OSStatusError: RawRepresentable {
    init?(rawValue: OSStatus) {
        switch rawValue {
\#(initRawValue)
        default:
            self = .unknown(rawValue)
        }
    }

    var rawValue: OSStatus {
        switch self {
\#(rawValue)
        case .unknown(let rawValue):
            return rawValue
        }
    }
}

// MARK: - CustomStringConvertible

extension OSStatusError: CustomStringConvertible {
    /// A textual representation of this instance.
    ///
    /// A
    var description: String {
        switch self {
\#(descriptionCase)
        case .unknown(let rawValue):
            return "The code, \(rawValue), is an unknown OSStatus to SecBase.h"
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension OSStatusError: CustomDebugStringConvertible {
    /// A textual representation of this instance.
    ///
    /// A
    var debugDescription: String {
        switch self {
\#(debugDescription)
        case .unknown(let rawValue):
            return "Unknown OSStatus to SecBase.h <OSStatusError.unknown: \(rawValue)>"
        }
    }
}

// MARK: - Error

extension OSStatusError: Error {
    var localizedDescription: String {
        switch self {
\#(localizedDescription)
        case .unknown(let rawValue):
            return "Unknown OSStatus to SecBase.h <OSStatusError.unknown: \(rawValue)>"
        }
    }
}
"""#
    }
}
