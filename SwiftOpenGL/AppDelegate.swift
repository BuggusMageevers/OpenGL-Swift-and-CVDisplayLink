//
//  AppDelegate.swift
//  SwiftOpenGL
//
//  Created by Myles La Verne Schultz on 2/15/15.
//  Copyright (c) 2015 MyKo. All rights reserved.
//

import Cocoa
import QuartzCore.CVDisplayLink

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        
        //  Grab the current window in our app, and from that grab the subviews of the attached viewController
        //  Cycle through that array to get our SwiftOpenGLView instance
        
        let windowController = NSApplication.sharedApplication().mainWindow?.windowController() as? NSWindowController
        let views = windowController?.contentViewController?.view.subviews as [NSView]
        for view in views {
            if let aView = view as? SwiftOpenGLView {
                println("Checking if CVDisplayLink is running")
                if let running = CVDisplayLinkIsRunning(aView.displayLink) as Boolean? {
                    println("Stopping CVDisplayLink")
                    let result = CVDisplayLinkStop(aView.displayLink)
                    if result == kCVReturnSuccess.value { println("CVDisplayLink stopped\n\tCode: \(result)") }
                }
            }
        }
    }


}

