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

class NDHppleElement {
    
    let node: Node
    weak var parent: NDHppleElement?
    
    convenience init(node: Node) {
        
        self.init(node: node, parent: nil)
    }
    
    init(node: Node, parent: NDHppleElement?) {
        
        self.node = node
        self.parent = parent
    }

    subscript(key: String) -> AnyObject? {

        return self.node[key]
    }

    var description: String { return self.node.description }
    var raw: String? { return self["raw"] as? String }
    var content: String? { return self[NDHppleNodeKey.Content.rawValue] as? String }
    var tagName: String? { return self[NDHppleNodeKey.Name.rawValue] as? String }
    
    var attributes: [String:AnyObject] {
    
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
    
    var hasChildren: Bool { return self[NDHppleNodeKey.Children.rawValue] != nil }

    var children: [NDHppleElement]? {
        
        let children = self[NDHppleNodeKey.Children.rawValue] as? [Node]
        return children?.map{ NDHppleElement(node: $0, parent: self) }
    }
    
    var firstChild: NDHppleElement? { return self.children?[0] }
    
    func childrenWithTagName(tagName: String) -> [NDHppleElement]? {
        
        return self.children?.filter{ $0.tagName == tagName }
    }
    
    func firstChildWithTagName(tagName: String) -> NDHppleElement? {
        
        return self.childrenWithTagName(tagName)?[0]
    }
    
    func childrenWithClassName(className: String) -> [NDHppleElement]? {
        
        return self.children?.filter{ $0["class"] as? String == className }
    }
    
    func firstChildWithClassName(className: String) -> NDHppleElement? {
        
        return self.childrenWithClassName(className)?[0]
    }
}

extension NDHppleElement {
    
    var isTextNode: Bool { return self.tagName == "text" && self.content != nil }
    var firstTextChild: NDHppleElement? { return self.firstChildWithTagName("text") }
    var text: String? { return self.firstTextChild?.content }
}