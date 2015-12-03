//
//  XPathQuery.swift
//  NDHpple
//
//  Created by Nicolai on 24/06/14.
//  Copyright (c) 2014 Nicolai Davidsson. All rights reserved.
//

import Foundation

private func createAttributes(attributes: xmlAttrPtr) -> [Node] {
    
    var attributeArray = [Node]()
    
    for var attribute = attributes; attribute != nil; attribute = attribute.memory.next {
            
        var attributeDictionary = Node()
            
        if let attributeName = String.fromCString(UnsafePointer<CChar>(attribute.memory.name)) {
                
            attributeDictionary.updateValue(attributeName, forKey: NDHppleNodeKey.AttributeName.rawValue)
        }
            
        if attribute.memory.children != nil,
           let childDictionary = createNode(attribute.memory.children, parentNode: &attributeDictionary, parentContent: true) {
            
                attributeDictionary.updateValue(childDictionary, forKey: NDHppleNodeKey.AttributeContent.rawValue)
        }
            
        if attributeDictionary.count > 0 {
                
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
    
    if attributeArray.count > 0 {
            
        resultForNode.updateValue(attributeArray, forKey: NDHppleNodeKey.AttributeArray.rawValue)
    }
    
    let children = currentNode.memory.children
    var childArray = [Node]()
    
    for var child = children; child != nil; child = child.memory.next {
        
        if let childDictionary = createNode(child, parentNode: &resultForNode, parentContent: false) {
            childArray.append(childDictionary)
        }
    }
    
    if childArray.count > 0 {
        
        resultForNode.updateValue(childArray, forKey: NDHppleNodeKey.Children.rawValue)
    }
    
    let buffer = xmlBufferCreate()
    xmlNodeDump(buffer, currentNode.memory.doc, currentNode, 0, 0)
    if let content = String.fromCString(UnsafePointer<CChar>(buffer.memory.content)) {
        
        resultForNode.updateValue(content, forKey: "raw")
    }
    xmlBufferFree(buffer)
    
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