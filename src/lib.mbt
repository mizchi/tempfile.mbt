///|
// Temporary file and directory management for MoonBit
// Similar to Rust's tempfile crate

///|
let default_temp_dir : String = "/tmp"

///|
priv struct RandomState {
  mut counter : UInt64
}

///|
let random_state : RandomState = { counter: 0 }

///|
fn generate_random_name(prefix : String, suffix : String, len : Int) -> String {
  let now = @env.now()
  random_state.counter += 1
  let seed_val = now + random_state.counter
  let seed_arr : FixedArray[Byte] = FixedArray::make(32, b'\x00')
  for i in 0..<8 {
    seed_arr[i] = ((seed_val >> (i * 8)) & 0xFF).to_byte()
  }
  for i in 0..<8 {
    seed_arr[i + 8] = ((random_state.counter >> (i * 8)) & 0xFF).to_byte()
  }
  let seed_bytes = Bytes::from_array(seed_arr.iter().collect())
  let rand = @random.Rand::chacha8(seed=seed_bytes)
  let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  let buf = StringBuilder::new()
  buf.write_string(prefix)
  for _ in 0..<len {
    let idx = rand.int(limit=chars.length())
    buf.write_char(chars[idx].to_int().unsafe_to_char())
  }
  buf.write_string(suffix)
  buf.to_string()
}

///|
/// Builder for creating temporary files and directories with custom options.
pub struct Builder {
  prefix : String
  suffix : String
  random_len : Int
  temp_dir : String
}

///|
/// Create a new Builder with default options.
pub fn Builder::new() -> Builder {
  { prefix: ".tmp", suffix: "", random_len: 10, temp_dir: default_temp_dir }
}

///|
/// Set the prefix for the temporary file/directory name.
pub fn Builder::prefix(self : Builder, prefix : String) -> Builder {
  { ..self, prefix, }
}

///|
/// Set the suffix for the temporary file/directory name.
pub fn Builder::suffix(self : Builder, suffix : String) -> Builder {
  { ..self, suffix, }
}

///|
/// Set the length of the random portion of the name.
pub fn Builder::random_len(self : Builder, len : Int) -> Builder {
  { ..self, random_len: len }
}

///|
/// Set the directory where temporary files/directories will be created.
pub fn Builder::temp_dir(self : Builder, dir : String) -> Builder {
  { ..self, temp_dir: dir }
}

///|
/// A named temporary file that can be accessed via its path.
/// Call `cleanup()` to delete the file when done.
pub struct NamedTempFile {
  path : String
}

///|
/// Get the path of the temporary file.
pub fn NamedTempFile::path(self : NamedTempFile) -> String {
  self.path
}

///|
/// Write string content to the temporary file.
pub fn NamedTempFile::write_string(
  self : NamedTempFile,
  content : String,
) -> Unit raise @fs.IOError {
  @fs.write_string_to_file(self.path, content)
}

///|
/// Write bytes content to the temporary file.
pub fn NamedTempFile::write_bytes(
  self : NamedTempFile,
  content : Bytes,
) -> Unit raise @fs.IOError {
  @fs.write_bytes_to_file(self.path, content)
}

///|
/// Read the file content as string.
pub fn NamedTempFile::read_string(
  self : NamedTempFile,
) -> String raise @fs.IOError {
  @fs.read_file_to_string(self.path)
}

///|
/// Read the file content as bytes.
pub fn NamedTempFile::read_bytes(
  self : NamedTempFile,
) -> Bytes raise @fs.IOError {
  @fs.read_file_to_bytes(self.path)
}

///|
/// Delete the file from the filesystem.
pub fn NamedTempFile::cleanup(self : NamedTempFile) -> Unit raise @fs.IOError {
  @fs.remove_file(self.path)
}

///|
/// Keep the file without deleting it. Returns the path.
pub fn NamedTempFile::keep(self : NamedTempFile) -> String {
  self.path
}

///|
/// Create a named temporary file using the builder options.
pub fn Builder::create_temp_file(
  self : Builder,
) -> NamedTempFile raise @fs.IOError {
  let name = generate_random_name(self.prefix, self.suffix, self.random_len)
  let path = self.temp_dir + "/" + name
  @fs.write_bytes_to_file(path, b"")
  { path, }
}

///|
/// A temporary directory that can be accessed via its path.
/// Call `cleanup()` to delete the directory and its contents when done.
pub struct TempDir {
  path : String
}

///|
/// Get the path of the temporary directory.
pub fn TempDir::path(self : TempDir) -> String {
  self.path
}

///|
/// Delete the directory. Note: directory must be empty.
/// Use `cleanup_recursive` for non-empty directories.
pub fn TempDir::cleanup(self : TempDir) -> Unit raise @fs.IOError {
  @fs.remove_dir(self.path)
}

///|
/// Recursively delete the directory and all its contents.
pub fn TempDir::cleanup_recursive(self : TempDir) -> Unit raise @fs.IOError {
  fn remove_recursive(path : String) -> Unit raise @fs.IOError {
    if @fs.is_dir(path) {
      let entries = @fs.read_dir(path)
      for entry in entries {
        remove_recursive(path + "/" + entry)
      }
      @fs.remove_dir(path)
    } else {
      @fs.remove_file(path)
    }
  }

  remove_recursive(self.path)
}

///|
/// Keep the directory without deleting it. Returns the path.
pub fn TempDir::keep(self : TempDir) -> String {
  self.path
}

///|
/// Create a temporary directory using the builder options.
pub fn Builder::create_temp_dir(self : Builder) -> TempDir raise @fs.IOError {
  let name = generate_random_name(self.prefix, self.suffix, self.random_len)
  let path = self.temp_dir + "/" + name
  @fs.create_dir(path)
  { path, }
}

///|
/// Create a named temporary file with default options.
pub fn tempfile() -> NamedTempFile raise @fs.IOError {
  Builder::new().create_temp_file()
}

///|
/// Create a temporary directory with default options.
pub fn tempdir() -> TempDir raise @fs.IOError {
  Builder::new().create_temp_dir()
}
