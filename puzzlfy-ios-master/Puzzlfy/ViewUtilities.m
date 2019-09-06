//
//  ViewUtilities.m
//  Puzzlfy
//
//  Created by Adham Aboul Einein on 5/13/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "ViewUtilities.h"
#import "Constants.h"
#import "AchievementsBadgeView.h"
#import "SoundUtilities.h"
#import "Notifications.h"

@implementation ViewUtilities

static NSTimer *idleTimer;
static NavigationBarView *navBar;
static NSMutableArray *queuedAchievements;
static bool isShowingBanner;
static bool isPhotoLibraryEmpty;
static UIAlertView *alertView;
static bool isPermissionDialogDismissed;

+(NSTimer*) idleTimer
{
    return idleTimer;
}

+(void)setIdleTimer:(NSTimer*)timer
{
    idleTimer = timer;
}


+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

+(void)presentNotification:(NSString *)title withMessage:(NSString *)message withType:(int)type onAction:(void (^)())action
{
    UIViewController *vc = ((UINavigationController*)[UIApplication sharedApplication].delegate.window.rootViewController).visibleViewController;
    [TSMessage showNotificationInViewController:vc title:title subtitle:message image:nil type:type duration:NOTIFICATION_DURATION callback:action buttonTitle:nil buttonCallback:nil atPosition:TSMessageNotificationPositionTop canBeDismissedByUser:YES];
}

+(void)presentError:(NSString *)message{
    [self presentNotification:@"Error" withMessage:message withType:PUZZLFY_NOTIFICATION_TYPE_ERROR onAction:nil];
}

+(void)presentInformation:(NSString *)message{
    [self presentNotification:@"" withMessage:message withType:PUZZLFY_NOTIFICATION_TYPE_MESSAGE onAction:nil];
}

+(void)presentWarning:(NSString *)message{
    [self presentNotification:@"Warning" withMessage:message withType:PUZZLFY_NOTIFICATION_TYPE_WARNING onAction:nil];
}

+(void)presentSuccess:(NSString *)message{
    [self presentNotification:@"Done!" withMessage:message withType:PUZZLFY_NOTIFICATION_TYPE_SUCCESS onAction:nil];
}

+(void)presentPushNotification:(NSString *)message onAction:(void (^)())action
{
    [self presentNotification:@"Notification" withMessage:message withType:PUZZLFY_NOTIFICATION_TYPE_MESSAGE onAction:action];
}

+(void)showAchievementsBadgeView:(UIView *)placeholder
{
    AchievementsBadgeView *av = [[[NSBundle mainBundle] loadNibNamed:@"AchievementsBadgeView" owner:self options:nil]firstObject];
    [placeholder addSubview:av];
}

+(void)showAchievementsBadgeViewWithTitle:(NSString *)title
{
    
    if (!queuedAchievements) {
        queuedAchievements = [[NSMutableArray alloc]initWithObjects:title, nil];
    }
    else {
        [queuedAchievements addObject:title];
    }
    if (!isShowingBanner) {
        isShowingBanner = YES;
        [self showBanner];
    }
    
}

+(void)showBanner
{
    if (queuedAchievements.count <= 0) {
        isShowingBanner = NO;
        return;
    }
    
    [SoundUtilities playAchievementsSound];
    
    UIViewController *vc = ((UINavigationController*)[UIApplication sharedApplication].delegate.window.rootViewController);
    AchievementsBadgeView *abv = [[[NSBundle mainBundle] loadNibNamed:@"AchievementsBadgeView" owner:self options:nil]firstObject];
    CGFloat width = (vc.view.frame.size.width > vc.view.frame.size.height) ? vc.view.frame.size.width : vc.view.frame.size.height;
    UIView *bannerView = [[UIView alloc]initWithFrame:CGRectMake((width/2)-abv.frame.size.width/2, 10, abv.frame.size.width, abv.frame.size.height)];
    
    [abv.acheivementText setText:[queuedAchievements firstObject]];
    [abv setFrame:bannerView.bounds];
    [bannerView addSubview:abv];
    
    [vc.view addSubview:bannerView];
    
    [bannerView setAlpha:0.0f];
    
    [UIView animateWithDuration:0.4f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [bannerView setAlpha:1.0f];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4f delay:4.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [bannerView setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [bannerView removeFromSuperview];
            [queuedAchievements removeObjectAtIndex:0];
            [self showBanner];
        }];
    }];
}

+(void)saveImageToPhotoLibrary:(UIImage *)image
{
    [[[ALAssetsLibrary alloc] init] saveImage:image  toAlbum:@"Puzzlfy" withCompletionBlock:^(NSError *error) {
        if (error) {
            NSLog(@"Error saving image");
        }
    }];
}

+(void)setNavBar:(NavigationBarView *)nBar
{
    navBar = nBar;
}

+(NavigationBarView *)getNavBar
{
    return navBar;
}

+ (void)checkPhotoLibraryContent
{
//    [self checkLibraryAuthorizationStatus];
    
    ALAssetsLibrary *assetsLibrary = [self defaultAssetsLibrary];

    __block BOOL stopEnumaration = NO;
    
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (!stopEnumaration) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            if ([group numberOfAssets]) {
                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"isEmpty", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:PHOTO_LIBRARY_NOTIFICATION object:data];
                isPhotoLibraryEmpty = NO;
            }
            else {
                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"isEmpty", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:PHOTO_LIBRARY_NOTIFICATION object:data];
                isPhotoLibraryEmpty = YES;
            }
            stopEnumaration = YES;
        }
    
    } failureBlock:^(NSError *error) {
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"isEmpty", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:PHOTO_LIBRARY_NOTIFICATION object:data];
        isPhotoLibraryEmpty = YES;
        NSLog(@"Error loading images %@", error);
    }];
}

+ (BOOL)isPhotoLibraryEmpty
{
    return isPhotoLibraryEmpty;
}

+ (BOOL)isPhotoLibraryPermissionSet
{
    return ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined) ? NO : YES;
}

+ (ALAuthorizationStatus)checkLibraryAuthorizationStatus
{
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusNotDetermined) {
        alertView = [[UIAlertView alloc] initWithTitle:@"Puzzlfy" message:LIBRARY_PERMISSION_TXT delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alertView show];
        return ALAuthorizationStatusNotDetermined;
    }
    return status;
}

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    isPermissionDialogDismissed = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:DISMISS_PERMISSION_NOTIFICATION object:nil];
}

+ (void)dismissAlertView
{
    if(alertView && !alertView.hidden)
    {
        [alertView dismissWithClickedButtonIndex:1 animated:NO];
    }
}
@end
