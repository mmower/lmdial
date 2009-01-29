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
    v1 = 0;
    v2 = 50;
  }
  
  return self;
}

- (void)awakeFromNib {
  [self addObserver:self forKeyPath:@"v1" options:NSKeyValueObservingOptionNew context:nil];
  [self addObserver:self forKeyPath:@"v2" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSMutableDictionary *)change context:(id)context {
  NSLog( @"%@ = %@", keyPath, [[change valueForKey:NSKeyValueChangeNewKey] description] );
}

@synthesize v1;
@synthesize v2;

@end
