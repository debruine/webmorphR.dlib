#' Demo stimuli
#'
#' @importFrom webmorphR demo_stim
#' @export demo_stim
#' @name demo_stim
NULL

.onLoad <- function(libname, pkgname) {
  reticulate::configure_environment(pkgname)
}
