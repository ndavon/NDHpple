//
//  NDHppleElement.swift
//  NDHpple
//
//  Created by Nicolai on 24/06/14.
//  Copyright (c) 2014 Nicolai Davidsson. All rights reserved.
//

import Foundation

enum NDHppleNodeKey: String {

    case Content = "nodeContent"
    case Name = "nodeName"
    case Children = "nodeChildArray"
    case AttributeArray = "nodeAttributeArray"
    case AttributeContent = "attributeContent"
    case AttributeName = "attributeName"
}

class NDHppleElement {
    
    typealias Node = Dictionary<String, AnyObject>
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

    var description: String {

        return self.node.description
    }
    
    var hasChildren: Bool {
    
        return self[NDHppleNodeKey.Children.toRaw()] != nil
    }
    
    var isTextNode: Bool {
    
        return self.tagName? == "text" && self.content
    }

    var raw: String? {
    
        return self["raw"] as? String
    }
    
    var content: String? {
    
        return self[NDHppleNodeKey.Content.toRaw()] as? String
    }
    
    var tagName: String? {
    
        return self[NDHppleNodeKey.Name.toRaw()] as? String
    }
    
    var children: Array<NDHppleElement>? {
    
        let children = self[NDHppleNodeKey.Children.toRaw()] as? Array<Dictionary<String, AnyObject>>
        return children?.map{ NDHppleElement(node: $0, parent: self) }
    }
    
    var firstChild: NDHppleElement? {
    
        return self.children?[0]
    }
    
    func childrenWithTagName(tagName: String) -> Array<NDHppleElement>? {
        
        return self.children?.filter{ $0.tagName == tagName }
    }
    
    func firstChildWithTagName(tagName: String) -> NDHppleElement? {
        
        return self.childrenWithTagName(tagName)?[0]
    }
    
    func childrenWithClassName(className: String) -> Array<NDHppleElement>? {
        
        return self.children?.filter{ $0["class"] as? String == className }
    }
    
    func firstChildWithClassName(className: String) -> NDHppleElement? {
        
        return self.childrenWithClassName(className)?[0]
    }
    
    var firstTextChild: NDHppleElement? {
    
        return self.firstChildWithTagName("text")
    }
	
	var text: String? {
	
		return self.firstTextChild?.content
	}
	
	var attributes: Dictionary<String, AnyObject> {
	
		var translatedAttribtues = Dictionary<String, AnyObject>()
		if let attrs : AnyObject=self[NDHppleNodeKey.AttributeArray.toRaw()]
		{
			for attributeDict in attrs as Array<Dictionary<String, AnyObject>> {
				
				if attributeDict[NDHppleNodeKey.Content.toRaw()] && attributeDict[NDHppleNodeKey.AttributeName.toRaw()] {
					
					let value : AnyObject = attributeDict[NDHppleNodeKey.Content.toRaw()]!
					let key : AnyObject = attributeDict[NDHppleNodeKey.AttributeName.toRaw()]!
					
					translatedAttribtues.updateValue(value, forKey: key as String)
				}
			}
		}
		return translatedAttribtues
    }
}