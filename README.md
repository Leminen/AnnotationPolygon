# AnnotationPolygon
A MATLAB tool for annotating polygons in images.

The tool currently support annotation of the following shapes:
- Squares, by drawing the corresponding diagonal
- Rectangles, axis aligned
- Custom shapes by pointing out cornors for the polygon


The tool takes a folder containing images as input and output a struct containing filename, filepath (local) and annotated polygons. The tool supports annotation of multiple annotations in the same image.

![Screenshot](images/screenshot.png)
