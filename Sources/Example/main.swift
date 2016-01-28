
import NDHpple
import Foundation

let url = Process.argc == 2 ? Process.arguments[1] : "https://www.reddit.com/r/swift"
guard let html = try? String(contentsOfURL: NSURL(string: url)!) else {
    print("No valid URL / HTML!")
    exit(1)
}

let parser = NDHpple(HTMLData: html)
let xpath = "//*[@id='siteTable']/div/div[2]/p[@class='title']/a"

let titleNodes = parser.searchWithXPathQuery(xpath)

for node in titleNodes {

    print(node.firstChild?.content!)
}
