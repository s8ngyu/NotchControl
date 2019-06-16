#import <Cephei/HBPreferences.h>
#import <AudioToolbox/AudioToolbox.h>
#import "./headers/MarqueeLabel.h"
#import "./headers/MediaRemote.h"
#import "./headers/AWeatherModel.h"
#import "./headers/WeatherHeaders.h"
#import "./headers/UIImage+tintColor.h"
#import "./headers/UIImage+ScaledImage.h"

@interface UIWindow (NotchControl)
-(void)addNowPlayingModule:(int)page;
-(void)addMusicControlModule:(int)page;
-(void)addClockModule:(int)page;
-(void)addWeatherModule:(int)page;
-(void)reorderViews;
-(void)updateWeather;
-(void)updateButton;
-(void)updateTime;
-(void)updateInfo;
@end

//Base
UIView *gestureView;
UIView *notchView;
UIScrollView *scrollView;
NSMutableArray *enabledModules;
CGFloat withoutNotch;

//Music Preview View
UIView *musicPreviewView;
UIImageView *artWorkView;
MarqueeLabel *musicTitleLabel;
MarqueeLabel *musicArtistLabel;

//Muisc Control View
UIView *musicControlView;
UIImageView *musicBackView;
UIImageView *musicPlayView;
UIImageView *musicNextView;

//Clock
UIView *clockView;
UILabel *clockLabel;

//Weather
UIView *weatherView;
UIImageView *conditionView;
UILabel *tempLabel;

//DRM
UIView *shit;

__attribute__((unused)) static UIImage* UIKitImage(NSString* imgName)
{
    NSString* artworkPath = @"/System/Library/PrivateFrameworks/UIKitCore.framework/Artwork.bundle";
    NSBundle* artworkBundle = [NSBundle bundleWithPath:artworkPath];
    if (!artworkBundle)
    {
        artworkPath = @"/System/Library/Frameworks/UIKit.framework/Artwork.bundle";
        artworkBundle = [NSBundle bundleWithPath:artworkPath];
    }
    UIImage* barsImg = [UIImage imageNamed:imgName inBundle:artworkBundle compatibleWithTraitCollection:nil];
	barsImg = [barsImg imageWithTintedColor:[UIColor whiteColor]];
	barsImg = [barsImg scaleImageToSize:CGSizeMake(20, 20)];

    return barsImg;
}

void loadPrefs() {
	HBPreferences *file = [[HBPreferences alloc] initWithIdentifier:@"com.peterdev.notchcontrol"];

	enabledModules = [[NSMutableArray alloc] init];
	enabledModules = [file objectForKey:@"kEnabledModules"];
	NSLog(@"NotchControl: %@", enabledModules);
}

%group NC
	%hook UIWindow
	-(void)layoutSubviews {
		%orig;
		CGFloat width = [UIScreen mainScreen].bounds.size.width;
		CGFloat height = [UIScreen mainScreen].bounds.size.height;

		if (width != self.frame.size.width) return;
		if (height != self.frame.size.height) return;

		withoutNotch = width - 209;

		if (!gestureView) {
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInfo) name:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateButton) name:(__bridge NSString*)kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification object:nil];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWeather) name:@"NotchControlWeatherUpdate" object:nil];
			[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];

			gestureView = [[UIView alloc] initWithFrame:CGRectMake(withoutNotch/2, -30, 209, 65)];
			gestureView.backgroundColor = [UIColor clearColor];
			gestureView.clipsToBounds = YES;
			gestureView.layer.cornerRadius = 23;
			[self addSubview:gestureView];

			UISwipeGestureRecognizer *downGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedNotch:)];
			downGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
			downGestureRecognizer.numberOfTouchesRequired = 1;
			[gestureView addGestureRecognizer:downGestureRecognizer];

			notchView = [[UIView alloc] initWithFrame:CGRectMake(withoutNotch/2, -120, 209, 120)];
			notchView.backgroundColor = [UIColor blackColor];
			notchView.clipsToBounds = YES;
			notchView.layer.cornerRadius = 23;
			[self addSubview:notchView];

			UISwipeGestureRecognizer *upGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedUpNotch:)];
			upGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
			upGestureRecognizer.numberOfTouchesRequired = 1;
			[notchView addGestureRecognizer:upGestureRecognizer];

			scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, notchView.frame.size.width, 60)];
			scrollView.backgroundColor = [UIColor blackColor];
			scrollView.pagingEnabled = YES;
			[notchView addSubview:scrollView];

			[self reorderViews];
		}
	}

	%new
	-(void)reorderViews {
		loadPrefs();
		[scrollView setContentSize:CGSizeMake(notchView.frame.size.width * enabledModules.count, 60)];

		[scrollView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
		int i = 0;
		for (NSString *string in enabledModules) {
			if ([string isEqualToString:@"Now Playing"]) {
				[self addNowPlayingModule:i];
			} else if ([string isEqualToString:@"Music Controller"]) {
				[self addMusicControlModule:i];
			} else if ([string isEqualToString:@"Clock"]) {
				[self addClockModule:i];
			} else if ([string isEqualToString:@"Weather"]) {
				[self addWeatherModule:i];
			}
			i = i + 1;
		}
	}

	%new
	-(void)addNowPlayingModule:(int)page {
		//Music Preview View Start
		musicPreviewView = [[UIView alloc] initWithFrame:CGRectMake(scrollView.frame.size.width * page, 0, scrollView.frame.size.width, scrollView.frame.size.height)];
		musicPreviewView.backgroundColor = [UIColor blackColor];
		[scrollView addSubview:musicPreviewView];

		artWorkView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 5, 50, 50)];
		artWorkView.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/NotchControl/noalbumart.png"];
		artWorkView.clipsToBounds = YES;
		artWorkView.layer.cornerRadius = 15;
		[musicPreviewView addSubview:artWorkView];

		musicTitleLabel = [[MarqueeLabel alloc] initWithFrame:CGRectMake(62, 10, 138, 15) duration:8.0 andFadeLength:10.0f];
		musicTitleLabel.font = [UIFont fontWithName:@".SFUIText-Bold" size:15];
		musicTitleLabel.textColor = [UIColor whiteColor];
		[musicPreviewView addSubview:musicTitleLabel];

		musicArtistLabel = [[MarqueeLabel alloc] initWithFrame:CGRectMake(62, 30, 138, 15) duration:8.0 andFadeLength:10.0f];
		musicArtistLabel.font = [UIFont fontWithName:@".SFUIText" size:15];
		musicArtistLabel.textColor = [UIColor whiteColor];
		[musicPreviewView addSubview:musicArtistLabel];
		//Music Preview View End

		[self updateInfo];
	}

	%new
	-(void)addMusicControlModule:(int)page {
		//Music Control Start
		musicControlView = [[UIView alloc] initWithFrame:CGRectMake(scrollView.frame.size.width * page, 0, scrollView.frame.size.width, scrollView.frame.size.height)];
		musicControlView.backgroundColor = [UIColor blackColor];
		[scrollView addSubview:musicControlView];

		musicBackView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 20, 20, 20)];
		musicBackView.backgroundColor = [UIColor clearColor];
		musicBackView.image = UIKitImage(@"UIButtonBarRewind");
		musicBackView.userInteractionEnabled = YES;
		[musicControlView addSubview:musicBackView];
		UITapGestureRecognizer *musicBackTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(musicBackTap:)];
		musicBackTap.numberOfTapsRequired = 1;
		[musicBackView addGestureRecognizer:musicBackTap];

		musicPlayView = [[UIImageView alloc] initWithFrame:CGRectMake(94.5, 20, 20, 20)];
		musicPlayView.backgroundColor = [UIColor clearColor];
		musicPlayView.userInteractionEnabled = YES;
		musicPlayView.image = UIKitImage(@"UIButtonBarPlay");
		[musicControlView addSubview:musicPlayView];
		UITapGestureRecognizer *musicPlayTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(musicPlayTap:)];
		musicPlayTap.numberOfTapsRequired = 1;
		[musicPlayView addGestureRecognizer:musicPlayTap];

		musicNextView = [[UIImageView alloc] initWithFrame:CGRectMake(174, 20, 20, 20)];
		musicNextView.backgroundColor = [UIColor clearColor];
		musicNextView.image = UIKitImage(@"UIButtonBarFastForward");
		musicNextView.userInteractionEnabled = YES;
		[musicControlView addSubview:musicNextView];
		UITapGestureRecognizer *musicNextTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(musicNextTap:)];
		musicNextTap.numberOfTapsRequired = 1;
		[musicNextView addGestureRecognizer:musicNextTap];
		//Music Control End

		[self updateButton];
	}

	%new
	-(void)addClockModule:(int)page {
		//Clock Start
		clockView = [[UIView alloc] initWithFrame:CGRectMake(scrollView.frame.size.width * page, 0, scrollView.frame.size.width, scrollView.frame.size.height)];
		clockView.backgroundColor = [UIColor blackColor];
		[scrollView addSubview:clockView];

		clockLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 209, 30)];
		clockLabel.font = [UIFont fontWithName:@".SFUIText" size:30];
		clockLabel.textColor = [UIColor whiteColor];
		clockLabel.textAlignment = NSTextAlignmentCenter;
		[clockView addSubview:clockLabel];
		//Clock End

		[self updateTime];
	}

	%new
	-(void)addWeatherModule:(int)page {
		//Weather Start
		weatherView = [[UIView alloc] initWithFrame:CGRectMake(scrollView.frame.size.width * page, 0, scrollView.frame.size.width, scrollView.frame.size.height)];
		weatherView.backgroundColor = [UIColor blackColor];
		[scrollView addSubview:weatherView];

		conditionView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 10, 40, 40)];
		[weatherView addSubview:conditionView];

		tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 15, 80, 30)];
		tempLabel.font = [UIFont fontWithName:@".SFUIText" size:30];
		tempLabel.textColor = [UIColor whiteColor];
		[weatherView addSubview:tempLabel];

		[self updateWeather];
		//Weather End
	}

	%new
	-(void)swipedNotch:(UISwipeGestureRecognizer *)gesture {
		[self reorderViews];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		CGRect frame = notchView.frame;
		frame.origin.y = -30;
		notchView.frame = frame;
		[UIView commitAnimations];
	}

	%new
	-(void)swipedUpNotch:(UISwipeGestureRecognizer *)gesture {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		CGRect frame = notchView.frame;
		frame.origin.y = -120;
		notchView.frame = frame;
		[UIView commitAnimations];
	}

	%new
	-(void)musicBackTap:(UITapGestureRecognizer *)gesture {
		MRMediaRemoteSendCommand(kMRPreviousTrack, nil);
		AudioServicesPlaySystemSound(1519);
	}

	%new
	-(void)musicPlayTap:(UITapGestureRecognizer *)gesture {
		MRMediaRemoteSendCommand(kMRTogglePlayPause, nil);
		AudioServicesPlaySystemSound(1519);
	}

	%new
	-(void)musicNextTap:(UITapGestureRecognizer *)gesture {
		MRMediaRemoteSendCommand(kMRNextTrack, nil);
		AudioServicesPlaySystemSound(1519);
	}

	%new
	-(void)updateInfo {
		MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
			NSDictionary *dict=(__bridge NSDictionary *)(information);
			if ([dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData] != nil) {
				NSData *artworkData = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData];
				artWorkView.image = [UIImage imageWithData:artworkData];
			} else {
				artWorkView.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/NotchControl/noalbumart.png"];
			}
			musicTitleLabel.text = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
			musicArtistLabel.text = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist];
		});
	}

	%new
	-(void)updateButton {
		MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_get_main_queue(), ^(Boolean isPlaying) {
			if (isPlaying) {
				//playing
				musicPlayView.image = UIKitImage(@"UIButtonBarPause");
			} else {
				//paused
				musicPlayView.image = UIKitImage(@"UIButtonBarPlay");
			}
		});
	}

	%new
	-(void)updateTime {
		NSDate *curDate = [NSDate date];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
		[dateFormatter setDateFormat:@"hh:mm:ss"];
		NSString *dateString = [dateFormatter stringFromDate:curDate];
		
		clockLabel.text = dateString;
	}

	%new
	-(void)updateWeather {
		AWeatherModel *weatherModel = [%c(AWeatherModel) sharedInstance];
		tempLabel.text = [weatherModel localeTemperature];

		conditionView.image = [weatherModel glyphWithOption:ConditionOptionDefault];
	}
	%end
%end

%group DRM
	%hook UIWindow
	-(void)layoutSubviews {
		%orig;
		CGFloat width = [UIScreen mainScreen].bounds.size.width;
		CGFloat height = [UIScreen mainScreen].bounds.size.height;

		if (width != self.frame.size.width) return;
		if (height != self.frame.size.height) return;

		if (!shit) {
			shit = [[UIView alloc] initWithFrame:CGRectMake(withoutNotch/2, -120, 209, 120)];
			shit.backgroundColor = [UIColor blackColor];
			shit.clipsToBounds = YES;
			shit.layer.cornerRadius = 23;
			shit.userInteractionEnabled = NO;
			[self addSubview:shit];

			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:10000];
			shit.frame = CGRectMake(withoutNotch/2, -120, 209, 1120);
			[UIView commitAnimations];
		}
	}
	%end
%end

%ctor {
	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.peterdev.notchcontrol/settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);

	if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/com.peterdev.notchcontrol.list"]) {
		%init(DRM);
	}

	%init(NC);
}