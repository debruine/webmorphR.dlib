test_that("tem_to_xml", {
  skip_on_cran() # requires a python installation with dlib

  stimuli <- demo_stim()
  dir <- tempfile()
  xml <- tem_to_xml(stimuli, dir, "Demo Stim")
  xml_text <- readLines(xml)

  expect_equal(xml_text[[1]], "<?xml version='1.0' encoding='ISO-8859-1'?>")
  expect_equal(xml_text[[4]], "<name>Demo Stim</name>")
  expect_equal(xml_text[[6]], paste0("  <image file='", normalizePath(dir), "/f_multi.jpg'>"))
  expect_equal(xml_text[[7]],"    <box top='180' left='159' width='186' height='186'>")
  expect_equal(grepl("</image>", xml_text) |> sum(),
               length(stimuli))
})
