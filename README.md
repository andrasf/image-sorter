image-sorter
============

A simple gtk-ruby image sorter

A small tool for sorting jpg/jpeg images to a maximum of 4 different folders at once. I made it to sort my Dropbox synced images.

Requirements
------------
* ruby
* ruby-gtk2

Usage
-----
* Start the application by ```ruby image_sorter.rb [path]```. If no path given it will use the current path.
* Type folder names to the text inputs
* Press ESC key to set focus on the buttons
* Press keys 0, 1, 2, 3 to move current image to the chosen subfolder, or Return to skip
* You can use the mouse if you wish
