//
//  LMDialView.m
//  LMDial
//
//  Created by Matt Mower on 13/01/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import <InterfaceBuilderKit/InterfaceBuilderKit.h>
#import <LMDial/LMDialView.h>
#import "LMDialInspector.h"

@implementation LMDialView ( LMDialView )

- (void)ibPopulateKeyPaths:(NSMutableDictionary *)keyPaths {
    [super ibPopulateKeyPaths:keyPaths];
    
    [[keyPaths objectForKey:IBAttributeKeyPaths] addObjectsFromArray:[NSArray arrayWithObjects:@"value",@"minimum",@"maximum",@"stepping",nil]];
}

- (void)ibPopulateAttributeInspectorClasses:(NSMutableArray *)classes {
    [super ibPopulateAttributeInspectorClasses:classes];
    [classes addObject:[LMDialInspector class]];
}

@end
