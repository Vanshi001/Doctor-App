import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}

class PushNotificationService {

  static final firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initNotification() async {
    await firebaseMessaging.requestPermission();
    final fcmToken = await firebaseMessaging.getToken();
    print('fcmToken ---- $fcmToken');

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  // static Future<String> getAccessToken() async {
  //   final serviceAccountJson = {
  //     "type": "service_account",
  //     "project_id": "di-doctorapp",
  //     "private_key_id": "ff87bf5ce4e55c6df0c9e95823c2e66eac2ce11b",
  //     "private_key":
  //     "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCR9sSwb3nPU4fE\nDpxRngMfDPAm1fVDbMDGC0V3dEeJYgzx/CtM3OjVv0V4M/V+ejhJBcP9aCcf3a0s\nSUagcV3dEHSFYo9RBz4rX8ZTr5ReV0j3LiWUE52ThW6I5VNn63UW5vDXSxfdodTJ\nuMdj/7y310gMsxXCzOD5GGnQoLPDoTPFAhKwW/5ggiP0EA8hsUqiU6JQFvepT+4Q\nadO72OSGTD7Mx7zgvST5tsIEGHeYzcHb4W02AshqrxquhHAaAok51XZ9udvXk0E+\nHA2ZMlbsfi0AHN7j27JnzihZtm6r0CidQlbd8VEm27G1jK8jBg4+XvPtjHYUDcLV\nT0QVvwAXAgMBAAECggEAE8+BGOHlukYVMP67UvfWEZ1Lwjbw2lgE0/xMpIQDf48a\nFa/K4AbtklvVnb+46+kXrDrcQ7pNRm3A/A1CnjJfccpdc4sRy4a8S95sXbMAuUsx\ny9vsssEfdm8Pi69LAi7lY0Mwi0VAYHl/QWpS+Zdd8Y+w/N7uLv8Sm7b8tERTZv4i\nDP0BPhfp27jRrKSLd3WILYRxX4//TscXZ1CxrKLqRGqtxwsNIiIl5dC8ohejtgp+\nMoY/mDpZqj3gdeTeVvVq6mqz73fmp9xX0X8aTqBHKn0Nk/KlXQZ7QhAvR+vDWV9c\nyFgHz5TFov5M2/c5rZmXEqLBYD7wczKQwjLn7SesxQKBgQDHlu96xeY/WbXVG6qR\nRxQtZlMTKfXuvxIt+9BMAT/sTTHla8nKHdnZqXTEO3s0WKGQr4UrWMhFDd2LXpZr\nf2+xMVyP0ZMjNBb2EO+wp/mCptyIOR8SnYC7SGqfEXa94r6a01YdfpQoIzPjhHxO\nHjDa0J0ztl+CQDpnvB9rllvcMwKBgQC7N9A1ccmP2xWoofwkLYWCkes55620WWes\ngef92tMZlHqDsdAyOiR1LRkksgI+4WHT52mwjj3K3GSTX0KresXnkKjNISFqztRR\nuVGSl7TjyqKnZDu/yKom9uuAQt7NTtwB8l12WxBH0jxnmscuOw2GT5Dj7+ywYW+h\nviOYi4ZojQKBgDrKErAvKqruWcjz5UH1ldPpl/7FFVPFpC03RxucIqAP/Op+3WlT\ncZ/Tcjl668d3c9+SU79430S32NH8goIXf2bKC2GxcY2lAj5orrFySORbEgpuCOEK\n06hWpFFGa5ty9oHUTkFRz4IjHF2f4J2B9xH88NESnv9Wu91iZD7kgxpRAoGAC9UV\nNauBX7QrBENomii+XWg3g6te0R0tbjuvm92updk6fQRJ8kK2dylog2c0uSCpfCkO\nBviWczHGsYG9xvS1eVMtN/m2EPgNdzTNMQShjBwMd6PgGtjl2ByW+b5AMp2fTggx\nW/+ZYdCpvKqNmCBnVGvG7oEFZohh88j+mu+GiSkCgYA21NPOJTPNDa794JPLrdOQ\nH1ol85Gg7TEATz4BSQh7uAAT+nhPQpppBolXoJGa4e85c9r9lhTVu9MjRKXUIxLc\nAXJSCLtLBmo8uO6gm4NdwadTS+xJZxmPSlqHrwha23Wls8orhHWV9+ufXmJnbUO8\ngRFUT73ANejteWI4ILRFPw==\n-----END PRIVATE KEY-----\n",
  //     "client_email": "firebase-adminsdk-fbsvc@di-doctorapp.iam.gserviceaccount.com",
  //     "client_id": "107973148054842729188",
  //     "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  //     "token_uri": "https://oauth2.googleapis.com/token",
  //     "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  //     "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40di-doctorapp.iam.gserviceaccount.com",
  //     "universe_domain": "googleapis.com",
  //   };
  //
  //   final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
  //
  //   http.Client client = await auth.clientViaServiceAccount(auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);
  //
  //   auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
  //     auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
  //     scopes,
  //     client,
  //   );
  //
  //   client.close();
  //   return credentials.accessToken.data;
  // }

  // static sendNotificationToSelectedUserAppointment(String deviceToken, BuildContext context, String tripId) async {
  //   final String serverAccessTokenKey = await getAccessToken();
  //   const String endPoint = 'https://fcm.googleapis.com/v1/projects/di-doctorapp/messages:send';
  //
  //   final Map<String, dynamic> message = {
  //     'token': deviceToken,
  //     'notification': {
  //       'title': 'You have an appointment',
  //       'body': 'Connect',
  //     },
  //     'data': {
  //       'tripID': tripId,
  //       'click_action': 'FLUTTER_NOTIFICATION_CLICK',
  //     },
  //   };
  //
  //   final http.Response response = await http.post(
  //     Uri.parse(endPoint),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $serverAccessTokenKey',
  //     },
  //     body: jsonEncode({'message': message}),
  //   );
  //
  //   print('response.statusCode -- ${response.statusCode}');
  //   if (response.statusCode == 200) {
  //     print('FCM message sent successfully');
  //   } else {
  //     print('Failed, Notification not sent');
  //   }
  // }
}
