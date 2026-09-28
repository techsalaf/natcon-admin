import 'package:googleapis_auth/auth_io.dart';

import 'Api/config.dart';

class FirebaseAccesstoken {
  static String firebaseMessageScope = "https://www.googleapis.com/auth/firebase.messaging";

  Future<String> getAccessToken() async {
    final credentials = ServiceAccountCredentials.fromJson({
      "type": "service_account",
      "project_id": "delivery-king-c74cb",
      "private_key_id": "******************",
      "private_key": "*******************************",
      "client_id": "******************",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-q2fc0%40delivery-king-c74cb.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    });

    final client = await clientViaServiceAccount(credentials, [firebaseMessageScope]);

    final accessToken = client.credentials.accessToken.data;
    Config.firebaseKey = accessToken;
    print("+++++++++++++++++:---- ${Config.firebaseKey}");
    return accessToken;
  }

}