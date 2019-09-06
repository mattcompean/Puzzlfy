//
//  PuzzleSelectionViewController.m
//  Puzzlfy
//
//  Created by Bahaa Zaid on 3/16/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "PuzzleSelectionViewController.h"
#import "StickersViewController.h"
#import "SegueNames.h"
#import "UIView+Shadow.h"
#import "SoundUtilities.h"
#import "Constants.h"
#import "StickersManager.h"
#import "EventsManager.h"
#import "ViewUtilities.h"
#import "Notifications.h"
#import "ViewUtilities.h"

@interface PuzzleSelectionViewController ()
{
    BOOL isUserImageSelected;
    BOOL isPhotoLibraryEmpty;
    int adjustIndexValue;
}

@property (weak, nonatomic) IBOutlet UICollectionView *galleryCollection;
@property (strong, nonatomic) NSArray *galleryItemPaths;
@property (strong, nonatomic) NSArray *galleryThumbsPaths;
@property (strong, nonatomic) UIImage *selectedImage;
@property (nonatomic) NSInteger selectedRow;
@property (strong, nonatomic) UIImage *userImage;
@property (strong, nonatomic) ALAsset *userImageAsset;
@property (strong, nonatomic) NSMutableArray *collectionContent;
@end

@implementation PuzzleSelectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.vShadowView makeInsetShadowWithRadius:15 Alpha:0.5];
    
    self.galleryItemPaths = [StickersManager loadStickersFromFile:@"bundled-assets"];
    
    self.galleryThumbsPaths = [StickersManager loadStickersFromFile:@"bundled-assets-thumbs"];
    
    self.galleryCollection.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.galleryCollection.layer.shadowOpacity = 0.7;
    self.galleryCollection.layer.shadowRadius = 4.0;
    self.galleryCollection.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    self.galleryCollection.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.galleryCollection.bounds].CGPath;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveApplicationWillEnterForegroundNotification) name:APP_WILL_ENTER_FOREGROUND_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoLibraryNotification:) name:PHOTO_LIBRARY_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissPermissionNotification) name:DISMISS_PERMISSION_NOTIFICATION object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveApplicationWillEnterBackgroundNotification) name:APP_WILL_ENTER_BACKGROUND_NOTIFICATION object:nil];
    
    self.userImage = nil;
//    [self.galleryCollection reloadData];
    
    ALAuthorizationStatus authorizationStatus = [ViewUtilities checkLibraryAuthorizationStatus];
    if (authorizationStatus == ALAuthorizationStatusRestricted || authorizationStatus == ALAuthorizationStatusDenied) {
        isPhotoLibraryEmpty = YES;
    }
    else if (authorizationStatus == ALAuthorizationStatusAuthorized) {
        [ViewUtilities checkPhotoLibraryContent];
    }
    
    adjustIndexValue = (isPhotoLibraryEmpty) ? 0 : 1;
    [self updateCollectionViewContent];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [ViewUtilities dismissAlertView];
}

- (void)updateCollectionViewContent
{
    self.collectionContent = [[NSMutableArray alloc]initWithArray:self.galleryThumbsPaths];
    if (!isPhotoLibraryEmpty) {
        [self.collectionContent insertObject:@"" atIndex:USER_IMAGE_INDEX];
    }
    adjustIndexValue = (isPhotoLibraryEmpty) ? 0 : 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [ViewUtilities dismissAlertView];
    isUserImageSelected = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_WILL_ENTER_FOREGROUND_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_WILL_ENTER_BACKGROUND_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PHOTO_LIBRARY_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DISMISS_PERMISSION_NOTIFICATION object:nil];
    
}

- (void)recieveApplicationWillEnterForegroundNotification
{
    if([[[self.navigationController viewControllers] lastObject] isKindOfClass:[PuzzleSelectionViewController class]]) {
        self.userImage = nil;
        ALAuthorizationStatus status = [ViewUtilities checkLibraryAuthorizationStatus];
        if (status == ALAuthorizationStatusAuthorized) {
            [self performSelector:@selector(callCheckPhotoLibraryContent) withObject:nil afterDelay:0.5];
        }
//        [self.galleryCollection reloadData];
    }
}

- (void)callCheckPhotoLibraryContent
{
    [ViewUtilities checkPhotoLibraryContent];
}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(![segue.identifier isEqualToString:SEGUE_GOTO_PUZZLE_SETTINGS_VIEW] && ![segue.identifier isEqualToString:SEGUE_GOTO_SETTINGS_VIEW]) {
        [SoundUtilities playSoundWithName:GENERIC_BUTTON_SOUND andFormat:SOUND_TYPE_MP3];
    }
    
    if ([segue.identifier isEqualToString:SEGUE_GOTO_STICKERS]) {
        NSArray *selectedItems = [self.galleryCollection indexPathsForSelectedItems];
        if (selectedItems.count > 0) {
            
            if (isUserImageSelected) {
                [((StickersViewController*)segue.destinationViewController) setPuzzleAssetType: PUZZLE_MEDIA_TYPE_IMAGE_ASSET];
                [((StickersViewController*)segue.destinationViewController) setPuzzleAsset: self.userImageAsset];
                
                [EventsManager reportEventWithType:EVENT_FEATURED_USER_IMAGE_SELECTED withParameters:nil];
                isUserImageSelected = NO;
            }
            else if ([[((NSDictionary*)[self.galleryItemPaths objectAtIndex:self.selectedRow]) objectForKey:@"type"] isEqualToString:@"image"] )
            {
                if ([((NSDictionary*)[self.galleryItemPaths objectAtIndex:self.selectedRow]) objectForKey:@"watermark"]) {
                    [((StickersViewController*)segue.destinationViewController) setBAddWatermark:[[((NSDictionary*)[self.galleryItemPaths objectAtIndex:self.selectedRow]) objectForKey:@"watermark"] boolValue]];
                }
                [((StickersViewController*)segue.destinationViewController) setPuzzleAssetType: PUZZLE_MEDIA_TYPE_IMAGE];
                [((StickersViewController*)segue.destinationViewController) setPuzzleAsset:[UIImage imageNamed:[((NSDictionary*)[self.galleryItemPaths objectAtIndex:self.selectedRow]) objectForKey:@"name"]]];
                
                [EventsManager reportEventWithType:EVENT_FEATURED_IMAGE_SELECTED withParameters:nil];
            }
            else {
                if ([((NSDictionary*)[self.galleryItemPaths objectAtIndex:self.selectedRow]) objectForKey:@"watermark"]) {
                    [((StickersViewController*)segue.destinationViewController) setBAddWatermark:[[((NSDictionary*)[self.galleryItemPaths objectAtIndex:self.selectedRow]) objectForKey:@"watermark"] boolValue]];
                }
                [((StickersViewController*)segue.destinationViewController) setPuzzleAssetType:PUZZLE_MEDIA_TYPE_VIDEO_URL];
                [((StickersViewController*)segue.destinationViewController) setPuzzleAsset:[[NSBundle mainBundle] URLForResource:[((NSDictionary*)[self.galleryItemPaths objectAtIndex:self.selectedRow]) objectForKey:@"name"] withExtension:@"mp4"]];
                NSInteger loop = [((NSDictionary*)[self.galleryItemPaths objectAtIndex:self.selectedRow]) objectForKey:@"loop"] ? [[((NSDictionary*)[self.galleryItemPaths objectAtIndex:self.selectedRow]) objectForKey:@"loop"] integerValue] : 0;
                [((StickersViewController*)segue.destinationViewController) setVideoLoopCount:loop];
                NSString *audio = [((NSDictionary*)[self.galleryItemPaths objectAtIndex:self.selectedRow]) objectForKey:@"track"] ? [((NSDictionary*)[self.galleryItemPaths objectAtIndex:self.selectedRow]) objectForKey:@"track"] : nil;
                [((StickersViewController*)segue.destinationViewController) setAudioTrack:audio];
                
                [EventsManager reportEventWithType:EVENT_FEATURED_VIDEO_SELECTED withParameters:nil];
            }
            
            
        }
    }
    
    [self resetNavBarBackBtn];
}

#pragma mark - Collection View
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.collectionContent.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PuzzlfyGallaryCell" forIndexPath:indexPath];
    UIActivityIndicatorView *loader = (UIActivityIndicatorView *)[cell viewWithTag:103];
    [loader setHidden:YES];
    [loader stopAnimating];
    UIImageView *imageView = (UIImageView *) [cell viewWithTag:102];
    
    if (indexPath.row == USER_IMAGE_INDEX && !isPhotoLibraryEmpty) {
        if (self.userImage) {
            [imageView setImage:self.userImage];
            [loader setHidden:YES];
            [loader stopAnimating];
        }
        else if (self.galleryThumbsPaths.count < self.collectionContent.count) {
            [imageView setImage: [UIImage imageNamed:EMPTY_THUMB_IMG]];
            [loader startAnimating];
            [loader setHidden:NO];
        }
    }
    else {
        [imageView setImage:[UIImage imageNamed:[((NSDictionary*)[self.galleryThumbsPaths objectAtIndex: (indexPath.row < USER_IMAGE_INDEX) ? indexPath.row : indexPath.row-adjustIndexValue]) objectForKey:@"name"]]];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == (self.collectionContent.count-1)) {
        [ViewUtilities presentInformation:@"More exciting videos coming soon!"];
    }
    else if (indexPath.row == USER_IMAGE_INDEX && !self.userImage && !isPhotoLibraryEmpty) {
        return;
    }
    else if (indexPath.row == 0) {
        [self performSegueWithIdentifier:SEGUE_GOTO_GALLERY_VIEW sender:collectionView];
    }
    else {
        if (indexPath.row == USER_IMAGE_INDEX && !isPhotoLibraryEmpty) {
            isUserImageSelected = YES;
        }
        self.selectedRow = (indexPath.row < USER_IMAGE_INDEX) ? indexPath.row : indexPath.row-adjustIndexValue;
        [self performSegueWithIdentifier:SEGUE_GOTO_STICKERS sender:collectionView];
    }
}

- (BOOL)isPhotoLibraryEmpty
{
    __block BOOL isEmpty;
    ALAssetsLibrary *assetsLibrary = [ViewUtilities defaultAssetsLibrary];
    
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if(result) {
                isEmpty = NO;
            }
            else {
                isEmpty = YES;
            }
            
            return;
        }];
        
    } failureBlock:^(NSError *error) {
        isEmpty = YES;
        NSLog(@"Error loading images %@", error);
    }];
    
    return isEmpty;
}

- (void)getRandomUserImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        ALAssetsLibrary *assetsLibrary = [ViewUtilities defaultAssetsLibrary];
        
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            if (group.numberOfAssets) {
                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *innerStop) {
                    if(result)
                    {
                        self.userImageAsset = result;
                        self.userImage = [UIImage imageWithCGImage:[self.userImageAsset aspectRatioThumbnail]];
                        *stop = YES;
                        *innerStop = YES;
                        if (isPhotoLibraryEmpty) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                isPhotoLibraryEmpty = NO;
                                [self updateCollectionViewContent];
                                [self addUserPhotoToCollectionView];
                            });
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self performSelector:@selector(reloadCollectionView) withObject:nil afterDelay:0.5];
                    });
                }];
            }
            else if (!group.numberOfAssets && !*stop && !isPhotoLibraryEmpty) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.collectionContent.count > self.galleryThumbsPaths.count) {
                        self.collectionContent = [[NSMutableArray alloc]initWithArray:self.galleryThumbsPaths];
                        adjustIndexValue = 0;
                        [self removeUserImageFromCollectionView];
                        [self.galleryCollection reloadData];
                    }
                });
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"Error loading images %@", error);
        }];
    });
}

- (void)reloadCollectionView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.galleryCollection reloadData];
    });
}

- (void)removeUserImageFromCollectionView
{
    @try {
        [self.galleryCollection deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:USER_IMAGE_INDEX inSection:0]]];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception.description);
    }
}

- (void)addUserPhotoToCollectionView
{
    @try {
        [self.galleryCollection insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:USER_IMAGE_INDEX inSection:0]]];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.debugDescription);
    }
}

- (void)photoLibraryNotification:(NSNotification *)notification
{
    BOOL oldFlag = isPhotoLibraryEmpty;
    [self getRandomUserImage];
    isPhotoLibraryEmpty = [[((NSDictionary*)[notification object]) objectForKey:@"isEmpty"] boolValue];
    [self updateCollectionViewContent];
    if (isPhotoLibraryEmpty && self.galleryThumbsPaths.count < self.collectionContent.count) {
        [self removeUserImageFromCollectionView];
    }
    else if (oldFlag && !isPhotoLibraryEmpty) {
        [self addUserPhotoToCollectionView];
    }
    adjustIndexValue = (isPhotoLibraryEmpty) ? 0 : 1;
    [self.galleryCollection reloadData];
}

- (void) dismissPermissionNotification
{
    [ViewUtilities checkPhotoLibraryContent];
}

- (void)recieveApplicationWillEnterBackgroundNotification
{
    [ViewUtilities dismissAlertView];
}

- (IBAction) unwind:(UIStoryboardSegue *) segue {
}
@end
