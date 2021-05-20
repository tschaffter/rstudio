# Render an Rmd notebook to HTML or PDF.
#
# TODO: Use a library for managing command-line options.

# input = Sys.getenv("RENDER_INPUT", unset = NA)
output_format = Sys.getenv("RENDER_OUTPUT_FORMAT", unset = "html_document")
quiet = Sys.getenv("RENDER_QUIET", unset = "TRUE")

options <- commandArgs(trailingOnly = TRUE)
notebook_files <- Sys.glob(options[1], dirmark = FALSE)

# TODO: Add try and catch
for (file in notebook_files) {
  message(sprintf("Rendering notebook %s", file))
  rmarkdown::render(
    file,
    output_format,
    quiet = as.logical(quiet)
  )
}
