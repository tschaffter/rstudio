# Renders a notebook in HTML or PDF format using args specified as environment
# variables.

input = Sys.getenv("RENDER_INPUT", unset = NA)
output_format = Sys.getenv("RENDER_OUTPUT_FORMAT", unset = "html_document")
quiet = Sys.getenv("RENDER_QUIET", unset = "TRUE")

if (is.na(input)) {
  stop("The environment variable RENDER_INPUT is required")
}

rmarkdown::render(
  input,
  output_format,
  quiet = as.logical(quiet)
)