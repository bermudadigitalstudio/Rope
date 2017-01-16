# Rope

Rope provides basic access to `PostgreSQL` in Swift around the `libpq` library.

## Example

```swift

// fill credential struct
let creds = RopeCredentials()
creds.host = "localhost"
creds.port = 5432
creds.user = "johannes"
creds.password = "very secure"
creds.dbName = "mydatabase"

// establish connection   
let conn = try? Rope.connect(credentials: creds)
guard let db = conn else { return }

// run query
let res = try! db.query("SELECT version();")

// LATER: show result data
...
```

## Supported Value Types

* `smallint`, `integer`, and `bigint` are returned as `Int`
* `real` and `double` precision are returned as `Float`
* `char`, `varchar`, and `text` are returned as `String`
* the `boolean` type is returned as `Bool`
* `date`, `timestampt` are returned as `Date`

## Testing & Database Credentials

Rope’s unit tests require a running Postgres 9.x database.

Connection credentials are securely stored in `Tests/RopeTests/Secrets.swift` outside of Git. To get started, please create a copy of `Tests/RopeTests/SecretsExample.swift`, rename it to `Secrets.swift` and follow the further instructions from `SecretsExample.swift`.

Please also see the unit tests about how to use `RopeCredentials` to establish a connection.

To run tests simple type `swift test` in your CLI.


## Contributing

Titan is maintained by Thomas Catterall ([@swizzlr](https://github.com/swizzlr)), Johannes Erhardt ([@johanneserhardt](https://github.com/johanneserhardt)), Sebastian Kreutzberger ([@skreutzberger](https://github.com/skreutzberger)) and Gabriel Peart ([@gabrielPeart](https://github.com/gabrielPeart)).

Contributions are more than welcomed. You can either work on existing Github issues or discuss with us your ideas in a new Github issue. Thanks 🙌

## License

Rope is released under the [Apache 2.0 License](https://github.com/bermudadigitalstudio/rope/blob/master/LICENSE.txt).
