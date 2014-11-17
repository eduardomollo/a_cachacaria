//
//  CMChatLoginViewController.m
//  A Cachacaria
//
//  Created by Eduardo Mollo on 8/4/14.
//  Copyright (c) 2014 EdtX. All rights reserved.
//

#import "CMHomeViewController.h"

@interface CMHomeViewController ()



@end

@implementation CMHomeViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
   // self.chat = [[self.tabBarController.tabBar subviews] objectAtIndex:2];
    
    [self slideShow];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

}


- (void)slideShow {
    [self.slideshow setDelay:3]; // Delay between transitions
    [self.slideshow setTransitionDuration:1]; // Transition duration
    [self.slideshow setTransitionType:KASlideShowTransitionFade]; // Choose a transition type (fade or slide)
    [self.slideshow setImagesContentMode:UIViewContentModeScaleAspectFit]; // Choose a content mode for images to display
    [self.slideshow addImagesFromResources:@[@"perfil.jpg",@"logo.png"]]; // Add images from resources
    [self.slideshow start];
}

- (void)getUserLocation {
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            // do something with the new geoPoint
            PFGeoPoint *acachacaria = [PFGeoPoint geoPointWithLatitude:-21.465765 longitude:-47.002666];
            
            PFObject *localizacao = [PFObject objectWithClassName:@"Localizacao"];
            [localizacao setObject:[PFUser currentUser] forKey:@"user"];
            [localizacao setObject:@(geoPoint.latitude) forKey:@"latitude"];
            [localizacao setObject:@(geoPoint.longitude) forKey:@"longitude"];
            [localizacao setObject:@([acachacaria distanceInKilometersTo:geoPoint]) forKey:@"distKm"];
            [localizacao saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) NSLog(@"geoPoint saved");
            }];
        }
    }];
}

@end
