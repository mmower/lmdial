//
//  LMDial.m
//  Dial
//
//  Created by Matt Mower on 11/01/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import "LMDial.h"

static float PI = 3.14159265358979323846264338327950288419716939937510;

NSPoint NSRectCentre( NSRect rect ) {
  return NSMakePoint( rect.origin.x + ( rect.size.width / 2 ), rect.origin.y + ( rect.size.height/2 ) );
}

float deg2rad( float degrees ) {
  return (degrees * PI) / 180;
}

@implementation LMDial

- (id)initWithFrame:(NSRect)frame {
    if( ( self = [super initWithFrame:frame] ) ) {
      value           = 0;
      minimum         = 0;
      maximum         = 100;
      stepping        = 1;
      
      backgroundColor = [NSColor grayColor];
      onColor         = [NSColor blueColor];
      offColor        = [NSColor blackColor];
    }
    return self;
}

@synthesize value;
@synthesize minimum;
@synthesize maximum;
@synthesize stepping;

@synthesize backgroundColor;
@synthesize onColor;
@synthesize offColor;

- (void)drawRect:(NSRect)rect {
  NSRect bounds  = [self bounds];
  NSPoint centre = NSRectCentre( bounds );
  CGFloat radius = bounds.size.width / 3;
  float angle    = 240 - ( 300 * (float)value / ( maximum - minimum ) );
  float theta    = deg2rad( angle );
  float cx       = radius * cos(theta);
  float cy       = radius * sin(theta);
  
  [offColor set];
  [[NSBezierPath bezierPathWithRect:bounds] stroke];
  
  NSBezierPath *segment = [NSBezierPath bezierPath];
  [segment setLineWidth:2.0];
  
  [offColor set];
  [segment appendBezierPathWithArcWithCenter:centre radius:radius startAngle:-60 endAngle:angle clockwise:NO];
  [segment stroke];
  [onColor set];
  [segment appendBezierPathWithArcWithCenter:centre radius:radius startAngle:angle endAngle:240 clockwise:NO];
  [segment moveToPoint:centre];
  [segment lineToPoint:NSMakePoint(centre.x + cx, centre.y + cy)];
  [segment stroke];
}

- (BOOL)mouseDownCanMoveWindow {
  return NO;
}

- (void)mouseDragged:(NSEvent *)event {
  value += (-[event deltaY] * stepping);
  if( value > maximum ) {
    value = maximum;
  } else if( value < minimum ) {
    value = minimum;
  }
  
  [self setNeedsDisplay:YES];
}

@end
