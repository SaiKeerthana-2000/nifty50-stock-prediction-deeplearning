import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'past_predictions_screen.dart';
import 'news_screen.dart';
import 'fgi_tomorrow_screen.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  String date = "N/A";
  String predictedPrice = "N/A";
  String range = "N/A";
  String sentiment = "N/A";
  String recommendation = "N/A";
  String todayClose = "N/A";
  String fgiScore = "N/A";
  String fgiSentiment = "N/A";
  String errorMessage = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchPrediction();
  }

  void fetchPrediction() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    final result = await ApiService.getPrediction();
    print("API Response in UI: $result");

    setState(() {
      isLoading = false;
      if (result.containsKey("error")) {
        errorMessage = result["error"]!;
      } else {
        date = result["date"] ?? "N/A";
        predictedPrice = _formatDouble(result["predictedPrice"]);
        range = _formatRange(result["range"]);
        sentiment = result["sentiment"] ?? "N/A";
        recommendation = result["recommendation"] ?? "N/A";
        todayClose = _formatDouble(result["todayClose"]);
        fgiScore = result["fgiScore"] ?? "N/A";
        fgiSentiment = result["fgiSentiment"] ?? "N/A";
      }
    });
  }

  String _formatDouble(String? value) {
    try {
      return value != null ? double.parse(value).toStringAsFixed(4) : "N/A";
    } catch (e) {
      return "N/A";
    }
  }

  String _formatRange(String? rangeValue) {
    if (rangeValue == null || !rangeValue.contains(" - ")) return "N/A";
    try {
      List<String> values = rangeValue.split(" - ");
      int low = (double.parse(values[0])).toInt();
      int high = (double.parse(values[1])).toInt();
      return "$low - $high";
    } catch (e) {
      return "N/A";
    }
  }

  Color getSentimentColor(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case "positive":
        return Colors.green;
      case "negative":
        return Colors.red;
      case "neutral":
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  Color _getRecommendationColor(String recommendation) {
    switch (recommendation.toUpperCase()) {
      case "STRONG BUY":
      case "BUY":
        return Colors.green;
      case "STRONG SELL":
      case "SELL":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showExplanationDialog() {
    String explanation = _generateExplanation();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    explanation,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      child: const Text("Close"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _generateExplanation() {
    if (recommendation == "STRONG BUY") {
      return "A Strong Buy is recommended because the predicted price of ₹$predictedPrice is significantly higher than today's close of ₹$todayClose. Additionally, the market sentiment is positive, and the Fear-Greed Index (FGI) shows $fgiSentiment with a score of $fgiScore, indicating strong investor confidence.";
    } else if (recommendation == "STRONG SELL") {
      return "A Strong Sell is recommended because the predicted price of ₹$predictedPrice is considerably lower than today's close of ₹$todayClose. Furthermore, the market sentiment is negative, and the Fear-Greed Index (FGI) shows $fgiSentiment with a low score of $fgiScore, suggesting weak market conditions.";
    } else if (recommendation == "BUY") {
      return "A Buy is suggested as the predicted price of ₹$predictedPrice is higher than today's close of ₹$todayClose, indicating a potential upward trend. The Fear-Greed Index (FGI) shows $fgiSentiment with a score of $fgiScore, providing additional insights for decision-making.";
    } else if (recommendation == "SELL") {
      return "A Sell is suggested because the predicted price of ₹$predictedPrice is lower than today's close of ₹$todayClose. This may indicate a potential decline. However, the Fear-Greed Index (FGI) shows $fgiSentiment with a score of $fgiScore, which should be considered before finalizing the decision.";
    } else {
      return "A Hold is advised as the predicted price of ₹$predictedPrice is close to today's closing price of ₹$todayClose. The Fear-Greed Index (FGI) shows $fgiSentiment with a score of $fgiScore, indicating minimal changes in market sentiment.";
    }
  }

  Widget _buildInfoText(
    String label,
    String value,
    double fontSize, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: fontSize, color: Colors.black),
          children: [
            TextSpan(
              text: label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color ?? Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.history, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PastPredictionsScreen()),
            );
          },
          tooltip: "View Past Predictions",
        ),
        IconButton(
          icon: const Icon(Icons.trending_up, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FgiTomorrowScreen()),
            );
          },
          tooltip: "View FGI Tomorrow",
        ),
        IconButton(
          icon: const Icon(Icons.newspaper, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NewsScreen()),
            );
          },
          tooltip: "View Latest News",
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background9.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text("", style: TextStyle(color: Colors.white)),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            double screenHeight = constraints.maxHeight;
            double screenWidth = constraints.maxWidth;
            double textSize = screenWidth * 0.045;

            return Center(
              child:
                  isLoading
                      ? const CircularProgressIndicator()
                      : errorMessage.isNotEmpty
                      ? Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red, fontSize: textSize),
                      )
                      : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            SizedBox(height: screenHeight * 0.1),
                            Expanded(
                              child: Center(
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  elevation: 8,
                                  child: Container(
                                    width: screenWidth * 0.9,
                                    padding: const EdgeInsets.all(20.0),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/nifty50.jpg',
                                            height: screenHeight * 0.15,
                                          ),
                                          const SizedBox(height: 10),
                                          _buildInfoText(
                                            "📅 Date: ",
                                            date,
                                            textSize,
                                          ),
                                          _buildInfoText(
                                            "📈 Close price: ",
                                            predictedPrice,
                                            textSize,
                                            color: Colors.blue,
                                          ),
                                          _buildInfoText(
                                            "📊 Price Range: ",
                                            range,
                                            textSize,
                                          ),
                                          _buildInfoText(
                                            "📉 Market Sentiment: ",
                                            sentiment,
                                            textSize,
                                            color: getSentimentColor(sentiment),
                                          ),
                                          _buildInfoText(
                                            "📝 Recommendation: ",
                                            recommendation,
                                            textSize,
                                            color: _getRecommendationColor(
                                              recommendation,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          ElevatedButton(
                                            onPressed: _showExplanationDialog,
                                            child: const Text(
                                              "View Explanation",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildBottomNavBar(context),
                          ],
                        ),
                      ),
            );
          },
        ),
      ),
    );
  }
}
