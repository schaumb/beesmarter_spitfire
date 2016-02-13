//
//  IRTestModeViewController.m
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

#import "IRTestModeViewController.h"

@interface IRTestModeViewController () <NSStreamDelegate>

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, strong) NSString *previousMessage;
@property (nonatomic, strong) NSString *imageBuffer;
@property (nonatomic, assign) BOOL previousMessageSent;
@property (nonatomic, assign) BOOL firstContainerTop;
@property (nonatomic, assign) NSInteger imagesLeftOnServer;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *labelContainerView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelContainerHeight;
@property (weak, nonatomic) IBOutlet UIButton *goButton;

- (IBAction)goButtonPressed:(id)sender;

@end

@implementation IRTestModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setupPhotoButtonAppearance];
}

#pragma mark Connection Initialization and Destruction

- (void)initNetworkCommunication {
	CFReadStreamRef readStream;
	CFWriteStreamRef writeStream;
	CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"localhost", 8888, &readStream, &writeStream);
	_inputStream = (__bridge NSInputStream *)readStream;
	_outputStream = (__bridge NSOutputStream *)writeStream;
	[_inputStream setDelegate:self];
	[_outputStream setDelegate:self];
	[_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_inputStream open];
	[_outputStream open];
	_previousMessageSent = YES;
}

- (void)destroyConnection {
	if (_inputStream) {
		[_inputStream close];
		[_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	}
	if (_outputStream) {
		[_outputStream close];
		[_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	}
	_previousMessageSent = YES;
}

#pragma mark - Communication

- (void)handleServerMessage:(NSString*)message {
	_previousMessage = message;
	if (![_outputStream hasSpaceAvailable])
		return;
//	NSLog(@"Handling: %@", message);
	if ([message isEqualToString:@"BeeZZZ 1.0 SERVER HELLO\n"]) {
		[self sayHiToServer];
	}
	else if ([message isEqualToString:@"SEND YOUR ID\n"]) {
		[self sendTeamName];
	}
	else if ([message rangeOfString:@"ID ACK - IMAGES LEFT" ].location != NSNotFound) {
		_imagesLeftOnServer = [self intValue:message];
		[self requestNextPicture];
	}
	else if ([message rangeOfString:@"FONT ACK - IMAGES LEFT"].location != NSNotFound) {
		_imagesLeftOnServer = [self intValue:message];
		[self requestNextPicture];
	}
	else if ([message rangeOfString:@"FONT ACK - NO IMAGE LEFT"].location != NSNotFound) {
		[self destroyConnection];
	}
	else if ([message rangeOfString:@"<<"].location != NSNotFound){
		_imageBuffer = [_imageBuffer stringByAppendingString:message];
		[self showPicturePreview];
		[self sendFontName:@"Anonymus Pro"];
	}
	else if ([message rangeOfString:@">>"].location != NSNotFound){
		_imageBuffer = [NSString stringWithString:message];
	}
	else {
		_imageBuffer = [_imageBuffer stringByAppendingString:message];
	}
}

- (void)sayHiToServer {
	[self sendMessage:@"BeeZZZ 1.0 CLIENT HELLO\n"];
}

- (void)sendTeamName {
	[self sendMessage:@"Spitfire\n"];
}

- (void)requestNextPicture {
	[self sendMessage:@"RQSTNEXTPICTURE\n"];
}

- (void)sendFontName:(NSString*)fontName {
	[self sendMessage:[NSString stringWithFormat:@"%@\n", fontName]];
}

- (void)sendMessage:(NSString*)message {
	uint8_t *buf = (uint8_t *)[message UTF8String];
	if ([_outputStream hasSpaceAvailable]) {
		[_outputStream write:buf maxLength:strlen((char*)buf)];
//		NSLog(@"Writing out the following: %@", message);
		_previousMessageSent = YES;
	}
	else {
//		NSLog(@"Stream does not have space!");
	}
}

#pragma mark - Hacker Stuff

- (NSInteger)intValue:(NSString*)baseString {
	NSString *numberString;
	NSScanner *scanner = [NSScanner scannerWithString:baseString];
	NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
	[scanner scanUpToCharactersFromSet:numbers intoString:NULL];
	[scanner scanCharactersFromSet:numbers intoString:&numberString];
	return [numberString integerValue];
}

- (NSData*)dataWithHexString:(NSString *)command {
	NSMutableData *commandToSend= [[NSMutableData alloc] init];
	unsigned char whole_byte;
	char byte_chars[3] = {'\0','\0','\0'};
	for (int i = 0; i < ([command length] / 2); i++) {
		byte_chars[0] = [command characterAtIndex:i*2];
		byte_chars[1] = [command characterAtIndex:i*2+1];
		whole_byte = strtol(byte_chars, NULL, 16);
		[commandToSend appendBytes:&whole_byte length:1];
	}
	return commandToSend;
}

- (void)setupPhotoButtonAppearance {
	_goButton.layer.borderWidth = 1.0f;
	_goButton.layer.cornerRadius = 5.0f;
	_goButton.layer.borderColor = UIColorFromRGB(0x0075BE).CGColor;
}

- (void)showPicturePreview {
	[_label setText:[NSString stringWithFormat:@"%ld images left on server", (long)_imagesLeftOnServer]];
	_imageBuffer = [_imageBuffer stringByReplacingOccurrencesOfString:@">>" withString:@""];
	_imageBuffer = [_imageBuffer stringByReplacingOccurrencesOfString:@"<<" withString:@""];
	UIImage *image = [UIImage imageWithData:[self dataWithHexString:_imageBuffer]];
	[_imageView setImage:image];
}

#pragma mark - Action Methods

- (IBAction)goButtonPressed:(id)sender {
	[self destroyConnection];
	[self initNetworkCommunication];
	[_goButton setEnabled:NO];
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
	switch (streamEvent) {
		case NSStreamEventOpenCompleted:
//			[_label setText:@"Stream Opened"];
			break;
		case NSStreamEventHasBytesAvailable:
			if (theStream == _inputStream) {
				uint8_t buffer[1048576];
				NSInteger len;
				while ([_inputStream hasBytesAvailable]) {
					len = [_inputStream read:buffer maxLength:sizeof(buffer)];
					if (len > 0) {
						NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
						if (nil != output) {
							_previousMessageSent = NO;
							[self handleServerMessage:output];
						}
					}
				}
			}
			break;
		case NSStreamEventHasSpaceAvailable:
			if (!_previousMessageSent) {
				[self handleServerMessage:_previousMessage];
			}
		case NSStreamEventErrorOccurred:
//			[_label setText:@"Cannot connect to the Host"];
			break;
		case NSStreamEventEndEncountered:
			[self destroyConnection];
			break;
		default:
			break;
//			[_label setText:@"Unknow Event"];
	}
}

@end
