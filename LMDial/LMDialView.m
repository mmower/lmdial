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

@interface LMDialView ()

- (void)editValue;
- (void)updateValueText;
- (void)updateBoundValue;
- (void)updateLocalColors;

- (void)drawValue:(NSRect)bounds;
- (void)drawText:(NSString *)text boundedBy:(NSRect)bounds;
- (void)drawAbletonLiveStyleDial:(NSRect)bounds;
- (void)drawLogicProStyleDial:(NSRect)bounds;
- (void)drawLogicPanStyleDial:(NSRect)bounds;

@end

@implementation LMDialView

+ (void)initialize {
  [self exposeBinding:@"enabled"];
  [self exposeBinding:@"value"];
  [self exposeBinding:@"minimum"];
  [self exposeBinding:@"maximum"];
  [self exposeBinding:@"stepping"];
  [self exposeBinding:@"divisor"];
  [self exposeBinding:@"formatter"];
}

- (void)dealloc {
  [formatter release];
  [valueText release];
  [super dealloc];
}

- (id)initWithFrame:(NSRect)frame {
  if( ( self = [super initWithFrame:frame] ) ) {
    enabled         = YES;
    style           = abletonLive;
    value           = 0;
    minimum         = 0;
    maximum         = 100;
    stepping        = 1;
    showValue       = YES;
    
    onBorderColor   = [NSColor blueColor];
    onFillColor     = [NSColor cyanColor];
    offBorderColor  = [NSColor blackColor];
    offFillColor    = [NSColor grayColor];
    valueColor      = [NSColor blackColor];
    
    divisor         = 1;
    formatter       = [@"%+d" retain];
    
    fontSize        = 6.0;
  }
  
  return self;
}

#pragma mark NSCoder implementation

- (id)initWithCoder:(NSCoder *)coder {
  if( ( self = [super initWithCoder:coder] ) ) {
    if( [coder containsValueForKey:@"lmdial.enabled"] ) {
      [self setEnabled:[[coder decodeObjectForKey:@"lmdial.enabled"] boolValue]];
    } else {
      [self setEnabled:YES];
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
      [self setShowValue:[[coder decodeObjectForKey:@"lmdial.showValue"] boolValue]];
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
    
    if( [coder containsValueForKey:@"lmdial.formatter"] ) {
      [self setFormatter:[coder decodeObjectForKey:@"lmdial.formatter"]];
    } else {
      [self setFormatter:@"%+d"];
    }
    
    if( [coder containsValueForKey:@"lmdial.divisor"] ) {
      [self setDivisor:[[coder decodeObjectForKey:@"lmdial.divisor"] intValue]];
    } else {
      [self setDivisor:1];
    }
    
    if( [coder containsValueForKey:@"lmdial.style"] ) {
      [self setStyle:(LMDialStyle)[[coder decodeObjectForKey:@"lmdial.style"] intValue]];
    } else {
      [self setStyle:abletonLive];
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
    
    // Initialize the value last and, especially, after the formatter (since, if it's null, we'll get an exception)
    if( [coder containsValueForKey:@"lmdial.value"] ) {
      [self setValue:[[coder decodeObjectForKey:@"lmdial.value"] intValue]];
    } else {
      [self setValue:0];
    }
  }
  
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [super encodeWithCoder:coder];
  
  [coder encodeObject:[NSNumber numberWithBool:[self enabled]] forKey:@"lmdial.enabled"];
  [coder encodeObject:[NSNumber numberWithInt:[self style]] forKey:@"lmdial.style"];
  [coder encodeObject:[NSNumber numberWithInt:[self value]] forKey:@"lmdial.value"];
  [coder encodeObject:[NSNumber numberWithInt:[self minimum]] forKey:@"lmdial.minimum"];
  [coder encodeObject:[NSNumber numberWithInt:[self maximum]] forKey:@"lmdial.maximum"];
  [coder encodeObject:[NSNumber numberWithInt:[self stepping]] forKey:@"lmdial.stepping"];
  [coder encodeObject:onBorderColor forKey:@"lmdial.onBorderColor"];
  [coder encodeObject:onFillColor forKey:@"lmdial.onFillColor"];
  [coder encodeObject:offBorderColor forKey:@"lmdial.offBorderColor"];
  [coder encodeObject:offFillColor forKey:@"lmdial.offFillColor"];
  [coder encodeObject:valueColor forKey:@"lmdial.valueColor"];
  [coder encodeObject:[NSNumber numberWithFloat:[self fontSize]] forKey:@"lmdial.fontSize"];
  [coder encodeObject:[NSNumber numberWithBool:[self showValue]] forKey:@"lmdial.showValue"];
  [coder encodeObject:formatter forKey:@"lmdial.formatter"];
  [coder encodeObject:[NSNumber numberWithInt:[self divisor]] forKey:@"lmdial.divisor"];
}

#pragma mark Properties

@dynamic enabled;

- (BOOL)enabled {
  return enabled;
}

- (void)setEnabled:(BOOL)nowEnabled {
  if( nowEnabled != enabled ) {
    enabled = nowEnabled;
    alpha = enabled ? 1.0 : 0.5;
    [self updateLocalColors];
    [self setNeedsDisplay:YES];
  }
}

@dynamic style;

- (LMDialStyle)style {
  return style;
}

- (void)setStyle:(LMDialStyle)newStyle {
  style = newStyle;
  [self setNeedsDisplay:YES];
}

@dynamic value;

- (int)value {
  return value;
}

- (void)setValue:(int)newValue {
  if( newValue > maximum ) {
    newValue = maximum;
  } else if( newValue < minimum ) {
    newValue = minimum;
  }
  value = newValue;
  [self updateValueText];
  [self setNeedsDisplay:YES];
}

@dynamic minimum;

- (int)minimum {
  return minimum;
}

- (void)setMinimum:(int)newMinimum {
  minimum = newMinimum;
  
  if( value < minimum ) {
    [self setValue:minimum];
  }
  [self setNeedsDisplay:YES];
}

@dynamic maximum;

- (int)maximum {
  return maximum;
}

- (void)setMaximum:(int)newMaximum {
  maximum = newMaximum;
  
  if( value > maximum ) {
    [self setValue:maximum];
  }
  [self setNeedsDisplay:YES];
}

@dynamic divisor;

- (int)divisor {
  return divisor;
}

- (void)setDivisor:(int)newDivisor {
  divisor = newDivisor;
  [self updateValueText];
  [self setNeedsDisplay:YES];
}

@dynamic formatter;

- (NSString *)formatter {
  return formatter;
}

- (void)setFormatter:(NSString *)newFormatter {
  [formatter release];
  formatter = [newFormatter copy];
  [self updateValueText];
  [self setNeedsDisplay:YES];
}

@synthesize stepping;

@dynamic showValue;

- (BOOL)showValue {
  return showValue;
}

- (void)setShowValue:(BOOL)nowShowValue {
  showValue = nowShowValue;
  [self setNeedsDisplay:YES];
}

@dynamic onBorderColor;

- (NSColor *)onBorderColor {
  return onBorderColor;
}

- (void)setOnBorderColor:(NSColor *)newOnBorderColor {
  [onBorderColor release];
  onBorderColor = [newOnBorderColor retain];
  [localOnBorderColor release];
  localOnBorderColor = [[onBorderColor colorWithAlphaComponent:alpha] retain];
  [self setNeedsDisplay:YES];
}

@dynamic onFillColor;

- (NSColor *)onFillColor {
  return onFillColor;
}

- (void)setOnFillColor:(NSColor *)newOnFillColor {
  [onFillColor release];
  onFillColor = [newOnFillColor retain];
  [localOnFillColor release];
  localOnFillColor = [[onFillColor colorWithAlphaComponent:alpha] retain];
  [self setNeedsDisplay:YES];
}

@dynamic offBorderColor;

- (NSColor *)offBorderColor {
  return offBorderColor;
}

- (void)setOffBorderColor:(NSColor *)newOffBorderColor {
  [offBorderColor release];
  offBorderColor = [newOffBorderColor retain];
  [localOffBorderColor release];
  localOffBorderColor = [[offBorderColor colorWithAlphaComponent:alpha] retain];
  [self setNeedsDisplay:YES];
}

@dynamic offFillColor;

- (NSColor *)offFillColor {
  return offFillColor;
}

- (void)setOffFillColor:(NSColor *)newOffFillColor {
  [offFillColor release];
  offFillColor = [newOffFillColor retain];
  [localOffFillColor release];
  localOffFillColor = [[offFillColor colorWithAlphaComponent:alpha] retain];
  [self setNeedsDisplay:YES];
}

@dynamic valueColor;

- (NSColor *)valueColor {
  return valueColor;
}

- (void)setValueColor:(NSColor *)newValueColor {
  valueColor = newValueColor;
  [self setNeedsDisplay:YES];
}

@dynamic fontSize;

- (CGFloat)fontSize {
  return fontSize;
}

- (void)setFontSize:(CGFloat)newFontSize {
  fontSize = newFontSize;
  [self setNeedsDisplay:YES];
}

#pragma mark Drawing Code

- (void)drawRect:(NSRect)rect {
  NSRect bounds  = [self bounds];
  
  switch( style ) {
    case abletonLive:
      [self drawAbletonLiveStyleDial:bounds];
      break;
      
    case logicPro:
      [self drawLogicProStyleDial:bounds];
      break;
    
    case logicPan:
      [self drawLogicPanStyleDial:bounds];
      break;
  }
}

- (void)drawAbletonLiveStyleDial:(NSRect)bounds {
  NSPoint centre = NSRectCentre( bounds );
  CGFloat radius = bounds.size.width / 3;
  float angle    = 240 - ( 300 * ((float)( value - minimum )) / ( maximum - minimum ) );
  
  NSBezierPath *path = [NSBezierPath bezierPath];
  [path setLineWidth:2.4];
  [localOffBorderColor set];
  [path appendBezierPathWithArcWithCenter:centre radius:radius startAngle:-60 endAngle:angle clockwise:NO];
  [path stroke];
  
  path = [NSBezierPath bezierPath];
  [path setLineWidth:2.4];
  [localOnBorderColor set];
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
  
  NSBezierPath *path;
  
  path = [NSBezierPath bezierPath];
  [path moveToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( 270 ) )];
  [path lineToPoint:NSPointOnCircumference( centre, outerRadius, deg2rad( 270 ) )];
  [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:270 endAngle:angle clockwise:YES];
  [path lineToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( angle ) )];
  [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:angle endAngle:270 clockwise:NO];
  
  [localOnFillColor set];
  [path fill];
  [localOnBorderColor set];
  [path stroke];
  
  path = [NSBezierPath bezierPath];
  [path moveToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( angle ) )];
  [path lineToPoint:NSPointOnCircumference( centre, outerRadius, deg2rad( angle ) )];
  [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:angle endAngle:-90 clockwise:YES];
  [path lineToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( -90 ) )];
  [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:-90 endAngle:angle clockwise:NO];
  
  [localOffFillColor set];
  [path fill];
  [localOffBorderColor set];
  [path stroke];
  
  if( showValue ) {
    [self drawValue:bounds];
  }
}

// For the moment we assuming zero point = 0 && minimum = maximum
- (void)drawLogicPanStyleDial:(NSRect)bounds {
  NSPoint centre      = NSRectCentre( bounds );
  CGFloat outerRadius = bounds.size.width / 2.5;
  CGFloat innerRadius = bounds.size.width / 3.5;
  
  NSBezierPath *path;
  
  // Draw the bottom "stopper" segement
  path = [NSBezierPath bezierPath];
  
  [path moveToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( -60 ) )];
  [path lineToPoint:NSPointOnCircumference( centre, outerRadius, deg2rad( -60 ) )];
  [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:-60 endAngle:-120 clockwise:YES];
  [path lineToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( -120 ) )];
  [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:-120 endAngle:-60 clockwise:NO];
  
  [localOffFillColor set];
  [path fill];
  [localOffBorderColor set];
  [path stroke];
  
  if( value < 0 ) {
    // Draw positive segement complete
    path = [NSBezierPath bezierPath];

    [path moveToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( 90 ) )];
    [path lineToPoint:NSPointOnCircumference( centre, outerRadius, deg2rad( 90 ) )];
    [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:90 endAngle:-60 clockwise:YES];
    [path lineToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( -60 ) )];
    [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:-60 endAngle:90 clockwise:NO];
    
    [localOffFillColor set];
    [path fill];
    [localOffBorderColor set];
    [path stroke];
    
    float angle = 90 + ( 150 * ( (float)( abs(minimum) - ( value - minimum ) ) / abs(minimum) ) );
    path = [NSBezierPath bezierPath];

    [path moveToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( angle ) )];
    [path lineToPoint:NSPointOnCircumference( centre, outerRadius, deg2rad( angle ) )];
    [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:angle endAngle:90 clockwise:YES];
    [path lineToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( 90 ) )];
    [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:90 endAngle:angle clockwise:NO];
    
    [localOnFillColor set];
    [path fill];
    [localOnBorderColor set];
    [path stroke];
    
    path = [NSBezierPath bezierPath];
    
    [path moveToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( 240 ) )];
    [path lineToPoint:NSPointOnCircumference( centre, outerRadius, deg2rad( 240 ) )];
    [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:240 endAngle:angle clockwise:YES];
    [path lineToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( angle ) )];
    [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:angle endAngle:240 clockwise:NO];
    
    [localOffFillColor set];
    [path fill];
    [localOffBorderColor set];
    [path stroke];
  } else {
    // Draw positive segement complete
    path = [NSBezierPath bezierPath];

    [path moveToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( 240 ) )];
    [path lineToPoint:NSPointOnCircumference( centre, outerRadius, deg2rad( 240 ) )];
    [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:240 endAngle:90 clockwise:YES];
    [path lineToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( 90 ) )];
    [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:90 endAngle:240 clockwise:NO];
    
    [localOffFillColor set];
    [path fill];
    [localOffBorderColor set];
    [path stroke];
    
    float angle = -60 + ( 150 * ( (float)( maximum - value ) / maximum ) );
    
    path = [NSBezierPath bezierPath];

    [path moveToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( 90 ) )];
    [path lineToPoint:NSPointOnCircumference( centre, outerRadius, deg2rad( 90 ) )];
    [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:90 endAngle:angle clockwise:YES];
    [path lineToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( angle ) )];
    [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:angle endAngle:90 clockwise:NO];
    
    [localOnFillColor set];
    [path fill];
    [localOnBorderColor set];
    [path stroke];
    
    path = [NSBezierPath bezierPath];

    [path moveToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( angle ) )];
    [path lineToPoint:NSPointOnCircumference( centre, outerRadius, deg2rad( angle ) )];
    [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:angle endAngle:-60 clockwise:YES];
    [path lineToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( -60 ) )];
    [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:-60 endAngle:angle clockwise:NO];
    
    [localOffFillColor set];
    [path fill];
    [localOffBorderColor set];
    [path stroke];
  }
  
  if( showValue ) {
    [self drawValue:bounds];
  }
}

- (void)drawValue:(NSRect)bounds {
  [self drawText:valueText boundedBy:bounds];
}

- (void)drawText:(NSString *)text boundedBy:(NSRect)bounds {
  NSFont *textFont = [NSFont labelFontOfSize:[self fontSize]];
  
  NSColor *localValueColor = [valueColor colorWithAlphaComponent:([self enabled] ? 1.0 : 0.5)];
  
  NSMutableDictionary *textAttributes = [[[NSMutableDictionary alloc] init] autorelease];
  [textAttributes setObject:textFont forKey:NSFontAttributeName];
  [textAttributes setObject:localValueColor forKey:NSForegroundColorAttributeName];
  
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

- (void)mouseDown:(NSEvent *)event {
  if( [event clickCount] == 2 && [self enabled] ) {
    [self editValue];
  }
}

- (void)mouseDragged:(NSEvent *)event {
  if( [self enabled] ) {
    int multiplier = 1;
    
    if( [event modifierFlags] & NSControlKeyMask ) {
      multiplier *= 2;
    }
    
    if( [event modifierFlags] & NSAlternateKeyMask ) {
      multiplier *= 5;
    }
    
    if( [event modifierFlags] & NSCommandKeyMask ) {
      multiplier *= 10;
    }
    
    int newValue = [self value] + (-[event deltaY] * stepping * multiplier);
    if( newValue > maximum ) {
      newValue = maximum;
    } else if( newValue < minimum ) {
      newValue = minimum;
    }
    [self setValue:newValue];
    [self updateBoundValue];
  }
}

- (void)updateBoundValue {
  NSDictionary *binding = [self infoForBinding:@"value"];
  id controller = [binding objectForKey:NSObservedObjectKey];
  NSString *keyPath = [binding objectForKey:NSObservedKeyPathKey];
  [controller setValue:[NSNumber numberWithInt:value] forKeyPath:keyPath];
}

- (void)editValue {
  valueEditor = [[NSTextField alloc] initWithFrame:NSZeroRect];
  NSRect editorFrame = NSMakeRect( [self frame].origin.x, [self frame].origin.y + [self frame].size.height / 4, [self frame].size.width, [[valueEditor font] boundingRectForFont].size.height );
  [valueEditor setFrame:editorFrame];
  
  [valueEditor setDelegate:self];
  [valueEditor bind:@"value" toObject:self withKeyPath:@"value" options:nil];
  [[[self window] contentView] addSubview:valueEditor];
  [[self window] makeFirstResponder:valueEditor];
}

- (void)controlTextDidEndEditing:(NSNotification *)notification {
  [valueEditor removeFromSuperview];
  [valueEditor autorelease];
  [self setEnabled:YES];
  [self updateBoundValue];
}

- (void)updateValueText {
  [valueText release];
  
  if( divisor > 1 ) {
    valueText = [[NSString stringWithFormat:formatter,(((float)value) / divisor)] retain];
  } else {
    valueText = [[NSString stringWithFormat:formatter,value] retain];
  }
}

- (void)updateLocalColors {
  [localOnBorderColor release];
  localOnBorderColor = [[onBorderColor colorWithAlphaComponent:alpha] retain];
  [localOnFillColor release];
  localOnFillColor = [[onFillColor colorWithAlphaComponent:alpha] retain];
  [localOffBorderColor release];
  localOffBorderColor = [[offBorderColor colorWithAlphaComponent:alpha] retain];
  [localOffFillColor release];
  localOffFillColor = [[offFillColor colorWithAlphaComponent:alpha] retain];
}

@end
