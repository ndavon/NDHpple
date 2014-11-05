# DESCRIPTION

NDHpple is a Swift wrapper on the XMLPathQuery library based on [Hpple](http://github.com/topfunky/hpple).

# CREDITS

NDHpple was created by Nicolai Davidsson, based on [Hpple](http://github.com/topfunky/hpple) by Geoffrey Grosenbach, [Topfunky Corporation](http://topfunky.com).

# INSTALLATION

* Drag the NDHpple files to your project
* add the following lines to your project's Bridging Header:

<pre>
#import &lt;libxml/tree.h>
#import &lt;libxml/parser.h>
#import &lt;libxml/HTMLparser.h>
#import &lt;libxml/xpath.h>
#import &lt;libxml/xpathInternals.h>
</pre>

# USAGE

See AppDelegate.swift for a more detailed sample.

<pre>
let html = NSString(data: data, encoding: NSUTF8StringEncoding)
let parser = NDHpple(HTMLData: html!)
let result = parser.searchWithXPathQuery(query)!

for node in result {
                
    println(node)
}
</pre>

# TODO

* fix hacky code with further Swift versions
* more error catching
