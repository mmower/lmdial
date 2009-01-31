//
//  DialController.m
//  DialTest
//
//  Created by Matt Mower on 17/01/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import "DialController.h"

@implementation DialController

- (id)init {
  if( ( self = [super init] ) ) {
    v1     = 63;
    v1min  = 0;
    v1max  = 127;
    v1step = 1;
    
    v2     = 63;
    v2min  = 0;
    v2max  = 127;
    v2step = 1;
    
    v3     = 0;
    v3min  = -24;
    v3max  = 24;
    v3step = 1;
    
    v4     = 1000;
    v4min  = 100;
    v4max  = 5000;
    v4step = 100;
  }
  
  return self;
}

- (void)awakeFromNib {
  [self addObserver:self forKeyPath:@"v1" options:NSKeyValueObservingOptionNew context:nil];
  [self addObserver:self forKeyPath:@"v2" options:NSKeyValueObservingOptionNew context:nil];
  [self addObserver:self forKeyPath:@"v3" options:NSKeyValueObservingOptionNew context:nil];
  [self addObserver:self forKeyPath:@"v4" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSMutableDictionary *)change context:(id)context {
  // NSLog( @"%@ = %@", keyPath, [[change valueForKey:NSKeyValueChangeNewKey] description] );
}

@synthesize v1;
@synthesize v1min;
@synthesize v1max;
@synthesize v1step;

@synthesize v2;
@synthesize v2min;
@synthesize v2max;
@synthesize v2step;

@synthesize v3;
@synthesize v3min;
@synthesize v3max;
@synthesize v3step;

@synthesize v4;
@synthesize v4min;
@synthesize v4max;
@synthesize v4step;

@end
