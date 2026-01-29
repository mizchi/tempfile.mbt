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

## Quick Start

```moonbit
fn main {
  // Create a temporary file
  let tmp = @tempfile.tempfile!()

  tmp.write_string!("Hello, tempfile!")
  println(tmp.path())  // /tmp/.tmpXXXXXXXXXX

  tmp.cleanup!()

  // Create a temporary directory
  let tmpdir = @tempfile.tempdir!()
  println(tmpdir.path())  // /tmp/.tmpXXXXXXXXXX
  tmpdir.cleanup!()
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

- Dependencies: `moonbitlang/x`

## License

Apache-2.0
