//
//  InfoViewController.h
//  Puzzlfy
//
//  Created by Adham Aboul Einein on 5/27/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PuzzleSelectionViewController.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface InfoViewController : PuzzlfyParentViewController <MFMailComposeViewControllerDelegate>

- (IBAction)openWebsite:(id)sender;
- (IBAction)sendFeedback:(id)sender;
- (IBAction)caminandesClicked:(id)sender;
- (IBAction)kidssafeClicked:(id)sender;

@end
