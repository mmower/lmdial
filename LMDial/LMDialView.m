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
  return NSMakePoint( rect.origin.x + ( rect.size.width / 2 ), rect.origin.y + ( rect.size.height / 2 ) );
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
    showValue       = YES;
    
    backgroundColor = [NSColor lightGrayColor];
    onBorderColor   = [NSColor blueColor];
    onFillColor     = [NSColor cyanColor];
    offBorderColor  = [NSColor blackColor];
    offFillColor    = [NSColor grayColor];
    valueColor      = [NSColor blackColor];
    
    fontSize        = 6.0;
  }
  
  return self;
}

#pragma mark NSCoder implementation

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
      [self setBackgroundColor:[coder decodeObjectForKey:@"lmdial.backgroundColor"]];
    } else {
      [self setBackgroundColor:[NSColor lightGrayColor]];
    }
    
    if( [coder containsValueForKey:@"lmdial.onBorderColor"] ) {
      [self setOnBorderColor:[coder decodeObjectForKey:@"lmdial.onBorderColor"]];
    } else {
      [self setOnBorderColor:[NSColor blueColor]];
    }
    
    if( [coder containsValueForKey:@"lmdial.onFillColor"] ) {
      [self setOnFillColor:[coder decodeObjectForKey:@"lmdial.onFillColor"]];
    } else {
      [self setOnFillColor:[NSColor cyanColor]];
    }
    
    if( [coder containsValueForKey:@"lmdial.offBorderColor"] ) {
      [self setOffBorderColor:[coder decodeObjectForKey:@"lmdial.offBorderColor"]];
    } else {
      [self setOffBorderColor:[NSColor blackColor]];
    }
    
    if( [coder containsValueForKey:@"lmdial.offFillColor"] ) {
      [self setOffFillColor:[coder decodeObjectForKey:@"lmdial.offFillColor"]];
    } else {
      [self setOffFillColor:[NSColor grayColor]];
    }
    
    if( [coder containsValueForKey:@"lmdial.showValue"] ) {
      [self setShowValue:[[coder decodeObjectForKey:@"lmdial.showValue"] intValue]];
    } else {
      [self setShowValue:YES];
    }
    
    if( [coder containsValueForKey:@"lmdial.valueColor"] ) {
      [self setValueColor:[coder decodeObjectForKey:@"lmdial.valueColor"]];
    } else {
      [self setValueColor:[NSColor blackColor]];
    }
    
    if( [coder containsValueForKey:@"lmdial.fontSize"] ) {
      [self setFontSize:[[coder decodeObjectForKey:@"lmdial.fontSize"] floatValue]];
    } else {
      [self setFontSize:6.0];
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
  [coder encodeObject:valueColor forKey:@"lmdial.valueColor"];
  [coder encodeObject:[NSNumber numberWithFloat:[self fontSize]] forKey:@"lmdial.fontSize"];
  [coder encodeObject:[NSNumber numberWithInt:[self showValue]] forKey:@"lmdial.showValue"];
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

#pragma mark Properties

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

@dynamic minimum;

- (int)minimum {
  return minimum;
}

- (void)setMinimum:(int)newMinimum {
  [self willChangeValueForKey:@"minimum"];
  minimum = newMinimum;
  [self didChangeValueForKey:@"minimum"];
  
  if( value < minimum ) {
    [self setValue:minimum];
  } else {
    [self setNeedsDisplay:YES];
  }
}

@dynamic maximum;

- (int)maximum {
  return maximum;
}

- (void)setMaximum:(int)newMaximum {
  [self willChangeValueForKey:@"maximum"];
  maximum = newMaximum;
  [self didChangeValueForKey:@"maximum"];
  
  if( value > maximum ) {
    [self setValue:maximum];
  } else {
    [self setNeedsDisplay:YES];
  }
}

@synthesize stepping;

@dynamic showValue;

- (BOOL)showValue {
  return showValue;
}

- (void)setShowValue:(BOOL)nowShowValue {
  [self willChangeValueForKey:@"showValue"];
  showValue = nowShowValue;
  [self didChangeValueForKey:@"showValue"];
  [self setNeedsDisplay:YES];
}

@dynamic backgroundColor;

- (NSColor *)backgroundColor {
  return backgroundColor;
}

- (void)setBackgroundColor:(NSColor *)newBackgroundColor {
  [self willChangeValueForKey:@"backgroundColor"];
  backgroundColor = newBackgroundColor;
  [self didChangeValueForKey:@"backgroundColor"];
  [self setNeedsDisplay:YES];
}

@dynamic onBorderColor;

- (NSColor *)onBorderColor {
  return onBorderColor;
}

- (void)setOnBorderColor:(NSColor *)newOnBorderColor {
  [self willChangeValueForKey:@"onBorderColor"];
  onBorderColor = newOnBorderColor;
  [self didChangeValueForKey:@"onBorderColor"];
  [self setNeedsDisplay:YES];
}

@dynamic onFillColor;

- (NSColor *)onFillColor {
  return onFillColor;
}

- (void)setOnFillColor:(NSColor *)newOnFillColor {
  [self willChangeValueForKey:@"onFillColor"];
  onFillColor = newOnFillColor;
  [self didChangeValueForKey:@"onFillColor"];
  [self setNeedsDisplay:YES];
}

@dynamic offBorderColor;

- (NSColor *)offBorderColor {
  return offBorderColor;
}

- (void)setOffBorderColor:(NSColor *)newOffBorderColor {
  [self willChangeValueForKey:@"offBorderColor"];
  offBorderColor = newOffBorderColor;
  [self didChangeValueForKey:@"offBorderColor"];
  [self setNeedsDisplay:YES];
}

@dynamic offFillColor;

- (NSColor *)offFillColor {
  return offFillColor;
}

- (void)setOffFillColor:(NSColor *)newOffFillColor {
  [self willChangeValueForKey:@"offFillColor"];
  offFillColor = newOffFillColor;
  [self didChangeValueForKey:@"offFillColor"];
  [self setNeedsDisplay:YES];
}

@dynamic valueColor;

- (NSColor *)valueColor {
  return valueColor;
}

- (void)setValueColor:(NSColor *)newValueColor {
  [self willChangeValueForKey:@"valueColor"];
  valueColor = newValueColor;
  [self didChangeValueForKey:@"valueColor"];
  [self setNeedsDisplay:YES];
}

@dynamic fontSize;

- (CGFloat)fontSize {
  return fontSize;
}

- (void)setFontSize:(CGFloat)newFontSize {
  [self willChangeValueForKey:@"fontSize"];
  fontSize = newFontSize;
  [self didChangeValueForKey:@"fontSize"];
  [self setNeedsDisplay:YES];
}

#pragma mark Drawing Code

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
  float angle    = 240 - ( 300 * ((float)( value - minimum )) / ( maximum - minimum ) );
  
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
  float angle         = 270 - ( 360 * ((float)( value - minimum )) / ( maximum - minimum ) );
  CGFloat outerRadius = bounds.size.width / 2.5;
  CGFloat innerRadius = bounds.size.width / 3.5;
  
  NSLog( @"value = %d / angle = %f", value, angle );
  
  NSBezierPath *path;
  
  path = [NSBezierPath bezierPath];
  [path moveToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( 270 ) )];
  [path lineToPoint:NSPointOnCircumference( centre, outerRadius, deg2rad( 270 ) )];
  [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:270 endAngle:angle clockwise:YES];
  [path lineToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( angle ) )];
  [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:angle endAngle:270 clockwise:NO];
  
  [onFillColor set];
  [path fill];
  [onBorderColor set];
  [path stroke];
  
  path = [NSBezierPath bezierPath];
  [path moveToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( angle ) )];
  [path lineToPoint:NSPointOnCircumference( centre, outerRadius, deg2rad( angle ) )];
  [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:angle endAngle:-90 clockwise:YES];
  [path lineToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( -90 ) )];
  [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:-90 endAngle:angle clockwise:NO];
  
  [offFillColor set];
  [path fill];
  [offBorderColor set];
  [path stroke];
  
  if( showValue ) {
    [self drawValue:bounds];
  }
}

- (void)drawValue:(NSRect)bounds {
  NSLog( @"display value-3" );
  
  NSString *valueText;
  if( value > 0 ) {
    valueText = [NSString stringWithFormat:@"+%d",value];
  } else {
    valueText = [[NSNumber numberWithInt:value] stringValue];
  }
  
  [self drawText:valueText boundedBy:bounds];
}

- (void)drawText:(NSString *)text boundedBy:(NSRect)bounds {
  NSFont *textFont = [NSFont labelFontOfSize:[self fontSize]];
  
  NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] init];
  [textAttributes setObject:textFont forKey:NSFontAttributeName];
  [textAttributes setObject:valueColor forKey:NSForegroundColorAttributeName];
  
  NSSize textSize = [text sizeWithAttributes:textAttributes];
  NSPoint textOrigin = NSRectCentre( bounds );
  textOrigin.x -= textSize.width / 2;
  textOrigin.y -= textSize.height / 2;
  
  [text drawAtPoint:textOrigin withAttributes:textAttributes];
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
