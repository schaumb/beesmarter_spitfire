//
//  IRMainViewController.m
//  iRecognize
//
//  Created by Háló Zsolt on 12/02/16.
//  Copyright © 2016 Spitfire. All rights reserved.
//

#import "IRMainViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface IRMainViewController () 

- (IBAction)showPreviewButtonPressed:(id)sender;

@end

@implementation IRMainViewController

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void) presentImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType {
	UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
	[imagePickerController setSourceType:([UIImagePickerController isSourceTypeAvailable:sourceType] ? sourceType : UIImagePickerControllerSourceTypePhotoLibrary)];
	[imagePickerController setDelegate:self];
	[self presentViewController:imagePickerController animated:YES completion:nil];
}

- (IBAction)showPreviewButtonPressed:(id)sender {
	AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
	if (status == AVAuthorizationStatusNotDetermined) {
		[AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
			if (granted) {
				[self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
			}
		}];
	}
	else {
		[self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
	}
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
	
}


@end
