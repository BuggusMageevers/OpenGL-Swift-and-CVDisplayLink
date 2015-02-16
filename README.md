# SwiftOpenGL

Swift implementation of an OpenGL content view driven by CVDisplayLinkimplement

PROJECT_FEATURES:
     Swift except for CVDisplayLinkCallback function (bridged from Obj-C Class)
     CVDisplayLink driven rendering
     Swift OpenGL view subclassed from NSOpenGLView
     Thought process provided in each file
     
I have tried to make a Swift project that utilizes CVDisplayLink for driving an OpenGL rendering loop for some time.
I tried to look for examples of how this could be done, but I was unsuccessful for a very long timem.  Only recently,
did I find the example listed below by Jonas Jongejan. Even having seen that file, I feel the it is too long and
devoid of comments to be instantly useful to the reader. Considering the mass of code, and my inexperience as a 
programmer, I was only able to evalute the file for a specific need.  Namely, using CVTimeStamp to calculate the app's
current frames per second.

Therein lies the purpose of this example project:  to develop a simple app with a documented process of thought. In
doing so, I hope future programmers will understand how to use one of Apple's "mysterious" C API's with Swift (and
minimal use of Objective-C and C).

It is my hope that in the future, Swift will adopt the functions necessary to work with these C API's without the need
to bridge over into Objective-C. It's a new language after all, and Swift 1.2 has already shown some great development.

REFERENCES: These links were of great help to me while developing this small project file.

SWIFT_GRAMMAR_THEORY
Swift: Generating keys, and Encrypting and Decrypting text
  Blog post that provided a great deal of insight into Swift's UnsafePointer<T>, UnsafeMutablePointer<T>, and Unmanaged<T>
  http://netsplit.com/swift-generating-keys-and-encrypting-and-decrypting-text
  
STACK_OVERFLOW_THREADS
Answer to: Understanding typedefs for function pointers in C: Examples, hints and tips, please by Johnathan Leffler
  Very lengthy explanation of typedef, most of it was followable, but it gets a little convoluted towards the end. I just the following StackOverflow answer for clarification.
  http://stackoverflow.com/a/1591492/3928158
Answer to:  How to make a function return a pointer to a function?(C++) by Rutger Nijlunsing
  To better understand the use of the CVDisplayLinkCallback typedef and how to better implement it
  http://stackoverflow.com/a/997852/3928158

CODE_EXAMPLES  
Random web examples using CVTimeStamp to calculate the frames per second
  Blog post: "Take Candle" on 14th May 2012
    http://www.takecandle.com/wheels-in-motion.html
  Code example by Jonas Jongejan on 11/27/09
    http://ofxcocoaplugins.googlecode.com/svn-history/r172/trunk/src/OpenGL/PluginOutputView.mm
