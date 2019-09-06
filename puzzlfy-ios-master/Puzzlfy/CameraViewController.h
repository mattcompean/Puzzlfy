//
//  CameraViewController.h
//  Puzzlfy
//
//  Created by Adham Aboul Einein on 5/7/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PuzzlfyParentViewController.h"
#import "PuzzlfyUIButton.h"

@interface CameraViewController : PuzzlfyParentViewController <UIAlertViewDelegate>

- (IBAction)closeButtonClicked:(id)sender;
@property (strong, nonatomic) IBOutlet PuzzlfyUIButton *closeButton;
@end
