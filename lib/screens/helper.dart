import 'dart:convert';
import 'dart:io';

import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
// import 'package:crop_desease_detection/screens/c';

class GoogleSheetsHelper {
  static const _scopes = [SheetsApi.spreadsheetsScope];
  final String _spreadsheetId;

  GoogleSheetsHelper(this._spreadsheetId);

  Future<void> appendRow(List<String> row) async {
    // Use a relative path to the credentials file
    // var cur_dir = Directory.current.path;
    // print(cur_dir);
      var credentialsFile = '''
{
  "type": "service_account",
  "project_id": "sheetapi-431215",
  "private_key_id": "b716db9c7f0a478596b9e1e85f13855ef3f18945",
  "private_key": "-----BEGIN PRIVATE KEY-----\\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDVZ525ld+1CHlj\\n7lHyzEtKDDSF7QPmX6Q6ZmCwN98bcMTE40+vJvIbRgpRKTJVsoenyd3wNL6w3zze\\nZlHHsAEAHmnSCs28T07UZsIlJ99HhnfbvEHWS+JfMg2tOnCfpmrkY3jsxaYhUpae\\n2zOTT6fAHEXBKzz/f6moOfFIJ8YmurgO9XA3EvfV4GLAtsmqM4+qsh5q3heuanPR\\n6WHhBvcnrXw8YZStT3xw1oYLtTUwZoOPCiTUksDQ+6JsP03tU7Va3Fhu3TQVLYNS\\nIf8Rvzn7NYWv9AjOmwbQc4Hr4w4oNmDkklKjyfeG/0xGQtq4rgg3RD4xvpdAOujQ\\nlohFPL7VAgMBAAECggEAFuyKhOUUot3GLHXtV6eabtngyoIraRPdEGju+f8GeGwk\\ntwG0DZyhZUygzxcd0Rbce6mzrZn84gMZBsr2/fxqHxklROrkLtZWIXroYBVoZsaL\\nGY+fguWj65X04ibk8kFuOhp1YvnYXrwAchAZ+jkUTA69b4K1iryr/OY8hQPAxWgX\\nAb9QDOduRwx2Pc805XndxfIyW1cKSTaZaJq63gTYqFdj2qsUznDYc9mbGBY0gFrt\\nNUCWw6OUOWFLQPwRVsnMKM/uiOSc9mIeeh73bBwzgXJajHVY4oS1raPpLGLAfSEq\\nH+41nP/veC+Px+jcfGxbiAfexWgUxhsdg1Zajw66AQKBgQD7/xSyQVreHS9/lGAG\\ns3IjbgMsII8jv3XHtOPfBZYS5wRB4EYXobFoPW+cl9k5rySN8A/hUdYK/UnsnxcA\\nOBriiWNT0UbCL2b40sEwJTFXrNl/kMp414bvnR2q2Jnnd/q39MqMb/AtM/xVMxby\\nY49gSMXAC4Rp/7stKz04z0d1nwKBgQDYy5NLeq73cxBndElIB6xb8/ULZeTbfOMf\\nV6J5z9CmGa1wZN+Ujb0/FaeIOjZJz9LruT1RUhHznDiGAmsgzdXOpo9xGDyhyeG1\\nsFgGYDRMSFQGKjh+znBNOWL5ZE6ASu/Cfy+31NAHHq7kxE/SB/+HxaSlOuxsvG4l\\nl9ORl12vCwKBgAeDaXiPHkh1Ek95ewt4GjUYOJv+NIZaVQapTAoAPqM9pBDawPw/\\nY+y5uDQxCtb/c9WPjMmpCPq25pdZfvQQuCx88Cs1mCh+BVHx5rSqxzfX/XwiMwc7\\nVdibFKFdZ+lQ2HbXo5pgVAbk/+cCaPK9KS8zvEGnlkEa0Nfd7Ctfcr/9AoGAaICh\\nLOYjhyZRBv14AZ+pRt3vBiKE0gR+WvJcYIl7U0XXY/FMEQjN66Xdjv44gxYJ3xT4\\n6MU94Acy++4Yg8SUxrtlM6fyOi7dfT5XACPJsee/kQUzHHUYjzEVc5AVgyQcNM4o\\nS13rNTNmLOIwc9blJyZvejJQGw4trjNkia7EOwcCgYBlHZcHUWFZrptK7DpdQfci\\n7mPJL/obg3eNPKFzrtgtIzsoA8XATmPjsbQIyB5RK06C/6uoWdNMm8WjxRHxmZ6/\\nRFGCQY+hZr+9etuv3FWAWPiMLfyQkBIypCXr7dPn/wd7E0DpMMMuY3aI0kceO+Zo\\nUdE5uUZt746KXwPTue4uTw==\\n-----END PRIVATE KEY-----\\n",
  "client_email": "python-api@sheetapi-431215.iam.gserviceaccount.com",
  "client_id": "114910684284650097946",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/python-api%40sheetapi-431215.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
''';

    var credentials = ServiceAccountCredentials.fromJson(
        json.decode(credentialsFile));

    var client = await clientViaServiceAccount(credentials, _scopes);

    var sheetsApi = SheetsApi(client);

    var range = 'Sheet1!A1'; // Adjust the range as needed

    var valueRange = ValueRange.fromJson({
      'range': range,
      'values': [row]
    });

    try {
      await sheetsApi.spreadsheets.values.append(
        valueRange,
        _spreadsheetId,
        range,
        valueInputOption: 'RAW',
      );
      print('Data added successfully.');
    } catch (e) {
      print('Error: $e');
    }

    client.close();
  }
}