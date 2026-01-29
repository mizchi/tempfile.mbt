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

## Quick Start

```moonbit
async fn main {
  // Create a temporary file
  let tmp = @tempfile.tempfile()
  defer tmp.cleanup()

  tmp.file().write("Hello, tempfile!")
  println(tmp.path())  // /tmp/.tmpXXXXXXXXXX

  // Create a temporary directory
  let tmpdir = @tempfile.tempdir()
  defer tmpdir.cleanup()

  println(tmpdir.path())  // /tmp/.tmpXXXXXXXXXX
}
```

## API

See [src/README.mbt.md](src/README.mbt.md) for detailed API documentation with executable examples.

### Types

- `NamedTempFile` - A temporary file with path access
- `TempDir` - A temporary directory with recursive cleanup
- `Builder` - Builder for customizing temporary file/directory creation

### Functions

- `tempfile() -> NamedTempFile` - Create a temporary file
- `tempdir() -> TempDir` - Create a temporary directory

## Requirements

- Target: `native` only
- Dependencies: `moonbitlang/async`

## License

Apache-2.0
