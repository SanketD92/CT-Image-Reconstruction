# Computed Tomography Image Reconstruction
## Introduction
Computed tomography is a collection of X-ray images stacked together in order to get the depth information as the third dimension of a diagnostic image. These "stacked" X-ray images are received as a sinogram from the CT gantry, and represent the X-ray absorption profile of a single layer of the subject. The objective of this project was to re-construct the original 2D image of this single layer and also distinguish between different X-ray absorption levels by the subject's tissues using light attenuation information.

## Project Details
The X-ray projection of the object at each angle of the CT gantry rotation produces a sinogram where the Y axis shows the angle in degrees while the X axis shows the spatial distance. 

For the following project, I've created a sample sinogram and  are required to construct its corresponding phantom object and determining the X-ray attenuation and possibly the object density throughout the object. 

![screenshot](<img src="github.com/SanketD92/CT-Image-Reconstruction/blob/master/Assets/Phantom.png" width="425"/> )
![screenshot](<img src="https://github.com/SanketD92/CT-Image-Reconstruction/blob/master/Assets/Phantom_Sinogram.jpg" width="425"/> )

You can also:
  - Import and save files from GitHub, Dropbox, Google Drive and One Drive
  - Drag and drop markdown and HTML files into Dillinger
  - Export documents as Markdown, HTML and PDF

Markdown is a lightweight markup language based on the formatting conventions that people naturally use in email.  As [John Gruber] writes on the [Markdown site][df1]

> The overriding design goal for Markdown's
> formatting syntax is to make it as readable
> as possible. The idea is that a
> Markdown-formatted document should be
> publishable as-is, as plain text, without
> looking like it's been marked up with tags
> or formatting instructions.

This text you see here is *actually* written in Markdown! To get a feel for Markdown's syntax, type some text into the left window and watch the results in the right.

## Result for some test images

Dillinger uses a number of open source projects to work properly:

* [AngularJS] - HTML enhanced for web apps!
* [Ace Editor] - awesome web-based text editor
* [markdown-it] - Markdown parser done right. Fast and easy to extend.
* [Twitter Bootstrap] - great UI boilerplate for modern web apps
* [node.js] - evented I/O for the backend
* [Express] - fast node.js network app framework [@tjholowaychuk]
* [Gulp] - the streaming build system
* [Breakdance](http://breakdance.io) - HTML to Markdown converter
* [jQuery] - duh

And of course Dillinger itself is open source with a [public repository][dill]
 on GitHub.

## Have fun

If you want to try reconstructing images from your own sinogram database, go ahead! 
Fiddle with the parameters and try different filters to see how the result image varies.

Installations Required:
- MATLAB
