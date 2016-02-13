//
//  IRMainViewController.m
//  iRecognize
//
//  Created by Háló Zsolt on 12/02/16.
//  Copyright © 2016 Spitfire. All rights reserved.
//

#import "IRMainViewController.h"
#import "IRUseModeViewController.h"
#import "IRTestModeViewController.h"

@interface IRMainViewController () 

@property (nonatomic, weak) IBOutlet UIView *viewControllerContainer;
@property (nonatomic, strong) IRUseModeViewController *useController;
@property (nonatomic, strong) IRTestModeViewController *testController;

- (IBAction)segmentControlValueChanged:(UISegmentedControl*)sender;

@end

@implementation IRMainViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self addUseControler];
	[self addTestControler];
}

#pragma mark - Action Methods

- (IBAction)segmentControlValueChanged:(UISegmentedControl*)sender {
	switch (sender.selectedSegmentIndex) {
		case 0:
			[self showTestViewController];
			break;
		case 1:
			[self showUseViewController];
			break;
	}
	
}

- (void)addUseControler {
	_useController = [[IRUseModeViewController alloc] initWithNibName:@"IRUseModeViewController" bundle:[NSBundle mainBundle]];
	[self addChildViewController:_useController];
	_useController.view.frame = self.view.frame;
	[_viewControllerContainer addSubview:_useController.view];
	[_useController didMoveToParentViewController:self];
}

- (void)addTestControler {
	_testController = [[IRTestModeViewController alloc] initWithNibName:@"IRTestModeViewController" bundle:[NSBundle mainBundle]];
	[self addChildViewController:_testController];
	_testController.view.frame = self.view.frame;
	[_viewControllerContainer addSubview:_testController.view];
	[_testController didMoveToParentViewController:self];
}

- (void)showUseViewController {
	[UIView transitionFromView:_testController.view toView:_useController.view duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve completion:nil];
}

- (void)showTestViewController {
	[UIView transitionFromView:_useController.view toView:_testController.view duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve completion:nil];
}

@end
