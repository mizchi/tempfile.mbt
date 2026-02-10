# mizchi/tempfile

Temporary file and directory management for MoonBit. Similar to Rust's [tempfile](https://crates.io/crates/tempfile) crate.

## Features

- Create temporary files with automatic cleanup
- Create temporary directories with recursive cleanup
- Builder pattern for customization (prefix, suffix, temp directory)
- Cross-platform support (js, wasm, native)

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

```moonbit nocheck
///|
fn example() {
  let tmp = @tempfile.tempfile()
  tmp.write_string("Hello!")
  println(tmp.path()) // /tmp/.tmpXXXXXXXXXX
  tmp.cleanup()
}
```

### Create a temporary directory

```moonbit nocheck
///|
fn example_dir() {
  let tmpdir = @tempfile.tempdir()

  // Create files inside
  @fs.write_string_to_file(tmpdir.path() + "/data.txt", "content")

  // Recursive cleanup for non-empty directories
  tmpdir.cleanup_recursive()
}
```

### Builder pattern

```moonbit nocheck
///|
fn custom_tempfile() {
  let tmp = @tempfile.Builder::new()
    .prefix("myapp_")
    .suffix(".log")
    .temp_dir("/var/tmp")
    .create_temp_file()
  println(tmp.path()) // /var/tmp/myapp_XXXXXXXXXX.log
  tmp.cleanup()
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
- `write_string(String)` - Write string content
- `write_bytes(Bytes)` - Write bytes content
- `read_string() -> String` - Read as string
- `read_bytes() -> Bytes` - Read as bytes
- `cleanup()` - Delete the file
- `keep() -> String` - Keep without deleting, returns path

### TempDir Methods

- `path() -> String` - Get the directory path
- `cleanup()` - Delete empty directory
- `cleanup_recursive()` - Recursively delete directory and contents
- `keep() -> String` - Keep without deleting, returns path

### Builder Methods

- `Builder::new() -> Builder` - Create a new builder
- `prefix(String) -> Builder` - Set name prefix (default: ".tmp")
- `suffix(String) -> Builder` - Set name suffix (default: "")
- `random_len(Int) -> Builder` - Set random portion length (default: 10)
- `temp_dir(String) -> Builder` - Set temp directory (default: "/tmp")
- `create_temp_file() -> NamedTempFile` - Create a temporary file
- `create_temp_dir() -> TempDir` - Create a temporary directory

## Requirements

- Dependencies: `moonbitlang/x`

## License

Apache-2.0
