//
//  CMChatLoginViewController.h
//  A Cachacaria
//
//  Created by Eduardo Mollo on 8/4/14.
//  Copyright (c) 2014 EdtX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KASlideShow.h"

@interface CMHomeViewController : UIViewController

@property (strong, nonatomic) NSMutableData *imageData;

@property (strong, nonatomic) IBOutlet UIButton *facebookLoginButton;
@property (strong, nonatomic) IBOutlet UIButton *googleLoginButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UITextView *introTextView;
@property (strong, nonatomic) IBOutlet PFImageView *perfilImageView;

@property (strong, nonatomic) IBOutlet KASlideShow *slideshow;

- (IBAction)facebookButtonPressed:(UIButton *)sender;
- (IBAction)googleButtonPressed:(UIButton *)sender;

@end
