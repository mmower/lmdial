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
      style           = abletonLive;
      value           = 0;
      minimum         = 0;
      maximum         = 100;
      stepping        = 1;
      
      backgroundColor = [NSColor lightGrayColor];
      onBorderColor   = [NSColor blueColor];
      onFillColor     = [NSColor cyanColor];
      offBorderColor  = [NSColor blackColor];
      offFillColor    = [NSColor grayColor];
    }
    return self;
}

@synthesize style;
@synthesize value;
@synthesize minimum;
@synthesize maximum;
@synthesize stepping;

@synthesize backgroundColor;
@synthesize onBorderColor;
@synthesize onFillColor;
@synthesize offBorderColor;
@synthesize offFillColor;

- (void)drawRect:(NSRect)rect {
  NSRect bounds  = [self bounds];
  
  [backgroundColor set];
  NSRectFill( bounds );
  
  switch( style ) {
    case abletonLive:
      [self drawAbletonLiveStyleDial:bounds];
      break;
      
    case logicPro:
      [self drawLogicProStyleDial:bounds];
      break;
  }
}

- (void)drawAbletonLiveStyleDial:(NSRect)bounds {
  NSPoint centre = NSRectCentre( bounds );
  CGFloat radius = bounds.size.width / 3;
  float angle    = 240 - ( 300 * (float)value / ( maximum - minimum ) );
  
  NSBezierPath *path = [NSBezierPath bezierPath];
  [path setLineWidth:2.4];
  [offBorderColor set];
  [path appendBezierPathWithArcWithCenter:centre radius:radius startAngle:-60 endAngle:angle clockwise:NO];
  [path stroke];
  
  path = [NSBezierPath bezierPath];
  [path setLineWidth:2.4];
  [onBorderColor set];
  [path appendBezierPathWithArcWithCenter:centre radius:radius startAngle:angle endAngle:240 clockwise:NO];
  [path moveToPoint:centre];
  [path lineToPoint:NSPointOnCircumference( centre, radius, deg2rad( angle ) )];
  [path stroke];
}

- (void)drawLogicProStyleDial:(NSRect)bounds {
  NSPoint centre      = NSRectCentre( bounds );
  float angle         = 240 - ( 300 * (float)value / ( maximum - minimum ) );
  CGFloat outerRadius = bounds.size.width / 2.5;
  CGFloat innerRadius = bounds.size.width / 3;
  
  NSBezierPath *path;
  
  path = [NSBezierPath bezierPath];
  [path moveToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( 240 ) )];
  [path lineToPoint:NSPointOnCircumference( centre, outerRadius, deg2rad( 240 ) )];
  [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:240 endAngle:angle clockwise:YES];
  [path lineToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( angle ) )];
  [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:angle endAngle:240 clockwise:NO];
  
  [offFillColor set];
  [path fill];
  [offBorderColor set];
  [path stroke];
  
  path = [NSBezierPath bezierPath];
  [path moveToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( angle ) )];
  [path lineToPoint:NSPointOnCircumference( centre, outerRadius, deg2rad( angle ) )];
  [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:angle endAngle:-60 clockwise:YES];
  [path lineToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( -60 ) )];
  [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:-60 endAngle:angle clockwise:NO];
  
  [onFillColor set];
  [path fill];
  [onBorderColor set];
  [path stroke];
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
