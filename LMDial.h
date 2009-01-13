//
//  LMDial.h
//  Dial Control
//
//  Created by Matt Mower on 11/01/2009.
//  Copyright 2009 Matt Mower
//  See MIT-LICENSE for usage info
//

#import <Cocoa/Cocoa.h>

typedef enum tagLMDialStyle {
  abletonLive,
  logicPro
} LMDialStyle;

@interface LMDial : NSView {
  LMDialStyle style;
  int         minimum;
  int         maximum;
  int         stepping;
  int         value;
  
  NSColor     *backgroundColor;
  NSColor     *onBorderColor;
  NSColor     *onFillColor;
  NSColor     *offBorderColor;
  NSColor     *offFillColor;
}

@property LMDialStyle style;
@property int minimum;
@property int maximum;
@property int stepping;
@property int value;

@property (assign) NSColor *backgroundColor;
@property (assign) NSColor *onBorderColor;
@property (assign) NSColor *onFillColor;
@property (assign) NSColor *offBorderColor;
@property (assign) NSColor *offFillColor;

- (void)drawAbletonLiveStyleDial:(NSRect)rect;
- (void)drawLogicProStyleDial:(NSRect)rect;

@end
