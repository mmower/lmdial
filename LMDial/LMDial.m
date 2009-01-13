//
//  LMDial.m
//  LMDial
//
//  Created by Matt Mower on 13/01/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import "LMDial.h"

@implementation LMDial
- (NSArray *)libraryNibNames {
    return [NSArray arrayWithObject:@"LMDialLibrary"];
}

- (NSArray *)requiredFrameworks {
    return [NSArray arrayWithObjects:[NSBundle bundleWithIdentifier:@"com.lucidmac.LMDial"], nil];
}

-(NSString *)label {
  return @"LMDial";
}

@end
