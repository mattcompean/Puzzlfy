//
//  PuzzlfyIAPHelper.m
//  Puzzlfy
//
//  Created by Youmna on 5/20/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "PuzzlfyIAPHelper.h"

@implementation PuzzlfyIAPHelper
+ (PuzzlfyIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static PuzzlfyIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.radius60.ios.puzzlfy.firststickerbundle",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}
@end
