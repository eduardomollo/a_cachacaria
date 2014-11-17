//
//  CM2ChatsTableViewController.m
//  A Cachacaria
//
//  Created by Eduardo Mollo on 8/13/14.
//  Copyright (c) 2014 EdtX. All rights reserved.
//

#import "CM2ChatsTableViewController.h"
#import "CMChatRoomViewController.h"

@interface CM2ChatsTableViewController ()

@property (strong, nonatomic) NSMutableArray *availableChatRoomsArray;
@property (strong, nonatomic) NSMutableArray *photoUsersArray;

@end

@implementation CM2ChatsTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom the table
        
        // The className to query on
        self.parseClassName = kCCChatRoomClassKey;
        
        // The key of the PFObject to display in the label of the default cell style
      //  self.textKey = kCCPhotoUserKey;
        
        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
    //    self.imageKey = kCCPhotoPictureKey;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 25;
    }
    return self;
}

-(NSMutableArray *)availableChatRoomsArray
{
    if (!_availableChatRoomsArray){
        _availableChatRoomsArray = [[NSMutableArray alloc] init];
    }
    return _availableChatRoomsArray;
}


#pragma mark - UIViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - PFQueryTableViewController

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
}

// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:kCCChatRoomUser1Key equalTo:[PFUser currentUser]];
    PFQuery *quereInverse = [PFQuery queryWithClassName:self.parseClassName];
    [quereInverse whereKey:kCCChatRoomUser2Key equalTo:[PFUser currentUser]];
    
    PFQuery *queryCombined = [PFQuery orQueryWithSubqueries:@[query, quereInverse]];
    
    [queryCombined includeKey:kCCChatRoomUser1Key];
    [queryCombined includeKey:kCCChatRoomUser2Key];
    
    // If Pull To Refresh is enabled, query against the network by default.
    if (self.pullToRefreshEnabled) {
        queryCombined.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        queryCombined.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [queryCombined orderByDescending:@"createdAt"];
    
    return queryCombined;
}

// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the textKey in the object,
// and the imageView being the imageKey in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";
    
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    PFUser *otherUser;
    PFUser *currentUser = [PFUser currentUser];
    PFUser *testUser = object[kCCChatRoomUser1Key];
    if ([testUser.objectId isEqual:currentUser.objectId]) {
        otherUser = [object objectForKey:kCCChatRoomUser2Key];
    }
    else {
        otherUser = [object objectForKey:kCCChatRoomUser1Key];
    }

    PFQuery *queryForPhoto = [[PFQuery alloc] initWithClassName:kCCPhotoClassKey];
    [queryForPhoto whereKey:kCCPhotoUserKey equalTo:otherUser];
    [queryForPhoto findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && [objects count] > 0){
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[kCCPhotoPictureKey];
            PFImageView *imageView = (PFImageView*)[cell viewWithTag:100];
            imageView.image = [UIImage imageNamed:@"Chat_user.png"];
            imageView.file = pictureFile;
            [imageView loadInBackground];
        }
        else {
            NSLog(@"%@", error);
        }
    }];
    
    UILabel *nameLabel = (UILabel*) [cell viewWithTag:101];
    nameLabel.text = otherUser[kCCUserProfileKey][kCCUserProfileFirstNameKey];
    
    [self.availableChatRoomsArray addObject:object];
    
    return cell;
}


/*
 // Override if you need to change the ordering of objects in the table.
 - (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
 return [self.objects objectAtIndex:indexPath.row];
 }
 */

/*
 // Override to customize the look of the cell that allows the user to load the next page of objects.
 // The default implementation is a UITableViewCellStyleDefault cell with simple labels.
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
 static NSString *CellIdentifier = @"NextPage";
 
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 
 if (cell == nil) {
 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
 }
 
 cell.selectionStyle = UITableViewCellSelectionStyleNone;
 cell.textLabel.text = @"Load more...";
 
 return cell;
 }
 */

#pragma mark - UITableViewDataSource

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the object from Parse and reload the table view
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, and save it to Parse
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"chatsToChatRoomSegue" sender:indexPath];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (self.availableChatRoomsArray != nil) {
        CMChatRoomViewController *chatVC = segue.destinationViewController;
        NSIndexPath *indexPath = sender;
        chatVC.chatRoom = [self.availableChatRoomsArray objectAtIndex:indexPath.row];
    }

}



@end
