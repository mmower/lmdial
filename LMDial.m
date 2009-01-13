//
//  LMDial.m
//  Dial Control
//
//  Created by Matt Mower on 11/01/2009.
//  Copyright 2009 Matt Mower
//  See MIT-LICENSE for usage info
//

#import "LMDial.h"

static float PI = 3.14159265358979323846264338327950288419716939937510;

NSPoint NSRectCentre( NSRect rect ) {
  return NSMakePoint( rect.origin.x + ( rect.size.width / 2 ), rect.origin.y + ( rect.size.height/2 ) );
}

float deg2rad( float degrees ) {
  return (degrees * PI) / 180;
}

NSPoint NSPointOnCircumference( NSPoint centre, CGFloat radius, CGFloat theta ) {
  return NSMakePoint( centre.x + ( radius * cos( theta ) ), centre.y + ( radius * sin( theta ) ) );
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
  
  [offColor set];
  [[NSBezierPath bezierPathWithRect:bounds] stroke];
  
  NSBezierPath *segment = [NSBezierPath bezierPath];
  [segment setLineWidth:2.4];
  [offColor set];
  [segment appendBezierPathWithArcWithCenter:centre radius:radius startAngle:-60 endAngle:angle clockwise:NO];
  [segment stroke];
  
  segment = [NSBezierPath bezierPath];
  [segment setLineWidth:2.4];
  [onColor set];
  [segment appendBezierPathWithArcWithCenter:centre radius:radius startAngle:angle endAngle:240 clockwise:NO];
  [segment moveToPoint:centre];
  [segment lineToPoint:NSPointOnCircumference( centre, radius, theta )];
  [segment stroke];
}

- (BOOL)mouseDownCanMoveWindow {
  return NO;
}

- (BOOL)acceptsFirstMouse {
  return YES;
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
