import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../services/api_service.dart';

class FgiDataScreen extends StatefulWidget {
  const FgiDataScreen({super.key});

  @override
  _FgiDataScreenState createState() => _FgiDataScreenState();
}

class _FgiDataScreenState extends State<FgiDataScreen> {
  List<Map<String, dynamic>> fgiData = [];
  String errorMessage = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFgiData();
  }

  // 📊 Fetch Past FGI Data
  void fetchFgiData() async {
    try {
      final result = await ApiService.getFgiData();
      print("✅ API Response: $result");

      setState(() {
        isLoading = false;
        fgiData =
            result.map<Map<String, dynamic>>((entry) {
              return {
                "Date": entry["date"] ?? "N/A",
                "FGI_Normalized": entry["fgiScore"]?.toString() ?? "N/A",
                "Market_Sentiment": entry["sentiment"] ?? "N/A",
              };
            }).toList();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Failed to load FGI data.";
      });
    }
  }

  // 🌈 Get Sentiment Color (Light Gray for all sentiments)
  Color getSentimentColor(String sentiment) {
    return const Color(0xFFD3D3D3); // Light Gray for all sentiments
  }

  // 🧭 Build Mini Gauge Widget
  Widget buildMiniGauge(double fgiScore) {
    return SizedBox(
      width: 75,
      height: 75,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: 100,
            showLabels: false,
            showTicks: false,
            axisLineStyle: const AxisLineStyle(
              thickness: 0.1,
              thicknessUnit: GaugeSizeUnit.factor,
              color: Colors.grey,
            ),
            ranges: <GaugeRange>[
              GaugeRange(startValue: 0, endValue: 25, color: Colors.red),
              GaugeRange(startValue: 25, endValue: 50, color: Colors.orange),
              GaugeRange(startValue: 50, endValue: 75, color: Colors.green),
              GaugeRange(startValue: 75, endValue: 100, color: Colors.red),
            ],
            pointers: <GaugePointer>[
              NeedlePointer(
                value: fgiScore,
                enableAnimation: true,
                animationDuration: 1000,
                animationType: AnimationType.easeOutBack,
                needleColor: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🎯 Sentiment Badge
  Widget buildSentimentBadge(String sentiment) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: getSentimentColor(sentiment),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            sentiment.contains("Greed")
                ? Icons.trending_up
                : Icons.trending_down,
            size: 10,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            sentiment,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: Colors.white, // Transparent background
        elevation: 0, // Remove shadow
        iconTheme: const IconThemeData(
          color: Colors.white, // Set the arrow color to white
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background9.jpg'), // Background image
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background9.jpg'), // Background image
            fit: BoxFit.cover,
          ),
        ),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
                : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Reduced height of SizedBox to move content closer to the top
                      const SizedBox(
                        height: 0,
                      ), // Adjusted height to move content further up
                      for (var entry in fgiData)
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(3, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 📊 Mini Gauge
                              buildMiniGauge(
                                double.tryParse(entry["FGI_Normalized"]) ?? 0.0,
                              ),
                              const SizedBox(width: 12),
                              // 📅 Date & FGI Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          "📅 Date: ",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          entry["Date"],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.bar_chart,
                                          color: Colors.blue,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "FGI Score: ${entry["FGI_Normalized"]}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // 🎯 Sentiment Badge
                              buildSentimentBadge(entry["Market_Sentiment"]),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
      ),
    );
  }
}
