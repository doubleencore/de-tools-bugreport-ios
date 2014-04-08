//
//  DENDebugSnapper.h
//  DENDebugSnapper
//
//  Created by Brad Dillon on 4/8/14.
//  Copyright (c) 2014 Double Encore. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NSData *(^DENSnapDataCaptureBlock)(void);


@interface DENDebugSnapper : NSObject

@property (nonatomic, strong) UIGestureRecognizer *gestureRecognizer;
@property (nonatomic) BOOL shouldSnapOnUserScreenshot;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, copy) DENSnapDataCaptureBlock captureBlock;

- (void)snap;

@end
