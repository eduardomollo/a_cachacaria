//
//  CMChatRoomViewController.m
//  A Cachacaria
//
//  Created by Eduardo Mollo on 8/9/14.
//  Copyright (c) 2014 EdtX. All rights reserved.
//

#import "CMChatRoomViewController.h"

@interface CMChatRoomViewController ()

extern NSString *const TXCToxAppDelegateNotificationNewMessage;

@property (strong, nonatomic) PFUser *withUser;
@property (strong, nonatomic) PFUser *currentUser;

@property (strong, nonatomic) NSTimer *chatsTimer;
@property (nonatomic) BOOL initialLoadComplete;

@property (strong, nonatomic) NSMutableArray *chats;
@property (strong, nonatomic) NSMutableArray *message;

@end

@implementation CMChatRoomViewController

-(NSMutableArray *)chats
{
    if (!_chats){
        _chats = [[NSMutableArray alloc] init];
    }
    return _chats;
}

-(NSMutableArray *)message
{
    if (!_message){
        _message = [[NSMutableArray alloc] init];
    }
    return _message;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// Scroll to the most recent message before view appears
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = YES;
    [self scrollToBottomAnimated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
    self.dataSource = self;
    
    [[JSBubbleView appearance] setFont:[UIFont fontWithName:@"HelveticaNeue" size:17.0f]];
    self.messageInputView.textView.placeHolder = @"Nova mensagem";
    self.sender = [PFUser currentUser][kCCUserProfileKey][kCCUserProfileFirstNameKey];
    [self setBackgroundColor:[UIColor whiteColor]];
    
    
    self.currentUser = [PFUser currentUser];
    PFUser *testUser1 = self.chatRoom[kCCChatRoomUser1Key];
    if ([testUser1.objectId isEqual:self.currentUser.objectId]){
        self.withUser = self.chatRoom[kCCChatRoomUser2Key];
    }
    else {
        self.withUser = self.chatRoom[kCCChatRoomUser1Key];
    }
    self.title = self.withUser[kCCUserProfileKey][kCCUserProfileFirstNameKey];
    self.initialLoadComplete = NO;
    
    [self checkForNewChats];
    
    self.chatsTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkForNewChats) userInfo:nil repeats:YES];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
    self.tabBarController.tabBar.hidden = NO;
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.chatsTimer invalidate];
    self.chatsTimer = nil;
}

#pragma mark - TableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.chats count];
}

#pragma mark - Message View Delegate REQUIRED

- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date
{
    if (text.length != 0){
        PFObject *chat = [PFObject objectWithClassName:kCCChatClassKey];
        [chat setObject:self.chatRoom forKey:kCCChatChatroomKey];
        [chat setObject:self.currentUser forKey:kCCChatFromUserKey];
        [chat setObject:self.withUser forKey:kCCChatToUserKey];
        [chat setObject:text forKey:kCCChatTextKey];
        [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self.chats addObject:chat];
                [JSMessageSoundEffect playMessageSentSound];
                [self.tableView reloadData];
                [self finishSend];
                [self scrollToBottomAnimated:YES];
            }
            else {
                NSLog(@"%@", error);
            }

        }];
    }

}
    
-(JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testFromUser = chat[kCCChatFromUserKey];
    
    if ([testFromUser.objectId isEqual:self.currentUser.objectId]){
        return JSBubbleMessageTypeOutgoing;
    }
    else {
        return JSBubbleMessageTypeIncoming;
    }
}

-(UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testFromUser = chat[kCCChatFromUserKey];
    
    
    if ([testFromUser.objectId isEqual:self.currentUser.objectId]){
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleGreenColor]];
    }
    else{
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleLightGrayColor]];
    }
}

-(JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

#pragma mark - Messages View Delegate OPTIONAL

-(void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([cell messageType] == JSBubbleMessageTypeOutgoing){
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
    }
}

-(BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return YES;
}

#pragma mark - Messages View Data Source REQUIRED

-(id<JSMessageData>)messageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];
    NSDate *createdDate = chat.createdAt;
    NSString *text = [chat objectForKey:kCCChatTextKey];
    PFUser *fromUser = [chat objectForKey:kCCChatFromUserKey];

    NSString *sender = fromUser[kCCUserProfileKey][kCCUserProfileFirstNameKey];
    self.message = [[NSMutableArray alloc] initWithObjects:
                     [[JSQMessage alloc] initWithText:text sender:sender date:createdDate], nil];
    
    return self.message[0];
}

-(UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender
{
    return nil;
}


#pragma mark - Helper Methods

- (void)checkForNewChats
{
    int oldChatCount = [self.chats count];
    
    PFQuery *queryForChats = [PFQuery queryWithClassName:kCCChatClassKey];
    [queryForChats whereKey:kCCChatChatroomKey equalTo:self.chatRoom];
    [queryForChats includeKey:kCCChatFromUserKey];
    [queryForChats orderByAscending:@"createdAt"];
    [queryForChats findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error){
            if (self.initialLoadComplete == NO || oldChatCount != [objects count]){
                self.chats = [objects mutableCopy];
                
                [self.tableView reloadData];
                
                if (self.initialLoadComplete == YES){
                    [JSMessageSoundEffect playMessageReceivedSound];
                }
                
                self.initialLoadComplete = YES;
                [self scrollToBottomAnimated:YES];
            }
        }
        else {
            NSLog(@"%@", error);
        }
    }];
}

@end
