package com.twtech.shared_preferences_app_group_ios;

import android.content.Context;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

/** SharedPreferencesAppGroupIosPlugin */
public class SharedPreferencesAppGroupIosPlugin implements FlutterPlugin {
  private static final String CHANNEL_NAME = "shared_preferences_app_group_ios";
  private MethodChannel channel;

  public static void registerWith(PluginRegistry.Registrar registrar) {
    final SharedPreferencesAppGroupIosPlugin plugin = new SharedPreferencesAppGroupIosPlugin();
    plugin.setupChannel(registrar.messenger(), registrar.context());
  }

  @Override
  public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding binding) {
    setupChannel(binding.getBinaryMessenger(), binding.getApplicationContext());
  }

  @Override
  public void onDetachedFromEngine(FlutterPlugin.FlutterPluginBinding binding) {
    teardownChannel();
  }

  private void setupChannel(BinaryMessenger messenger, Context context) {
    channel = new MethodChannel(messenger, CHANNEL_NAME);
    MethodCallHandlerImpl handler = new MethodCallHandlerImpl(context);
    channel.setMethodCallHandler(handler);
  }

  private void teardownChannel() {
    channel.setMethodCallHandler(null);
    channel = null;
  }
}
