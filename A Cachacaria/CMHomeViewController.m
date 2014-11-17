//
//  CMChatLoginViewController.m
//  A Cachacaria
//
//  Created by Eduardo Mollo on 8/4/14.
//  Copyright (c) 2014 EdtX. All rights reserved.
//

#import "CMHomeViewController.h"

@interface CMHomeViewController ()

@property (strong, nonatomic) NSMutableArray *photoUsersArray;
@property (strong, nonatomic) UIBarButtonItem *chat;

@end

@implementation CMHomeViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.chat = [[self.tabBarController.tabBar subviews] objectAtIndex:2];
    
    [self slideShow];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){
        [self updateUserInformation];
        [self queryForPhotoUsers];
        [self.chat setEnabled:YES];
        [self getUserLocation];
    }
    else {
        NSString *introText = [[NSString alloc] initWithFormat:@"Olá, seja bem vindo ao App da Cachaçaria Mococa"];
        self.introTextView.text = introText;
        self.perfilImageView.image = nil;
        [self.chat setEnabled:NO];
        NSLog(@"viewWillAppear");
    }
}

#pragma mark - IBAction

- (IBAction)facebookButtonPressed:(UIButton *)sender
{
    [self.activityIndicator startAnimating];
    
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){
        [PFUser logOut];
        self.perfilImageView.image = nil;
        
        [self.chat setEnabled:NO];
        
        [self.activityIndicator stopAnimating];
        
        [self.facebookLoginButton setImage:[UIImage imageNamed:@"facebookLoginButton.png"] forState:UIControlStateNormal];
        
        NSString *introText = [[NSString alloc] initWithFormat:@"Olá, seja bem vindo ao App da Cachaçaria Mococa"];
        self.introTextView.text = introText;
        
    }
    else {
        
        NSArray *permissionsArray = @[@"user_about_me", @"user_interests", @"user_relationships", @"user_birthday", @"user_location", @"user_relationship_details"];
        
        //NSArray *permissionsArray = @[@"public_profile", @"email", @"user_friends", @"user_birthday", @"user_location"];
        
        [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
            
            [self.activityIndicator stopAnimating];

            if (!user){
                if (!error){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"The Facebook Login was Canceled" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [alertView show];
                }
                else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [alertView show];
                }
            }
            else{
                [self updateUserInformation];
                [self queryForPhotoUsers];
                [self.chat setEnabled:YES];
            }
        }];
        
    }

}

- (IBAction)googleButtonPressed:(UIButton *)sender {
}


#pragma mark - Helper Method

- (void)updateUserInformation
{
    [self.facebookLoginButton setImage:[UIImage imageNamed:@"facebookLogout.png"] forState:UIControlStateNormal];
    
    FBRequest *request = [FBRequest requestForMe];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        if (!error){
            NSDictionary *userDictionary = (NSDictionary *)result;
            
            //create URL
            NSString *facebookID = userDictionary[@"id"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] initWithCapacity:8];
            if (userDictionary[@"name"]){
                userProfile[kCCUserProfileNameKey] = userDictionary[@"name"];
            }
            if (userDictionary[@"first_name"]){
                userProfile[kCCUserProfileFirstNameKey] = userDictionary[@"first_name"];
            }
            if (userDictionary[@"location"][@"name"]){
                userProfile[kCCUserProfileLocationKey] = userDictionary[@"location"][@"name"];
            }
            if (userDictionary[@"gender"]){
                userProfile[kCCUserProfileGenderKey] = userDictionary[@"gender"];
            }
            if (userDictionary[@"birthday"]){
                userProfile[kCCUserProfileBirthdayKey] = userDictionary[@"birthday"];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterShortStyle];
                NSDate *date = [formatter dateFromString:userDictionary[@"birthday"]];
                NSDate *now = [NSDate date];
                NSTimeInterval seconds = [now timeIntervalSinceDate:date];
                int age = seconds / 31536000;
                userProfile[kCCUserProfileAgeKey] = @(age);
            }
            if (userDictionary[@"interested_in"]){
                userProfile[kCCUserProfileInterestedInKey] = userDictionary[@"interested_in"];
            }
            if (userDictionary[@"relationship_status"]){
                userProfile[kCCUserProfileRelationshipStatusKey] = userDictionary[@"relationship_status"];
            }
            if ([pictureURL absoluteString]){
                userProfile[kCCUserProfilePictureURL] = [pictureURL absoluteString];
            }
            
            [[PFUser currentUser] setObject:userProfile forKey:kCCUserProfileKey];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [self requestImage];
                }
                else NSLog(@"User not saved");
            }];
            
            NSString *introText = [[NSString alloc] initWithFormat:@"Olá %@, seja bem vindo ao App da Cachaçaria Mococa", userProfile[kCCUserProfileFirstNameKey]];
            self.introTextView.text = introText;
            
            
        }
        else {
            NSLog(@"Error in FB request %@", error);
        }
    }];
    
}


- (void)uploadPFFileToParse:(UIImage *)image
{
    NSLog(@"upload called");
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    
    if (!imageData){
        NSLog(@"imageData was not found.");
        return;
    }
    
    PFFile *photoFile = [PFFile fileWithData:imageData];
    
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded){
            PFObject *photo = [PFObject objectWithClassName:kCCPhotoClassKey];
            [photo setObject:[PFUser currentUser] forKey:kCCPhotoUserKey];
            [photo setObject:photoFile forKey:kCCPhotoPictureKey];
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Photo saved successfully");
                }
            }];
        }
        else NSLog(@"Failed to save photo");
    }];
}

- (void)requestImage
{
    PFQuery *query = [PFQuery queryWithClassName:kCCPhotoClassKey];
    [query whereKey:kCCPhotoUserKey equalTo:[PFUser currentUser]];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error && number == 0)
        {
            PFUser *user = [PFUser currentUser];
            self.imageData = [[NSMutableData alloc] init];
            
            NSURL *profilePictureURL = [NSURL URLWithString:user[kCCUserProfileKey][kCCUserProfilePictureURL]];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            if (!urlConnection) {
                NSLog(@"Failed to Download Picture");
            }
        }
    }];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"connection did recieve data");
    [self.imageData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connectionDidFinishLoading");
    UIImage *profileImage = [UIImage imageWithData:self.imageData];
    [self uploadPFFileToParse:profileImage];
}

- (void)queryForPhotoUsers
{
    PFQuery *queryPhotoClass = [PFQuery queryWithClassName:kCCPhotoClassKey];
    [queryPhotoClass whereKey:kCCPhotoUserKey notEqualTo:[PFUser currentUser]];
    [queryPhotoClass includeKey:kCCPhotoUserKey];
    [queryPhotoClass findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && objects != NULL) {
            self.photoUsersArray = [objects mutableCopy];
            [self updateChatRoom:self.photoUsersArray];
        }
        else NSLog(@"Erro: %@", error);
    }];
    
    PFQuery *perfilPhotoQuery = [PFQuery queryWithClassName:kCCPhotoClassKey];
    [perfilPhotoQuery whereKey:kCCPhotoUserKey equalTo:[PFUser currentUser]];
    [perfilPhotoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && objects != NULL) {
            PFObject *photoObject = objects[0];
            PFFile *photoFile = photoObject[kCCPhotoPictureKey];
            self.perfilImageView.file = photoFile;
            [self.perfilImageView loadInBackground];
        }
    }];
}

- (void)updateChatRoom:(NSMutableArray *)array
{
    int i;
    if (array != NULL) {
        for (i = 0; i < array.count; i++) {
            PFObject *toUser = array[i];
            
            PFQuery *chatRoom = [PFQuery queryWithClassName:kCCChatRoomClassKey];
            [chatRoom whereKey:kCCChatRoomUser1Key equalTo:[PFUser currentUser]];
            [chatRoom whereKey:kCCChatRoomUser2Key equalTo:toUser[kCCPhotoUserKey]];
            
            PFQuery *chatRoomInverse = [PFQuery queryWithClassName:kCCChatRoomClassKey];
            [chatRoomInverse whereKey:kCCChatRoomUser1Key equalTo:toUser[kCCPhotoUserKey]];
            [chatRoomInverse whereKey:kCCChatRoomUser2Key equalTo:[PFUser currentUser]];
            
            PFQuery *queryCombined = [PFQuery orQueryWithSubqueries:@[chatRoom, chatRoomInverse]];
            [queryCombined includeKey:kCCChatRoomUser1Key];
            [queryCombined includeKey:kCCChatRoomUser2Key];
            [queryCombined findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error && objects.count == 0) {
                    PFObject *chatRoomObject = [PFObject objectWithClassName:kCCChatRoomClassKey];
                    [chatRoomObject setObject:[PFUser currentUser] forKey:kCCChatRoomUser1Key];
                    [chatRoomObject setObject:toUser[kCCPhotoUserKey] forKey:kCCChatRoomUser2Key];
                    [chatRoomObject saveInBackground];
                }
                else {
                    NSLog(@"Erro %@", error);
                }
            }];
        }
    }
    
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
