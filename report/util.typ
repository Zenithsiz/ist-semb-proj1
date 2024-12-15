#let title = [MicroProject 1: #linebreak() Implementation of the Blinking sample in ESP32]
#let course = [Embedded Systems]

#let authors = ([Filipe Rodrigues - 96735],)

/// Displays a figure of code
#let code_figure(body, ..rest) = {
  figure(
    body,
    kind: "code",
    supplement: "Code",
    ..rest,
  )
}

/// Displays a link to a file, relative to `src`.
#let src_link(rel_link) = {
  link("file://./src/" + rel_link, raw(rel_link))
}
