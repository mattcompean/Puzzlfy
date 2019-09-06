//
//  StickersManager.m
//  Puzzlfy
//
//  Created by Youmna on 5/12/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "StickersManager.h"


@implementation StickersManager
+(NSArray*)loadStickersFromFile:(NSString*)fileName
{
    NSError * error=nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    NSString *jsonStr = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    NSData * jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    // Parse the string into JSON
    NSArray * array = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    return array;
}

@end
