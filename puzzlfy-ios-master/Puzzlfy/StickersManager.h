//
//  StickersManager.h
//  Puzzlfy
//
//  Created by Youmna on 5/12/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StickersManager : NSObject
+(NSArray*)loadStickersFromFile:(NSString*)fileName;
@end
