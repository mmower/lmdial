//
//  LMDialEditWindow.m
//  LMDial
//
//  Created by Matt Mower on 25/01/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import "LMDialEditWindow.h"

#import "LMDialView.h"

@interface LMDialEditWindow (LMDialEditWindowPrivateMethods)
@end

@implementation LMDialEditWindow

#pragma mark Initializers

- (id)initForDialView:(LMDialView *)dialView inWindow:(NSWindow *)theParentWindow {
  viewController = [[[NSViewController alloc] initWithNibName:@"DialEditor" bundle:[NSBundle bundleForClass:[self class]]] retain];
  NSRect contentRect = NSZeroRect;
  contentRect.size = [[viewController view] frame].size;
  
  self = [self initWithContentRect:contentRect
                         styleMask:NSBorderlessWindowMask
                           backing:NSBackingStoreBuffered
                             defer:NO];
  if( self ) {
    parentWindow = theParentWindow;
    [super setBackgroundColor:[NSColor clearColor]];
    [self setMovableByWindowBackground:NO];
    [self setExcludedFromWindowsMenu:YES];
    [self setAlphaValue:1.0];
    [self setOpaque:NO];
    [self setHasShadow:YES];
    [self useOptimizedDrawing:YES];
    
    [[self contentView] addSubview:[viewController view]];
  } else {
    [viewController release];
  }
  
  return self;
}

- (void)dealloc {
  [viewController release];
  [super dealloc];
}

# pragma mark Window Behaviour

- (BOOL)canBecomeMainWindow
{
    return NO;
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (BOOL)isExcludedFromWindowsMenu
{
    return YES;
}

- (BOOL)validateMenuItem:(NSMenuItem *)item
{
    if( parentWindow ) {
        return [parentWindow validateMenuItem:item];
    }
    return [super validateMenuItem:item];
}

- (IBAction)performClose:(id)sender
{
    if( parentWindow ) {
        [parentWindow performClose:sender];
    } else {
        [super performClose:sender];
    }
}

@end
