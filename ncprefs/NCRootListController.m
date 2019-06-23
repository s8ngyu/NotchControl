#include "NCRootListController.h"

@implementation NCRootListController
- (instancetype)init {
    self = [super init];

    if (self) {
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tintColor = [UIColor colorWithRed:253.0f/255.0f green:170/255.0f blue:44/255.0f alpha:1.0f];
        appearanceSettings.tableViewCellSeparatorColor = [UIColor colorWithWhite:0 alpha:0];
        appearanceSettings.statusBarTintColor = [UIColor whiteColor];
        appearanceSettings.navigationBarTitleColor = [UIColor whiteColor];
        appearanceSettings.navigationBarTintColor = [UIColor whiteColor];
        appearanceSettings.navigationBarBackgroundColor = [UIColor colorWithRed:253.0f/255.0f green:170/255.0f blue:44/255.0f alpha:1.0f];
        appearanceSettings.translucentNavigationBar = NO;
        self.hb_appearanceSettings = appearanceSettings;

        self.navigationItem.titleView = [UIView new];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,10,10)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"NotchControl\nVersion 1.0.1"];
        [text addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@".SFUIText-Medium" size:15],
            NSForegroundColorAttributeName:[UIColor whiteColor]}
        range:NSMakeRange(0, 12)];
        [text addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@".SFUIText" size:11],
            NSForegroundColorAttributeName:[[UIColor whiteColor] colorWithAlphaComponent:0.5]}
        range:NSMakeRange(13, 13)];
        [self.titleLabel setAttributedText:text];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.alpha = 0.0f;
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.titleLabel.numberOfLines = 0;
        [self.navigationItem.titleView addSubview:self.titleLabel];

        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,10,10)];
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        self.iconView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/NCPrefs.bundle/icon@2x.png"];
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        self.iconView.alpha = 1.0;
        [self.navigationItem.titleView addSubview:self.iconView];
        
        [NSLayoutConstraint activateConstraints:@[
            [self.titleLabel.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
            [self.iconView.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
        ]];
    }

    return self;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 180)];
    self.headerCoverView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 180)];
    self.headerCoverView.contentMode = UIViewContentModeScaleAspectFill;
    self.headerCoverView.backgroundColor = [UIColor colorWithRed:253.0f/255.0f green:170/255.0f blue:44/255.0f alpha:1.0f];
    self.headerCoverView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerView addSubview:self.headerCoverView];

    self.bannerAuthorLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 100, 20)];
    self.bannerAuthorLabel.font = [UIFont fontWithName:@".SFUIText-Semibold" size:16];
    self.bannerAuthorLabel.text = @"PeterDev";
    self.bannerAuthorLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    [self.headerView addSubview:self.bannerAuthorLabel];

    self.bannerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 75, 300, 40)];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"NotchControl v1.0.1"];
    [text addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@".SFUIDisplay-Medium" size:36],
        NSForegroundColorAttributeName:[UIColor whiteColor]}
    range:NSMakeRange(0, 12)];
    [text addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@".SFUIDisplay-Medium" size:26],
        NSForegroundColorAttributeName:[[UIColor whiteColor] colorWithAlphaComponent:0.7]}
    range:NSMakeRange(13, 6)];
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

    self.navigationController.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:253.0f/255.0f green:170/255.0f blue:44/255.0f alpha:1.0f];
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

    if (offsetY > 100) {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 0.0;
            self.titleLabel.alpha = 1.0;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 1.0;
            self.titleLabel.alpha = 0.0;
        }];
    }
    
    if (offsetY > 0) offsetY = 0;
    self.headerCoverView.frame = CGRectMake(0, offsetY, self.headerView.frame.size.width, 180 - offsetY);
}

- (void)respring:(id)sender {
	if ([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/bin/sbreload"]) {
        //sbreload
        pid_t pid;
        const char* args[] = {"sbreload", NULL};
        posix_spawn(&pid, "/usr/bin/sbreload", NULL, NULL, (char* const*)args, NULL);
    } else {
        //common respring
        pid_t pid;
        const char* args[] = {"killall", "backboardd", NULL};
        posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
    }
}

- (void)resetPrefs:(id)sender {
    HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:@"com.peterdev.notchcontrol"];
    [prefs removeAllObjects];

    [self respring:sender];
}
@end
