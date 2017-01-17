# Rope

Rope provides basic access to `PostgreSQL` in Swift around the `libpq` library.

## Example

```swift

// fill credential struct
let creds = RopeCredentials(host: "localhost", port: 5432, dbName: "mydatabase", user: "johannes", password: "very_secure_password")

// establish connection   
let conn = try? Rope.connect(credentials: creds)
guard let db = conn else { return }

// run query
let res = try! db.query("SELECT version();")

// LATER: show result data
...
```

## Postgres Types to Swift Conversion

* `serial`, `bigserial`, `smallint`, `integer`, and `bigint` are returned as `Int`
* `real` and `double` precision are returned as `Float`
* `char`, `varchar`, and `text` are returned as `String`
* the `boolean` type is returned as `Bool`
* `date`, `timestamp` are returned as `Date`

## Testing & Database Credentials

Rope’s unit tests require a running Postgres 9.x database.

You can easily provide the database credentials via environment variables.
Please see the `RopeTestCredentials.swift` file.

#### Using XCode

Please enter the following info via `Edit Scheme` > `Arguements` using `Environment Variables` or `Arguments Passend On Launch`:

* `DATABASE_HOST`
* `DATABASE_PORT`
* `DATABASE_NAME`
* `DATABASE_USER`
* `DATABASE_PASSWORD`

#### Using CLI

```
swift build DATABASE_HOST=host DATABASE_PORT=port DATABASE_NAME=dbname DATABASE_USER=user DATABASE_PASSWORD=pass

swift test
```

Please also see the unit tests about how to use `RopeCredentials` to establish a connection.

To run tests simple type `swift test` in your CLI.


## Contributing

Titan is maintained by Thomas Catterall ([@swizzlr](https://github.com/swizzlr)), Johannes Erhardt ([@johanneserhardt](https://github.com/johanneserhardt)), Sebastian Kreutzberger ([@skreutzberger](https://github.com/skreutzberger)) and Gabriel Peart ([@gabrielPeart](https://github.com/gabrielPeart)).

Contributions are more than welcomed. You can either work on existing Github issues or discuss with us your ideas in a new Github issue. Thanks 🙌

## License

Rope is released under the [Apache 2.0 License](https://github.com/bermudadigitalstudio/rope/blob/master/LICENSE.txt).
