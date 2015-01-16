//
//  LMDialView.m
//  LMDial
//
//  Created by Matt Mower on 13/01/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import "LMDialView.h"

static float PI = 3.14159265358979323846264338327950288419716939937510;

NSPoint NSRectCentre(NSRect rect) {
    return NSMakePoint(rect.origin.x + (rect.size.width / 2), rect.origin.y + (rect.size.height / 2));
}

float deg2rad(float degrees) {
    return (degrees * PI) / 180;
}

NSPoint NSPointOnCircumference(NSPoint centre, CGFloat radius, CGFloat theta) {
    return NSMakePoint(centre.x + (radius * cos(theta)), centre.y + (radius * sin(theta)));
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
    [_formatter release];
    [_valueText release];
    [_onBorderColor release];
    [_localOnBorderColor release];
    [_onFillColor release];
    [_localOnFillColor release];
    [_offBorderColor release];
    [_offFillColor release];
    [_localOffBorderColor release];
    [_localOffFillColor release];
    [_valueColor release];
    [super dealloc];
}

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _enabled        = YES;
        _style          = abletonLive;
        _value          = 0;
        _minimum        = 0;
        _maximum        = 100;
        _stepping       = 1;
        _showValue      = YES;
        
        _onBorderColor  = [NSColor blueColor];
        _onFillColor    = [NSColor cyanColor];
        _offBorderColor = [NSColor blackColor];
        _offFillColor   = [NSColor grayColor];
        _valueColor     = [NSColor blackColor];
        
        _divisor        = 1;
        _formatter      = [@"%+d" retain];
        
        _fontSize       = 6.0;
    }
    
    return self;
}

#pragma mark NSCoder implementation

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        if ([coder containsValueForKey:@"lmdial.enabled"]) {
            [self setEnabled:[[coder decodeObjectForKey:@"lmdial.enabled"] boolValue]];
        }
        else {
            [self setEnabled:YES];
        }
        
        if ([coder containsValueForKey:@"lmdial.onBorderColor"]) {
            [self setOnBorderColor:[coder decodeObjectForKey:@"lmdial.onBorderColor"]];
        }
        else {
            [self setOnBorderColor:[NSColor blueColor]];
        }
        
        if ([coder containsValueForKey:@"lmdial.onFillColor"]) {
            [self setOnFillColor:[coder decodeObjectForKey:@"lmdial.onFillColor"]];
        }
        else {
            [self setOnFillColor:[NSColor cyanColor]];
        }
        
        if ([coder containsValueForKey:@"lmdial.offBorderColor"]) {
            [self setOffBorderColor:[coder decodeObjectForKey:@"lmdial.offBorderColor"]];
        }
        else {
            [self setOffBorderColor:[NSColor blackColor]];
        }
        
        if ([coder containsValueForKey:@"lmdial.offFillColor"]) {
            [self setOffFillColor:[coder decodeObjectForKey:@"lmdial.offFillColor"]];
        }
        else {
            [self setOffFillColor:[NSColor grayColor]];
        }
        
        if ([coder containsValueForKey:@"lmdial.showValue"]) {
            [self setShowValue:[[coder decodeObjectForKey:@"lmdial.showValue"] boolValue]];
        }
        else {
            [self setShowValue:YES];
        }
        
        if ([coder containsValueForKey:@"lmdial.valueColor"]) {
            [self setValueColor:[coder decodeObjectForKey:@"lmdial.valueColor"]];
        }
        else {
            [self setValueColor:[NSColor blackColor]];
        }
        
        if ([coder containsValueForKey:@"lmdial.fontSize"]) {
            [self setFontSize:[[coder decodeObjectForKey:@"lmdial.fontSize"] floatValue]];
        }
        else {
            [self setFontSize:6.0];
        }
        
        if ([coder containsValueForKey:@"lmdial.formatter"]) {
            [self setFormatter:[coder decodeObjectForKey:@"lmdial.formatter"]];
        }
        else {
            [self setFormatter:@"%+d"];
        }
        
        if ([coder containsValueForKey:@"lmdial.divisor"]) {
            [self setDivisor:[[coder decodeObjectForKey:@"lmdial.divisor"] intValue]];
        }
        else {
            [self setDivisor:1];
        }
        
        if ([coder containsValueForKey:@"lmdial.style"]) {
            [self setStyle:(LMDialStyle)[[coder decodeObjectForKey:@"lmdial.style"] intValue]];
        }
        else {
            [self setStyle:abletonLive];
        }
        
        if ([coder containsValueForKey:@"lmdial.minimum"]) {
            [self setMinimum:[[coder decodeObjectForKey:@"lmdial.minimum"] intValue]];
        }
        else {
            [self setMinimum:0];
        }
        
        if ([coder containsValueForKey:@"lmdial.maximum"]) {
            [self setMaximum:[[coder decodeObjectForKey:@"lmdial.maximum"] intValue]];
        }
        else {
            [self setMaximum:100];
        }
        
        if ([coder containsValueForKey:@"lmdial.stepping"]) {
            [self setStepping:[[coder decodeObjectForKey:@"lmdial.stepping"] intValue]];
        }
        else {
            [self setStepping:1];
        }
        
        // Initialize the value last and, especially, after the formatter (since, if it's null, we'll get an exception)
        if ([coder containsValueForKey:@"lmdial.value"]) {
            [self setValue:[[coder decodeObjectForKey:@"lmdial.value"] intValue]];
        }
        else {
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


//- (void)setEnabled:(BOOL)enabled {
//    if (enabled != _enabled) {
//        _enabled = enabled;
//        _alpha = _enabled ? 1.0 : 0.5;
//        [self updateLocalColors];
//        [self setNeedsDisplay:YES];
//    }
//}

- (void)setStyle:(LMDialStyle)style {
    if (style != _style) {
        _style = style;
        [self setNeedsDisplay:YES];
    }
}

- (void)setValue:(int)value {
    if (value > [self maximum]) {
        value = [self maximum];
    }
    else if (value < [self minimum]) {
        value = [self minimum];
    }
    _value = value;
    [self updateValueText];
    [self setNeedsDisplay:YES];
}

- (void)setMinimum:(int)minimum {
    _minimum = minimum;
    
    if ([self value] < minimum) {
        [self setValue:minimum];
    }
    [self setNeedsDisplay:YES];
}

- (void)setMaximum:(int)maximum {
    _maximum = maximum;
    
    if ([self value] > maximum) {
        [self setValue:maximum];
    }
    [self setNeedsDisplay:YES];
}

- (void)setDivisor:(int)divisor {
    _divisor = divisor;
    [self updateValueText];
    [self setNeedsDisplay:YES];
}

- (void)setFormatter:(NSString *)formatter {
    [_formatter release];
    _formatter = [formatter copy];
    [self updateValueText];
    [self setNeedsDisplay:YES];
}

- (void)setShowValue:(BOOL)showValue {
    _showValue = showValue;
    [self setNeedsDisplay:YES];
}

- (void)setOnBorderColor:(NSColor *)onBorderColor {
    [_onBorderColor release];
    _onBorderColor = [onBorderColor retain];
    [_localOnBorderColor release];
    _localOnBorderColor = [[_onBorderColor colorWithAlphaComponent:_alpha] retain];
    [self setNeedsDisplay:YES];
}

- (void)setOnFillColor:(NSColor *)onFillColor {
    [_onFillColor release];
    _onFillColor = [onFillColor retain];
    [_localOnFillColor release];
    _localOnFillColor = [[_onFillColor colorWithAlphaComponent:_alpha] retain];
    [self setNeedsDisplay:YES];
}

@synthesize offBorderColor = _offBorderColor;

- (void)setOffBorderColor:(NSColor *)offBorderColor {
    [_offBorderColor release];
    _offBorderColor = [offBorderColor retain];
    [_localOffBorderColor release];
    _localOffBorderColor = [[_offBorderColor colorWithAlphaComponent:_alpha] retain];
    [self setNeedsDisplay:YES];
}

- (void)setOffFillColor:(NSColor *)offFillColor {
    [_offFillColor release];
    _offFillColor = [offFillColor retain];
    [_localOffFillColor release];
    _localOffFillColor = [[_offFillColor colorWithAlphaComponent:_alpha] retain];
    [self setNeedsDisplay:YES];
}

- (void)setValueColor:(NSColor *)valueColor {
    [_valueColor release];
    _valueColor = [valueColor retain];
    [self setNeedsDisplay:YES];
}

- (void)setFontSize:(CGFloat)fontSize {
    _fontSize = fontSize;
    [self setNeedsDisplay:YES];
}

#pragma mark Drawing Code

- (void)drawRect:(NSRect)rect {
    NSRect bounds  = [self bounds];
    
    switch ([self style]) {
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
    NSPoint centre = NSRectCentre(bounds);
    CGFloat radius = bounds.size.width / 3;
    float angle    = 240 - (300 * ((float)([self value] - [self minimum])) / ([self maximum] - [self minimum]));
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setLineWidth:2.4];
    [_localOffBorderColor set];
    [path appendBezierPathWithArcWithCenter:centre radius:radius startAngle:-60 endAngle:angle clockwise:NO];
    [path stroke];
    
    path = [NSBezierPath bezierPath];
    [path setLineWidth:2.4];
    [_localOnBorderColor set];
    [path appendBezierPathWithArcWithCenter:centre radius:radius startAngle:angle endAngle:240 clockwise:NO];
    [path moveToPoint:centre];
    [path lineToPoint:NSPointOnCircumference(centre, radius, deg2rad(angle))];
    [path stroke];
}

- (void)drawLogicProStyleDial:(NSRect)bounds {
    NSPoint centre      = NSRectCentre(bounds);
    float angle         = 270 - (360 * ((float)([self value] - [self minimum])) / ([self maximum] - [self minimum]));
    CGFloat outerRadius = bounds.size.width / 2.5;
    CGFloat innerRadius = bounds.size.width / 3.5;
    
    NSBezierPath *path;
    
    path = [NSBezierPath bezierPath];
    [path moveToPoint:NSPointOnCircumference(centre, innerRadius, deg2rad(270))];
    [path lineToPoint:NSPointOnCircumference(centre, outerRadius, deg2rad(270))];
    [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:270 endAngle:angle clockwise:YES];
    [path lineToPoint:NSPointOnCircumference(centre, innerRadius, deg2rad(angle))];
    [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:angle endAngle:270 clockwise:NO];
    
    [_localOnFillColor set];
    [path fill];
    [_localOnBorderColor set];
    [path stroke];
    
    path = [NSBezierPath bezierPath];
    [path moveToPoint:NSPointOnCircumference(centre, innerRadius, deg2rad(angle))];
    [path lineToPoint:NSPointOnCircumference(centre, outerRadius, deg2rad(angle))];
    [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:angle endAngle:-90 clockwise:YES];
    [path lineToPoint:NSPointOnCircumference(centre, innerRadius, deg2rad(-90))];
    [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:-90 endAngle:angle clockwise:NO];
    
    [_localOffFillColor set];
    [path fill];
    [_localOffBorderColor set];
    [path stroke];
    
    if ([self showValue]) {
        [self drawValue:bounds];
    }
}

// For the moment we assuming zero point = 0 && minimum = maximum
- (void)drawLogicPanStyleDial:(NSRect)bounds {
    NSPoint centre      = NSRectCentre(bounds);
    CGFloat outerRadius = bounds.size.width / 2.5;
    CGFloat innerRadius = bounds.size.width / 3.5;
    
    NSBezierPath *path;
    
    // Draw the bottom "stopper" segement
    path = [NSBezierPath bezierPath];
    
    [path moveToPoint:NSPointOnCircumference(centre, innerRadius, deg2rad(-60))];
    [path lineToPoint:NSPointOnCircumference(centre, outerRadius, deg2rad(-60))];
    [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:-60 endAngle:-120 clockwise:YES];
    [path lineToPoint:NSPointOnCircumference(centre, innerRadius, deg2rad(-120))];
    [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:-120 endAngle:-60 clockwise:NO];
    
    [_localOffFillColor set];
    [path fill];
    [_localOffBorderColor set];
    [path stroke];
    
    if ([self value] < 0) {
        // Draw positive segement complete
        path = [NSBezierPath bezierPath];
        
        [path moveToPoint:NSPointOnCircumference(centre, innerRadius, deg2rad(90))];
        [path lineToPoint:NSPointOnCircumference(centre, outerRadius, deg2rad(90))];
        [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:90 endAngle:-60 clockwise:YES];
        [path lineToPoint:NSPointOnCircumference(centre, innerRadius, deg2rad(-60))];
        [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:-60 endAngle:90 clockwise:NO];
        
        [_localOffFillColor set];
        [path fill];
        [_localOffBorderColor set];
        [path stroke];
        
        float angle = 90 + (150 * ((float)(abs([self minimum]) - ([self value] - [self minimum])) / abs([self minimum])));
        path = [NSBezierPath bezierPath];
        
        [path moveToPoint:NSPointOnCircumference(centre, innerRadius, deg2rad(angle))];
        [path lineToPoint:NSPointOnCircumference(centre, outerRadius, deg2rad(angle))];
        [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:angle endAngle:90 clockwise:YES];
        [path lineToPoint:NSPointOnCircumference(centre, innerRadius, deg2rad(90))];
        [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:90 endAngle:angle clockwise:NO];
        
        [_localOnFillColor set];
        [path fill];
        [_localOnBorderColor set];
        [path stroke];
        
        path = [NSBezierPath bezierPath];
        
        [path moveToPoint:NSPointOnCircumference(centre, innerRadius, deg2rad(240))];
        [path lineToPoint:NSPointOnCircumference(centre, outerRadius, deg2rad(240))];
        [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:240 endAngle:angle clockwise:YES];
        [path lineToPoint:NSPointOnCircumference(centre, innerRadius, deg2rad(angle))];
        [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:angle endAngle:240 clockwise:NO];
        
        [_localOffFillColor set];
        [path fill];
        [_localOffBorderColor set];
        [path stroke];
    }
    else {
        // Draw positive segement complete
        path = [NSBezierPath bezierPath];
        
        [path moveToPoint:NSPointOnCircumference(centre, innerRadius, deg2rad(240))];
        [path lineToPoint:NSPointOnCircumference(centre, outerRadius, deg2rad(240))];
        [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:240 endAngle:90 clockwise:YES];
        [path lineToPoint:NSPointOnCircumference(centre, innerRadius, deg2rad(90))];
        [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:90 endAngle:240 clockwise:NO];
        
        [_localOffFillColor set];
        [path fill];
        [_localOffBorderColor set];
        [path stroke];
        
        float angle = -60 + (150 * ((float)([self maximum] - [self value]) / [self maximum]));
        
        path = [NSBezierPath bezierPath];
        
        [path moveToPoint:NSPointOnCircumference(centre, innerRadius, deg2rad(90))];
        [path lineToPoint:NSPointOnCircumference(centre, outerRadius, deg2rad(90))];
        [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:90 endAngle:angle clockwise:YES];
        [path lineToPoint:NSPointOnCircumference(centre, innerRadius, deg2rad(angle))];
        [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:angle endAngle:90 clockwise:NO];
        
        [_localOnFillColor set];
        [path fill];
        [_localOnBorderColor set];
        [path stroke];
        
        path = [NSBezierPath bezierPath];
        
        [path moveToPoint:NSPointOnCircumference(centre, innerRadius, deg2rad(angle))];
        [path lineToPoint:NSPointOnCircumference(centre, outerRadius, deg2rad(angle))];
        [path appendBezierPathWithArcWithCenter:centre radius:outerRadius startAngle:angle endAngle:-60 clockwise:YES];
        [path lineToPoint:NSPointOnCircumference(centre, innerRadius, deg2rad(-60))];
        [path appendBezierPathWithArcWithCenter:centre radius:innerRadius startAngle:-60 endAngle:angle clockwise:NO];
        
        [_localOffFillColor set];
        [path fill];
        [_localOffBorderColor set];
        [path stroke];
    }
    
    if ([self showValue]) {
        [self drawValue:bounds];
    }
}

- (void)drawValue:(NSRect)bounds {
    [self drawText:_valueText boundedBy:bounds];
}

- (void)drawText:(NSString *)text boundedBy:(NSRect)bounds {
    NSFont *textFont = [NSFont labelFontOfSize:[self fontSize]];
    
    NSColor *localValueColor = [[self valueColor] colorWithAlphaComponent:([self enabled] ? 1.0 : 0.5)];
    
    NSMutableDictionary *textAttributes = [[[NSMutableDictionary alloc] init] autorelease];
    [textAttributes setObject:textFont forKey:NSFontAttributeName];
    [textAttributes setObject:localValueColor forKey:NSForegroundColorAttributeName];
    
    NSSize textSize = [text sizeWithAttributes:textAttributes];
    NSPoint textOrigin = NSRectCentre(bounds);
    textOrigin.x -= textSize.width / 2;
    textOrigin.y -= textSize.height / 2;
    
    [text drawAtPoint:textOrigin withAttributes:textAttributes];
}

#pragma mark Mouse event handling

- (BOOL)mouseDownCanMoveWindow {
    return NO;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event {
    return YES;
}

- (void)mouseDown:(NSEvent *)event {
    if ([event clickCount] == 2 && [self enabled]) {
        [self editValue];
    }
}

- (void)mouseDragged:(NSEvent *)event {
    if ([self enabled]) {
        float multiplier = 1.0;
        
        if ([event modifierFlags] & NSShiftKeyMask) {
            multiplier *= 0.5;
        }
        
        if ([event modifierFlags] & NSControlKeyMask) {
            multiplier *= 2;
        }
        
        if ([event modifierFlags] & NSAlternateKeyMask) {
            multiplier *= 5;
        }
        
        if ([event modifierFlags] & NSCommandKeyMask) {
            multiplier *= 10;
        }
        
        int newValue = [self value] + (-[event deltaY] * [self stepping] * multiplier);
        if (newValue > [self maximum]) {
            newValue = [self maximum];
        }
        else if (newValue < [self minimum]) {
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
    _valueEditor = [[NSTextField alloc] initWithFrame:NSZeroRect];
    NSRect editorFrame = NSMakeRect([self frame].origin.x, [self frame].origin.y + [self frame].size.height / 4, [self frame].size.width, [[_valueEditor font] boundingRectForFont].size.height);
    [_valueEditor setFrame:editorFrame];
    
    [_valueEditor setDelegate:self];
    [_valueEditor bind:@"value" toObject:self withKeyPath:@"value" options:nil];
    [[[self window] contentView] addSubview:_valueEditor];
    [[self window] makeFirstResponder:_valueEditor];
}

- (void)controlTextDidEndEditing:(NSNotification *)notification {
    [_valueEditor removeFromSuperview];
    [_valueEditor autorelease];
    [self setEnabled:YES];
    [self updateBoundValue];
}

- (void)updateValueText {
    [_valueText release];
    
    if ([self divisor] > 1) {
        _valueText = [[NSString stringWithFormat:[self formatter], (((float)[self value]) / [self divisor])] retain];
    }
    else {
        _valueText = [[NSString stringWithFormat:[self formatter], [self value]] retain];
    }
}

#pragma mark Housekeeping

- (void)updateLocalColors {
    [_localOnBorderColor release];
    _localOnBorderColor = [[_onBorderColor colorWithAlphaComponent:_alpha] retain];
    
    [_localOnFillColor release];
    _localOnFillColor = [[_onFillColor colorWithAlphaComponent:_alpha] retain];
    
    [_localOffBorderColor release];
    _localOffBorderColor = [[_offBorderColor colorWithAlphaComponent:_alpha] retain];
    
    [_localOffFillColor release];
    _localOffFillColor = [[_offFillColor colorWithAlphaComponent:_alpha] retain];
}

@end
