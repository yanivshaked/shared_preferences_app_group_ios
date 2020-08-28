#import "SharedPreferencesAppGroupIosPlugin.h"

@implementation SharedPreferencesAppGroupIosPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"shared_preferences_app_group_ios"
            binaryMessenger:[registrar messenger]];
  SharedPreferencesAppGroupIosPlugin* instance = [[SharedPreferencesAppGroupIosPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {

  NSString *method = [call method];
  NSDictionary *arguments = [call arguments];
  NSString *appGroupName = arguments[@"appGroupName"];

  if ([method isEqualToString:@"getAll"]) {
    result(getAllPrefs(appGroupName));
  } else if ([method isEqualToString:@"setBool"]) {
    NSString *key = arguments[@"key"];
    NSNumber *value = arguments[@"value"];
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:appGroupName];
    [sharedDefaults setBool:value.boolValue forKey:key];
    result(@YES);
  } else if ([method isEqualToString:@"setInt"]) {
    NSString *key = arguments[@"key"];
    NSNumber *value = arguments[@"value"];
    // int type in Dart can come to native side in a variety of forms
    // It is best to store it as is and send it back when needed.
    // Platform channel will handle the conversion.
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:appGroupName];
    [sharedDefaults setValue:value forKey:key];
    result(@YES);
  } else if ([method isEqualToString:@"setDouble"]) {
    NSString *key = arguments[@"key"];
    NSNumber *value = arguments[@"value"];
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:appGroupName];
    [sharedDefaults setDouble:value.doubleValue forKey:key];
    result(@YES);
  } else if ([method isEqualToString:@"setString"]) {
    NSString *key = arguments[@"key"];
    NSString *value = arguments[@"value"];
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:appGroupName];
    [sharedDefaults setValue:value forKey:key];
    result(@YES);
  } else if ([method isEqualToString:@"setStringList"]) {
    NSString *key = arguments[@"key"];
    NSArray *value = arguments[@"value"];
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:appGroupName];
    [sharedDefaults setValue:value forKey:key];
    result(@YES);
  } else if ([method isEqualToString:@"commit"]) {
    // synchronize is deprecated.
    // "this method is unnecessary and shouldn't be used."
    result(@YES);
  } else if ([method isEqualToString:@"remove"]) {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:appGroupName];
    [sharedDefaults removeObjectForKey:arguments[@"key"]];
    result(@YES);
  } else if ([method isEqualToString:@"clear"]) {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:appGroupName];
    for (NSString *key in getAllPrefs()) {
      [defaults removeObjectForKey:key];
    }
    result(@YES);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

#pragma mark - Private

static NSMutableDictionary *getAllPrefs:(NSString *)appGroupName {
  NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:appGroupName];
  NSDictionary *prefs = [defaults dictionaryRepresentation];
  NSMutableDictionary *filteredPrefs = [NSMutableDictionary dictionary];
  if (prefs != nil) {
    for (NSString *candidateKey in prefs) {
      if ([candidateKey hasPrefix:@"flutter."]) {
        [filteredPrefs setObject:prefs[candidateKey] forKey:candidateKey];
      }
    }
  }
  return filteredPrefs;
}

@end
