//
//  CMProgramacaoViewController.m
//  A Cachacaria
//
//  Created by Eduardo Mollo on 8/4/14.
//  Copyright (c) 2014 EdtX. All rights reserved.
//

#import "CMProgramacaoViewController.h"
#define pi 3.1415

@interface CMProgramacaoViewController ()

@property (strong, nonatomic) NSMutableArray *banner;

@end

@implementation CMProgramacaoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.programacaoImageView.hidden = YES;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self.activityIndicator startAnimating];
    
    PFQuery *queryForBanner = [PFQuery queryWithClassName:kCMBannerClassKey];

    [queryForBanner findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.banner = [objects mutableCopy];
            
            PFObject *diaUm = self.banner[0];
            PFObject *diaDois = self.banner[1];
            
            self.diaUmLabel.text = diaUm[@"date"];
            self.diaDoisLabel.text = diaDois[@"date"];
            
            PFFile *diaUmFile = diaUm[@"banner"];
            
            PFFile *diaDoisFile = diaDois[@"banner"];
            
            if (diaUmFile != NULL) {
                [diaUmFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        UIImage *bannerImage = [UIImage imageWithData:data];
                        self.diaUmSmallImageView.image = bannerImage;

                    }
                    [self.activityIndicator stopAnimating];
                    
                }];
            }
            else {
                [self.activityIndicator stopAnimating];
            }
            
            if (diaDoisFile != NULL) {
                [diaDoisFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        UIImage *bannerImage = [UIImage imageWithData:data];
                        self.diaDoisSmallImageView.image = bannerImage;
                    }
                    [self.activityIndicator stopAnimating];
                    
                }];
            }
            else {
                [self.activityIndicator stopAnimating];
            }
            
        }
    }];

}


- (IBAction)diaUmButtonPressed:(UIButton *)sender
{
    if (self.programacaoImageView.isHidden) {
        
        PFObject *diaUm = self.banner[0];
        
        PFFile *bannerFile = diaUm[@"banner"];
        
        if (bannerFile != NULL) {
            [bannerFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    UIImage *bannerImage = [UIImage imageWithData:data];
                    self.programacaoImageView.image = bannerImage;
                }
                [self.activityIndicator stopAnimating];
                
            }];
        }
        else {
            [self.activityIndicator stopAnimating];
        }

        self.programacaoImageView.hidden = NO;
    }
    else {
        self.programacaoImageView.hidden = YES;
    }
}

- (IBAction)diaDoisButtonPressed:(UIButton *)sender
{
    if (self.programacaoImageView.isHidden) {
        
        PFObject *diaDois = self.banner[1];
        
        PFFile *bannerFile = diaDois[@"rotatedBanner"];
        
        if (bannerFile != NULL) {
            [bannerFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    UIImage *bannerImage = [UIImage imageWithData:data];
                    self.programacaoImageView.image = bannerImage;
                }
                [self.activityIndicator stopAnimating];
                
            }];
        }
        else {
            [self.activityIndicator stopAnimating];
        }

        self.programacaoImageView.hidden = NO;
    }
    else {
        self.programacaoImageView.hidden = YES;
    }
}
@end
