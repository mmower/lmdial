//
//  LMDial.h
//  Dial Control
//
//  Created by Matt Mower on 11/01/2009.
//  Copyright 2009 Matt Mower
//  See MIT-LICENSE for usage info
//

#import <Cocoa/Cocoa.h>

@interface LMDial : NSView {
  int     minimum;
  int     maximum;
  int     stepping;
  int     value;
  
  NSColor *backgroundColor;
  NSColor *onColor;
  NSColor *offColor;
}

@property int minimum;
@property int maximum;
@property int stepping;
@property int value;

@property (assign) NSColor *backgroundColor;
@property (assign) NSColor *onColor;
@property (assign) NSColor *offColor;

@end
