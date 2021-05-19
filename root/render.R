# Render an Rmd notebook to HTML or PDF.
#
# TODO: Use a library for managing command-line options.

# input = Sys.getenv("RENDER_INPUT", unset = NA)
output_format = Sys.getenv("RENDER_OUTPUT_FORMAT", unset = "html_document")
quiet = Sys.getenv("RENDER_QUIET", unset = "TRUE")

options <- commandArgs(trailingOnly = TRUE)
input <- options[1]

if (is.na(input)) {
  stop("The environment variable RENDER_INPUT is required")
}

rmarkdown::render(
  input,
  output_format,
  quiet = as.logical(quiet)
)