//
// osstatus_generator.swift
// osstatus-generator
//
// Created by Ryan Lovelett on 12/23/22.
//

import ArgumentParser
import Foundation
import RegexBuilder

@main
struct osstatus_generator: AsyncParsableCommand {
    @Argument(help: "Path to SecBase.h", completion: .file())
    var secBase: URL = URL(filePath: "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/Security.framework/Versions/A/Headers/SecBase.h")

    func run() async throws {
        let secBaseStr = try String(contentsOf: secBase, encoding: .utf8)
        let itr = StatusSequence(parsing: secBaseStr)

        // Generate the file
        let template = Template(statuses: itr)

        // Write it to STDOUT
        print(template.description)
    }
}
