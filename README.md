# DESCRIPTION

NDHpple is a Swift wrapper on the XMLPathQuery library based on [Hpple](http://github.com/topfunky/hpple).

# CREDITS

NDHpple was created by Nicolai Davidsson, based on [Hpple](http://github.com/topfunky/hpple) by Geoffrey Grosenbach, [Topfunky Corporation](http://topfunky.com).

# INSTALLATION

Build the package with the most recent Swift 2.2 Snapshot (as of January 28th) with this command:

<pre>
swift build -Xcc -I/usr/include/libxml2 -c release
</pre>

This will build NDHpple as module. You can also pass this URL (http://github.com/ndavon/NDHpple) as dependency in another package but you'll still have to pass the include path as compiler flag.

# USAGE

See [Example/main.swift](http://github.com/ndavon/NDHpple/tree/master/Sources/Example/main.swift) for a more detailed sample.

<pre>
import NDHpple

let html = try! String(contentsOfURL: NSURL(string: url)!)
let parser = NDHpple(HTMLData: html)

let result = parser.searchWithXPathQuery(query)

for node in result {

    print(node)
}
</pre>

Please note that some slight modifications were made that will probably break your existing implementation. 

# TODO

* replace C-style for loop in XPathQuery.swift with a SequenceType object