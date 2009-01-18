//
//  LMDialView.m
//  LMDial
//
//  Created by Matt Mower on 13/01/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import "LMDialView.h"

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

@implementation LMDialView

+ (void)initialize {
  [self exposeBinding:@"value"];
  [self exposeBinding:@"minimum"];
  [self exposeBinding:@"maximum"];
  [self exposeBinding:@"stepping"];
}

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

- (id)initWithCoder:(NSCoder *)coder {
  if( ( self = [super initWithCoder:coder] ) ) {
    if( [coder containsValueForKey:@"lmdial.style"] ) {
      [self setStyle:[[coder decodeObjectForKey:@"lmdial.style"] intValue]];
    } else {
      [self setStyle:abletonLive];
    }
    
    if( [coder containsValueForKey:@"lmdial.value"] ) {
      [self setValue:[[coder decodeObjectForKey:@"lmdial.value"] intValue]];
    } else {
      [self setValue:0];
    }
    
    if( [coder containsValueForKey:@"lmdial.minimum"] ) {
      [self setMinimum:[[coder decodeObjectForKey:@"lmdial.minimum"] intValue]];
    } else {
      [self setMinimum:0];
    }
    
    if( [coder containsValueForKey:@"lmdial.maximum"] ) {
      [self setMaximum:[[coder decodeObjectForKey:@"lmdial.maximum"] intValue]];
    } else {
      [self setMaximum:100];
    }
    
    if( [coder containsValueForKey:@"lmdial.stepping"] ) {
      [self setStepping:[[coder decodeObjectForKey:@"lmdial.stepping"] intValue]];
    } else {
      [self setStepping:1];
    }
    
    if( [coder containsValueForKey:@"lmdial.backgroundColor"] ) {
      backgroundColor = [coder decodeObjectForKey:@"lmdial.backgroundColor"];
    } else {
      backgroundColor = [NSColor lightGrayColor];
    }
    
    if( [coder containsValueForKey:@"lmdial.onBorderColor"] ) {
      onBorderColor = [coder decodeObjectForKey:@"lmdial.onBorderColor"];
    } else {
      onBorderColor = [NSColor blueColor];
    }
    
    if( [coder containsValueForKey:@"lmdial.onFillColor"] ) {
      onFillColor = [coder decodeObjectForKey:@"lmdial.onFillColor"];
    } else {
      onFillColor = [NSColor cyanColor];
    }
    
    if( [coder containsValueForKey:@"lmdial.offBorderColor"] ) {
      offBorderColor = [coder decodeObjectForKey:@"lmdial.offBorderColor"];
    } else {
      offBorderColor = [NSColor blackColor];
    }
    
    if( [coder containsValueForKey:@"lmdial.offFillColor"] ) {
      offFillColor = [coder decodeObjectForKey:@"lmdial.offFillColor"];
    } else {
      offFillColor = [NSColor grayColor];
    }
  }
  
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  
  [coder encodeObject:[NSNumber numberWithInt:[self style]] forKey:@"lmdial.style"];
  [coder encodeObject:[NSNumber numberWithInt:[self value]] forKey:@"lmdial.value"];
  [coder encodeObject:[NSNumber numberWithInt:[self minimum]] forKey:@"lmdial.minimum"];
  [coder encodeObject:[NSNumber numberWithInt:[self maximum]] forKey:@"lmdial.maximum"];
  [coder encodeObject:[NSNumber numberWithInt:[self stepping]] forKey:@"lmdial.stepping"];
  [coder encodeObject:backgroundColor forKey:@"lmdial.backgroundColor"];
  [coder encodeObject:onBorderColor forKey:@"lmdial.onBorderColor"];
  [coder encodeObject:onFillColor forKey:@"lmdial.onFillColor"];
  [coder encodeObject:offBorderColor forKey:@"lmdial.offBorderColor"];
  [coder encodeObject:offFillColor forKey:@"lmdial.offFillColor"];
}

// - (Class)valueClassForBinding:(NSString *)binding {
//   if( [binding isEqualToString:@"value"] ||
//       [binding isEqualToString:@"minimum"] ||
//       [binding isEqualToString:@"maximum"] ||
//       [binding isEqualToString:@"stepping"] ) {
//     return [NSNumber class];
//   } else {
//     return [super valueClassForBinding:binding];
//   }
// }

@dynamic style;

- (LMDialStyle)style {
  return style;
}

- (void)setStyle:(LMDialStyle)newStyle {
  [self willChangeValueForKey:@"style"];
  style = newStyle;
  [self didChangeValueForKey:@"style"];
  [self setNeedsDisplay:YES];
}

@dynamic value;

- (int)value {
  return value;
}

- (void)setValue:(int)newValue {
  [self willChangeValueForKey:@"value"];
  value = newValue;
  [self didChangeValueForKey:@"value"];
  [self setNeedsDisplay:YES];
}

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
  int newValue = [self value] + (-[event deltaY] * stepping);
  if( newValue > maximum ) {
    newValue = maximum;
  } else if( newValue < minimum ) {
    newValue = minimum;
  }
  [self setValue:newValue];
  [self updateBoundValue];
}

- (void)updateBoundValue {
  NSDictionary *binding = [self infoForBinding:@"value"];
  id controller = [binding objectForKey:NSObservedObjectKey];
  NSString *keyPath = [binding objectForKey:NSObservedKeyPathKey];
  [controller setValue:[NSNumber numberWithInt:value] forKeyPath:keyPath];
}

@end
