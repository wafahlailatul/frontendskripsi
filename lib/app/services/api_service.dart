import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:kesehatan_jantung/app/modules/remindermodel.dart';
import 'package:kesehatan_jantung/app/services/storage_service.dart';
class ApiService {

  static const String baseUrl =
      'https://api2.atlass.my.id';

   static const FlutterSecureStorage storage =
      FlutterSecureStorage();

  // =====================================
  // CEK BACKEND
  // =====================================
  static Future<Map<String, dynamic>>
      getData() async {

    final response = await http.get(
      Uri.parse(baseUrl),
    );

    return jsonDecode(response.body);
  }

static Future<String?> getToken()
async {

 return await StorageService.getToken();

}


static Future logout() async {

 final token = await getToken();


 await http.post(
   Uri.parse("$baseUrl/logout"),

   headers:{
    "Authorization":
    "Bearer $token"
   }

 );

}
// =====================================
// ADD REMINDER
// =====================================

static Future<Map<String, dynamic>> addReminder({

  required String title,
  required String category,
  required int hour,
  required int minute,
  bool isActive = true,

}) async {

  final token = await getToken();


  final response = await http.post(

    Uri.parse("$baseUrl/add-reminder"),

    headers: {

      "Content-Type": "application/json",
      "Authorization": "Bearer $token",

    },


    body: jsonEncode({

      "title": title,

      "category": category,

      "hour": hour,

      "minute": minute,

      "is_active": isActive

    }),

  );


  return jsonDecode(response.body);

}



// =====================================
// GET REMINDERS
// =====================================

static Future<Map<String,dynamic>> getReminders() async {


  final token = await getToken();


  final response = await http.get(

    Uri.parse("$baseUrl/get-reminders"),


    headers: {

      "Authorization":
      "Bearer $token"

    },

  );


  return jsonDecode(response.body);

}



// =====================================
// UPDATE REMINDER
// =====================================

static Future<Map<String,dynamic>> updateReminder({

  required String id,

  required bool isActive,


}) async {


  final token = await getToken();


  final response = await http.put(


    Uri.parse("$baseUrl/update-reminder"),


    headers: {

      "Content-Type":"application/json",

      "Authorization":
      "Bearer $token"

    },


    body: jsonEncode({

      "id": id,

      "is_active": isActive

    }),

  );


  return jsonDecode(response.body);

}



// =====================================
// DELETE REMINDER
// =====================================
static Future<Map<String, dynamic>> deleteReminder(
    String id,
) async {

  final token = await getToken();

  final response = await http.delete(

    Uri.parse("$baseUrl/delete-reminder"),

    headers: {

      "Content-Type": "application/json",

      "Authorization": "Bearer $token",

    },

    body: jsonEncode({

      "id": id,

    }),

  );

  return jsonDecode(response.body);

}
static Future<Map<String, dynamic>> forgotPassword(
    String email
) async {

  final response = await http.post(
    Uri.parse("$baseUrl/forgot-password"),
    headers: {
      "Content-Type":"application/json"
    },
    body: jsonEncode({
      "email": email.trim().toLowerCase()
    }),
  );


  return jsonDecode(response.body);
}


static Future<Map<String, dynamic>> sendOtpRegister(
  String email,
  String username,
  String password,
) async {
  final response = await http.post(
    Uri.parse("$baseUrl/send-otp-register"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "username": username,
      "password": password
    }),
  );

  return jsonDecode(response.body);
}
static Future<Map<String, dynamic>> verifyOtpRegister(
  String email,
  String otp,
) async {

  final response = await http.post(
    Uri.parse("$baseUrl/verify-otp-register"),
    headers: {
      "Content-Type": "application/json"
    },
    body: jsonEncode({
      "email": email.trim().toLowerCase(),
      "otp": otp.trim(),
    }),
  );


  print("STATUS OTP : ${response.statusCode}");
  print("BODY OTP : ${response.body}");


  return jsonDecode(response.body);
}

static Future<Map<String,dynamic>> verifyResetOtp(
    String email,
    String otp
) async {

  final response = await http.post(
    Uri.parse("$baseUrl/verify-reset-otp"),
    headers:{
      "Content-Type":"application/json"
    },
    body:jsonEncode({
      "email":email,
      "otp":otp
    })
  );


  return jsonDecode(response.body);
}


static Future<Map<String, dynamic>> resendResetOtp(
    String email,
) async {

  try {

    final response = await http.post(

      Uri.parse("$baseUrl/resend-reset-otp"),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({
        "email": email,
      }),
    );

    return jsonDecode(response.body);

  } catch (e) {

    return {
      "status": "error",
      "message": e.toString(),
    };

  }
}

static Future<Map<String,dynamic>> resetPassword(
    String email,
    String password
) async {

 final response = await http.post(
   Uri.parse("$baseUrl/reset-password"),
   headers:{
     "Content-Type":"application/json"
   },
   body:jsonEncode({

     "email":email,
     "password":password

   })
 );


 return jsonDecode(response.body);
}
// =====================================
// SAVE ACTIVITY
// =====================================

static Future<Map<String, dynamic>> saveActivity({

  required int langkah,
  required double jarak,
  required int durasi,
  required double kalori,

}) async {

  final token =
      await StorageService.getToken();

  if (token == null) {

    return {

      "status": "error",

      "message": "Token tidak ditemukan"

    };

  }

  final response = await http.post(

    Uri.parse(
      "$baseUrl/save-activity",
    ),

    headers: {

      "Content-Type":
          "application/json",

      "Authorization":
          "Bearer $token",

    },

    body: jsonEncode({

      "langkah": langkah,

      "jarak": jarak,

      "durasi": durasi,

      "kalori": kalori,

    }),

  );

  print(
    "SAVE ACTIVITY : ${response.body}",
  );

  return jsonDecode(
    response.body,
  );

}

// =====================================
// HISTORY ACTIVITY
// =====================================
static Future<Map<String, dynamic>>
getActivityHistory() async {

  final token =
      await StorageService.getToken();

  if (token == null) {

    return {

      "status": "error",

      "message": "Token tidak ditemukan"

    };

  }

  final response = await http.get(

    Uri.parse(
      "$baseUrl/activity-history",
    ),

    headers: {

      "Authorization":
          "Bearer $token"

    },

  );

  print(
    "ACTIVITY HISTORY : ${response.body}",
  );

  return jsonDecode(
    response.body,
  );

}
// =====================================
// TODAY ACTIVITY
// =====================================
static Future<Map<String, dynamic>>
todayActivity() async {

  final token =
      await StorageService.getToken();

  if (token == null) {

    return {

      "status": "error",

      "message": "Token tidak ditemukan"

    };

  }

  final response = await http.get(

    Uri.parse(
      "$baseUrl/today-activity",
    ),

    headers: {

      "Authorization":
          "Bearer $token"

    },

  );

  print(
    "TODAY ACTIVITY : ${response.body}",
  );

  return jsonDecode(
    response.body,
  );

}
// =====================================
// WEEKLY SUMMARY
// =====================================
static Future<Map<String, dynamic>>
weeklySummary() async {

  final token =
      await StorageService.getToken();

  if (token == null) {

    return {

      "status": "error",

      "message": "Token tidak ditemukan"

    };

  }

  final response = await http.get(

    Uri.parse(
      "$baseUrl/weekly-summary",
    ),

    headers: {

      "Authorization":
          "Bearer $token"

    },

  );

  print(
    "WEEKLY SUMMARY : ${response.body}",
  );

  return jsonDecode(
    response.body,
  );

}
// =====================================
// DELETE HISTORY
// =====================================
static Future<Map<String,dynamic>>
deleteActivity(int id) async {

  final token = await getToken();

  final response = await http.delete(

    Uri.parse("$baseUrl/delete-activity/$id"),

    headers:{

      "Authorization":"Bearer $token"

    },

  );

  return jsonDecode(response.body);

}

// =====================================
// SAVE ANALYSIS
// =====================================
static Future<Map<String, dynamic>> saveAnalysis({

  required int age,
  required String gender,
  required double bmi,
  required String smoking,
  required String smokingEnvironment,
  required int activity,
  required int sleep,
  required String stress,
  required String eating,
  required int score,
  required String category,
  required String topFactor,
  required int sportsDuration,
  required int sportsTargetSteps,
  required String sportsRecommendation,

}) async {

  try {

    final token =
        await StorageService.getToken();

    if (token == null) {

      return {

        "status": "error",

        "message":
            "Token tidak ditemukan"

      };

    }

    final response = await http.post(

      Uri.parse(
        "$baseUrl/save-analysis",
      ),

      headers: {

        "Content-Type":
            "application/json",

        "Authorization":
            "Bearer $token",

      },

      body: jsonEncode({

        "age": age,

        "gender": gender,

        "bmi": bmi,

        "smoking": smoking,

        "smokingEnvironment":
            smokingEnvironment,

        "activity": activity,

        "sleep": sleep,

        "stress": stress,

        "eating": eating,

        "score": score,

        "category": category,

        "topFactor": topFactor,

        "sportsDuration":
            sportsDuration,

        "sportsTargetSteps":
            sportsTargetSteps,

        "sportsRecommendation":
            sportsRecommendation,

      }),

    );

    print(
      "SAVE ANALYSIS : ${response.body}",
    );

    return jsonDecode(
      response.body,
    );

  } catch (e) {

    return {

      "status": "error",

      "message":
          e.toString(),

    };

  }

}

// ========================================================
  // FUNGSI UNTUK MENGAMBIL PROGRESS AKTIVITAS FISIK HARI INI
  // ========================================================
  static Future<Map<String, dynamic>> getAllActivities() async {

  try {

    final token =
        await StorageService.getToken();

    if (token == null) {

      return {

        "status": "error",

        "message": "Token tidak ditemukan"

      };

    }

    final response = await http.get(

      Uri.parse(
        "$baseUrl/get-all-activities",
      ),

      headers: {

        "Content-Type":
            "application/json",

        "Authorization":
            "Bearer $token",

      },

    );

    print(
      "GET ALL ACTIVITY : ${response.body}",
    );

    return jsonDecode(
      response.body,
    );

  } catch (e) {

    return {

      "status": "error",

      "message": e.toString(),

    };

  }

}
// =====================================
// get analysis
// =====================================
static Future<Map<String, dynamic>>
getLastAnalysis() async {

  try {

    final token =
        await StorageService.getToken();

    if (token == null) {

      return {

        "status": "error",

        "message":
            "Token tidak ditemukan"

      };

    }

    final response = await http.get(

      Uri.parse(
        "$baseUrl/get-last-analysis",
      ),

      headers: {

        "Authorization":
            "Bearer $token",

      },

    );

    print(
      "LAST ANALYSIS : ${response.body}",
    );

    return jsonDecode(
      response.body,
    );

  } catch (e) {

    return {

      "status": "error",

      "message":
          e.toString(),

    };

  }

}
// =====================================
// SAVE PROFILE
// =====================================
static Future<Map<String, dynamic>> saveProfile({

  required String fullName,
  required String birthDate,
  required String gender,
  required double height,
  required double weight,

}) async {


  final token =
      await StorageService.getToken();



  if(token == null){

    return {

      "status":"error",
      "message":
      "Token tidak ditemukan"

    };

  }



  final response = await http.post(

    Uri.parse(
      "$baseUrl/save-profile"
    ),


    headers:{


      "Content-Type":
      "application/json",


      "Authorization":
      "Bearer $token"


    },


    body:jsonEncode({

      "full_name":
      fullName,


      "birth_date":
      birthDate,


      "gender":
      gender,


      "height":
      height,


      "weight":
      weight

    })

  );



  print(
    "SAVE PROFILE : ${response.body}"
  );


  return jsonDecode(
      response.body
  );

}

// =====================================
// GET PROFILE
// =====================================
static Future<Map<String,dynamic>> getProfile() async {


  final token =
      await StorageService.getToken();



  final response = await http.get(

    Uri.parse(
      "$baseUrl/profile"
    ),


    headers: {

      "Authorization":
      "Bearer $token"

    }

  );


  print(
    "PROFILE BODY : ${response.body}"
  );


  return jsonDecode(
    response.body
  );

}

static Future<Map<String, dynamic>>
getAnalysisHistory() async {

  try {

    final token =
        await StorageService.getToken();

    if (token == null) {

      return {

        "status": "error",

        "message":
            "Token tidak ditemukan"

      };

    }

    final response = await http.get(

      Uri.parse(
        "$baseUrl/analysis-history",
      ),

      headers: {

        "Authorization":
            "Bearer $token",

      },

    );

    print(
      "ANALYSIS HISTORY : ${response.body}",
    );

    return jsonDecode(
      response.body,
    );

  } catch (e) {

    return {

      "status": "error",

      "message":
          e.toString(),

    };

  }

}

  // =====================================
  // REGISTER
  // =====================================
  static Future<Map<String, dynamic>>
      register(
    String username,
    String email,
    String password,
  ) async {

    final response = await http.post(

      Uri.parse('$baseUrl/register'),

      headers: {
        'Content-Type': 'application/json',
      },

      body: jsonEncode({

        'username': username,
        'email': email,
        'password': password,
      }),
    );

    return jsonDecode(response.body);
  }

static Future<Map<String, dynamic>> resendOtpRegister(String email) async {
  final response = await http.post(
    Uri.parse("$baseUrl/send-otp-register"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
    }),
  );

  return jsonDecode(response.body);
}
static Future<Map<String, dynamic>> resendOtp(
  String email,
  String type,
) async {
  final response = await http.post(
    Uri.parse("$baseUrl/resend-otp"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "email": email,
      "type": type,
    }),
  );

  return jsonDecode(response.body);
}


  // =====================================
  // LOGIN
  // =====================================
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
) async {

  final response = await http.post(
    Uri.parse("$baseUrl/login"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "email": email,
      "password": password,
    }),
  );

  final result = jsonDecode(response.body);

  if (result["status"] == "success") {

    await StorageService.saveToken(result["token"]);

    String? token = await StorageService.getToken();

    print("==================================");
    print("TOKEN LOGIN : $token");
    print("==================================");
  }

  return result;
}


static Future<Map<String, dynamic>> googleLogin({

  required String email,

  required String username,

  required String photo,

  required String firebaseUid,

}) async {

  try {

    final response = await http.post(

      Uri.parse("$baseUrl/google-login"),

      headers: {

        "Content-Type": "application/json",

      },

      body: jsonEncode({

        "email": email,

        "username": username,

        "photo": photo,

        "firebase_uid": firebaseUid,

      }),

    );

    final data = jsonDecode(response.body);

    if (data["status"] == "success") {

      await StorageService.saveToken(
        data["token"],
      );

    }

    return data;

  } catch (e) {

    return {

      "status": "error",

      "message": e.toString(),

    };

  }

}
// =====================================
// DEVICE CONNECT
// =====================================
static Future<Map<String, dynamic>>
    connectDevice(
  String deviceName,
  String deviceId,
) async {

  final response = await http.post(

    Uri.parse('$baseUrl/device/connect'),

    headers: {
      'Content-Type': 'application/json',
    },

    body: jsonEncode({

      'device_name': deviceName,
      'device_id': deviceId,

    }),
  );

  return jsonDecode(response.body);
}

}