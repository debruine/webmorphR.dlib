# webmorphR_dlibs

Install this dlib for the 70-point template in [webmorphR](https://debruine.github.io/webmorphR/)

``` r
dlib70 <- "path/to/dlib70.dat"
python_dir <- system.file("python", package = "webmorphR")
file.copy(from = dlib70, to = paste0(python_dir, "/dlib70.dat"))
```
