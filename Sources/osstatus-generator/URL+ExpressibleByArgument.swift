//
//  URL+ExpressibleByArgument.swift
//  osstatus-generator
//
//  Created by Ryan Lovelett on 12/23/22.
//

import ArgumentParser
import Foundation

extension URL: ExpressibleByArgument {
    public init?(argument: String) {
        self = URL(filePath: argument)
    }
}
