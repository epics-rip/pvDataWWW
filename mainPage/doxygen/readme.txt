doxygen example
===============

generate default configuration file:
doxygen -g Doxyfile

Change some defaults:

--- Doxyfile.orig       2011-11-14 16:11:26.000000000 +0000
+++ Doxyfile    2011-11-14 16:11:20.000000000 +0000
@@ -228,17 +228,17 @@
 # Private class members and static file members will be hidden unless
 # the EXTRACT_PRIVATE and EXTRACT_STATIC tags are set to YES

-EXTRACT_ALL            = NO
+EXTRACT_ALL            = YES

 # If the EXTRACT_PRIVATE tag is set to YES all private members of a class
 # will be included in the documentation.

-EXTRACT_PRIVATE        = NO
+EXTRACT_PRIVATE        = YES

 # If the EXTRACT_STATIC tag is set to YES all static members of a file
 # will be included in the documentation.

-EXTRACT_STATIC         = NO
+EXTRACT_STATIC         = YES

 # If the EXTRACT_LOCAL_CLASSES tag is set to YES classes (and structs)
 # defined locally in source files will be included in the documentation.
@@ -459,7 +459,7 @@
 # directories like "/usr/src/myproject". Separate the files or directories
 # with spaces.

-INPUT                  =
+INPUT                  = src

 # If the value of the INPUT tag contains directories, you can use the
 # FILE_PATTERNS tag to specify one or more wildcard pattern (like *.cpp
@@ -744,7 +744,7 @@
 # If the GENERATE_LATEX tag is set to YES (the default) Doxygen will
 # generate Latex output.

-GENERATE_LATEX         = YES
+GENERATE_LATEX         = NO

 # The LATEX_OUTPUT tag is used to specify where the LaTeX docs will be put.
 # If a relative path is entered the value of OUTPUT_DIRECTORY will be

run doxygen:
doxygen

output in html/index.html

