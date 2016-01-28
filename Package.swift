import PackageDescription

let package = Package(
    name: "NDHpple",
    dependencies: [ .Package(url: "http://github.com/ndavon/Clibxml2", majorVersion: 1) ],
    targets: [
        Target(
            name: "Example",
            dependencies: [ .Target(name: "NDHpple") ]),
        Target(
            name: "NDHpple")
    ]
)
