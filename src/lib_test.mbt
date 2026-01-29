///|
async test "tempfile creates and cleans up file" {
  let tmp = @tempfile.tempfile()
  let path = tmp.path()
  assert_true(@fs.exists(path))
  tmp.cleanup()
  assert_false(@fs.exists(path))
}

///|
async test "tempfile write and read" {
  let tmp = @tempfile.tempfile()
  let file = tmp.file()
  file.write("hello")
  file.close()
  let content = @fs.read_file(tmp.path())
  inspect(content.text(), content="hello")
  tmp.cleanup()
}

///|
async test "tempdir creates and cleans up directory" {
  let tmp = @tempfile.tempdir()
  let path = tmp.path()
  assert_true(@fs.exists(path))
  assert_true(@fs.kind(path) is Directory)
  tmp.cleanup()
  assert_false(@fs.exists(path))
}

///|
async test "tempdir with files cleans up recursively" {
  let tmp = @tempfile.tempdir()
  let file_path = tmp.path() + "/test.txt"
  @fs.write_file(file_path, b"content", create=0o644)
  assert_true(@fs.exists(file_path))
  tmp.cleanup()
  assert_false(@fs.exists(tmp.path()))
}

///|
async test "builder with prefix and suffix" {
  let builder = @tempfile.Builder::new().prefix("myprefix_").suffix(".txt")
  let tmp = builder.create_temp_file()
  let path = tmp.path()
  assert_true(path.contains("myprefix_"))
  assert_true(path.has_suffix(".txt"))
  tmp.cleanup()
}

///|
async test "builder with custom temp_dir" {
  let base = @tempfile.tempdir()
  let builder = @tempfile.Builder::new().temp_dir(base.path())
  let tmp = builder.create_temp_file()
  assert_true(tmp.path().has_prefix(base.path()))
  tmp.cleanup()
  base.cleanup()
}

///|
async test "keep preserves file" {
  let tmp = @tempfile.tempfile()
  let path = tmp.keep()
  assert_true(@fs.exists(path))
  @fs.remove(path)
}

///|
async test "keep preserves directory" {
  let tmp = @tempfile.tempdir()
  let path = tmp.keep()
  assert_true(@fs.exists(path))
  @fs.rmdir(path)
}
