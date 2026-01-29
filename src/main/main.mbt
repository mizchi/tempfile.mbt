///|
async fn main {
  // Create a temporary file
  let tmp = @tempfile.tempfile()
  println("Created temp file: " + tmp.path())

  // Write some data
  tmp.file().write("Hello, tempfile!")
  tmp.file().close()

  // Read it back
  let content = @fs.read_file(tmp.path())
  println("Content: " + content.text())

  // Cleanup
  tmp.cleanup()
  println("File cleaned up")

  // Create a temporary directory
  let tmpdir = @tempfile.tempdir()
  println("Created temp dir: " + tmpdir.path())
  tmpdir.cleanup()
  println("Directory cleaned up")
}
