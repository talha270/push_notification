import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math';

import 'package:push_notification/notification_screen.dart';

class Notificationservices{
  static FirebaseMessaging messaging=FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin=FlutterLocalNotificationsPlugin();


  static void requestnotificationpermission()async{
    NotificationSettings settings =await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay:true,
      criticalAlert: true,
      provisional: true,
      sound: true
    );
    if(settings.authorizationStatus==AuthorizationStatus.authorized){
      print("notification authorized");
    }else if(settings.authorizationStatus==AuthorizationStatus.provisional){
      print("provisional notification authorized");
    }else{
      print("access denied");
    }
  }

  static Future<String> getdevicetoken()async{
    String? token =await messaging.getToken();
    return token!;
  }

  static void isrefreshtoken()async {
    messaging.onTokenRefresh.listen((event) {
      print("refresh");
    },);
  }
  static void initlocalnotification(BuildContext context,RemoteMessage message){
    var androidinitializationsettings=AndroidInitializationSettings("@mipmap/ic_launcher");
    var iosinitializationsettings=DarwinInitializationSettings();

    var initializationSettings=InitializationSettings(
        android: androidinitializationsettings,
        iOS: iosinitializationsettings
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (details) {
      clickhandler(context, message);
    },
    onDidReceiveBackgroundNotificationResponse: (details) {
      clickhandler(context, message);

    },);

  }
  static clickhandler(BuildContext context,RemoteMessage message){
      if(message.data["type"]=="notification"){
        Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationScreen(),));
      }
  }
  static setupinteractmessage(BuildContext context)async{

  //   when app is terminated
    RemoteMessage? initalmessage=await FirebaseMessaging.instance.getInitialMessage();

    if(initalmessage!=null){
      clickhandler(context, initalmessage);
    }

  //   when app in background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      clickhandler(context, message);
    },);
  }
  static void firebaseinit(BuildContext context){
    FirebaseMessaging.onMessage.listen((message) {
      print("listen");
      print(message.notification!.title.toString());
      print(message.notification!.body.toString());
      print(message.data.toString());
      print(message.data["type"]??"no");
      if(Platform.isAndroid)
      initlocalnotification(context, message);

      shownotification(message);
    },);
  }
  static shownotification(RemoteMessage message)async{

      AndroidNotificationChannel channel=AndroidNotificationChannel(
         0.toString(),
          // Random.secure().nextInt(1000000).toString(),
        "channel name",
        importance: Importance.max,
      );

      AndroidNotificationDetails androidNotificationDetails=AndroidNotificationDetails(
        channel.id.toString(),
        channel.name.toString(),
        channelDescription: "your channel description",
        importance: Importance.high,
        priority: Priority.high,
        ticker: "ticker",
        icon: 'ic_notification'
      );

      DarwinNotificationDetails darwinNotificationDetails =DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,

      );

      NotificationDetails  notificationDetails=NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails
      );

      await flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails);
  }
}