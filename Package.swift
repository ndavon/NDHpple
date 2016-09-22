import PackageDescription

let package = Package(
    name: "NDHpple",
    targets: [
        Target(
            name: "Example",
            dependencies: [ .Target(name: "NDHpple") ]),
        Target(
            name: "NDHpple")
    ],
    dependencies: [ .Package(url: "http://github.com/ndavon/Clibxml2", majorVersion: 1) ]
)
