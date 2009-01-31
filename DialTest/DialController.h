//
//  DialController.h
//  DialTest
//
//  Created by Matt Mower on 17/01/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DialController : NSObject {
  int v1;
  int v1min;
  int v1max;
  int v1step;
  
  int v2;
  int v2min;
  int v2max;
  int v2step;
  
  int v3;
  int v3min;
  int v3max;
  int v3step;

  int v4;
  int v4min;
  int v4max;
  int v4step;
}

@property int v1;
@property int v1min;
@property int v1max;
@property int v1step;

@property int v2;
@property int v2min;
@property int v2max;
@property int v2step;

@property int v3;
@property int v3min;
@property int v3max;
@property int v3step;

@property int v4;
@property int v4min;
@property int v4max;
@property int v4step;

@end
