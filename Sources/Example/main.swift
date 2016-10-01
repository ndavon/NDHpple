import NDHpple
import Foundation

let url = CommandLine.argc == 2 ? CommandLine.arguments[1] : "https://www.reddit.com/r/swift"
guard let html = try? String(contentsOf: URL(string: url)!) else {
    print("No valid URL / HTML!")
    exit(1)
}

let parser = NDHpple(HTMLData: html)
let xpath = "//*[@id='siteTable']/div/div[2]/p[@class='title']/a"
let titleNodes = parser.search(withQuery: xpath)

titleNodes.flatMap { $0.text }.forEach { 
    print($0)
}
