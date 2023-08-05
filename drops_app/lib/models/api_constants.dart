class ApiConstants {
  // static String baseUrl = "http://127.0.0.1:8000/";
  // static String baseUrl = "http://10.12.13.134:8000/";
  // Cloud server
  // static String baseUrl = "drops-1-s5572360.deta.app";
  static String baseUrl = "drops.coloccini.com.ar";
  
  static Map<String, String> headersJson = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'X-API-Key':'e0VWFr7o7hYG_57RNKAK9vaUwz16JwdsahgVRTdjr7o8A',
  };
  static String droppersEndpoint = "droppers/";
  static String dosesEndpoint = "doses/";
  static int leftEye = 1;
  static int rightEye = 2;
  static int bothEyes = 3;
}
