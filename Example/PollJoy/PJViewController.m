//
//  PJViewController.m
//  PollJoy
//
//  Created by Bartjezzz on 07/30/2021.
//  Copyright (c) 2021 Bartjezzz. All rights reserved.
//

#import "PJViewController.h"


@interface PJViewController ()

@end

@implementation PJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[Polljoy getPollWithDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark delegate methods

-(void) PJPollNotAvailable:(PJResponseStatus) status
{
	NSLog(@"PJPollNotAvailable: %i",status);
}

-(void) PJPollIsReady:(NSArray *) polls
{
	NSLog(@"PJPollIsReady: %@",[polls description]);
	[Polljoy showPoll];
}

-(void) PJPollWillShow:(PJPoll*) poll
{
	NSLog(@"PJPollWillShow: %@",[poll description]);
}

-(void) PJPollDidShow:(PJPoll*) poll
{
	NSLog(@"PJPollDidShow: %@",[poll description]);
}

-(void) PJPollWillDismiss:(PJPoll*) poll
{
	NSLog(@"PJPollWillDismiss: %@",[poll description]);
}

-(void) PJPollDidDismiss:(PJPoll*) poll
{
	NSLog(@"PJPollDidDismiss: %@",[poll description]);
}

@end
