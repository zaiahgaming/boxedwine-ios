#define SDL_MAIN_HANDLED  // Prevent SDL from redefining main()

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "GameHubViewController.h"

// Forward declaration of Boxedwine engine entry point (defined in Boxedwine/source/sdl/main.cpp)
extern int boxedmain(int argc, const char **argv);

static void SetupGameAudioSession(void) {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    
    [session setCategory:AVAudioSessionCategoryPlayback
                    mode:AVAudioSessionModeDefault
                 options:AVAudioSessionCategoryOptionMixWithOthers
                   error:&error];
    
    [session setPreferredIOBufferDuration:0.005 error:&error];
    [session setActive:YES error:&error];
}

@interface BoxedwineAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@end

@implementation BoxedwineAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    SetupGameAudioSession();
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    GameHubMainViewController *gameHubVC = [[GameHubMainViewController alloc] init];
    self.window.rootViewController = gameHubVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end

// Launch Boxedwine engine on a background thread (called from the UI when user picks a game)
void LaunchBoxedwineEngine(NSArray<NSString *> *args) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray *allArgs = [NSMutableArray arrayWithObject:@"boxedwine"];
        if (args) {
            [allArgs addObjectsFromArray:args];
        }
        
        int argc = (int)[allArgs count];
        const char **argv = (const char **)malloc(sizeof(const char *) * argc);
        for (int i = 0; i < argc; i++) {
            argv[i] = [allArgs[i] UTF8String];
        }
        
        boxedmain(argc, argv);
        free(argv);
    });
}

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([BoxedwineAppDelegate class]));
    }
}
