test_that("xml_to_tem", {
  dir <- tempfile()
  s <- demo_stim()
  xml <- tem_to_xml(s, dir)

  tems <- xml_to_tem(xml)

  # points rounded in XML conversion
  point_diff <- abs(s[[1]]$points - tems[[1]]$points)
  expect_true( all(point_diff <= 0.5) )

  # draw_tem(tems) |> plot()
})
