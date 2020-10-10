import Foundation
import NDHpple
import XCTest

final class NDHppleTests: XCTestCase {

    func testBasicHtml() throws {
        let html = """
            <!DOCTYPE html>
            <html>
                <body>
                    <h1>My First Heading</h1>
                    <div>
                        <p>My first paragraph.</p>
                        <p id='segundo'>My second paragraph.</p>
                        <p class='hidden'>My third paragraph.</p>
                        <p>My fourth paragraph.</p>
                    </div>
                    <div>
                        <p>A paragraph.</p>
                        <p id='other'>Other paragraph.</p>
                        <p class='warning'>Warning paragraph.</p>
                        <p>Last paragraph.</p>
                    </div>
                </body>
            </html>
            """

        let parser = NDHpple(htmlData: html)

        XCTContext.runActivity(named: "Get 'html' node") { _ in
            let htmlNodes = parser.search(withQuery: "/html")
            XCTAssertEqual(htmlNodes.count, 1)
        }

        XCTContext.runActivity(named: "Get all 'p' nodes") { _ in
            let pNodes = parser.search(withQuery: "//p")
            XCTAssertEqual(pNodes.count, 8)
        }

        XCTContext.runActivity(named: "Get all 'p' nodes that have attribute 'class' with value 'hidden'") { _ in
            let hiddenPNodes = parser.search(withQuery: "//p[@class='hidden']")
            XCTAssertEqual(hiddenPNodes.count, 1)
            XCTAssertEqual(hiddenPNodes[0].text, "My third paragraph.")
        }

        XCTContext.runActivity(named: "Get last 'p' node inside the first div") { _ in
            let div1lastPNodes = parser.search(withQuery: "//div[1]/p[last()]")
            XCTAssertEqual(div1lastPNodes.count, 1)
            XCTAssertEqual(div1lastPNodes[0].text, "My fourth paragraph.")
        }

        XCTContext.runActivity(named: "Get last 'p' node inside the second div") { _ in
            let div2lastPNodes = parser.search(withQuery: "//div[2]/p[last()]")
            XCTAssertEqual(div2lastPNodes.count, 1)
            XCTAssertEqual(div2lastPNodes[0].text, "Last paragraph.")
        }

        try XCTContext.runActivity(named: "Search first div with xpath. Then search in results the element with attributed class='hidden'")
        { _ in
            let nodesInDiv = try XCTUnwrap(parser.peekAtSearch(withQuery: "//div[1]"))
            XCTAssertTrue(nodesInDiv.hasChildren)

            // For educational purposes search using childrenForClass.
            // Xpath query can solve this problem in an easier way. See next activity.
            let hiddenElements = nodesInDiv.children(forClass: "hidden")
            XCTAssertEqual(hiddenElements.count, 1)
            XCTAssertEqual(hiddenElements.first?.children.first?.content, "My third paragraph.")

            // Since it is the first element in the results, firstChild(forClass:) also works
            let hiddentElement = try XCTUnwrap(nodesInDiv.firstChild(forClass: "hidden"))
            XCTAssertEqual(hiddentElement.children.first?.content, "My third paragraph.")

            // Get element and subelement entire string
            XCTAssertEqual(hiddentElement.raw, "<p class=\"hidden\">My third paragraph.</p>")
            XCTAssertFalse(hiddentElement.isText)  // because it is a p element
            XCTAssertTrue(hiddentElement.children.first?.isText == true)
        }

        try XCTContext.runActivity(named: "Search first div then p with class hidden with xpath.") { _ in
            let hiddenP = try XCTUnwrap(parser.peekAtSearch(withQuery: "//div[1]/p[@class='hidden']"))
            XCTAssertEqual(hiddenP.raw, "<p class=\"hidden\">My third paragraph.</p>")
            XCTAssertFalse(hiddenP.isText)  // because it is a p element
            XCTAssertTrue(hiddenP.children.first?.isText == true)
        }
    }

    func testBasicXml() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <bookstore>
                <book>
                    <title lang="en">Harry Potter</title>
                    <price>29.99</price>
                </book>
                <book>
                    <title lang="en">Learning XML</title>
                    <price>39.95</price>
                </book>
                <book class="myclass">
                    <title lang="en">Learning MVC in 2020</title>
                    <price>5.25</price>
                </book>
            </bookstore>
            """

        let parser = NDHpple(xmlData: xml)

        // Get "html" node
        let htmlNodes = parser.search(withQuery: "/root")
        XCTAssertEqual(htmlNodes.count, 0)

        // Selects the first two "book" elements that are children of the bookstore element
        let twoBookNodes = parser.search(withQuery: "/bookstore/book[position()<3]")
        XCTAssertEqual(twoBookNodes.count, 2)

        // Selects all the book elements of the bookstore element that have a price element with a value greater than 35.00
        let costyBookNodes = parser.search(withQuery: "/bookstore/book[price>35.00]")
        XCTAssertEqual(costyBookNodes.count, 1)

        // Filter some children from previous selection
        XCTAssertEqual(costyBookNodes[0].children(forName: "title")[0].text, "Learning XML")
        XCTAssertEqual(costyBookNodes[0].children(forName: "price")[0].text, "39.95")

        // Select title of book where price is more than 35
        let costyBookTitleNodes = parser.search(withQuery: "/bookstore/book[price>35.00]/title")
        XCTAssertEqual(costyBookTitleNodes.count, 1)
        XCTAssertEqual(costyBookTitleNodes[0].text, "Learning XML")

        // Instead of getting a list of nodes we can get the first element directly
        let costyBookTitleNode = parser.peekAtSearch(withQuery: "/bookstore/book[price>35.00]/title")
        XCTAssertNotNil(costyBookTitleNode)
        XCTAssertEqual(costyBookTitleNode?.text, "Learning XML")
    }

    func testWrongQuery() throws {
        let parser = NDHpple(xmlData: "")
        let nodes = parser.search(withQuery: "/root")
        XCTAssertEqual(nodes.count, 0)
    }

    static var allTests = [
        ("testBasicHtml", testBasicHtml),
        ("testBasicXml", testBasicXml),
        ("testWrongQuery", testWrongQuery),
    ]
}
