//
//  NDHpple.swift
//  NDHpple
//
//  Created by Nicolai on 24/06/14.
//  Copyright (c) 2014 Nicolai Davidsson. All rights reserved.
//

import Foundation

public struct NDHpple {

    private let data: String
    private let isXML: Bool

    public init(data: String, isXML: Bool) {
        self.data = data
        self.isXML = isXML
    }

    public init(xmlData: String) {
        self.init(data: xmlData, isXML: true)
    }

    public init(htmlData: String) {
        self.init(data: htmlData, isXML: false)
    }

    /// Perform an Xpath query search.
    public func search(withQuery query: String) -> [NDHppleElement] {
        do {
            let nodes = try performXPathQuery(data: data, query: query, isXML: isXML)
            return nodes.map { NDHppleElement(node: $0) }
        } catch {
            print("Perform Xpath query error: \(error)")
        }
        return []
    }

    /// Perform an Xpath query search then return the first element.
    public func peekAtSearch(withQuery query: String) -> NDHppleElement? {
        let results = search(withQuery: query)
        return results.first
    }
}
