
import NDHpple
import Foundation

let url = CommandLine.argc == 2 ? CommandLine.arguments[1] : "https://www.reddit.com/r/swift"
guard let html = try? String(contentsOf: URL(string: url)!) else {
    print("No valid URL / HTML!")
    exit(1)
}

let parser = NDHpple(HTMLData: html)
let xpath = "//*[@id='siteTable']/div/div[2]/p[@class='title']/a"
let titleNodes = parser.searchWithXPathQuery(query: xpath)

titleNodes.forEach {
    print($0.firstChild?.content)
}
