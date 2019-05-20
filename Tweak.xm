#import "MediaRemote.h"

UIView *gestureView;
UIView *notchView;
UIScrollView *scrollView;
UIView *musicPreviewView;

//Music Preview View
UIImageView *artWorkView;
MarqueeLabel *musicTitleLabel;
MarqueeLabel *musicArtistLabel;

%hook UIWindow
-(void)layoutSubviews {
	%orig;

	if (!gestureView) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInfo) name:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];

		gestureView = [[UIView alloc] initWithFrame:CGRectMake(83, -30, 209, 65)]; //Size for iPX, IPXS
		gestureView.backgroundColor = [UIColor clearColor];
		gestureView.clipsToBounds = YES;
		gestureView.layer.cornerRadius = 23;
		[self addSubview:gestureView];

		UISwipeGestureRecognizer *downGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedNotch:)];
    	downGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    	downGestureRecognizer.numberOfTouchesRequired = 1;
    	[gestureView addGestureRecognizer:downGestureRecognizer];

		notchView = [[UIView alloc] initWithFrame:CGRectMake(83, -120, 209, 120)]; //Size for iPX, IPXS
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

		[scrollView setContentSize:CGSizeMake(notchView.frame.size.width * 3, 60)];

		musicPreviewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)];
		musicPreviewView.backgroundColor = [UIColor blackColor];
		[scrollView addSubview:musicPreviewView];

		artWorkView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 5, 50, 50)];
		artWorkView.backgroundColor = [UIColor greenColor];
		artWorkView.clipsToBounds = YES;
		artWorkView.layer.cornerRadius = 15;
		[musicPreviewView addSubview:artWorkView];

		musicTitleLabel = [[MarqueeLabel alloc] initWithFrame:CGRectMake(60, 10, 140, 15) duration:8.0 andFadeLength:10.0f];
		musicTitleLabel.font = [UIFont fontWithName:@".SFUIText-Bold" size:15];
		musicTitleLabel.textColor = [UIColor whiteColor];
		[musicPreviewView addSubview:musicTitleLabel];

		musicArtistLabel = [[MarqueeLabel alloc] initWithFrame:CGRectMake(60, 30, 140, 15) duration:8.0 andFadeLength:10.0f];
		musicArtistLabel.font = [UIFont fontWithName:@".SFUIText" size:15];
		musicArtistLabel.textColor = [UIColor whiteColor];
		[musicPreviewView addSubview:musicArtistLabel];
	}
}

%new
-(void)swipedNotch:(UISwipeGestureRecognizer *)gesture {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	notchView.frame = CGRectMake(83, -30, 209, 120);
	[UIView commitAnimations];
}

%new
-(void)swipedUpNotch:(UISwipeGestureRecognizer *)gesture {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	notchView.frame = CGRectMake(83, -120, 209, 120);
	[UIView commitAnimations];
}

%new
-(void)updateInfo {
	MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
        NSDictionary *dict=(__bridge NSDictionary *)(information);
		if ([dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData] != nil) {
			NSData *artworkData = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData];
			artWorkView.image = [UIImage imageWithData:artworkData];
		}
	});

	MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
        NSDictionary *dict=(__bridge NSDictionary *)(information);
		if ([dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData] != nil) {
			musicTitleLabel.text = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
		}
	});

	MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
        NSDictionary *dict=(__bridge NSDictionary *)(information);
		if ([dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData] != nil) {
			musicArtistLabel.text = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist];
		}
	});
}
%end