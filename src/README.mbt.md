# mizchi/tempfile

Temporary file and directory management for MoonBit. Similar to Rust's [tempfile](https://crates.io/crates/tempfile) crate.

## Features

- Create temporary files with automatic cleanup
- Create temporary directories with recursive cleanup
- Builder pattern for customization (prefix, suffix, temp directory)
- Native target support (uses `moonbitlang/async/fs`)

## Installation

Add to your `moon.mod.json`:

```json
{
  "deps": {
    "mizchi/tempfile": "0.1.0"
  }
}
```

## Usage

### Create a temporary file

```moonbit
///|
async fn example() {
  let tmp = @tempfile.tempfile()
  defer tmp.cleanup()
  tmp.file().write("Hello!")
  println(tmp.path()) // /tmp/.tmpXXXXXXXXXX
}
```

### Create a temporary directory

```moonbit
///|
async fn example_dir() {
  let tmpdir = @tempfile.tempdir()
  defer tmpdir.cleanup()

  // Create files inside
  @fs.write_file(tmpdir.path() + "/data.txt", b"content", create=0o644)
}
```

### Builder pattern

```moonbit
///|
async fn custom_tempfile() {
  let tmp = @tempfile.Builder::new()
    .prefix("myapp_")
    .suffix(".log")
    .temp_dir("/var/tmp")
    .create_temp_file()
  defer tmp.cleanup()
  println(tmp.path()) // /var/tmp/myapp_XXXXXXXXXX.log
}
```

### Keep files without deletion

```moonbit
///|
async fn keep_example() {
  let tmp = @tempfile.tempfile()
  let path = tmp.keep() // File is NOT deleted
  println("Preserved at: " + path)
}
```

## API

### Functions

```mbt check
///|
test {
  // Builder creates customizable temp file/dir
  let builder = Builder::new()
  inspect(builder.prefix, content=".tmp")
  inspect(builder.suffix, content="")
  inspect(builder.random_len, content="10")
  inspect(builder.temp_dir, content="/tmp")
}
```

```mbt check
///|
test {
  // Builder methods return new Builder (immutable)
  let b1 = Builder::new()
  let b2 = b1.prefix("test_")
  inspect(b1.prefix, content=".tmp")
  inspect(b2.prefix, content="test_")
}
```

```mbt check
///|
test {
  // Builder can chain methods
  let builder = Builder::new()
    .prefix("app_")
    .suffix(".tmp")
    .random_len(8)
    .temp_dir("/var/tmp")
  inspect(builder.prefix, content="app_")
  inspect(builder.suffix, content=".tmp")
  inspect(builder.random_len, content="8")
  inspect(builder.temp_dir, content="/var/tmp")
}
```

### Types

- `NamedTempFile` - A temporary file with path access
- `TempDir` - A temporary directory with recursive cleanup
- `Builder` - Builder for customizing temporary file/directory creation

### NamedTempFile Methods

- `path() -> String` - Get the file path
- `file() -> @fs.File` - Get the file handle
- `cleanup()` - Close and delete the file (async)
- `keep() -> String` - Close without deleting, returns path

### TempDir Methods

- `path() -> String` - Get the directory path
- `cleanup()` - Recursively delete the directory (async)
- `keep() -> String` - Keep without deleting, returns path

### Builder Methods

- `Builder::new() -> Builder` - Create a new builder
- `prefix(String) -> Builder` - Set name prefix (default: ".tmp")
- `suffix(String) -> Builder` - Set name suffix (default: "")
- `random_len(Int) -> Builder` - Set random portion length (default: 10)
- `temp_dir(String) -> Builder` - Set temp directory (default: "/tmp")
- `create_temp_file() -> NamedTempFile` - Create a temporary file (async)
- `create_temp_dir() -> TempDir` - Create a temporary directory (async)

## Requirements

- Target: `native` only (uses `moonbitlang/async/fs`)
- Dependencies: `moonbitlang/async`

## License

Apache-2.0
