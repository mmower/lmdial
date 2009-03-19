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
  [mFormatter release];
  [mValueText release];
  [mOnBorderColor release];
  [mLocalOnBorderColor release];
  [mOnFillColor release];
  [mLocalOnFillColor release];
  [mOffBorderColor release];
  [mOffFillColor release];
  [mLocalOffBorderColor release];
  [mLocalOffFillColor release];
  [mValueColor release];
  [super dealloc];
}

- (id)initWithFrame:(NSRect)frame {
  if( ( self = [super initWithFrame:frame] ) ) {
    mEnabled        = YES;
    mStyle          = abletonLive;
    mValue          = 0;
    mMinimum        = 0;
    mMaximum        = 100;
    mStepping       = 1;
    mShowValue      = YES;
    
    mOnBorderColor  = [NSColor blueColor];
    mOnFillColor    = [NSColor cyanColor];
    mOffBorderColor = [NSColor blackColor];
    mOffFillColor   = [NSColor grayColor];
    mValueColor     = [NSColor blackColor];
    
    mDivisor        = 1;
    mFormatter      = [@"%+d" retain];
    
    mFontSize       = 6.0;
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
  [coder encodeObject:[self onBorderColor] forKey:@"lmdial.onBorderColor"];
  [coder encodeObject:[self onFillColor] forKey:@"lmdial.onFillColor"];
  [coder encodeObject:[self offBorderColor] forKey:@"lmdial.offBorderColor"];
  [coder encodeObject:[self offFillColor] forKey:@"lmdial.offFillColor"];
  [coder encodeObject:[self valueColor] forKey:@"lmdial.valueColor"];
  [coder encodeObject:[NSNumber numberWithFloat:[self fontSize]] forKey:@"lmdial.fontSize"];
  [coder encodeObject:[NSNumber numberWithBool:[self showValue]] forKey:@"lmdial.showValue"];
  [coder encodeObject:[self formatter] forKey:@"lmdial.formatter"];
  [coder encodeObject:[NSNumber numberWithInt:[self divisor]] forKey:@"lmdial.divisor"];
}

#pragma mark Properties

@synthesize mEnabled;

- (void)setEnabled:(BOOL)enabled {
  if( enabled != mEnabled ) {
    mEnabled = enabled;
    mAlpha = mEnabled ? 1.0 : 0.5;
    [self updateLocalColors];
    [self setNeedsDisplay:YES];
  }
}

@synthesize mStyle;

- (void)setStyle:(LMDialStyle)style {
  mStyle = style;
  [self setNeedsDisplay:YES];
}

@synthesize mValue;

- (void)setValue:(int)value {
  if( value > [self maximum] ) {
    value = [self maximum];
  } else if( value < [self minimum] ) {
    value = [self minimum];
  }
  mValue = value;
  [self updateValueText];
  [self setNeedsDisplay:YES];
}

@synthesize mMinimum;

- (void)setMinimum:(int)minimum {
  mMinimum = minimum;
  
  if( [self value] < mMinimum ) {
    [self setValue:mMinimum];
  }
  [self setNeedsDisplay:YES];
}

@synthesize mMaximum;

- (void)setMaximum:(int)maximum {
  mMaximum = maximum;
  
  if( [self value] > mMaximum ) {
    [self setValue:mMaximum];
  }
  [self setNeedsDisplay:YES];
}

@synthesize mDivisor;

- (void)setDivisor:(int)divisor {
  mDivisor = divisor;
  [self updateValueText];
  [self setNeedsDisplay:YES];
}

@synthesize mFormatter;

- (void)setFormatter:(NSString *)formatter {
  [mFormatter release];
  mFormatter = [formatter copy];
  [self updateValueText];
  [self setNeedsDisplay:YES];
}

@synthesize mStepping;

@synthesize mShowValue;

- (void)setShowValue:(BOOL)showValue {
  mShowValue = showValue;
  [self setNeedsDisplay:YES];
}

@synthesize mOnBorderColor;

- (void)setOnBorderColor:(NSColor *)onBorderColor {
  [mOnBorderColor release];
  mOnBorderColor = [onBorderColor retain];
  [mLocalOnBorderColor release];
  mLocalOnBorderColor = [[mOnBorderColor colorWithAlphaComponent:mAlpha] retain];
  [self setNeedsDisplay:YES];
}

@synthesize mOnFillColor;

- (void)setOnFillColor:(NSColor *)onFillColor {
  [mOnFillColor release];
  mOnFillColor = [onFillColor retain];
  [mLocalOnFillColor release];
  mLocalOnFillColor = [[mOnFillColor colorWithAlphaComponent:mAlpha] retain];
  [self setNeedsDisplay:YES];
}

@synthesize mOffBorderColor;

- (void)setOffBorderColor:(NSColor *)offBorderColor {
  [mOffBorderColor release];
  mOffBorderColor = [offBorderColor retain];
  [mLocalOffBorderColor release];
  mLocalOffBorderColor = [[mOffBorderColor colorWithAlphaComponent:mAlpha] retain];
  [self setNeedsDisplay:YES];
}

@synthesize mOffFillColor;

- (void)setOffFillColor:(NSColor *)offFillColor {
  [mOffFillColor release];
  mOffFillColor = [offFillColor retain];
  [mLocalOffFillColor release];
  mLocalOffFillColor = [[mOffFillColor colorWithAlphaComponent:mAlpha] retain];
  [self setNeedsDisplay:YES];
}

@synthesize mValueColor;

- (void)setValueColor:(NSColor *)valueColor {
  [mValueColor release];
  mValueColor = [valueColor retain];
  [self setNeedsDisplay:YES];
}

@synthesize mFontSize;

- (void)setFontSize:(CGFloat)fontSize {
  mFontSize = fontSize;
  [self setNeedsDisplay:YES];
}


#pragma mark Drawing Code

- (void)drawRect:(NSRect)rect {
  NSRect bounds  = [self bounds];
  
  switch( [self style] ) {
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
  float angle    = 240 - ( 300 * ((float)( [self value] - [self minimum] )) / ( [self maximum] - [self minimum] ) );
  
  NSBezierPath *path = [NSBezierPath bezierPath];
  [path setLineWidth:2.4];
  [mLocalOffBorderColor set];
  [path appendBezierPathWithArcWithCenter:centre radius:radius startAngle:-60 endAngle:angle clockwise:NO];
  [path stroke];
  
  path = [NSBezierPath bezierPath];
  [path setLineWidth:2.4];
  [mLocalOnBorderColor set];
  [path appendBezierPathWithArcWithCenter:centre radius:radius startAngle:angle endAngle:240 clockwise:NO];
  [path moveToPoint:centre];
  [path lineToPoint:NSPointOnCircumference( centre, radius, deg2rad( angle ) )];
  [path stroke];
}


- (void)drawLogicProStyleDial:(NSRect)bounds {
  NSPoint centre      = NSRectCentre( bounds );
  float angle         = 270 - ( 360 * ((float)( [self value] - [self minimum] )) / ( [self maximum] - [self minimum] ) );
  CGFloat outerRadius = bounds.size.width / 2.5;
  CGFloat innerRadius = bounds.size.width / 3.5;
  
  NSBezierPath *path;
  
  path = [NSBezierPath bezierPath];
  [path moveToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( 270 ) )];
  [path lineToPoint:NSPointOnCircumference( centre, outerRadius, deg2rad( 270 ) )];
  [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:270 endAngle:angle clockwise:YES];
  [path lineToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( angle ) )];
  [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:angle endAngle:270 clockwise:NO];
  
  [mLocalOnFillColor set];
  [path fill];
  [mLocalOnBorderColor set];
  [path stroke];
  
  path = [NSBezierPath bezierPath];
  [path moveToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( angle ) )];
  [path lineToPoint:NSPointOnCircumference( centre, outerRadius, deg2rad( angle ) )];
  [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:angle endAngle:-90 clockwise:YES];
  [path lineToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( -90 ) )];
  [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:-90 endAngle:angle clockwise:NO];
  
  [mLocalOffFillColor set];
  [path fill];
  [mLocalOffBorderColor set];
  [path stroke];
  
  if( [self showValue] ) {
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
  
  [mLocalOffFillColor set];
  [path fill];
  [mLocalOffBorderColor set];
  [path stroke];
  
  if( [self value] < 0 ) {
    // Draw positive segement complete
    path = [NSBezierPath bezierPath];

    [path moveToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( 90 ) )];
    [path lineToPoint:NSPointOnCircumference( centre, outerRadius, deg2rad( 90 ) )];
    [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:90 endAngle:-60 clockwise:YES];
    [path lineToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( -60 ) )];
    [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:-60 endAngle:90 clockwise:NO];
    
    [mLocalOffFillColor set];
    [path fill];
    [mLocalOffBorderColor set];
    [path stroke];
    
    float angle = 90 + ( 150 * ( (float)( abs([self minimum]) - ( [self value] - [self minimum] ) ) / abs([self minimum]) ) );
    path = [NSBezierPath bezierPath];

    [path moveToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( angle ) )];
    [path lineToPoint:NSPointOnCircumference( centre, outerRadius, deg2rad( angle ) )];
    [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:angle endAngle:90 clockwise:YES];
    [path lineToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( 90 ) )];
    [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:90 endAngle:angle clockwise:NO];
    
    [mLocalOnFillColor set];
    [path fill];
    [mLocalOnBorderColor set];
    [path stroke];
    
    path = [NSBezierPath bezierPath];
    
    [path moveToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( 240 ) )];
    [path lineToPoint:NSPointOnCircumference( centre, outerRadius, deg2rad( 240 ) )];
    [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:240 endAngle:angle clockwise:YES];
    [path lineToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( angle ) )];
    [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:angle endAngle:240 clockwise:NO];
    
    [mLocalOffFillColor set];
    [path fill];
    [mLocalOffBorderColor set];
    [path stroke];
  } else {
    // Draw positive segement complete
    path = [NSBezierPath bezierPath];

    [path moveToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( 240 ) )];
    [path lineToPoint:NSPointOnCircumference( centre, outerRadius, deg2rad( 240 ) )];
    [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:240 endAngle:90 clockwise:YES];
    [path lineToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( 90 ) )];
    [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:90 endAngle:240 clockwise:NO];
    
    [mLocalOffFillColor set];
    [path fill];
    [mLocalOffBorderColor set];
    [path stroke];
    
    float angle = -60 + ( 150 * ( (float)( [self maximum] - [self value] ) / [self maximum] ) );
    
    path = [NSBezierPath bezierPath];

    [path moveToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( 90 ) )];
    [path lineToPoint:NSPointOnCircumference( centre, outerRadius, deg2rad( 90 ) )];
    [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:90 endAngle:angle clockwise:YES];
    [path lineToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( angle ) )];
    [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:angle endAngle:90 clockwise:NO];
    
    [mLocalOnFillColor set];
    [path fill];
    [mLocalOnBorderColor set];
    [path stroke];
    
    path = [NSBezierPath bezierPath];

    [path moveToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( angle ) )];
    [path lineToPoint:NSPointOnCircumference( centre, outerRadius, deg2rad( angle ) )];
    [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:angle endAngle:-60 clockwise:YES];
    [path lineToPoint:NSPointOnCircumference( centre, innerRadius, deg2rad( -60 ) )];
    [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:-60 endAngle:angle clockwise:NO];
    
    [mLocalOffFillColor set];
    [path fill];
    [mLocalOffBorderColor set];
    [path stroke];
  }
  
  if( [self showValue] ) {
    [self drawValue:bounds];
  }
}


- (void)drawValue:(NSRect)bounds {
  [self drawText:mValueText boundedBy:bounds];
}


- (void)drawText:(NSString *)text boundedBy:(NSRect)bounds {
  NSFont *textFont = [NSFont labelFontOfSize:[self fontSize]];
  
  NSColor *localValueColor = [[self valueColor] colorWithAlphaComponent:([self enabled] ? 1.0 : 0.5)];
  
  NSMutableDictionary *textAttributes = [[[NSMutableDictionary alloc] init] autorelease];
  [textAttributes setObject:textFont forKey:NSFontAttributeName];
  [textAttributes setObject:localValueColor forKey:NSForegroundColorAttributeName];
  
  NSSize textSize = [text sizeWithAttributes:textAttributes];
  NSPoint textOrigin = NSRectCentre( bounds );
  textOrigin.x -= textSize.width / 2;
  textOrigin.y -= textSize.height / 2;
  
  [text drawAtPoint:textOrigin withAttributes:textAttributes];
}


#pragma mark Mouse event handling

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
    
    int newValue = [self value] + (-[event deltaY] * [self stepping] * multiplier);
    if( newValue > [self maximum] ) {
      newValue = [self maximum];
    } else if( newValue < [self minimum] ) {
      newValue = [self minimum];
    }
    [self setValue:newValue];
    [self updateBoundValue];
  }
}


#pragma mark Binding support

- (void)updateBoundValue {
  NSDictionary *binding = [self infoForBinding:@"value"];
  id controller = [binding objectForKey:NSObservedObjectKey];
  NSString *keyPath = [binding objectForKey:NSObservedKeyPathKey];
  [controller setValue:[NSNumber numberWithInt:[self value]] forKeyPath:keyPath];
}


#pragma mark Value editing

- (void)editValue {
  mValueEditor = [[NSTextField alloc] initWithFrame:NSZeroRect];
  NSRect editorFrame = NSMakeRect( [self frame].origin.x, [self frame].origin.y + [self frame].size.height / 4, [self frame].size.width, [[mValueEditor font] boundingRectForFont].size.height );
  [mValueEditor setFrame:editorFrame];
  
  [mValueEditor setDelegate:self];
  [mValueEditor bind:@"value" toObject:self withKeyPath:@"value" options:nil];
  [[[self window] contentView] addSubview:mValueEditor];
  [[self window] makeFirstResponder:mValueEditor];
}

- (void)controlTextDidEndEditing:(NSNotification *)notification {
  [mValueEditor removeFromSuperview];
  [mValueEditor autorelease];
  [self setEnabled:YES];
  [self updateBoundValue];
}

- (void)updateValueText {
  [mValueText release];
  
  if( [self divisor] > 1 ) {
    mValueText = [[NSString stringWithFormat:[self formatter],(((float)[self value]) / [self divisor])] retain];
  } else {
    mValueText = [[NSString stringWithFormat:[self formatter],[self value]] retain];
  }
}


#pragma mark Housekeeping

- (void)updateLocalColors {
  [mLocalOnBorderColor release];
  mLocalOnBorderColor = [[mOnBorderColor colorWithAlphaComponent:mAlpha] retain];
  [mLocalOnFillColor release];
  mLocalOnFillColor = [[mOnFillColor colorWithAlphaComponent:mAlpha] retain];
  [mLocalOffBorderColor release];
  mLocalOffBorderColor = [[mOffBorderColor colorWithAlphaComponent:mAlpha] retain];
  [mLocalOffFillColor release];
  mLocalOffFillColor = [[mOffFillColor colorWithAlphaComponent:mAlpha] retain];
}


@end
