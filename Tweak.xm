UIView *gestureView;
UIView *notchView;

%hook UIWindow
-(void)layoutSubviews {
	%orig;

	if (!gestureView) {
		gestureView = [[UIView alloc] initWithFrame:CGRectMake(83, -30, 209, 70)]; //Size for iPX, IPXS
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
%end