import 'package:googleapis_auth/auth_io.dart';

class AccessTokenFirebase{
  static String FirebaseMessagingScope = "https://www.googleapis.com/auth/firebase.messaging";

 static Future<String> getAccessToken() async {
    final client = await clientViaServiceAccount(ServiceAccountCredentials.fromJson({
      "type": "service_account",
      "project_id": "bmoovddatabase",
      "private_key_id": "d3646e236507d1f3f7a1f3878f1370489b8f91f0",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDhyMRbGS/79FW1\ncpNhioZ1KJrPvYcP/elu9SnXYOU1EO9nVko13wq9sySIu//nEDK7YVMcOeTJtEw4\naLAW6mVDEoISTCy/q8Zn2nmCQd/R2Ye4vEeZkcYSQdizFOVOk7p62YPM2hKelQeQ\nxRVbHxXJQVMAhj8Z0urc16S3cjMZm0dnnRm+VdTgtiOAfQapELi22r/69+xI/4Sx\nMF5A2gc0sQvMhudcrfxGoL1BHSCNYyy3eYcfNDLkxC+HP1DGW8jC7TRKq6ItLakW\nWa+t8Wwp3kS7YyzMdfTh7zGOFaIhHb5rpt5DflKGX5bgQMkoOgMStPAwefxUH7h4\n0xLTk6JzAgMBAAECggEAJVvvAZPdWLdJJ0jaEh21udUKKK2Xl5HP+kgesECcLHes\n5VBl3xwUzubBeM6CvVz0yASGl/kMXkOzCPJpkKEgOETruNNZ5C0sGysPR/pWaoav\n6mVdA5AXUhYLITan6qSPCpzLLi43Pn4yTkYODpHKLQ7eCQwtjLxVmE0mOCRxSB8V\nvreiJkNk9ikiFVQw04jGiiik3RlR7l71/fPCwEFWp7DaYNDUNzfJryyDN5kVNCEs\nsKlFovMgHAhGaLR/+olaNjmFf/pMqsgmRCwXAgRvdsWbwQSdWtlIbl+V6yCXKA5u\nknT6z592CmSOdhqkrsJCE/CS1usqzbWqMj9wl+pzwQKBgQD8GyUJ1i/+HTYoDejt\nIMmqnUYHoxrPpzch/k7M0GKR8zv7q2LcdEPcfdXOXMIjIQ0rI4ZXZQOWIrBIL4L9\n9h5dGUpX6VSdAPTZPR+M0mNB3+PrYqgt5cwdyEuk5ggWAYuuh+nkEiYVNKEGJND7\nUsFl3k+d/rjaq68Zv4GWYWMD6QKBgQDlRYsFqeHF6xxydz8P0AGxxb8MQBw2y+Cl\nQBtv6pAJG+K975VtxmtsxPaxOf8XLIocuv9oeXy+xdiLQA83i78mXGYN669MEHCw\nladpQLP/JzPMHJHc0w3b1GvUK6EWcrnZehTcnzUqrD3WQ6xcxJfZxuOCLUTSIItA\nY+o0+klF+wKBgQCC4Pi2hZp+ut2Np8L/r+DiESn09wkJOo8Vt7di/t/dU0AVpGD7\nf+RnCHDB5EfpAtSaS6QHpOpavAF2SCwh+e7DeEivIPQLWh7C1MeXTPW4kin53krf\nIQh5ga07mywheIXygp67B2z730mlLeHMR6cdYm9E36NJ6o1JubDlyAMmWQKBgQCZ\nTg0NtnCfVPzqlU33ltDrPBzpZhz3jxAhr2IpTaEOVjUhaAh1JM5EJtgF3Y/ywPeB\nCpEqHMILFmQbiLQkIi+oyPP8rvHCXOPdT9RnjrpNDLuX6iqmjAGiUsHfV2UZi5E2\nGGnGtDZq2E1o7ktcpKAdIN6T9w0jrFswrR64WfuQ7QKBgQDb67eySbvl3CEAVmgx\nNznuLhgIXq5wEmfHRz3KjO9n6gNkWrWEYnGKmJKW1LUejl/xZylFAcXcJZIctpGw\n3WwFBcALEEDxMn+leAWQs9MvKFHiMmUnn1G9twRx7Ybmv0trxt+xx6GPkIUn334j\nwU3KPZheO0Ql8V47yL9tFiaDjg==\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-yq7f7@bmoovddatabase.iam.gserviceaccount.com",
      "client_id": "115255676533571229585",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-yq7f7%40bmoovddatabase.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    }), [FirebaseMessagingScope]);

    final accessToken = client.credentials.accessToken.data;

    return accessToken;
  }
}