///|
fn main {
  try {
    // Create a temporary file
    let tmp = @tempfile.tempfile()
    println("Created temp file: " + tmp.path())

    // Write some data
    tmp.write_string("Hello, tempfile!")

    // Read it back
    let content = tmp.read_string()
    println("Content: " + content)

    // Cleanup
    tmp.cleanup()
    println("File cleaned up")

    // Create a temporary directory
    let tmpdir = @tempfile.tempdir()
    println("Created temp dir: " + tmpdir.path())
    tmpdir.cleanup()
    println("Directory cleaned up")
  } catch {
    e => println("Error: " + e.to_string())
  }
}
