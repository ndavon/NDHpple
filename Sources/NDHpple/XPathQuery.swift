//
//  XPathQuery.swift
//  NDHpple
//
//  Created by Nicolai on 24/06/14.
//  Copyright (c) 2014 Nicolai Davidsson. All rights reserved.
//

import Foundation
import Clibxml2

private class XmlList<T> : Sequence {
    
    typealias Element = UnsafeMutablePointer<T>?
    var current: Element
    var next: Element { return nil }

    init(head: Element) { self.current = head }

    func makeIterator() -> AnyIterator<UnsafeMutablePointer<T>> {
        
        return AnyIterator {
            
            guard self.current != nil else { return nil }
            
            let c = self.current!
            self.current = self.next
            
            return c
        }
    }
}

private class XmlAttrList : XmlList<xmlAttr> {

    override var next: Element { return current?.pointee.next }
    override init(head: Element) { super.init(head: head) }
}

private class XmlNodeList : XmlList<xmlNode> {

    override var next: Element { return current?.pointee.next }
    override init(head: Element) { super.init(head: head) }
}

private func createAttributes(attributes: xmlAttrPtr) -> Attributes {
    
    var attributeDictionary = Attributes()

    for attribute in XmlAttrList(head: attributes) {
                
        // Logically, can an attribute have more than one child (which is a text node)?
        if let children = attribute.pointee.children,
           let name = attribute.pointee.name {
            
            print(String(cString: name))
            let childNode = createNode(from: children) 
            print(String(cString: name))
            print(childNode)
            attributeDictionary[String(cString: name)] = childNode
        }
    }
        
    return attributeDictionary
}

private func createNode(from currentNode: xmlNodePtr!) -> Node {
    
    var node = Node(minimumCapacity: 8)

    if let name = currentNode.pointee.name {
        node[NDHppleNodeKey.Name] = String(cString: name) as AnyObject
    }

    if let content = currentNode.pointee.content {
        node[NDHppleNodeKey.Content] = String(cString: content) as AnyObject
    }
    
    if let attributes = currentNode.pointee.properties {
        let attributeArray = createAttributes(attributes: attributes)
        
        if !attributeArray.isEmpty {
            node[NDHppleNodeKey.Attributes] = attributeArray as AnyObject
        }
    }
    
    if let children = currentNode.pointee.children {
        let childArray = XmlNodeList(head: children).map(createNode)

        if !childArray.isEmpty {
            node[NDHppleNodeKey.Children] = childArray as AnyObject
        }
    }
    
    if let buffer = xmlBufferCreate() {
        xmlNodeDump(buffer, currentNode.pointee.doc, currentNode, 0, 0)
    
        let rawContent = String(cString: buffer.pointee.content)
        node[NDHppleNodeKey.Raw] = rawContent as AnyObject 
    
        defer { xmlBufferFree(buffer) }
    }

    return node
}

enum QueryError : Error {
    
    case Empty
    case Parse
    case Create
}

func PerformXPathQuery(data: String, query: String, isXML: Bool) throws -> [Node] {
    
    guard !data.isEmpty else { throw QueryError.Empty }
    
    let bytes = data.cString(using: .utf8)
    let length = CInt(data.lengthOfBytes(using: .utf8))
    let encoding = CFStringGetCStringPtr(nil, 0)
    // isXML ? XML_PARSE_RECOVER : (HTML_PARSE_NOERROR | HTML_PARSE_NOWARNING)
    let options: CInt = isXML ? 1 : (1 << 5 | 1 << 6)
    let function = isXML ? xmlReadMemory : htmlReadMemory
    
    guard let doc = function(bytes, length, "", encoding, options) else { throw QueryError.Parse }
    defer { xmlFreeDoc(doc) }
    
    guard let xPathCtx = xmlXPathNewContext(doc) else { throw QueryError.Parse }
    defer { xmlXPathFreeContext(xPathCtx) }
    
    let queryBytes = query.utf8CString.map { xmlChar($0) }

    guard let xPathObj = xmlXPathEvalExpression(queryBytes, xPathCtx) else { throw QueryError.Parse }
    defer { xmlXPathFreeObject(xPathObj) }
    
    guard let nodes = xPathObj.pointee.nodesetval else { throw QueryError.Parse }
    
    let nodesArray = UnsafeBufferPointer(start: nodes.pointee.nodeTab, count: Int(nodes.pointee.nodeNr))
    return nodesArray.flatMap { createNode(from: $0!) }
}

func PerformXMLXPathQuery(data: String, query: String) throws -> [Node] {

    return try PerformXPathQuery(data: data, query: query, isXML: true)
}

func PerformHTMLXPathQuery(data: String, query: String) throws -> [Node] {

    return try PerformXPathQuery(data: data, query: query, isXML: false)
}
