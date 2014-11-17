//
//  CMProgramacaoViewController.h
//  A Cachacaria
//
//  Created by Eduardo Mollo on 8/4/14.
//  Copyright (c) 2014 EdtX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMProgramacaoViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet UILabel *diaUmLabel;
@property (strong, nonatomic) IBOutlet UILabel *diaDoisLabel;

@property (strong, nonatomic) IBOutlet UIImageView *diaUmSmallImageView;
@property (strong, nonatomic) IBOutlet UIImageView *diaDoisSmallImageView;

@property (strong, nonatomic) IBOutlet UIImageView *programacaoImageView;

- (IBAction)diaUmButtonPressed:(UIButton *)sender;
- (IBAction)diaDoisButtonPressed:(UIButton *)sender;

@end
