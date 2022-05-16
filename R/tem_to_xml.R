#' Templates to XML
#'
#' Make an XML file with the template points for a set of stimuli. For use with [facetrain] for training dlib models.
#'
#' @param stimuli list of class stimlist
#' @param dir path to save the images and XML file
#' @param imageset name for the image set (in the XML file)
#'
#' @return the path to the xml file (invisibly)
#'
#' @export
#' @examples
#' xml <- system.file("demo/_images.xml", package = "webmorphR.dlib")
#'
#' # read the first 10 lines of the xml file
#' readLines(xml, n = 10)
tem_to_xml <- function(stimuli, dir = "images", imageset = "Image Set") {
  stimuli <- webmorphR::validate_stimlist(stimuli)
  verbose <- getOption("webmorph.verbose", TRUE)

  # write images to dir ----
  if (verbose) message("Writing images to directory")

  stim_names <- names(stimuli)
  unique_names <- unique(stim_names)
  if (length(stim_names) > length(unique_names)) {
    stop("Make sure none of your images has a duplicate name.")
  }

  paths <- stimuli |>
    webmorphR::remove_tem() |>
    webmorphR::write_stim(dir = dir, format = "jpg", overwrite = TRUE) |>
    unlist() |>
    normalizePath()

  # get bounding boxes ----
  if (verbose) {
    pb <- progress::progress_bar$new(
      total = length(paths), clear = FALSE,
      format = "Detecting face locations [:bar] :current/:total :elapsedfull"
    )
    pb$tick(0)
    Sys.sleep(0.5)
    pb$tick(0)
  }

  py_get_location <- NULL # stops CMD check from complaining
  pyscript <- system.file("python/facedetect.py", package = "webmorphR.dlib")
  reticulate::source_python(pyscript)
  boxes <- lapply(paths, function(p) {
    if (verbose) pb$tick()
    py_get_location(p)
  }) |>
    lapply(unlist)

  # create XML ----
  if (verbose) {
    pb <- progress::progress_bar$new(
      total = length(paths), clear = FALSE,
      format = "Creating XML file [:bar] :current/:total :elapsedfull"
    )
    pb$tick(0)
    Sys.sleep(0.5)
    pb$tick(0)
  }

  imgs <- mapply(function(stim, path, box) {
    if (verbose) pb$tick()

    i <- -1
    pts <- apply(stim$points, 2, function(pt) {
      i <<- i + 1
      sprintf("<part name='%03.f' x='%.0f' y='%.0f'/>", i,
              round(pt["x"]), round(pt["y"]))
    }) |>
      paste(collapse = "\n      ")

    if (is.null(box)) {
      minpt <- apply(stim$points, 1, min)
      maxpt <- apply(stim$points, 1, max)
      box <- c(top = max(0, minpt["y"]-10),
               right = min(stim$width, maxpt["x"]+10),
               bottom = min(stim$height, maxpt["y"]+10),
               left = max(0, minpt["x"]-10)
      ) |> round()
    }

    sprintf("  <image file='%s'>
    <box top='%d' left='%d' width='%d' height='%d'>
      %s
    </box>
  </image>", path,
  box[[1]], box[[4]],
  abs(box[[2]]-box[[4]]),
  abs(box[[3]]-box[[1]]), pts)
  }, stimuli, paths, boxes) |>
    paste(collapse = "\n")

  # write XML ----
  filename <- file.path(normalizePath(dir), "_images.xml")
  xml <- sprintf("<?xml version='1.0' encoding='ISO-8859-1'?>
<?xml-stylesheet type='text/xsl' href='image_metadata_stylesheet.xsl'?>
<dataset>
<name>%s</name>
<images>
%s
</images>
</dataset>", imageset, imgs)

  write(xml, filename)

  invisible(filename)
}


