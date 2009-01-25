//
//  LMDialEditWindow.h
//  LMDial
//
//  Created by Matt Mower on 25/01/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class LMDialView;

@interface LMDialEditWindow : NSWindow {
  __weak  NSWindow          *parentWindow;
          NSViewController  *viewController;
}

- (id)initForDialView:(LMDialView *)dialView inWindow:(NSWindow *)parentWindow;

@end
