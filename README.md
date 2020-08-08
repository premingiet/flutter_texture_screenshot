# flutter_texture_screenshot

This is a flutter app to test bug in flutter texture widget. Because of this bug, screenshot of texture widget returns null image.

## Getting Started

1. Run pub get inside the project to fetch all dependencies in pubspec.yaml file
1. Run the app in an android device and make sure internet is there
1. Now as app starts, press the middle play button and the video will start playing
1. Now press the 1st button called "Top Capture" and this should capture the texture widget screenshot
1. Now try to press the 3rd button called "Mid Capture" and this should capture the color changing animated container widget screenshot
1. Preview the screenshot in the "Preview Captured Screenshot Container".

> Bug here is
-----------

Pressing "Top Capture" button, returns null screenshot image of texture widget, but pressing "Mid Capture" button returns the screenshot of animated container widget.

> What should actually happen 
----------------------------

Pressing "Top Capture" button, should take screenshot of video playing.
