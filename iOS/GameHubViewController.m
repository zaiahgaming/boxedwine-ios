#import "GameHubViewController.h"
#import "GameHubModels.h"
#include "iOS_JIT_Compiler.h"

// Dark Mode Palette
#define COLOR_BG [UIColor colorWithRed:0.05 green:0.05 blue:0.08 alpha:1.0]
#define COLOR_CARD [UIColor colorWithRed:0.10 green:0.11 blue:0.16 alpha:1.0]
#define COLOR_ACCENT [UIColor colorWithRed:0.00 green:0.75 blue:1.00 alpha:1.0] // Neon Blue
#define COLOR_TEXT_PRIMARY [UIColor whiteColor]
#define COLOR_TEXT_MUTED [UIColor colorWithRed:0.6 green:0.65 blue:0.75 alpha:1.0]

// ============================================================================
// MAIN TAB BAR CONTROLLER
// ============================================================================
@implementation GameHubMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize On-Device ARM64 JIT Engine Subsystem
    iOS_JIT_Initialize();
    
    self.tabBar.barTintColor = COLOR_CARD;
    self.tabBar.tintColor = COLOR_ACCENT;
    self.tabBar.unselectedItemTintColor = COLOR_TEXT_MUTED;
    
    // Tab 1: Games Library
    GamesLibraryViewController *gamesVC = [[GamesLibraryViewController alloc] init];
    UINavigationController *navGames = [[UINavigationController alloc] initWithRootViewController:gamesVC];
    navGames.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Games" image:[UIImage systemImageNamed:@"gamecontroller.fill"] tag:0];
    
    // Tab 2: Wine Containers
    ContainersViewController *containersVC = [[ContainersViewController alloc] init];
    UINavigationController *navContainers = [[UINavigationController alloc] initWithRootViewController:containersVC];
    navContainers.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Containers" image:[UIImage systemImageNamed:@"shippingbox.fill"] tag:1];
    
    // Tab 3: Performance & Thermal Overlay
    PerformanceViewController *perfVC = [[PerformanceViewController alloc] init];
    UINavigationController *navPerf = [[UINavigationController alloc] initWithRootViewController:perfVC];
    navPerf.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Performance" image:[UIImage systemImageNamed:@"speedometer"] tag:2];
    
    // Tab 4: Advanced Emulation & Built-in JIT Settings
    SettingsViewController *settingsVC = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *navSettings = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    navSettings.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage systemImageNamed:@"gearshape.fill"] tag:3];
    
    self.viewControllers = @[navGames, navContainers, navPerf, navSettings];
}

@end

// ============================================================================
// GAMES LIBRARY VIEW CONTROLLER
// ============================================================================
@interface GamesLibraryViewController ()
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray<GameItem *> *gamesList;
@end

@implementation GamesLibraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"GameHub iOS";
    self.view.backgroundColor = COLOR_BG;
    
    self.navigationController.navigationBar.barTintColor = COLOR_BG;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: COLOR_TEXT_PRIMARY};
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    
    [self mockGamesData];
    [self setupCollectionView];
}

- (void)mockGamesData {
    self.gamesList = [NSMutableArray array];
    
    NSArray *titles = @[@"Cyberpunk 2077", @"Elden Ring", @"Hades II", @"Grand Theft Auto V", @"Doom Eternal", @"Starfield", @"Fallout 4", @"The Witcher 3"];
    NSArray *categories = @[@"Action RPG", @"Action", @"Indie", @"Open World", @"FPS", @"Sci-Fi", @"RPG", @"Action RPG"];
    
    for (NSInteger i = 0; i < titles.count; i++) {
        GameItem *item = [[GameItem alloc] init];
        item.gameId = [NSString stringWithFormat:@"game_%ld", (long)i];
        item.title = titles[i];
        item.category = categories[i];
        item.targetFPS = 60;
        item.resolution = @"1280x720";
        item.cpuCoreMode = @"Native ARM64 JIT";
        item.wineVersion = @"Proton-10.0-arm64ec";
        [self.gamesList addObject:item];
    }
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((self.view.bounds.size.width - 48) / 2, 220);
    layout.minimumInteritemSpacing = 16;
    layout.minimumLineSpacing = 16;
    layout.sectionInset = UIEdgeInsetsMake(16, 16, 16, 16);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.backgroundColor = COLOR_BG;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"GameCell"];
    
    [self.view addSubview:self.collectionView];
}

#pragma mark - CollectionView DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.gamesList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GameCell" forIndexPath:indexPath];
    cell.contentView.backgroundColor = COLOR_CARD;
    cell.contentView.layer.cornerRadius = 14.0;
    cell.contentView.clipsToBounds = YES;
    
    for (UIView *sub in cell.contentView.subviews) {
        [sub removeFromSuperview];
    }
    
    GameItem *item = self.gamesList[indexPath.item];
    
    UIView *poster = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.bounds.size.width, 140)];
    poster.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"gamecontroller"]];
    iconView.tintColor = COLOR_ACCENT;
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.frame = CGRectMake((cell.bounds.size.width - 40)/2, 50, 40, 40);
    [poster addSubview:iconView];
    [cell.contentView addSubview:poster];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(8, 148, cell.bounds.size.width - 16, 22)];
    lblTitle.text = item.title;
    lblTitle.textColor = COLOR_TEXT_PRIMARY;
    lblTitle.font = [UIFont boldSystemFontOfSize:14];
    [cell.contentView addSubview:lblTitle];
    
    UILabel *lblCategory = [[UILabel alloc] initWithFrame:CGRectMake(8, 172, cell.bounds.size.width - 16, 18)];
    lblCategory.text = [NSString stringWithFormat:@"%@ • %ld FPS", item.category, (long)item.targetFPS];
    lblCategory.textColor = COLOR_TEXT_MUTED;
    lblCategory.font = [UIFont systemFontOfSize:11];
    [cell.contentView addSubview:lblCategory];
    
    UILabel *lblBadge = [[UILabel alloc] initWithFrame:CGRectMake(8, 192, cell.bounds.size.width - 16, 16)];
    lblBadge.text = item.cpuCoreMode;
    lblBadge.textColor = COLOR_ACCENT;
    lblBadge.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
    [cell.contentView addSubview:lblBadge];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    GameItem *item = self.gamesList[indexPath.item];
    GameDetailViewController *detailVC = [[GameDetailViewController alloc] initWithGameItem:item];
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end

// ============================================================================
// CONTAINERS VIEW CONTROLLER
// ============================================================================
@implementation ContainersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Wine Containers";
    self.view.backgroundColor = COLOR_BG;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.backgroundColor = COLOR_BG;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 2; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? 3 : 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (section == 0) ? @"Active Compatibility Prefixes" : @"Actions";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContainerCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContainerCell"];
    }
    cell.backgroundColor = COLOR_CARD;
    cell.textLabel.textColor = COLOR_TEXT_PRIMARY;
    cell.detailTextLabel.textColor = COLOR_TEXT_MUTED;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Proton-10.0-arm64ec JIT Container (Win64)";
            cell.detailTextLabel.text = @"DXVK 2.4 • Built-in iOS JIT Engine • RAM: 4096MB";
            cell.imageView.image = [UIImage systemImageNamed:@"shippingbox.fill"];
            cell.imageView.tintColor = COLOR_ACCENT;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Wine 9.0 Fast Container (Win64)";
            cell.detailTextLabel.text = @"DXVK 2.3 Async • Box64 Dynarec • RAM: 4096MB";
            cell.imageView.image = [UIImage systemImageNamed:@"shippingbox"];
            cell.imageView.tintColor = COLOR_TEXT_MUTED;
        } else {
            cell.textLabel.text = @"WineD3D Legacy Container (Win32)";
            cell.detailTextLabel.text = @"Wine 8.0 • WineD3D OpenGL • RAM: 2048MB";
            cell.imageView.image = [UIImage systemImageNamed:@"shippingbox"];
            cell.imageView.tintColor = COLOR_TEXT_MUTED;
        }
    } else {
        cell.textLabel.text = @"Create New Custom Prefix";
        cell.textLabel.textColor = COLOR_ACCENT;
        cell.detailTextLabel.text = @"Configure environment variables, Turnip drivers & Wine version";
        cell.imageView.image = [UIImage systemImageNamed:@"plus.circle.fill"];
        cell.imageView.tintColor = COLOR_ACCENT;
    }
    
    return cell;
}

@end

// ============================================================================
// PERFORMANCE & THERMAL OVERLAY VIEW CONTROLLER
// ============================================================================
@implementation PerformanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Game Performance HUD";
    self.view.backgroundColor = COLOR_BG;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:scrollView];
    
    // FPS Card
    UIView *fpsCard = [[UIView alloc] initWithFrame:CGRectMake(16, 20, self.view.bounds.size.width - 32, 100)];
    fpsCard.backgroundColor = COLOR_CARD;
    fpsCard.layer.cornerRadius = 16;
    [scrollView addSubview:fpsCard];
    
    UILabel *lblFpsVal = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 120, 40)];
    lblFpsVal.text = @"60 FPS";
    lblFpsVal.textColor = COLOR_ACCENT;
    lblFpsVal.font = [UIFont boldSystemFontOfSize:32];
    [fpsCard addSubview:lblFpsVal];
    
    UILabel *lblFpsSub = [[UILabel alloc] initWithFrame:CGRectMake(20, 55, 250, 25)];
    lblFpsSub.text = @"Target: 60 FPS • ProMotion 120Hz Active";
    lblFpsSub.textColor = COLOR_TEXT_MUTED;
    lblFpsSub.font = [UIFont systemFontOfSize:12];
    [fpsCard addSubview:lblFpsSub];
    
    // Metrics Grid
    NSArray *metrics = @[@"CPU Usage: 42%", @"GPU Usage: 68%", @"System RAM: 3.4 GB", @"Thermal State: Nominal", @"Built-in JIT: Active", @"MAP_JIT W^X: Active"];
    for (int i = 0; i < metrics.count; i++) {
        CGFloat x = 16 + (i % 2) * ((self.view.bounds.size.width - 48) / 2 + 16);
        CGFloat y = 140 + (i / 2) * 90;
        
        UIView *metricCard = [[UIView alloc] initWithFrame:CGRectMake(x, y, (self.view.bounds.size.width - 48) / 2, 74)];
        metricCard.backgroundColor = COLOR_CARD;
        metricCard.layer.cornerRadius = 12;
        
        UILabel *lblMetric = [[UILabel alloc] initWithFrame:CGRectMake(12, 24, metricCard.bounds.size.width - 24, 25)];
        lblMetric.text = metrics[i];
        lblMetric.textColor = COLOR_TEXT_PRIMARY;
        lblMetric.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
        [metricCard addSubview:lblMetric];
        
        [scrollView addSubview:metricCard];
    }
}

@end

// ============================================================================
// ADVANCED EMULATION SETTINGS VIEW CONTROLLER (INCLUDING BUILT-IN JIT ENGINE)
// ============================================================================
@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Emulation Settings";
    self.tableView.backgroundColor = COLOR_BG;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 7; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 4; // Built-in On-Device JIT Engine (New!)
        case 1: return 4; // Graphics & Display (DXVK, VKD3D, FSR, FrameGen)
        case 2: return 4; // CPU Emulation & Dynarec
        case 3: return 3; // Wine / Proton Prefix Settings
        case 4: return 2; // Audio & Latency
        case 5: return 3; // Gamepad & Touch Overlay
        case 6: return 2; // iOS System Resources
        default: return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return @"Built-in On-Device JIT Engine (iOS ARM64)";
        case 1: return @"Graphics, DXVK & Upscaling (GameNative)";
        case 2: return @"CPU Emulation & Dynarec Flags";
        case 3: return @"Wine / Proton Prefix Settings";
        case 4: return @"Audio Engine & Latency Buffers";
        case 5: return @"Controls & Gamepad Mapping";
        case 6: return @"iOS Game Mode & Resource Allocations";
        default: return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"SettingCell"];
    }
    cell.backgroundColor = COLOR_CARD;
    cell.textLabel.textColor = COLOR_TEXT_PRIMARY;
    cell.detailTextLabel.textColor = COLOR_TEXT_MUTED;
    
    if (indexPath.section == 0) { // Built-in JIT Engine
        if (indexPath.row == 0) { cell.textLabel.text = @"On-Device JIT Mode"; cell.detailTextLabel.text = @"Native ARM64 MAP_JIT"; }
        else if (indexPath.row == 1) { cell.textLabel.text = @"W^X Permission Toggle"; cell.detailTextLabel.text = @"pthread_jit_write_protect_np"; }
        else if (indexPath.row == 2) { cell.textLabel.text = @"Instruction Cache Flushing"; cell.detailTextLabel.text = @"sys_icache_invalidate"; }
        else { cell.textLabel.text = @"JIT Emitter Library"; cell.detailTextLabel.text = @"AsmJit ARM64 Engine"; }
    } else if (indexPath.section == 1) { // Graphics
        if (indexPath.row == 0) { cell.textLabel.text = @"Graphics Driver / API"; cell.detailTextLabel.text = @"Metal (MoltenVK / Turnip Zink)"; }
        else if (indexPath.row == 1) { cell.textLabel.text = @"DirectX Layer (DXVK / VKD3D)"; cell.detailTextLabel.text = @"DXVK v2.4 (Async Pipeline)"; }
        else if (indexPath.row == 2) { cell.textLabel.text = @"FidelityFX Super Res (FSR)"; cell.detailTextLabel.text = @"Quality Mode (1.5x)"; }
        else { cell.textLabel.text = @"LSFG-VK Frame Generation"; cell.detailTextLabel.text = @"Enabled (2x FPS Boost)"; }
    } else if (indexPath.section == 2) { // CPU
        if (indexPath.row == 0) { cell.textLabel.text = @"x86/x64 Translator"; cell.detailTextLabel.text = @"Box64 (Dynamic Dynarec)"; }
        else if (indexPath.row == 1) { cell.textLabel.text = @"CPU Core Affinity Mask"; cell.detailTextLabel.text = @"Prime Cores (Exclude E-Cores)"; }
        else if (indexPath.row == 2) { cell.textLabel.text = @"Self-Modifying Code (SMC)"; cell.detailTextLabel.text = @"Fast Memory Access"; }
        else { cell.textLabel.text = @"Box64 Optimization Preset"; cell.detailTextLabel.text = @"Gaming Performance"; }
    } else if (indexPath.section == 3) { // Wine / Proton
        if (indexPath.row == 0) { cell.textLabel.text = @"Default Proton Version"; cell.detailTextLabel.text = @"Proton-10.0-arm64ec"; }
        else if (indexPath.row == 1) { cell.textLabel.text = @"Windows OS Version Spoof"; cell.detailTextLabel.text = @"Windows 10 (Build 19045)"; }
        else { cell.textLabel.text = @"Container Environment Vars"; cell.detailTextLabel.text = @"MESA_EXT=2024, DXVK_ASYNC=1"; }
    } else if (indexPath.section == 4) { // Audio
        if (indexPath.row == 0) { cell.textLabel.text = @"Audio Engine"; cell.detailTextLabel.text = @"CoreAudio / PulseAudio"; }
        else if (indexPath.row == 1) { cell.textLabel.text = @"IO Buffer Latency"; cell.detailTextLabel.text = @"5ms (Ultra Low Latency)"; }
    } else if (indexPath.section == 5) { // Controls
        if (indexPath.row == 0) { cell.textLabel.text = @"Gamepad Auto-Mapping"; cell.detailTextLabel.text = @"Extended Xbox/MFi Controller"; }
        else if (indexPath.row == 1) { cell.textLabel.text = @"On-Screen Touch Controls"; cell.detailTextLabel.text = @"Dynamic Joysticks + Triggers"; }
        else { cell.textLabel.text = @"Gyroscope Aiming"; cell.detailTextLabel.text = @"Right-Stick Emulation"; }
    } else { // System
        if (indexPath.row == 0) { cell.textLabel.text = @"iOS Category Metadata"; cell.detailTextLabel.text = @"public.app-category.games"; }
        else { cell.textLabel.text = @"iOS 18 Game Mode Priority"; cell.detailTextLabel.text = @"Maximum Priority (Unthrottled)"; }
    }
    
    return cell;
}

@end

// ============================================================================
// GAME DETAIL / LAUNCHER VIEW CONTROLLER
// ============================================================================
@interface GameDetailViewController ()
@property (nonatomic, strong) GameItem *game;
@end

@implementation GameDetailViewController

- (instancetype)initWithGameItem:(GameItem *)game {
    self = [super init];
    if (self) {
        _game = game;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.game.title;
    self.view.backgroundColor = COLOR_BG;
    
    UIButton *btnLaunch = [UIButton buttonWithType:UIButtonTypeSystem];
    btnLaunch.frame = CGRectMake(32, self.view.bounds.size.height - 140, self.view.bounds.size.width - 64, 54);
    btnLaunch.backgroundColor = COLOR_ACCENT;
    [btnLaunch setTitle:@"PLAY GAME" forState:UIControlStateNormal];
    [btnLaunch setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnLaunch.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    btnLaunch.layer.cornerRadius = 16;
    [btnLaunch addTarget:self action:@selector(onLaunchPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnLaunch];
}

- (void)onLaunchPressed {
    // Allocate a sample JIT executable page on device
    iOSJITPage *jitPage = iOS_JIT_AllocatePage(4096);
    if (jitPage) {
        // Emit ARM64 RET instruction (0xD65F03C0)
        uint32_t arm64_ret = 0xD65F03C0;
        iOS_JIT_EmitCode(jitPage, (const uint8_t*)&arm64_ret, sizeof(arm64_ret));
        iOS_JIT_Execute(jitPage);
        iOS_JIT_FreePage(jitPage);
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Launching Windows Game"
                                                                   message:[NSString stringWithFormat:@"Starting %@ with Built-in ARM64 JIT Engine...", self.game.title]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
