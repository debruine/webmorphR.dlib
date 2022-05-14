#' dlib Auto-Delineation
#'
#' Automatically delineate faces using dlib shape predictor models.
#'
#' @param stimuli list of class stimlist
#' @param model Which of the built-in models (dlib7, dlib70)
#' @param replace if FALSE, only gets templates for images with no template
#' @param dlib_path path to a custom dlib .dat landmark file to use (model is ignored if set)
#'
#' @return stimlist with templates
#' @export
#'
#' @examples
#' \dontrun{
#'   auto_dlib7 <- demo_stim() |>
#'     auto_delin(replace = TRUE) # replace existing templates
#'
#'   auto_dlib70 <- demo_stim() |>
#'     auto_delin(model = "dlib70", replace = TRUE)
#' }
dlib_auto_delin <- function(stimuli,
                            model = c("dlib7", "dlib70"),
                            replace = FALSE,
                            dlib_path = NULL) {
  stimuli <- webmorphR::validate_stimlist(stimuli)
  model <- match.arg(model)
  verbose <- getOption("webmorph.verbose", TRUE)

  # find out which stimuli need tems ----
  if (isTRUE(replace)) stimuli <- webmorphR::remove_tem(stimuli)

  notems <- sapply(stimuli, `[[`, "points") |> sapply(is.null)

  if (all(notems == FALSE)) {
    warning("No images needed templates; set replace = TRUE to replace existing templates")
    return(stimuli)
  }

  # check for required things ----
  ## load/check python stuff ----
  if (!reticulate::py_available(TRUE)) {
    stop("You need to install Python to use the dlib templates")
  }

  if (!is.null(dlib_path)) {
    pred_file <- normalizePath(dlib_path)
  } else {
    # get pred_file location
    filename <- list(
      dlib7 = "shape_predictor_5_face_landmarks",
      dlib70 = "shape_predictor_68_face_landmarks"
    )
    pred_file <- paste0("python/", filename[model], ".dat") |>
      system.file(package = "webmorphR.dlib")
  }

  if (pred_file == "" || !file.exists(pred_file)) {
    stop("The landmark file could not be found at ", pred_file)
  }

  # load script
  py_get_points <- NULL # stops CMD check from complaining
  pyscript <- system.file("python/facedetect.py", package = "webmorphR.dlib")
  reticulate::source_python(pyscript)

  # save images to temp file ----
  tempdir <- tempfile()
  paths <- stimuli |>
    webmorphR::remove_tem() |>
    webmorphR::write_stim(tempdir, format = "jpg", ask = FALSE, overwrite = TRUE) |>
    unlist()

  if (verbose) {
    pb <- progress::progress_bar$new(
      total = length(stimuli), clear = FALSE,
      format = "Autodelineating [:bar] :current/:total :elapsedfull"
    )
    pb$tick(0)
    Sys.sleep(0.5)
    pb$tick(0)
  }

  # get points ----
  for (i in seq_along(stimuli)) {
    pts <- py_get_points(paths[i], pred_file) |>
      unlist() |>
      matrix(nrow = 2, dimnames = list(c("x", "y"), c()))

    stimuli[[i]]$points <- pts

    # delete lines
    stimuli[[i]]$lines <- NULL
    stimuli[[i]]$closed <- NULL

    if (verbose) pb$tick()
  }

  # add eye points and lines if a built-in model ----
  if (is.null(dlib_path)) {
    tem_def <- webmorphR::tem_def(model)

    for (i in seq_along(stimuli)) {
      pts <- stimuli[[i]]$points

      # calculate centres of pupils
      if (model == "dlib70") {
        le <- c(38, 39, 41, 42)
        re <- c(44, 45, 47, 48)
      } else if (model == "dlib7") {
        le <- c(3, 4)
        re <- c(1, 2)
      }

      left_eye <- pts[, le] |> apply(1, mean)
      right_eye <- pts[, re] |> apply(1, mean)

      x <- c(left_eye[["x"]], right_eye[["x"]], pts["x", ])
      y <- c(left_eye[["y"]], right_eye[["y"]], pts["y", ])

      stimuli[[i]]$points <- matrix(c(x, y), nrow = 2, byrow = TRUE,
                                  dimnames = list(c("x", "y"), tem_def$points$name))

      # replace lines
      stimuli[[i]]$lines <- tem_def$lines
      stimuli[[i]]$closed <- tem_def$closed
    }
  }

  stimuli
}
