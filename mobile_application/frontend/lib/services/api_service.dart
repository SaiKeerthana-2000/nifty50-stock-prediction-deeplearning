import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import intl package
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // ✅ Signup method to register a new user
  static Future<Map<String, String>> signup(
    String name,
    String email,
    String username,
    String password, [
    String phone = '',
  ]) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "username": username,
          "password": password,
          "phone": phone,
        }),
      );

      print("Signup API Status Code: ${response.statusCode}");
      print("Signup API Raw Response: ${response.body}");

      if (response.statusCode == 201) {
        return {"message": "User registered successfully"};
      } else {
        return {"error": "Failed to register user: ${response.body}"};
      }
    } catch (e) {
      return {"error": "Failed to register user: $e"};
    }
  }

  // ✅ Login method to authenticate user
  static Future<Map<String, String>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("Login API Status Code: ${response.statusCode}");
      print("Login API Raw Response: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return {
          "message": data["message"],
          "user_id": data["user_id"].toString(),
        };
      } else {
        return {
          "error": "Invalid credentials or login failed: ${response.body}",
        };
      }
    } catch (e) {
      return {"error": "Failed to login: $e"};
    }
  }

  // ✅ Prediction method to get predicted stock price data
  static Future<Map<String, String>> getPrediction() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/predict'),
        headers: {"Content-Type": "application/json"},
      );

      print("API Status Code: ${response.statusCode}");
      print("API Raw Response: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("Parsed Data: $data");

        String range =
            (data["Prediction_Range"] as List<dynamic>?)?.join(" - ") ?? "N/A";

        return {
          "date": data["Date"] ?? "N/A",
          "predictedPrice": data["Predicted_Price"]?.toString() ?? "N/A",
          "range": range,
          "sentiment": data["Overall_Market_Sentiment"] ?? "N/A",
          "todayClose": data["Today_Close"]?.toString() ?? "N/A",
          "fgiScore": data["FGI Score"]?.toString() ?? "N/A",
          "fgiSentiment": data["FGI_Sentiment"] ?? "N/A",
          "recommendation": data["Recommendation"] ?? "N/A",
        };
      } else {
        return {
          "error": "Error fetching prediction (Status: ${response.statusCode})",
        };
      }
    } catch (e) {
      return {"error": "Failed to fetch prediction: $e"};
    }
  }

  // ✅ Fetch past 7 days of actual vs predicted prices
  static Future<List<Map<String, dynamic>>> getPastPredictions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/past_predictions'),
        headers: {"Content-Type": "application/json"},
      );

      print("Past Predictions API Status Code: ${response.statusCode}");
      print("Past Predictions API Raw Response: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        print("Parsed Past Predictions Data: $data");

        final DateFormat apiDateFormat = DateFormat("yyyy/MM/dd");

        return data.map<Map<String, dynamic>>((entry) {
          try {
            DateTime parsedDate = apiDateFormat.parse(entry["Date"]);

            return {
              "Close": entry["Close"],
              "Predicted_Price": entry["Predicted_Price"],
              "Date":
                  "${parsedDate.year}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.day.toString().padLeft(2, '0')}",
            };
          } catch (dateError) {
            print("Date parsing error: $dateError");
            return {
              "Close": entry["Close"],
              "Predicted_Price": entry["Predicted_Price"],
              "Date": "Invalid Date",
            };
          }
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching past predictions: $e");
      return [];
    }
  }

  // ✅ Fetch latest news and format the response
  static Future<List<Map<String, dynamic>>> getLatestNews() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/latest_news'),
        headers: {"Content-Type": "application/json"},
      );

      print("Latest News API Status Code: ${response.statusCode}");
      print("Latest News API Raw Response: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        print("Parsed Latest News Data: $data");

        return data.map<Map<String, dynamic>>((news) {
          try {
            DateTime parsedDate = DateTime.parse(news["publishedAt"]);
            String formattedDate =
                "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";

            return {
              "date": formattedDate,
              "source": news["source"] ?? "Unknown",
              "title": news["title"] ?? "No Title",
              "description": news["description"] ?? "No Description",
              "url": news["url"] ?? "",
              "sentiment": news["Sentiment"] ?? "neutral",
            };
          } catch (dateError) {
            print("Date parsing error: $dateError");
            return {
              "date": "Invalid Date",
              "source": news["source"] ?? "Unknown",
              "title": news["title"] ?? "No Title",
              "description": news["description"] ?? "No Description",
              "url": news["url"] ?? "",
              "sentiment": news["Sentiment"] ?? "neutral",
            };
          }
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching latest news: $e");
      return [];
    }
  }

  // ✅ Fetch FGI data for the past 7 days
  static Future<List<Map<String, dynamic>>> getFgiData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fgi_data'),
        headers: {"Content-Type": "application/json"},
      );

      print("FGI Data API Status Code: ${response.statusCode}");
      print("FGI Data API Raw Response: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        print("Parsed FGI Data: $data");

        return data.map<Map<String, dynamic>>((entry) {
          return {
            "date": entry["Date"] ?? "N/A",
            "fgiScore": entry["FGI_Normalized"]?.toString() ?? "N/A",
            "sentiment": entry["Market_Sentiment"] ?? "N/A",
          };
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching FGI data: $e");
      return [];
    }
  }

  // ✅ Fetch tomorrow's FGI value
  static Future<Map<String, dynamic>> getFgiTomorrow() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fgi_tomorrow'),
        headers: {"Content-Type": "application/json"},
      );

      print("FGI Tomorrow API Status Code: ${response.statusCode}");
      print("FGI Tomorrow API Raw Response: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("Parsed FGI Tomorrow Data: $data");

        return {
          "date": data["Date"] ?? "N/A",
          "fgiScore": data["FGI_Normalized"]?.toString() ?? "N/A",
          "sentiment": data["Market_Sentiment"] ?? "N/A",
        };
      } else {
        return {"error": "Error fetching FGI tomorrow data"};
      }
    } catch (e) {
      print("Error fetching tomorrow's FGI: $e");
      return {"error": "Failed to fetch tomorrow's FGI: $e"};
    }
  }
}
