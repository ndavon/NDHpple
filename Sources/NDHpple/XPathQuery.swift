//
//  XPathQuery.swift
//  NDHpple
//
//  Created by Nicolai on 24/06/14.
//  Copyright (c) 2014 Nicolai Davidsson. All rights reserved.
//

import Foundation
import libxml2

private class XmlList<T>: Sequence, IteratorProtocol {

    typealias Element = UnsafeMutablePointer<T>

    func nextOfCurrent() -> Element? { return nil }

    var current: Element?

    func next() -> Element? {
        guard current != nil else { return nil }
        let c = current!
        current = nextOfCurrent()
        return c
    }

    init(head: Element?) {
        current = head
    }
}

private class XmlAttrList: XmlList<xmlAttr> {
    override func nextOfCurrent() -> Element? { return current?.pointee.next }
}

private class XmlNodeList: XmlList<xmlNode> {
    override func nextOfCurrent() -> Element? { return current?.pointee.next }
}

private func createAttributes(attributes: xmlAttrPtr) -> Attributes {

    var attributeDictionary = Attributes()

    for attribute in XmlAttrList(head: attributes) {

        // Logically, can an attribute have more than one child (which is a text node)?
        if let children = attribute.pointee.children,
            let name = attribute.pointee.name
        {

            //print(String(cString: name))
            let childNode = createNode(from: children)
            //print(String(cString: name))
            //print(childNode)
            attributeDictionary[String(cString: name)] = childNode
        }
    }

    return attributeDictionary
}

private func createNode(from currentNode: xmlNodePtr!) -> Node {

    var node = Node(minimumCapacity: 8)

    if let name = currentNode.pointee.name {
        node[NDHppleElement.NodeKey.name] = String(cString: name) as Any
    }

    if let content = currentNode.pointee.content {
        node[NDHppleElement.NodeKey.content] = String(cString: content) as Any
    }

    if let attributes = currentNode.pointee.properties {
        let attributeArray = createAttributes(attributes: attributes)

        if !attributeArray.isEmpty {
            node[NDHppleElement.NodeKey.attributes] = attributeArray as Any
        }
    }

    if let children = currentNode.pointee.children {
        let childArray = XmlNodeList(head: children).map(createNode)

        if !childArray.isEmpty {
            node[NDHppleElement.NodeKey.children] = childArray as Any
        }
    }

    if let buffer = xmlBufferCreate() {
        xmlNodeDump(buffer, currentNode.pointee.doc, currentNode, 0, 0)

        let rawContent = String(cString: buffer.pointee.content)
        node[NDHppleElement.NodeKey.raw] = rawContent as Any

        do { xmlBufferFree(buffer) }
    }

    return node
}

enum QueryError: Error {

    case empty
    case parse
    case create
}

func performXPathQuery(data: String, query: String, isXML: Bool) throws -> [Node] {

    guard !data.isEmpty else { throw QueryError.empty }

    let bytes = data.cString(using: .utf8)
    let length = CInt(data.lengthOfBytes(using: .utf8))
    let encoding = CFStringGetCStringPtr(nil, 0)
    // isXML ? XML_PARSE_RECOVER : (HTML_PARSE_NOERROR | HTML_PARSE_NOWARNING)
    let options: CInt = isXML ? 1 : (1 << 5 | 1 << 6)
    let function = isXML ? xmlReadMemory : htmlReadMemory

    guard let doc = function(bytes, length, "", encoding, options) else { throw QueryError.parse }
    defer { xmlFreeDoc(doc) }

    guard let xPathCtx = xmlXPathNewContext(doc) else { throw QueryError.parse }
    defer { xmlXPathFreeContext(xPathCtx) }

    let queryBytes = query.utf8CString.map { xmlChar($0) }

    guard let xPathObj = xmlXPathEvalExpression(queryBytes, xPathCtx) else { throw QueryError.parse }
    defer { xmlXPathFreeObject(xPathObj) }

    guard let nodes = xPathObj.pointee.nodesetval else { throw QueryError.parse }

    let nodesArray = UnsafeBufferPointer(
        start: nodes.pointee.nodeTab, count: Int(nodes.pointee.nodeNr))
    //return nodesArray.flatMap { createNode(from: $0!) }
    return nodesArray.compactMap { return $0 == nil ? nil : createNode(from: $0!) }
}
