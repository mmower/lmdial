//
//  LMDialInspector.m
//  LMDial
//
//  Created by Matt Mower on 13/01/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import "LMDialInspector.h"

@implementation LMDialInspector

- (NSString *)viewNibName {
	return @"LMDialInspector";
}

- (void)refresh {
	// Synchronize your inspector's content view with the currently selected objects.
	[super refresh];
}

@end
