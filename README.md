# DESCRIPTION

NDHpple is a simple Swift wrapper on the XMLPathQuery library based on [Hpple](http://github.com/topfunky/hpple).

[![Actions Status](https://github.com/nacho4d/NDHpple/workflows/Swift/badge.svg)](https://github.com/nacho4d/NDHpple/actions)
[![codecov.io](https://codecov.io/github/nacho4d/NDHpple/coverage.svg?branch=master)](https://codecov.io/github/nacho4d/NDHpple?branch=master)

# CREDITS

NDHpple was created by Nicolai Davidsson, based on [Hpple](http://github.com/topfunky/hpple) by Geoffrey Grosenbach, [Topfunky Corporation](http://topfunky.com).

# INSTALLATION

Use swift package manager with url of this repository and then select a version. Old swift versions used to require to link libxml library but this problem has been fixed. No extra steps required.

# USAGE

See [Tests/NDHppleTests/NDHppleTests.swift](http://github.com/nacho4d/NDHpple/tree/master/Tests/NDHppleTests/NDHppleTests.swift) for more detailed samples.

```swift
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
let parser = NDHpple(htmlData: html)

let pNodes = parser.search(withQuery: "//p")
print(pNodes[0].text) // "My first paragraph."
print(pNodes[1].text) // "My last paragraph."

let pNode = parser.peekAtSearch(withQuery: "//p[1]")
print(pNode?.text ?? "") // "My first paragraph."
```
