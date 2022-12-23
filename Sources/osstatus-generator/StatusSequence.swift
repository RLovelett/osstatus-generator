//
//  CaseSequence.swift
//  osstatus-generator
//
//  Created by Ryan Lovelett on 12/23/22.
//

import RegexBuilder
import Security

struct StatusSequence: Sequence {
    let statuses: [Status]

    init(parsing string: String) {
        statuses = string.matches(of: StatusSequence.statusMatch).map { (match) in
            Status(
                name: String(match.1),
                code: match.2,
                description: match.3.map { String($0) }
            )
        }
    }

    func makeIterator() -> Array<Status>.Iterator {
        statuses.makeIterator()
    }

// MARK: - Regular Expressions

    /// ^\s*\w+\s*
    static let nameMatch = Regex {
        Anchor.startOfLine
        ZeroOrMore(.whitespace)
        Capture {
            OneOrMore(.word)
        }
        ZeroOrMore(.whitespace)
    }

    /// \s*(?<code>-?\d+)\s*
    static let codeMatch = Regex {
        ZeroOrMore(.whitespace)
        TryCapture {
            Optionally { "-" }
            OneOrMore(.digit)
        } transform: {
            OSStatus($0)
        }
        ZeroOrMore(.whitespace)
    }

    ///
    static let openComment = #/\/\*/#

    ///
    static let closeComment = #/\*\//#

    /// Extract the description for a given OSStatus from SecBase.h. The
    /// description is the part that is contained between the open and close
    /// comment tags (i.e., between /* and */).
    ///
    /// The `Regex` here is designed such that it will extract all characters
    /// excluding any leading whitespace between the two.
    ///
    /// - Example:
    ///
    /// ```
    /// errSecSuccess                            = 0,       /* No error. */
    /// errSecUnimplemented                      = -4,      /* Function or operation not implemented. */
    /// ```
    ///
    /// In the above example this `Regex` would extract `No error.` and
    /// `Function or operation not implemented.` respectively.
    static let descriptionMatch = Regex {
        ZeroOrMore(.whitespace)
        openComment
        ZeroOrMore(.whitespace)

        Capture {
            OneOrMore {
                NegativeLookahead {
                    ZeroOrMore(.whitespace)
                    closeComment
                }
                CharacterClass.any
            }
        }

        ZeroOrMore(.whitespace)
        closeComment
    }

    ///
    static let statusMatch = Regex {
        nameMatch
        "="
        codeMatch
        ","
        Optionally {
            descriptionMatch
        }
    }
}
