//
//  XPathQuery.swift
//  NDHpple
//
//  Created by Nicolai on 24/06/14.
//  Copyright (c) 2014 Nicolai Davidsson. All rights reserved.
//

import Foundation
import Clibxml2

private class XmlList<T> : SequenceType {
    
    typealias Element = UnsafeMutablePointer<T>
    var current: Element
    var next: Element { return nil }

    init(head: Element) { self.current = head }

    func generate() -> AnyGenerator<Element> {
        
        return AnyGenerator(body: {
            
            guard self.current != nil else { return nil }
            
            let c = self.current
            self.current = self.next
            
            return c
        })
    }
}

private class XmlAttrList : XmlList<xmlAttr> {

    override var next: Element { return current.memory.next }
    override init(head: Element) { super.init(head: head) }
}

private class XmlNodeList : XmlList<xmlNode> {

    override var next: Element { return current.memory.next }
    override init(head: Element) { super.init(head: head) }
}

private func createAttributes(attributes: xmlAttrPtr) -> [Node] {
    
    var attributeArray = [Node]()
    
    for attribute in XmlAttrList(head: attributes) {
        
        var attributeDictionary = Node()
            
        if let attributeName = String.fromCString(UnsafePointer<CChar>(attribute.memory.name)) {
                
            attributeDictionary.updateValue(attributeName, forKey: NDHppleNodeKey.AttributeName.rawValue)
        }
            
        if attribute.memory.children != nil,
           let childDictionary = createNode(attribute.memory.children, parentNode: &attributeDictionary, parentContent: true) {
            
                attributeDictionary.updateValue(childDictionary, forKey: NDHppleNodeKey.AttributeContent.rawValue)
        }
            
        if !attributeDictionary.isEmpty {
                
            attributeArray.append(attributeDictionary)
        }
    }
        
    return attributeArray
}

private func createNode(currentNode: xmlNodePtr, inout parentNode: Node, parentContent: Bool) -> Node? {
    
    var resultForNode = Node(minimumCapacity: 8)
    
    if let name = String.fromCString(UnsafePointer<CChar>(currentNode.memory.name)) {
        
        resultForNode.updateValue(name, forKey: NDHppleNodeKey.Name.rawValue)
    }
    
    if let content = String.fromCString(UnsafePointer<CChar>(currentNode.memory.content)) {

        let t = resultForNode[NDHppleNodeKey.Name.rawValue] as? String == "text"
        switch (t, parentContent) {
            
        case (true, true):
            parentNode.updateValue(content, forKey: NDHppleNodeKey.Content.rawValue)
            return nil
        case (true, false):
            resultForNode.updateValue(content, forKey: NDHppleNodeKey.Content.rawValue)
            return resultForNode
        default:
            resultForNode.updateValue(content, forKey: NDHppleNodeKey.Content.rawValue)
        }
    }
    
    let attributes = currentNode.memory.properties
    let attributeArray = createAttributes(attributes)
    
    if !attributeArray.isEmpty {
            
        resultForNode.updateValue(attributeArray, forKey: NDHppleNodeKey.AttributeArray.rawValue)
    }
    
    let children = currentNode.memory.children
    let childArray = XmlNodeList(head: children).flatMap { createNode($0, parentNode: &resultForNode, parentContent: false) }
    
    if childArray.count > 0 {
        
        resultForNode.updateValue(childArray, forKey: NDHppleNodeKey.Children.rawValue)
    }
    
    let buffer = xmlBufferCreate()
    xmlNodeDump(buffer, currentNode.memory.doc, currentNode, 0, 0)
    if let content = String.fromCString(UnsafePointer<CChar>(buffer.memory.content)) {
        
        resultForNode.updateValue(content, forKey: "raw")
    }
    defer { xmlBufferFree(buffer) }
    
    return resultForNode
}

enum QueryError : ErrorType {
    
    case Empty
    case Parse
    case Create
}

func PerformXPathQuery(data: NSString, query: String, isXML: Bool) throws -> [Node] {
    
    if data.length == 0 {
        
        throw QueryError.Empty
    }
    
    let bytes = data.cStringUsingEncoding(NSUTF8StringEncoding)
    let length = CInt(data.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
    let encoding = CFStringGetCStringPtr(nil, 0)
    // isXML ? XML_PARSE_RECOVER : (HTML_PARSE_NOERROR | HTML_PARSE_NOWARNING)
    let options: CInt = isXML ? 1 : (1 << 5 | 1 << 6)
    
    let function = isXML ? xmlReadMemory : htmlReadMemory
    let doc = function(bytes, length, "", encoding, options)
    guard doc != nil else { throw QueryError.Parse }
    defer { xmlFreeDoc(doc) }
    
    let xPathCtx = xmlXPathNewContext(doc)
    guard xPathCtx != nil else { throw QueryError.Parse }
    defer { xmlXPathFreeContext(xPathCtx) }
    
    let queryBytes = query.cStringUsingEncoding(NSUTF8StringEncoding)!
    let ptr = UnsafePointer<CUnsignedChar>(queryBytes)

    let xPathObj = xmlXPathEvalExpression(ptr, xPathCtx)
    guard xPathObj != nil else { throw QueryError.Parse }
    defer { xmlXPathFreeObject(xPathObj) }
    
    let nodes = xPathObj.memory.nodesetval
    guard nodes != nil else { throw QueryError.Parse }
    
    var resultNodes = [Node]()
    let nodesArray = UnsafeBufferPointer(start: nodes.memory.nodeTab, count: Int(nodes.memory.nodeNr))
    var dummy = Node()
    
    for rawNode in nodesArray {

        if let node = createNode(rawNode, parentNode: &dummy, parentContent: false) {

            resultNodes.append(node)
        } else {
            
            throw QueryError.Create
        }
    }
                    
    return resultNodes
}

func PerformXMLXPathQuery(data: String, query: String) throws -> [Node] {

    return try PerformXPathQuery(data, query: query, isXML: true)
}

func PerformHTMLXPathQuery(data: String, query: String) throws -> [Node] {

    return try PerformXPathQuery(data, query: query, isXML: false)
}
