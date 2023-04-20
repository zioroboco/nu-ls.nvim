#!/usr/bin/env nu

export def "main" [] { help main }

export def "main test" [path?: string = "tests"] {
  let-env RUST_BACKTRACE = 1
  nvim --headless -c $"PlenaryBustedDirectory ($path) { minimal = true }"
}
