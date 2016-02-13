//
//  IRUseModeViewController.m
//  iRecognize
//
//  Created by Háló Zsolt on 13/02/16.
//  Copyright © 2016 Spitfire. All rights reserved.
//

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

#import "IRUseModeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "IREvaluator.h"

@interface IRUseModeViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UILabel *fontTypeLabel;
@property (weak, nonatomic) IBOutlet UIView *typeLabelContainerView;

@property (weak, nonatomic) IBOutlet UIImageView *previewImage;

- (IBAction)photoButtonPressed:(id)sender;

@end

@implementation IRUseModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setupPhotoButtonAppearance];
}

- (IBAction)photoButtonPressed:(id)sender {
	[self checkForPermissionAndPresentImagePicker];
	[UIView animateWithDuration:0.3f animations:^{
		_typeLabelContainerView.alpha = 0.0f;
	}];
}

#pragma mark - Internal Methods

- (void)checkForPermissionAndPresentImagePicker {
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

- (void) presentImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType {
	UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
	[imagePickerController setSourceType:([UIImagePickerController isSourceTypeAvailable:sourceType] ? sourceType : UIImagePickerControllerSourceTypePhotoLibrary)];
	[imagePickerController setDelegate:self];
	[self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)setupPhotoButtonAppearance {
	_takePhotoButton.layer.borderWidth = 1.0f;
	_takePhotoButton.layer.cornerRadius = 5.0f;
	_takePhotoButton.layer.borderColor = UIColorFromRGB(0x0075BE).CGColor;
}

- (void)fakeDetect {
	[UIView animateWithDuration:0.3f animations:^{
		_typeLabelContainerView.alpha = 1.0f;
		[_fontTypeLabel setText:[NSString stringWithFormat:@"Font type: %@ ", [IREvaluator evaluateObjc]]];
	}];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
	[picker dismissViewControllerAnimated:YES completion:nil];
	[_previewImage setImage:[info objectForKey:@"UIImagePickerControllerOriginalImage"]];
	[self performSelector:@selector(fakeDetect) withObject:nil afterDelay:2.0f];

}


@end
