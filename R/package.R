#' Demo stimuli
#'
#' Function exported from [webmorphR::demo_stim()] for easier testing.
#'
#' @importFrom webmorphR demo_stim
#' @export demo_stim
#' @name demo_stim
NULL

#' Draw Template
#'
#' Function exported from [webmorphR::draw_tem()] for easier testing.
#'
#' @importFrom webmorphR draw_tem
#' @export draw_tem
#' @name draw_tem
NULL

.onLoad <- function(libname, pkgname) {
  reticulate::configure_environment(pkgname)
}
