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

private func createAttributes(attributes: xmlAttrPtr) -> [Node] {
    
    var attributeArray = [Node]()
    
    for attribute in XmlAttrList(head: attributes) {
        
        var attributeDictionary = Node()
            
        let attributeName = String(cString: attribute.pointee.name)
                
        attributeDictionary.updateValue(attributeName as AnyObject, forKey: NDHppleNodeKey.AttributeName)
            
        if attribute.pointee.children != nil,
           let childDictionary = createNode(currentNode: attribute.pointee.children, parentNode: &attributeDictionary, parentContent: true) {
            
                attributeDictionary.updateValue(childDictionary as AnyObject, forKey: NDHppleNodeKey.AttributeContent)
        }
            
        if !attributeDictionary.isEmpty {
                
            attributeArray.append(attributeDictionary)
        }
    }
        
    return attributeArray
}

private func createNode(currentNode: xmlNodePtr!, parentNode: inout Node, parentContent: Bool) -> Node? {
    
    var resultForNode = Node(minimumCapacity: 8)

    let name = String(cString: currentNode.pointee.name)
    resultForNode.updateValue(name as AnyObject, forKey: NDHppleNodeKey.Name)
    
    if currentNode.pointee.content != nil {
        
        let content = String(cString: currentNode.pointee.content)
        let isText = resultForNode[NDHppleNodeKey.Name] as? String == "text"

        switch (isText, parentContent) {        
        case (true, true):
            parentNode.updateValue(content as AnyObject, forKey: NDHppleNodeKey.Content)
            return nil
        case (true, false):
            resultForNode.updateValue(content as AnyObject, forKey: NDHppleNodeKey.Content)
            return resultForNode
        default:
            resultForNode.updateValue(content as AnyObject, forKey: NDHppleNodeKey.Content)
            break
        }
    }
    
    let attributes = currentNode.pointee.properties!
    let attributeArray = createAttributes(attributes: attributes)
    
    if !attributeArray.isEmpty {
            
        resultForNode.updateValue(attributeArray as AnyObject, forKey: NDHppleNodeKey.AttributeArray)
    }
    
    let children = currentNode.pointee.children
    let childArray = XmlNodeList(head: children).flatMap { createNode(currentNode: $0, parentNode: &resultForNode, parentContent: false) }
    
    if !childArray.isEmpty {
        
        resultForNode.updateValue(childArray as AnyObject, forKey: NDHppleNodeKey.Children)
    }
    
    let buffer = xmlBufferCreate()
    xmlNodeDump(buffer, currentNode.pointee.doc, currentNode, 0, 0)
    
    let rawContent = String(cString: buffer!.pointee.content)
    resultForNode.updateValue(rawContent as AnyObject, forKey: "raw")
    
    defer { xmlBufferFree(buffer) }

    return resultForNode
}

enum QueryError : Error {
    
    case Empty
    case Parse
    case Create
}

func PerformXPathQuery(data: String, query: String, isXML: Bool) throws -> [Node] {
    
    if data.isEmpty {
        
        throw QueryError.Empty
    }
    
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
    
    var resultNodes = [Node]()
    let nodesArray = UnsafeBufferPointer(start: nodes.pointee.nodeTab, count: Int(nodes.pointee.nodeNr))
    var dummy = Node()

    for rawNode in nodesArray {

        if let node = createNode(currentNode: rawNode, parentNode: &dummy, parentContent: false) {

            resultNodes.append(node)
        } else {
            
            throw QueryError.Create
        }
    }

    return resultNodes
}

func PerformXMLXPathQuery(data: String, query: String) throws -> [Node] {

    return try PerformXPathQuery(data: data, query: query, isXML: true)
}

func PerformHTMLXPathQuery(data: String, query: String) throws -> [Node] {

    return try PerformXPathQuery(data: data, query: query, isXML: false)
}
