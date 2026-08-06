#import <UIKit/UIKit.h>

@interface GameItem : NSObject
@property (nonatomic, strong) NSString *gameId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *exePath;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *iconName;
@property (nonatomic, strong) NSString *bannerUrl;
@property (nonatomic, assign) NSInteger targetFPS;
@property (nonatomic, strong) NSString *resolution;
@property (nonatomic, strong) NSString *cpuCoreMode; // "Interpreter", "JIT", "Fast"
@property (nonatomic, strong) NSString *wineVersion;
@property (nonatomic, assign) BOOL isFavorite;
@end

@implementation GameItem
@end

@interface ContainerItem : NSObject
@property (nonatomic, strong) NSString *containerId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *winePrefixPath;
@property (nonatomic, strong) NSString *graphicsDriver; // "DXVK", "WineD3D", "Metal/MoltenVK"
@property (nonatomic, assign) NSInteger ramAllocationMB;
@property (nonatomic, assign) BOOL audioEnabled;
@end

@implementation ContainerItem
@end
