import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_app_group_ios/shared_preferences_app_group_ios.dart';

void main() async {
  const MethodChannel channel = MethodChannel('shared_preferences_app_group_ios');

  TestWidgetsFlutterBinding.ensureInitialized();

  const Map<String, dynamic> testValuesGroup1 = <String, dynamic>{
    'flutter.String': 'hello world',
    'flutter.bool': true,
    'flutter.int': 42,
    'flutter.double': 3.14159,
    'flutter.List': <String>['foo', 'bar'],
    'flutter.Map': {'d1key1': 'd1value1', 'd1key2': 'd1value2'}
  };

  const Map<String, dynamic> testValuesGroup2 = <String, dynamic>{
    'flutter.String': 'nice place',
    'flutter.bool': false,
    'flutter.int': 24,
    'flutter.double': 2.7182818,
    'flutter.List': <String>['moshe', 'zuchmir'],
    'flutter.Map': {'d2key1': 'd2value1', 'd2key2': 'd2value2'}
  };

  List<Map<String, dynamic>> testValuesPerGroup = {
    testValuesGroup1,
    testValuesGroup2,
  }.toList();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      // By method call:
      // Set: Verify saved data
      // Get: Verify group name and return correct data
      int groupIndex;
      switch (methodCall.arguments["appGroupName"]) {
        case "group1.com.group.name":
          groupIndex = 0;
          break;
        case "group2.com.group.name":
          groupIndex = 1;
          break;
        default:
          assert(false, "Incorrect appGroupName provided, please add support for ${methodCall.arguments["appGroupName"]}");
      }

      switch (methodCall.method) {
        case "getAll":
          return testValuesPerGroup[groupIndex];
        case "setString":
          expect(methodCall.arguments["key"], "flutter.String");
          expect(methodCall.arguments["value"], testValuesPerGroup[groupIndex]['flutter.String']);
          return true;
        case "setBool":
          expect(methodCall.arguments["key"], "flutter.bool");
          expect(methodCall.arguments["value"], testValuesPerGroup[groupIndex]['flutter.bool']);
          return true;
        case "setInt":
          expect(methodCall.arguments["key"], "flutter.int");
          expect(methodCall.arguments["value"], testValuesPerGroup[groupIndex]['flutter.int']);
          return true;
        case "setDouble":
          expect(methodCall.arguments["key"], "flutter.double");
          expect(methodCall.arguments["value"], testValuesPerGroup[groupIndex]['flutter.double']);
          return true;
        case "setStringList":
          expect(methodCall.arguments["key"], "flutter.List");
          expect(methodCall.arguments["value"], testValuesPerGroup[groupIndex]['flutter.List']);
          return true;
        case "setMap":
          expect(methodCall.arguments["key"], "flutter.Map");
          expect(methodCall.arguments["value"], testValuesPerGroup[groupIndex]['flutter.Map']);
          return true;
        default:
          assert(false, "Unexpected method, please add support for ${methodCall.method}");
      }
      return 0;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  var appGroupName1 = "group1.com.group.name";
  var appGroupName2 = "group2.com.group.name";

  SharedPreferencesAppGroupIos sharedPrefsAppGroup1;
  SharedPreferencesAppGroupIos sharedPrefsAppGroup2;

  test('writing', () async {
    sharedPrefsAppGroup1 = await SharedPreferencesAppGroupIos.getInstance(appGroupName1);
    sharedPrefsAppGroup2 = await SharedPreferencesAppGroupIos.getInstance(appGroupName2);

    await sharedPrefsAppGroup1.setString('String', testValuesGroup1['flutter.String']);
    await sharedPrefsAppGroup2.setString('String', testValuesGroup2['flutter.String']);
    await sharedPrefsAppGroup1.setBool('bool', testValuesGroup1['flutter.bool']);
    await sharedPrefsAppGroup2.setBool('bool', testValuesGroup2['flutter.bool']);
    await sharedPrefsAppGroup1.setInt('int', testValuesGroup1['flutter.int']);
    await sharedPrefsAppGroup2.setInt('int', testValuesGroup2['flutter.int']);
    await sharedPrefsAppGroup1.setDouble('double', testValuesGroup1['flutter.double']);
    await sharedPrefsAppGroup2.setDouble('double', testValuesGroup2['flutter.double']);
    await sharedPrefsAppGroup1.setStringList('List', testValuesGroup1['flutter.List']);
    await sharedPrefsAppGroup2.setStringList('List', testValuesGroup2['flutter.List']);
    await sharedPrefsAppGroup1.setMap('Map', testValuesGroup1['flutter.Map']);
    await sharedPrefsAppGroup2.setMap('Map', testValuesGroup2['flutter.Map']);
  });

  /* Verify the cache */
  test('verify cache', () async {
    expect(sharedPrefsAppGroup1.getString('String'), testValuesGroup1['flutter.String']);
    expect(sharedPrefsAppGroup2.getString('String'), testValuesGroup2['flutter.String']);
    expect(sharedPrefsAppGroup1.getBool('bool'), testValuesGroup1['flutter.bool']);
    expect(sharedPrefsAppGroup2.getBool('bool'), testValuesGroup2['flutter.bool']);
    expect(sharedPrefsAppGroup1.getInt('int'), testValuesGroup1['flutter.int']);
    expect(sharedPrefsAppGroup2.getInt('int'), testValuesGroup2['flutter.int']);
    expect(sharedPrefsAppGroup1.getDouble('double'), testValuesGroup1['flutter.double']);
    expect(sharedPrefsAppGroup2.getDouble('double'), testValuesGroup2['flutter.double']);
    expect(sharedPrefsAppGroup1.getStringList('List'), testValuesGroup1['flutter.List']);
    expect(sharedPrefsAppGroup2.getStringList('List'), testValuesGroup2['flutter.List']);
    expect(sharedPrefsAppGroup1.getMap('Map'), testValuesGroup1['flutter.Map']);
    expect(sharedPrefsAppGroup2.getMap('Map'), testValuesGroup2['flutter.Map']);
  });

  /* Discard cache and reload from device */
  test('reload', () async {
    await sharedPrefsAppGroup1.reload();
    await sharedPrefsAppGroup2.reload();

    /* Verify loaded data */
    expect(sharedPrefsAppGroup1.getString('String'), testValuesGroup1['flutter.String']);
    expect(sharedPrefsAppGroup2.getString('String'), testValuesGroup2['flutter.String']);
    expect(sharedPrefsAppGroup1.getBool('bool'), testValuesGroup1['flutter.bool']);
    expect(sharedPrefsAppGroup2.getBool('bool'), testValuesGroup2['flutter.bool']);
    expect(sharedPrefsAppGroup1.getInt('int'), testValuesGroup1['flutter.int']);
    expect(sharedPrefsAppGroup2.getInt('int'), testValuesGroup2['flutter.int']);
    expect(sharedPrefsAppGroup1.getDouble('double'), testValuesGroup1['flutter.double']);
    expect(sharedPrefsAppGroup2.getDouble('double'), testValuesGroup2['flutter.double']);
    expect(sharedPrefsAppGroup1.getStringList('List'), testValuesGroup1['flutter.List']);
    expect(sharedPrefsAppGroup2.getStringList('List'), testValuesGroup2['flutter.List']);
    expect(sharedPrefsAppGroup1.getMap('Map'), testValuesGroup1['flutter.Map']);
    expect(sharedPrefsAppGroup2.getMap('Map'), testValuesGroup2['flutter.Map']);
  });

  test('load new prefs', () async {
    /* Load new prefs and verify data */
    sharedPrefsAppGroup1 = await SharedPreferencesAppGroupIos.getInstance(appGroupName1);
    sharedPrefsAppGroup2 = await SharedPreferencesAppGroupIos.getInstance(appGroupName2);
    /* Verify loaded data */
    expect(sharedPrefsAppGroup1.getString('String'), testValuesGroup1['flutter.String']);
    expect(sharedPrefsAppGroup2.getString('String'), testValuesGroup2['flutter.String']);
    expect(sharedPrefsAppGroup1.getBool('bool'), testValuesGroup1['flutter.bool']);
    expect(sharedPrefsAppGroup2.getBool('bool'), testValuesGroup2['flutter.bool']);
    expect(sharedPrefsAppGroup1.getInt('int'), testValuesGroup1['flutter.int']);
    expect(sharedPrefsAppGroup2.getInt('int'), testValuesGroup2['flutter.int']);
    expect(sharedPrefsAppGroup1.getDouble('double'), testValuesGroup1['flutter.double']);
    expect(sharedPrefsAppGroup2.getDouble('double'), testValuesGroup2['flutter.double']);
    expect(sharedPrefsAppGroup1.getStringList('List'), testValuesGroup1['flutter.List']);
    expect(sharedPrefsAppGroup2.getStringList('List'), testValuesGroup2['flutter.List']);
    expect(sharedPrefsAppGroup1.getMap('Map'), testValuesGroup1['flutter.Map']);
    expect(sharedPrefsAppGroup2.getMap('Map'), testValuesGroup2['flutter.Map']);
  });

  /* TODO: Test the remove */
}
