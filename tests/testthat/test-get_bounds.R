library(webmorphR)
library(webmorphR.stim)

test_that("get_bounds", {
  dir <- tempfile()
  stimuli <- load_stim_lisa()
  xml <- tem_to_xml(stimuli, dir)
  bounds <- get_bounds(xml)
  cropped <- get_bounds(xml, crop = TRUE)

  expect_equal(width(stimuli), width(bounds))
  expect_equal(height(stimuli), height(bounds))
  expect_equal(width(cropped),
               c(lisa1 = 386, lisa2 = 223, lisa3 = 321, lisa4 = 321))
  expect_equal(height(cropped),
               c(lisa1 = 385, lisa2 = 222, lisa3 = 321, lisa4 = 321))

  # draw_tem(bounds, line.alpha = 1, line.color = "green") |>
  #   plot(nrow = 2, maxwidth = 500)
  # plot(cropped, nrow = 2, maxwidth = 500)

  # subset
  cropped2 <- get_bounds(xml, TRUE, subset = c(1, 4))
  expect_equal(length(cropped2), 2)
  expect_equal(width(cropped)[c(1,4)], width(cropped2))
  expect_equal(height(cropped)[c(1,4)], height(cropped2))
})
