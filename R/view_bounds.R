#' Get Face Bounds
#'
#' Get the bounds detected by [tem_to_xml()] (uses dlib.get_frontal_face_detector()).
#'
#' @param xml The file path for the XML file created by [tem_to_xml()]
#' @param crop Whether to crop the image to the bounds
#' @param subset indices of images to subset
#'
#' @return A stimlist with a 4-point template of the top-left, top-right, bottom-right, and bottom-left corners of the bounding box, optionally cropped to this box
#' @export
#'
#' @examples
#' xml <- system.file("demo/_images.xml", package = "webmorphR.dlib")
#' bounds <- get_bounds(xml)
#' cropped <- get_bounds(xml, crop = TRUE)
#'
#' \dontrun{
#'   # plot images
#'   bounds |>
#'     draw_tem(line.alpha = 1, line.color = "green") |>
#'     c(cropped) |>
#'     plot(nrow = 1)
#' }
get_bounds <- function(xml, crop = FALSE, subset = NULL) {
  images <- XML::xmlParse(xml) |>
    XML::xmlToList() |>
    getElement("images")

  if (!is.null(subset)) images <- images[subset]

  files <- sapply(images, getElement, ".attrs")
  bounds <- lapply(images, getElement, "box") |>
    lapply(getElement, ".attrs") |>
    sapply(as.numeric) |>
    t() |>
    as.data.frame() |>
    setNames(c("top", "left", "width", "height"))

  points <- data.frame(
    x_1 = bounds$left,
    x_2 = bounds$left + bounds$width,
    x_3 = bounds$left + bounds$width,
    x_4 = bounds$left,
    y_1 = bounds$top,
    y_2 = bounds$top,
    y_3 = bounds$top + bounds$height,
    y_4 = bounds$top + bounds$height
  )

  pt_array <- points |> unlist() |>
    array(dim = c(nrow(bounds), 4, 2),
          dimnames = list(
            basename(files) |> gsub("\\.jpg", "", x = _),
            c("tl", "tr", "bl", "br"),
            c("x", "y")
          ))

  stimuli <- webmorphR::read_stim(files)

  for (i in seq_along(stimuli)) {
    stimuli[[i]]$points <- pt_array[i , ,] |> t()
    stimuli[[i]]$lines <- list(0:1, 1:2, 2:3, c(3,0))
    stimuli[[i]]$closed <- rep(FALSE, 4)
  }

  if (crop) {
    stimuli <- stimuli |> webmorphR::crop(
      width = bounds$width,
      height = bounds$height,
      x_off = bounds$left,
      y_off = bounds$top
    )
  } else {
    # h <- webmorphR::height(stimuli)
    # stimuli <- stimuli |> webmorphR::gglabel(
    #   geom = "rect",
    #   color = color,
    #   fill = "transparent",
    #   size = size,
    #   xmin = bounds$left,
    #   xmax = bounds$left + bounds$width,
    #   ymax = h - bounds$top,
    #   ymin = h - bounds$top - bounds$height
    # )
  }

  stimuli
}
