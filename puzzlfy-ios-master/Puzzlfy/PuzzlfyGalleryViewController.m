//
//  PuzzlfyGalleryViewController.m
//  Puzzlfy
//
//  Created by Youmna on 5/6/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "PuzzlfyGalleryViewController.h"
#import "NavigationBarView.h"
#import  <AssetsLibrary/AssetsLibrary.h>
#import "GalleryCellView.h"
#import "StickersViewController.h"
#import "GalleryCollectionView.h"
#import "SegueNames.h"
#import "UIView+Shadow.h"
#import "SoundUtilities.h"
#import "ViewUtilities.h"
#import "Notifications.h"
#import "Constants.h"
#import "EventsManager.h"

@interface PuzzlfyGalleryViewController ()
@property (strong, nonatomic) IBOutlet GalleryCollectionView *collectionView;
@property (strong, nonatomic) ALAssetsLibrary* assetsLibrary;
@property(nonatomic, strong) NSArray *assets;
@property (strong, nonatomic) ALAsset *libAsset;
@property (nonatomic) int assetType;

@end

@implementation PuzzlfyGalleryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadAssets
{
    if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) {
        [self.vPermissionsImageView setHidden:YES];
        
        _assets = [@[] mutableCopy];
        __block NSMutableArray *tmpAssets = [@[] mutableCopy];
        // 1
        
        ALAssetsLibrary *assetsLibrary = [ViewUtilities defaultAssetsLibrary];
        // 2
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if(result)
                {
                    // 3
                    [tmpAssets addObject:result];
                }
            }];
            
            // 4
            //NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
            //self.assets = [tmpAssets sortedArrayUsingDescriptors:@[sort]];
            self.assets = tmpAssets;
            
            // 5
            [self.collectionView reloadData];
        } failureBlock:^(NSError *error) {
            [EventsManager reportEventWithType:EVENT_GALLERY_PERMISSION_DENIED withParameters:nil];
            NSLog(@"Error loading images %@", error);
        }];
    }
    else if ([ALAssetsLibrary authorizationStatus] != ALAuthorizationStatusNotDetermined) {
        [self.vPermissionsImageView setHidden:NO];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAssets) name:APP_WILL_ENTER_FOREGROUND_NOTIFICATION object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAssetChangedNotifiation:) name:ALAssetsLibraryChangedNotification object:_assetsLibrary];
    [self loadAssets];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionViewContainer addSubview:self.collectionView.verticalScrollBar];
    [self.collectionViewContainer makeInsetShadowWithRadius:15 Color:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3] Directions:[NSArray arrayWithObjects:@"top", nil]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) adjustNavigationBarButtonsVisibility:(NavigationBarView*) bar
{
    [bar.menuButton setHidden:YES];
}

#pragma mark - Collection View
- (NSInteger)numberOfSectionsInCollectionView:(GalleryCollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(GalleryCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(GalleryCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GalleryCellView *cell = (GalleryCellView *)[collectionView dequeueReusableCellWithReuseIdentifier:@"galleryCell" forIndexPath:indexPath];
    
    ALAsset *asset = self.assets[indexPath.row];
    cell.asset = asset;
    cell.backgroundColor = [UIColor blackColor];
    return cell;
}

- (void) collectionView:(GalleryCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.libAsset = self.assets[indexPath.row];
    
    if (self.libAsset) {
        if(!((GalleryCellView*)[collectionView cellForItemAtIndexPath:indexPath]).isVideo)
        {
            self.assetType = PUZZLE_MEDIA_TYPE_IMAGE_ASSET;
            [EventsManager reportEventWithType:EVENT_GALLERY_IMAGE_SELECTED withParameters:nil];
        }
        else {
            self.assetType = PUZZLE_MEDIA_TYPE_VIDEO_ASSET;
            [EventsManager reportEventWithType:EVENT_GALLERY_IMAGE_SELECTED withParameters:nil];
        }
        @try {
            [self performSegueWithIdentifier:SEGUE_GOTO_STICKERS sender:self];
        }
        @catch (NSException *exception) {
            NSLog(@"Error loading image");
        }
    }
    else {
        [self loadAssets];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(self.collectionView == scrollView)
    {
        [self.collectionView.verticalScrollBar.handle setHidden:NO];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(self.collectionView == scrollView)
    {
        [self.collectionView.verticalScrollBar.handle setHidden:YES];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:SEGUE_GOTO_STICKERS])
    {
        [SoundUtilities playSoundWithName:GENERIC_BUTTON_SOUND andFormat:SOUND_TYPE_MP3];
        
        [((StickersViewController*)segue.destinationViewController) setPuzzleAsset:self.libAsset];
        [((StickersViewController*)segue.destinationViewController) setPuzzleAssetType: self.assetType];
    }
}


@end
