//
//  CMChatLoginViewController.h
//  A Cachacaria
//
//  Created by Eduardo Mollo on 11/17/14.
//  Copyright (c) 2014 EdtX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMChatLoginViewController : UIViewController

@property (strong, nonatomic) NSMutableData *imageData;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *facebookLoginButton;

- (IBAction)facebookButtonPressed:(UIButton *)sender;

@end
