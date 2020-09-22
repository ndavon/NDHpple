//
//  NDHppleElement.swift
//  NDHpple
//
//  Created by Nicolai on 24/06/14.
//  Copyright (c) 2014 Nicolai Davidsson. All rights reserved.
//

import Foundation

struct NDHppleNodeKey {
    static let Content      = "nodeContent"
    static let Name         = "nodeName"
    static let Children     = "nodeChildArray"
    static let Attributes   = "nodeAttributeArray"
    static let Raw          = "rawValue"
}

public typealias Node = [String:AnyObject]
public typealias Attributes = [String:Node]

public class NDHppleElement {
    
    private let node: Node
    public let children: [NDHppleElement]
    public let attributes: Attributes

    init(node: Node) {
        
        self.node = node
        self.children = (self.node[NDHppleNodeKey.Children] as? [Node] ?? []).map(NDHppleElement.init)
        self.attributes = self.node[NDHppleNodeKey.Attributes] as? Attributes ?? [:]
    }

    public subscript(key: String) -> AnyObject? {

        return self.node[key]
    }
}

extension NDHppleElement {
    
    public var raw: String? { return self[NDHppleNodeKey.Raw] as? String }
    public var content: String? { return self[NDHppleNodeKey.Content] as? String }
    public var name: String? { return self[NDHppleNodeKey.Name] as? String }
}

extension NDHppleElement {
    
    public var hasChildren: Bool { return !children.isEmpty }
    public var firstChild: NDHppleElement? { return children.first }
    
    public func children(forName name: String) -> [NDHppleElement] {
        
        return children.filter{ $0.name == name }
    }
    
    public func firstChild(forName name: String) -> NDHppleElement? {

        return children.first { return $0.name == name }
    }
    
    public func children(forClass class: String) -> [NDHppleElement] {
        
        return children.filter{ $0.attributes["class"]?[NDHppleNodeKey.Name] as? String == `class` }
    }
    
    public func firstChild(forClass class: String) -> NDHppleElement? {

        return children.first { return $0.attributes["class"]?[NDHppleNodeKey.Name] as? String == `class` }
    }
}

extension NDHppleElement {
    
    public var isText: Bool { return name == "text" && content != nil }
    public var firstTextChild: NDHppleElement? { return firstChild(forName: "text") }
    public var text: String? { return firstTextChild?.content }
}
