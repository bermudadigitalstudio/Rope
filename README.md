# Rope

Rope provides a convenient, easy-to-use, type-safe access to `PostgreSQL` for server-side Swift 3.   
It uses the thread-safe, highly performant `libpq` library.

[![Language Swift 3](https://img.shields.io/badge/Language-Swift%203-orange.svg)](https://swift.org) ![Platforms](https://img.shields.io/badge/Platforms-Docker%20%7C%20Linux%20%7C%20macOS-blue.svg) [![CircleCI](https://circleci.com/gh/bermudadigitalstudio/Rope/tree/master.svg?style=svg)](https://circleci.com/gh/bermudadigitalstudio/Rope)

<br>
## How to Use

Rope is so simple, you just need to learn 3 methods: 
- `Rope()` to create a connection
- `query()` to run a query
- `rows()` to turn a query result into a two-dimensional array


```swift

// credential struct as helper
let creds = RopeCredentials(host: "localhost", port: 5432,  dbName: "mydb", 
                            user: "foo", password: "bar")

// establish connection using the struct
let conn = try? Rope.connect(credentials: creds)

// run query
let res = try! conn!.query("SELECT id, my_text FROM my_table")

// turn result into 2-dimensional array
if let rows = res?.rows() {
    for let row in rows {
        let id = row["id"] as? Int
        let myText = row["my_text"] as? String
    }
}
```

<br>
## Postgres Types to Swift Conversion

* `serial`, `bigserial`, `smallint`, `integer`, and `bigint` are returned as `Int`
* `real` and `double` precision are returned as `Float`
* `char`, `varchar`, and `text` are returned as `String`
* the `boolean` type is returned as `Bool`
* `date`, `timestamp` are returned as `Date`


<br>
## Running Unit Tests

Rope’s unit tests require a running Postgres 9.x database and you can either provide the database credentials via environment variables, or via CLI arguments or use the built-in default values.

#### Using Defaults

All tests run without any additional configuration if your database has the following setup:

* `host: "localhost"`
* `port: 5432`
* `database name: "rope"`
* `user: "postgres"`
* `password: ""`

#### Using Environment Variables

You can easily provide the database credentials via environment variables.
Please see the `RopeTestCredentials.swift` file. Please also see the unit tests about how to use RopeCredentials to establish a connection.

For environment variables **in Xcode**, please enter the following info via `Edit Scheme` > `Arguements` using `Environment Variables` or `Arguments Passend On Launch`:

* `DATABASE_HOST`
* `DATABASE_PORT`
* `DATABASE_NAME`
* `DATABASE_USER`
* `DATABASE_PASSWORD`


#### Using CLI Arguments

```
swift build DATABASE_HOST=mydatabase_host DATABASE_PORT=mydatabase_port DATABASE_NAME=mydatabase_dbname DATABASE_USER=mydatabase_user DATABASE_PASSWORD=mydatabase_very_secure_password
```

To run tests simple type `swift test` in your CLI.

<br>
## Source Code Format

The source code is formatted using [SwiftFormat] (https://github.com/nicklockwood/SwiftFormat).
Before any commit, be sure to perform:

`> swiftformat --disable unusedArguments .`

<br>
## Contributing

Titan is maintained by Thomas Catterall ([@swizzlr](https://github.com/swizzlr)), Johannes Erhardt ([@johanneserhardt](https://github.com/johanneserhardt)), Sebastian Kreutzberger ([@skreutzberger](https://github.com/skreutzberger)) and Gabriel Peart ([@gabrielPeart](https://github.com/gabrielPeart)).

Contributions are more than welcomed. You can either work on existing Github issues or discuss with us your ideas in a new Github issue. Thanks 🙌

<br><br>
## License

Rope is released under the [Apache 2.0 License](https://github.com/bermudadigitalstudio/rope/blob/master/LICENSE.txt).
