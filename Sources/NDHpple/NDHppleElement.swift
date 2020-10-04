//
//  NDHppleElement.swift
//  NDHpple
//
//  Created by Nicolai on 24/06/14.
//  Copyright (c) 2014 Nicolai Davidsson. All rights reserved.
//

import Foundation

public typealias Node = [String:Any]
public typealias Attributes = [String:Node]

public class NDHppleElement {

    struct NodeKey {
        /// nodeContent
        static let content      = "nodeContent"
        /// nodeName
        static let name         = "nodeName"
        /// nodeChildArray
        static let children     = "nodeChildArray"
        /// nodeAttributeArray
        static let attributes   = "nodeAttributeArray"
        /// rawValue
        static let raw          = "rawValue"
    }
    
    private let node: Node
    public let children: [NDHppleElement]
    public let attributes: Attributes

    init(node: Node) {
        
        self.node = node
        self.children = (self.node[NodeKey.children] as? [Node] ?? []).map(NDHppleElement.init)
        self.attributes = self.node[NodeKey.attributes] as? Attributes ?? [:]
    }

    public subscript(key: String) -> Any? {

        return self.node[key]
    }
}

extension NDHppleElement {
    
    public var raw: String? { return self[NodeKey.raw] as? String }
    public var content: String? { return self[NodeKey.content] as? String }
    public var name: String? { return self[NodeKey.name] as? String }
}

extension NDHppleElement {
    
    public var hasChildren: Bool { return !children.isEmpty }
    public var firstChild: NDHppleElement? { return children.first }

    /// Get all children filtered by tag name.
    ///
    /// Example: If self node is like:
    /// ```
    /// <node><elem>a</elem><elem class="warn">w</elem><li>c</li></node>
    /// ```
    /// rhen `node.children(forName: "elem")` will return array of 2 elements:
    /// ```
    /// <elem>a</elem><elem class="warn">w</elem>
    /// ```
    public func children(forName name: String) -> [NDHppleElement] {
        return children.filter{ $0.name == name }
    }

    /// Get first child filtered tag name.
    ///
    /// Example: If self node is like:
    /// ```
    /// <node><elem>a</elem><elem class="warn">w</elem><li>c</li></node>
    /// ```
    /// then `node.firstChild(forName: "elem")` will return node:
    /// ```
    /// <elem>a</elem>
    /// ```
    public func firstChild(forName name: String) -> NDHppleElement? {
        return children.first { return $0.name == name }
    }

    /// Get all nodes in children that have given parameter as class attribute.
    ///
    /// Example: If self node is like:
    /// ```
    /// <node><elem>a</elem><elem class="warn">w</elem><li>c</li></node>
    /// ```
    /// then `node.children(forClass: "warn")` will return array of 1 element:
    /// ```
    /// <elem class="warning">w</elem>
    /// ```
    public func children(forClass class: String) -> [NDHppleElement] {
        return children.filter { $0.attributes["class"]?[NodeKey.content] as? String == `class` }
    }

    /// Extract first node in children that has given parameter as class attribute.
    ///
    /// Example: If self node is like:
    /// ```
    /// <node><elem>a</elem><elem class="warning">w</elem><elem>c</elem></node>
    /// ```
    /// then `node.firstChild(forClass: "warning")` will return node:
    /// ```
    /// <elem class="warning">w</elem>
    /// ```
    public func firstChild(forClass class: String) -> NDHppleElement? {
        return children.first { $0.attributes["class"]?[NodeKey.content] as? String == `class` }
    }
}

extension NDHppleElement {
    
    public var isText: Bool { return name == "text" && content != nil }
    public var firstTextChild: NDHppleElement? { return firstChild(forName: "text") }
    public var text: String? { return firstTextChild?.content }
}

#if DEBUG
extension NDHppleElement: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "<NDHppleElement node: \(node.description), attributes: \(attributes.description), children: \(children.count)>"
    }
}
#endif
