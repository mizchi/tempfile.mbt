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
  file : @fs.File
}

///|
/// Get the path of the temporary file.
pub fn NamedTempFile::path(self : NamedTempFile) -> String {
  self.path
}

///|
/// Get the underlying file handle.
pub fn NamedTempFile::file(self : NamedTempFile) -> @fs.File {
  self.file
}

///|
/// Close the file and delete it from the filesystem.
pub async fn NamedTempFile::cleanup(self : NamedTempFile) -> Unit {
  self.file.close()
  @fs.remove(self.path)
}

///|
/// Close the file without deleting it. Returns the path.
pub fn NamedTempFile::keep(self : NamedTempFile) -> String {
  self.file.close()
  self.path
}

///|
/// Create a named temporary file using the builder options.
pub async fn Builder::create_temp_file(self : Builder) -> NamedTempFile {
  let name = generate_random_name(self.prefix, self.suffix, self.random_len)
  let path = self.temp_dir + "/" + name
  let file = @fs.create(path, permission=0o600)
  { path, file }
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
/// Delete the directory and all its contents.
pub async fn TempDir::cleanup(self : TempDir) -> Unit {
  @fs.rmdir(self.path, recursive=true)
}

///|
/// Keep the directory without deleting it. Returns the path.
pub fn TempDir::keep(self : TempDir) -> String {
  self.path
}

///|
/// Create a temporary directory using the builder options.
pub async fn Builder::create_temp_dir(self : Builder) -> TempDir {
  let name = generate_random_name(self.prefix, self.suffix, self.random_len)
  let path = self.temp_dir + "/" + name
  @fs.mkdir(path, permission=0o700)
  { path, }
}

///|
/// Create a named temporary file with default options.
pub async fn tempfile() -> NamedTempFile {
  Builder::new().create_temp_file()
}

///|
/// Create a temporary directory with default options.
pub async fn tempdir() -> TempDir {
  Builder::new().create_temp_dir()
}
