//
//  CVDisplayLInkCallbackFunction.h
//  SwiftOpenGL
//
//  Created by Myles La Verne Schultz on 2/15/15.
//  Copyright (c) 2015 MyKo. All rights reserved.
//

@import Foundation;
@import QuartzCore.CVDisplayLink;


@interface CVDisplayLinkCallbackFunction : NSObject

CVDisplayLinkOutputCallback CVDLCallbackFunctionPointer();

@end
