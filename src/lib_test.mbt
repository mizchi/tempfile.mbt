///|
test "tempfile creates and cleans up file" {
  let tmp = @tempfile.tempfile()
  let path = tmp.path()
  assert_true(@fs.path_exists(path))
  tmp.cleanup()
  assert_false(@fs.path_exists(path))
}

///|
test "tempfile write and read" {
  let tmp = @tempfile.tempfile()
  tmp.write_string("hello")
  let content = tmp.read_string()
  inspect(content, content="hello")
  tmp.cleanup()
}

///|
test "tempdir creates and cleans up directory" {
  let tmp = @tempfile.tempdir()
  let path = tmp.path()
  assert_true(@fs.path_exists(path))
  assert_true(@fs.is_dir(path))
  tmp.cleanup()
  assert_false(@fs.path_exists(path))
}

///|
test "tempdir with files cleans up recursively" {
  let tmp = @tempfile.tempdir()
  let file_path = tmp.path() + "/test.txt"
  @fs.write_string_to_file(file_path, "content")
  assert_true(@fs.path_exists(file_path))
  tmp.cleanup_recursive()
  assert_false(@fs.path_exists(tmp.path()))
}

///|
test "builder with prefix and suffix" {
  let builder = @tempfile.Builder::new().prefix("myprefix_").suffix(".txt")
  let tmp = builder.create_temp_file()
  let path = tmp.path()
  assert_true(path.contains("myprefix_"))
  assert_true(path.has_suffix(".txt"))
  tmp.cleanup()
}

///|
test "builder with custom temp_dir" {
  let base = @tempfile.tempdir()
  let builder = @tempfile.Builder::new().temp_dir(base.path())
  let tmp = builder.create_temp_file()
  assert_true(tmp.path().has_prefix(base.path()))
  tmp.cleanup()
  base.cleanup()
}

///|
test "keep preserves file" {
  let tmp = @tempfile.tempfile()
  let path = tmp.keep()
  assert_true(@fs.path_exists(path))
  @fs.remove_file(path)
}

///|
test "keep preserves directory" {
  let tmp = @tempfile.tempdir()
  let path = tmp.keep()
  assert_true(@fs.path_exists(path))
  @fs.remove_dir(path)
}
