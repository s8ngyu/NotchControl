@interface _UIStatusBarForegroundView : UIView
@end

UIView *gestureView;

%hook _UIStatusBarForegroundView
-(void)layoutSubviews {
	%orig;
	if (!gestureView) {
		gestureView = [[UIView alloc] initWithFrame:CGRectMake(83, -30, 209, 120)]; //Size for iPX, IPXS
		gestureView.backgroundColor = [UIColor blackColor];
		gestureView.clipsToBounds = YES;
		gestureView.layer.cornerRadius = 23;
		[self addSubview:gestureView];
	}
}
%end