test_that("facetrain", {
  skip_on_cran() # requires a python installation with dlib

  stimuli <- demo_stim("composite") |>
    webmorphR::subset_tem(webmorphR::features("face"))
  #stimuli[1] |> webmorphR::draw_tem()

  ## too-small
  dir <- tempfile()
  xml <- tem_to_xml(stimuli[1:2], dir = dir)

  # train model
  output <- tempfile(fileext = ".dat")
  expect_error( facetrain(xml, output) )
  # options with errors
  expect_error( facetrain(xml, output, nu = 2) )
  expect_error( facetrain(xml, output, jitter = -1) )

  skip("long process")

  # create xml and image directory for training
  dir <- tempfile()
  xml <- tem_to_xml(stimuli, dir = dir)

  # train model
  output <- tempfile(fileext = ".dat")
  newmodel <- facetrain(xml, output)

  teststim <- demo_stim("lisa") |>
    dlib_auto_delin(replace = TRUE, dlib_path = newmodel)

  expect_equal(teststim[[1]]$points |> dim(),
               stimuli[[1]]$points |> dim())

  # teststim[1] |> webmorphR::draw_tem(pt.shape = "index", pt.size = 15)
})
