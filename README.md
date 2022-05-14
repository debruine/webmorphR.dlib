# webmorphR.dlibs

This package provides dlib files for use with the package [webmorphR](https://debruine.github.io/webmorphR/). These files are used for different auto-delineations with the python module [face_recognition](https://github.com/ageitgey/face_recognition). It also provides functions for training shape models with dlib and OpenCV.

## Install the package

``` r
remotes::install_github("debruine/webmorphR.dlib")
```
## dlib7

This is the 5-point template from Davis King's [shape_predictor_5_face_landmarks.dat](https://github.com/davisking/dlib-models#shape_predictor_5_face_landmarksdatbz2) trained on 7198 faces from the [dlib 5-point face landmark dataset](http://dlib.net/files/data/dlib_faces_5points.tar). I added two points for the eye centres (0 and 1) in order to aid alignment by eyes.

It's a very fast auto-delineation and useful if you just need to align faces to the same position, orientation or general size.

## dlib70

<img src="man/figures/dlib70.jpg" style="max-width: 100%;"/>

This is the 68-point template from Davis King's [shape_predictor_68_face_landmarks.dat](https://github.com/davisking/dlib-models#shape_predictor_68_face_landmarksdatbz2) trained on the [iBUG 300-W dataset](https://ibug.doc.ic.ac.uk/resources/facial-point-annotations/). I added two points for the eye centres (0 and 1) in order to aid alignment by eyes.

> C. Sagonas, E. Antonakos, G, Tzimiropoulos, S. Zafeiriou, M. Pantic. 300 faces In-the-wild challenge: Database and results. 
Image and Vision Computing (IMAVIS), Special Issue on Facial Landmark Localisation "In-The-Wild". 2016.

The license for this dataset excludes commercial use, so the trained model can not be used in a commercial product. 


