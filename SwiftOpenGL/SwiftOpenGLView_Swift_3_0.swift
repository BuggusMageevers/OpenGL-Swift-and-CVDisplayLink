//
//  SwiftOpenGLView_Swift_3_0.swift
//  SwiftOpenGL
//
//  Created by Myles La Verne Schultz on 1/11/17.
//  Copyright © 2017 MyKo. All rights reserved.
//
//  This file is an update to the previous SwiftOpenGLView used
//  to display animated content using the CVDisplayLink.  This
//  version uses Swift 3.0 without the need for a bridging
//  header for the CVDisplayLinkCallback function.  An
//  explanation of the CVTimeStamp is also provided.
//

import Cocoa
import OpenGL.GL3


final class SwiftOpenGLView: NSOpenGLView {
    
    //  A CVDisplayLink for animating.
    fileprivate var displayLink: CVDisplayLink?
    
    //  The current time, used to produce varying values to change background color
    fileprivate var currentTime = 0.0
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let attrs: [NSOpenGLPixelFormatAttribute] = [
            UInt32(NSOpenGLPFAAccelerated),
            UInt32(NSOpenGLPFADoubleBuffer),
            UInt32(NSOpenGLPFAColorSize), UInt32(32),
            UInt32(NSOpenGLPFAOpenGLProfile), UInt32(NSOpenGLProfileVersion3_2Core),
            UInt32(0)
        ]
        guard let pixelFormat = NSOpenGLPixelFormat(attributes: attrs) else {
            Swift.print("pixelFormat could not be constructed")
            return
        }
        self.pixelFormat = pixelFormat
        guard let context = NSOpenGLContext(format: pixelFormat, share: nil) else {
            Swift.print("context could not be constructed")
            return
        }
        self.openGLContext = context
        
        //  Set the context's swap interval parameter to 60Hz (i.e. 1 frame per swamp)
        self.openGLContext?.setValues([1], for: .swapInterval)
        
    }
    
    override func prepareOpenGL() {
        
        super.prepareOpenGL()
        
        glClearColor(0.0, 0.0, 0.0, 1.0)
        
        // ** ** ** ** ** ** ** ** ** //
        // Setup OpenGL pipline here  //
        // ** ** ** ** ** ** ** ** ** //
        
        /*  Now that the OpenGL pipeline is defined, declare a callback for our CVDisplayLink.
            There are three ways to do this:  declare a function, declare a computed property,
            or declare/pass a closure.  Using each requires subtle changes in the
            CVDisplayLinkSetOutputCallback()'s argument list.  We shall declare a local
            closure of type CVDisplayLinkOutputCallback.
         */
        let displayLinkOutputCallback: CVDisplayLinkOutputCallback = {(displayLink: CVDisplayLink, inNow: UnsafePointer<CVTimeStamp>, inOutputTime: UnsafePointer<CVTimeStamp>, flagsIn: CVOptionFlags, flagsOut: UnsafeMutablePointer<CVOptionFlags>, displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn in
             
            /*  It's prudent to also have a brief discussion about the CVTimeStamp.
                CVTimeStamp has five properties.  Three of the five are very useful
                for keeping track of the current time, calculating delta time, the
                frame number, and the number of frames per second.  The utility of
                each property is not terribly obvious from just reading the names
                or the descriptions in the Developer dcumentation and has been a
                mystery to many a developer.  Thankfully, CaptainRedmuff on
                StackOverflow asked a question that provided the equation that
                calculates frames per second.  From that equation, we can
                extrapolate the value of each field.
                
                @hostTime = current time in Units of the "root".  Yeah, I don't know.
                  The key to this field is to understand that it is in nanoseconds
                  (e.g. 1/1_000_000_000 of a second) not units.  To convert it to
                  seconds divide by 1_000_000_000.  Dividing by videoRefreshPeriod
                  and videoTimeScale in a calculation for frames per second yields
                  the appropriate number of frames.  This works as a result of
                  proportionality--dividing seconds by seconds.  Note that dividing
                  by videoTimeScale to get the time in seconds does not work like it
                  does for videoTime.
                  
                  framesPerSecond:
                    (videoTime / videoRefreshPeriod) / (videoTime / videoTimeScale) = 59
                  and
                    (hostTime / videoRefreshPeriod) / (hostTime / videoTimeScale) = 59
                  but
                    hostTime * videoTimeScale ≠ seconds, but Units = seconds * (Units / seconds) = Units
        
              @rateScalar = ratio of "rate of device in CVTimeStamp/unitOfTime" to
                the "Nominal Rate".  I think the "Nominal Rate" is
                videoRefreshPeriod, but unfortunately, the documentation doesn't
                just say videoRefreshPeriod is the Nominal rate and then define
                what that means.  Regardless, because this is a ratio, and the fact
                that we know the value of one of the parts (e.g. Units/frame), we
                then know that the "rate of the device" is frame/Units (the units of
                measure need to cancel out for the ratio to be a ratio).  This
                makes sense in that rateScalar's definition tells us the rate is
                "measured by timeStamps".  Since there is a frame for every
                timeStamp, the rate of the device equals CVTimeStamp/Unit or
                frame/Unit.  Thus,
        
                  rateScalar = frame/Units : Units/frame
        
              @videoTime = the time the frame was created since computer started up.
                If you turn your computer off and then turn it back on, this timer
                returns to zero.  The timer is paused when you put your computer to
                sleep.  This value is in Units not seconds.  To get the number of
                seconds this value represents, you have to apply videoTimeScale.
                
              @videoRefreshPeriod = the number of Units per frame (i.e. Units/frame)
                This is useful in calculating the frame number or frames per second.
                The documentation calls this the "nominal update period" and I am
                pretty sure that is quivalent to the aforementioned "nominal rate".
                Unfortunately, the documetation mixes naming conventions and this
                inconsistency creates confusion.
        
                  frame = videoTime / videoRefreshPeriod
        
              @videoTimeScale = Units/second, used to convert videoTime into seconds
                and may also be used with videoRefreshPeriod to calculate the expected
                framesPerSecond.  I say expected, because videoTimeScale and
                videoRefreshPeriod don't change while videoTime does change.  Thus,
                to calculate fps in the case of system slow down, one would need to
                use videoTime with videoTimeScale to calculate the actual fps value.
        
                  seconds = videoTime / videoTimeScale
        
                  framesPerSecondConstant = videoTimeScale / videoRefreshPeriod (this value does not change if their is system slowdown)
        
            USE CASE 1: Time in DD:HH:mm:ss using hostTime
              let rootTotalSeconds = inNow.pointee.hostTime
              let rootDays = inNow.pointee.hostTime / (1_000_000_000 * 60 * 60 * 24) % 365
              let rootHours = inNow.pointee.hostTime / (1_000_000_000 * 60 * 60) % 24
              let rootMinutes = inNow.pointee.hostTime / (1_000_000_000 * 60) % 60
              let rootSeconds = inNow.pointee.hostTime / 1_000_000_000 % 60
              Swift.print("rootTotalSeconds: \(rootTotalSeconds) rootDays: \(rootDays) rootHours: \(rootHours) rootMinutes: \(rootMinutes) rootSeconds: \(rootSeconds)")
        
            USE CASE 2: Time in DD:HH:mm:ss using videoTime
              let totalSeconds = inNow.pointee.videoTime / Int64(inNow.pointee.videoTimeScale)
              let days = (totalSeconds / (60 * 60 * 24)) % 365
              let hours = (totalSeconds / (60 * 60)) % 24
              let minutes = (totalSeconds / 60) % 60
              let seconds = totalSeconds % 60
              Swift.print("totalSeconds: \(totalSeconds) Days: \(days) Hours: \(hours) Minutes: \(minutes) Seconds: \(seconds)")
        
              Swift.print("fps: \(Double(inNow.pointee.videoTimeScale) / Double(inNow.pointee.videoRefreshPeriod)) seconds: \(Double(inNow.pointee.videoTime) / Double(inNow.pointee.videoTimeScale))")
             */
             
            /*  The displayLinkContext in CVDisplayLinkOutputCallback's parameter list is the
                view being driven by the CVDisplayLink.  In order to use the context as an
                instance of SwiftOpenGLView (which has our drawView() method) we need to use
                unsafeBitCast() to cast this context to a SwiftOpenGLView.
             */
             
            let view = unsafeBitCast(displayLinkContext, to: SwiftOpenGLView.self)
            //  Capture the current time in the currentTime property.
            view.currentTime = inNow.pointee.videoTime / Int64(inNow.pointee.videoTimeScale)
            view.drawView()
            
            //  We are going to assume that everything went well, and success as the CVReturn
            return kCVReturnSuccess
        }
        
        /*  Grab the a link to the active displays, set the callback defined above, and start
            the link.  An alternative to a nested function is a global function or a closure
            passed as the argument--a local function (i.e. a function defined within the
            class) is NOT allowed.  The
            UnsafeMutableRawPointer(unmanaged.passUnretained(self).toOpaque()) passes a
            pointer to an instance of SwiftOpenGLView.  UnsafeMutableRawPointer is a new type
            Swift 3.0 that does not require type definition at its creation.  For greater
            detail place the Swift Evolution notes at https://github.com/apple/swift-evolution/blob/master/proposals/0107-unsaferawpointer.md
        */
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
        CVDisplayLinkSetOutputCallback(displayLink!, displayLinkOutputCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        CVDisplayLinkStart(displayLink!)
        
        //  Test render
        
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
        // This call is not entirely necessary as the view is already
        // set to draw with every screen refresh.  Were we to have
        // used the view's display() function, then this object's
        // draw(_:) would actually be called and this our drawView()
        // within it.  As it is now, it's not based on our implementation.
        drawView()
        
    }
    
    fileprivate func drawView() {
        
        //  Grab a context, make it the active context for drawing, and then lock the focus
        //  before making OpenGL calls that change state or data within objects.
        guard let context = self.openGLContext else {
            //  Just a filler error
            Swift.print("oops")
            return
        }
        
        context.makeCurrentContext()
        CGLLockContext(context.cglContextObj!)
        
        value = sin(currentTime)
        glClearColor(value, value, value, 1.0)
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        //  glFlush() is replaced with CGLFlushDrawable() and swaps the buffer being displayed
        CGLFlushDrawable(context.cglContextObj!)
        CGLUnlockContext(context.cglContextObj!)
    }
    
    deinit {
        //  Stop the display link.  A better place to stop the link is in
        //  the viewController or windowController within functions such as
        //  windowWillClose(_:)
        CVDisplayLinkStop(displayLink!)
    }
    
}
