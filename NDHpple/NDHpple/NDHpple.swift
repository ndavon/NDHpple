//
//  NDHpple.swift
//  NDHpple
//
//  Created by Nicolai on 24/06/14.
//  Copyright (c) 2014 Nicolai Davidsson. All rights reserved.
//

import Foundation
import UIKit

enum NDHppleError : ErrorType {
    
    case Empty
}

class NDHpple {
    
    let data: String
    let isXML: Bool
    
    init(data: String, isXML: Bool) {
        
        self.data = data
        self.isXML = isXML
    }
    
    convenience init(XMLData: String) {
        
        self.init(data: XMLData, isXML: true)
    }
    
    convenience init(HTMLData: String) {
        
        self.init(data: HTMLData, isXML: false)
    }

    func searchWithXPathQuery(query: String) -> [NDHppleElement]? {
        
        do {

            let function = isXML ? PerformXMLXPathQuery : PerformHTMLXPathQuery
            let nodes = try function(data, query: query)
            return nodes.map{ NDHppleElement(node: $0) }
        } catch _ {
            
            return nil
        }
    }
    
    func peekAtSearchWithXPathQuery(query: String) throws -> NDHppleElement {
        
        guard let results = searchWithXPathQuery(query) else { throw NDHppleError.Empty }
        return results[0]
    }
}