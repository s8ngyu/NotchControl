#include "NCClockPrefsController.h"

@implementation NCClockPrefsController
- (instancetype)init {
    self = [super init];

    if (self) {
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tintColor = [UIColor colorWithRed:66.0f/255.0f green:75/255.0f blue:117/255.0f alpha:1.0f];
        appearanceSettings.tableViewCellSeparatorColor = [UIColor colorWithWhite:0 alpha:0];
        appearanceSettings.statusBarTintColor = [UIColor whiteColor];
        appearanceSettings.navigationBarTitleColor = [UIColor whiteColor];
        appearanceSettings.navigationBarTintColor = [UIColor whiteColor];
        appearanceSettings.navigationBarBackgroundColor = [UIColor colorWithRed:66.0f/255.0f green:75/255.0f blue:117/255.0f alpha:1.0f];
        appearanceSettings.translucentNavigationBar = NO;
        self.hb_appearanceSettings = appearanceSettings;
    }

    return self;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Clock" target:self] retain];
	}

	return _specifiers;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 180)];
    self.headerCoverView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 180)];
    self.headerCoverView.contentMode = UIViewContentModeScaleAspectFill;
    self.headerCoverView.backgroundColor = [UIColor colorWithRed:66.0f/255.0f green:75/255.0f blue:117/255.0f alpha:1.0f];
    self.headerCoverView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerView addSubview:self.headerCoverView];

    self.bannerAuthorLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 100, 20)];
    self.bannerAuthorLabel.font = [UIFont fontWithName:@".SFUIText-Semibold" size:16];
    self.bannerAuthorLabel.text = @"Settings";
    self.bannerAuthorLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    [self.headerView addSubview:self.bannerAuthorLabel];

    self.bannerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 75, 300, 40)];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"Clock Module"];
    [text addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@".SFUIDisplay-Medium" size:36],
        NSForegroundColorAttributeName:[UIColor whiteColor]}
    range:NSMakeRange(0, 5)];
    [text addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@".SFUIDisplay-Medium" size:26],
        NSForegroundColorAttributeName:[[UIColor whiteColor] colorWithAlphaComponent:0.7]}
    range:NSMakeRange(6, 6)];
    [self.bannerTitleLabel setAttributedText:text];
    [self.headerView addSubview:self.bannerTitleLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.headerCoverView.topAnchor constraintEqualToAnchor:self.headerView.topAnchor],
        [self.headerCoverView.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor],
        [self.headerCoverView.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor],
        [self.headerCoverView.bottomAnchor constraintEqualToAnchor:self.headerView.bottomAnchor],
    ]];

    _table.tableHeaderView = self.headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.tableHeaderView = self.headerView;
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

    CGRect frame = self.table.bounds;
    frame.origin.y = -frame.size.height;

    self.navigationController.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:66.0f/255.0f green:75/255.0f blue:117/255.0f alpha:1.0f];
    [self.navigationController.navigationController.navigationBar setShadowImage: [UIImage new]];
    self.navigationController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.navigationController.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.navigationController.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if (offsetY > 0) offsetY = 0;
    self.headerCoverView.frame = CGRectMake(0, offsetY, self.headerView.frame.size.width, 180 - offsetY);
}
@end
