# DESCRIPTION

NDHpple is a Swift wrapper on the XMLPathQuery library based on [Hpple](http://github.com/topfunky/hpple).

# CREDITS

NDHpple was created by Nicolai Davidsson, based on [Hpple](http://github.com/topfunky/hpple) by Geoffrey Grosenbach, [Topfunky Corporation](http://topfunky.com).

# INSTALLATION

Use swift package manager with url of this repository and then select a version. Old swift versions used to require to link libxml library but this problem has been fixed. No extra steps required.

# USAGE

See [Tests/NDHppleTests/NDHppleTests.swift](http://github.com/nacho4d/NDHpple/tree/master/Tests/NDHppleTests/NDHppleTests.swift) for more detailed samples.

```
import NDHpple

// read xml into a string
let html = """
    <!DOCTYPE html>
    <html>
        <body>
            <p>My first paragraph.</p>
            <p>My last paragraph.</p>
        </body>
    </html>
    """
// initialize parser
let parser = NDHpple(HTMLData: html)

let htmlNodes = parser.search(withQuery: "//p[1]")
let pNodes = parser.search(withQuery: "//p")
result.flatMap { $0.text }.forEach { 
        print($0)
}
```
