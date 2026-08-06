#import <UIKit/UIKit.h>

@interface GameHubMainViewController : UITabBarController
@end

@interface GamesLibraryViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>
@end

@interface ContainersViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@end

@interface PerformanceViewController : UIViewController
@end

@interface SettingsViewController : UITableViewController
@end

@interface GameDetailViewController : UIViewController
- (instancetype)initWithGameItem:(id)game;
@end
