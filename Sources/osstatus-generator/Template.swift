//
//  Template.swift
//  osstatus-generator
//
//  Created by Ryan Lovelett on 12/23/22.
//

import Foundation.NSDateFormatter
import Security

/// Convert a `Sequence` of `Status` structs into a `OSStatusError.swift` file.
struct Template {
    /// The sequence of `Status` structs that will be written to the
    /// `OSStatusError.swift`.
    let statuses: AnySequence<Status>

    /// If a `Status` does not have a description then this this string will be
    /// used.
    let defaultDescription: String

    /// Createa a new `Template` from the provided `Status`s and comment.
    /// - Parameters:
    ///   - statuses: A sequence of `Status` structs that will be written to the
    ///   template.
    ///   - defaultComment: The description to be used if a `Status` in the
    ///   `statuses` parameter has a `nil` `description`.
    init<S: Sequence>(
        statuses: S,
        defaultComment: String = "No comment provided in SecBase.h"
    )
        where S.Element == Status
    {
        self.statuses = AnySequence(statuses)
        self.defaultDescription = defaultComment
    }

    // MARK: Computed properties

    /// The date to be displayed in the header.
    var date: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: Date())
    }

    /// The cases of the `enum`.
    var cases: String {
        statuses.map({ (status) in
            "    /// \(status.description ?? defaultDescription)\n    case \(status.name)"
        }).joined(separator: "\n\n")
    }

    /// The cases of the `switch` in `init(status: OSStatus)`.
    var initStatus: String {
        statuses.map({ (status) in
            "        case \(status.code):\n            self = .\(status.name)"
        }).joined(separator: "\n")
    }

    /// The cases of the `switch` in `var rawValue: OSStatus`.
    var rawValue: String {
        statuses.map({ (status) in
            "        case .\(status.name):\n            return \(status.code)"
        }).joined(separator: "\n")
    }

    /// The cases of the `switch` in the `var description: String` for
    /// `CustomStringConvertible` conformance.
    var descriptionCase: String {
        statuses.map({ (status) in
            "        case .\(status.name):\n            return \"\(status.description ?? defaultDescription)\""
        }).joined(separator: "\n")
    }

    /// The cases of the `switch` in the `var debugDescription: String` for
    /// `CustomDebugStringConvertible` conformance.
    var debugDescription: String {
        statuses.map({ (status) in
            "        case .\(status.name):\n            return \"\(status.description ?? defaultDescription) <OSStatusError.\(status.name): \(status.code)>\""
        }).joined(separator: "\n")
    }

    /// The cases of the `switch` in the `var localizedDescription: String` for
    /// `Error` conformance.
    var localizedDescription: String {
        statuses.map({ (status) in
            "        case .\(status.name):\n            return \"\(status.description ?? defaultDescription) <OSStatusError.\(status.name): \(status.code)>\""
        }).joined(separator: "\n")
    }

    // MARK: Render template

    /// A textual representation of this instance.
    ///
    /// The text here is the rendered
    func render() -> String {
        return #"""
//
// OSStatusError.swift
//
//
// Created by OSStatusGenerator on \#(date)
// Please report issues: https://github.com/RLovelett/osstatus-generator/issues
// ?????? This file is automatically generated and should not be edited by hand. ??????
//

import Security

enum OSStatusError {
\#(cases)

    /// Unknown OSStatus to SecBase.h
    case unknown(OSStatus)

    /// Creates a new instance with the specified OSStatus code.
    init(status: OSStatus) {
        switch status {
\#(initStatus)
        default:
            self = .unknown(status)
        }
    }
}

// MARK: - RawRepresentable

extension OSStatusError: RawRepresentable {
    /// Creates a new instance with the specified raw value.
    ///
    /// This is a failable initializer, in practice this initializer will
    /// _always_ provide a non-`nil` value. This initializer is provided to meet
    /// conformance for the RawRepresentable protocol.
    @available(*, deprecated, renamed: "init(status:)")
    init?(rawValue: OSStatus) {
        self = .init(status: rawValue)
    }

    /// The corresponding value of the raw type.
    ///
    /// This is the OSStatus code that was parsed from SecBase.h.
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
    /// Typically, this is a description from SecBase.h.
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
    /// A textual representation of this instance, suitable for debugging.
    ///
    /// Typically, this is a description from SecBase.h with the underlying
    /// OSStatus error name and the associated code.
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
    /// Retrieve the localized description for this error.
    ///
    /// Typically, this is a description from SecBase.h with the underlying
    /// OSStatus error name and the associated code.
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
