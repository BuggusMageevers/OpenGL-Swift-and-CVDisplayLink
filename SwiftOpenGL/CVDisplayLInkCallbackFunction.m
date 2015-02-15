//
//  CVDisplayLInkCallbackFunction.m
//  SwiftOpenGL
//
//  Created by Myles La Verne Schultz on 2/15/15.
//  Copyright (c) 2015 MyKo. All rights reserved.
//

#import "CVDisplayLinkCallbackFunction.h"
#import "SwiftOpenGL-Swift.h"


@implementation CVDisplayLinkCallbackFunction


CVDisplayLinkOutputCallback CVDLCallbackFunctionPointer()
{
    return CVDLCallbackFunction;
}


CVReturn CVDLCallbackFunction( CVDisplayLinkRef displayLink, const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext )
{
    CVReturn result = [(__bridge SwiftOpenGLView*)displayLinkContext getFrameForTime:inOutputTime];
    
    return result;
}

@end
