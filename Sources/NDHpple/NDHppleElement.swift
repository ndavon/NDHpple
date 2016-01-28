//
//  NDHppleElement.swift
//  NDHpple
//
//  Created by Nicolai on 24/06/14.
//  Copyright (c) 2014 Nicolai Davidsson. All rights reserved.
//

import Foundation

enum NDHppleNodeKey: String {

    case Content            = "nodeContent"
    case Name               = "nodeName"
    case Children           = "nodeChildArray"
    case AttributeArray     = "nodeAttributeArray"
    case AttributeContent   = "attributeContent"
    case AttributeName      = "attributeName"
}

typealias Node = [String:AnyObject]

public class NDHppleElement {
    
    private let node: Node
    private weak var parent: NDHppleElement?
    
    convenience init(node: Node) {
        
        self.init(node: node, parent: nil)
    }
    
    init(node: Node, parent: NDHppleElement?) {
        
        self.node = node
        self.parent = parent
    }

    public subscript(key: String) -> AnyObject? {

        return self.node[key]
    }

    public var description: String { return self.node.description }
    public var raw: String? { return self["raw"] as? String }
    public var content: String? { return self[NDHppleNodeKey.Content.rawValue] as? String }
    public var tagName: String? { return self[NDHppleNodeKey.Name.rawValue] as? String }
    
    public var attributes: [String:AnyObject] {
    
        var translatedAttribtues = [String:AnyObject]()
        for attributeDict in self[NDHppleNodeKey.AttributeArray.rawValue] as! [[String:AnyObject]] {
            
            if  let value = attributeDict[NDHppleNodeKey.Content.rawValue],
                let key = attributeDict[NDHppleNodeKey.AttributeName.rawValue] as? String {
                    
                translatedAttribtues.updateValue(value, forKey: key)
            }
        }
            
        return translatedAttribtues
    }
}

extension NDHppleElement {
    
    public var hasChildren: Bool { return self[NDHppleNodeKey.Children.rawValue] != nil }

    public var children: [NDHppleElement]? {
        
        let children = self[NDHppleNodeKey.Children.rawValue] as? [Node]
        return children?.map{ NDHppleElement(node: $0, parent: self) }
    }
    
    public var firstChild: NDHppleElement? { return self.children?[0] }
    
    public func childrenWithTagName(tagName: String) -> [NDHppleElement]? {
        
        return self.children?.filter{ $0.tagName == tagName }
    }
    
    public func firstChildWithTagName(tagName: String) -> NDHppleElement? {
        
        return self.childrenWithTagName(tagName)?[0]
    }
    
    public func childrenWithClassName(className: String) -> [NDHppleElement]? {
        
        return self.children?.filter{ $0["class"] as? String == className }
    }
    
    public func firstChildWithClassName(className: String) -> NDHppleElement? {
        
        return self.childrenWithClassName(className)?[0]
    }
}

extension NDHppleElement {
    
    public var isTextNode: Bool { return self.tagName == "text" && self.content != nil }
    public var firstTextChild: NDHppleElement? { return self.firstChildWithTagName("text") }
    public var text: String? { return self.firstTextChild?.content }
}