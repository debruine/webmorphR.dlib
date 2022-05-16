#' XML to Templates
#'
#' Make webmorph templates out of XML formatted point files.
#'
#' @param xml The file path for the XML file
#'
#' @return A stimlist with only tem points
#' @export
#'
xml_to_tem <- function(xml) {
  images <- XML::xmlParse(xml) |>
    XML::xmlToList() |>
    getElement("images")

  files <- sapply(images, getElement, ".attrs")

  points <- lapply(images, getElement, "box") |>
    lapply(function(box) {
      parts <- box[1:(length(box)-1)]

      x <- sapply(parts, `[[`, 2) |> as.numeric()
      y <- sapply(parts, `[[`, 3) |> as.numeric()

      matrix(c(x, y), nrow = 2, byrow = TRUE,
             dimnames = list(c("x", "y")))
    })

  stimuli <- webmorphR::read_stim(files)

  for (i in seq_along(stimuli)) {
    stimuli[[i]]$points <- points[[i]]
  }

  stimuli
}
