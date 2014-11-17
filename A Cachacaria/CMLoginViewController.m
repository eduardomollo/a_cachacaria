//
//  CMLoginViewController.m
//  A Cachacaria
//
//  Created by Eduardo Mollo on 8/11/14.
//  Copyright (c) 2014 EdtX. All rights reserved.
//

#import "CMLoginViewController.h"

@interface CMLoginViewController ()

@end

@implementation CMLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PFLogInViewController *logInController = [[PFLogInViewController alloc] init];
    logInController.delegate = self;
    [self presentModalViewController:logInController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
