import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../services/api_service.dart';
import 'fgi_data_screen.dart';

class FgiTomorrowScreen extends StatefulWidget {
  const FgiTomorrowScreen({super.key});

  @override
  _FgiTomorrowScreenState createState() => _FgiTomorrowScreenState();
}

class _FgiTomorrowScreenState extends State<FgiTomorrowScreen> {
  String date = "N/A";
  double fgiScore = 0.0;
  String errorMessage = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFgiTomorrow();
  }

  void fetchFgiTomorrow() async {
    try {
      final result = await ApiService.getFgiTomorrow();
      setState(() {
        isLoading = false;
        if (result.containsKey("error")) {
          errorMessage = result["error"]!;
        } else {
          date = result["date"] ?? "N/A";
          fgiScore = double.tryParse(result["fgiScore"].toString()) ?? 0.0;
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Failed to load FGI data.";
      });
    }
  }

  void showZoneInfo(String title, String description) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Color getSentimentColor(double value) {
    if (value <= 25) return Colors.deepOrange;
    if (value <= 50) return Colors.orange;
    if (value <= 75) return Colors.green;
    return Colors.red;
  }

  String getSentimentZone(double value) {
    if (value <= 25) return "Extreme Fear";
    if (value <= 50) return "Fear";
    if (value <= 75) return "Greed";
    return "Extreme Greed";
  }

  String getSentimentDescription(double value) {
    if (value <= 25) {
      return "🚨 Extreme Fear indicates that most investors are very scared and pulling out their money. "
          "This often happens when the market is declining sharply due to unfavorable conditions, "
          "which may create good buying opportunities for long-term investors.";
    } else if (value <= 50) {
      return "⚠️ Fear suggests that investors are worried and hesitant. "
          "The market is not very stable, with mixed signals from market trends and other factors. "
          "Cautious buying is advised during such uncertain conditions.";
    } else if (value <= 75) {
      return "📈 Greed shows that investors are feeling positive and confident. "
          "The market is moving up due to favorable conditions, but it’s wise to stay cautious "
          "because excessive optimism may push prices too high.";
    } else {
      return "⚡ Extreme Greed indicates that investors are very excited and buying heavily. "
          "This often occurs when market conditions are highly favorable, but unchecked enthusiasm can inflate prices beyond actual value, potentially leading to a correction.";
    }
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
                : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Market Mood Index",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    height: 350,
                                    width: double.infinity,
                                    child: SfRadialGauge(
                                      axes: <RadialAxis>[
                                        RadialAxis(
                                          minimum: 0,
                                          maximum: 100,
                                          radiusFactor: 0.9,
                                          labelOffset: 15,
                                          axisLabelStyle: const GaugeTextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          ranges: <GaugeRange>[
                                            GaugeRange(
                                              startValue: 0,
                                              endValue: 25,
                                              color: Colors.deepOrange,
                                              label: 'Extreme Fear',
                                              startWidth: 20,
                                              endWidth: 20,
                                              labelStyle: const GaugeTextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            GaugeRange(
                                              startValue: 25,
                                              endValue: 50,
                                              color: Colors.orange,
                                              label: 'Fear',
                                              startWidth: 20,
                                              endWidth: 20,
                                              labelStyle: const GaugeTextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            GaugeRange(
                                              startValue: 50,
                                              endValue: 75,
                                              color: Colors.green,
                                              label: 'Greed',
                                              startWidth: 20,
                                              endWidth: 20,
                                              labelStyle: const GaugeTextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            GaugeRange(
                                              startValue: 75,
                                              endValue: 100,
                                              color: Colors.red,
                                              label: 'Extreme Greed',
                                              startWidth: 20,
                                              endWidth: 20,
                                              labelStyle: const GaugeTextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                          pointers: <GaugePointer>[
                                            NeedlePointer(
                                              value: fgiScore,
                                              enableAnimation: true,
                                              needleColor: getSentimentColor(
                                                fgiScore,
                                              ),
                                              knobStyle: KnobStyle(
                                                color: getSentimentColor(
                                                  fgiScore,
                                                ),
                                              ),
                                            ),
                                          ],
                                          annotations: <GaugeAnnotation>[
                                            GaugeAnnotation(
                                              angle: 90,
                                              positionFactor: 0.5,
                                              widget: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    fgiScore.toStringAsFixed(2),
                                                    style: const TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    getSentimentZone(fgiScore),
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: getSentimentColor(
                                                        fgiScore,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 10,
                                children: [
                                  ElevatedButton(
                                    onPressed:
                                        () => showZoneInfo(
                                          "Extreme Fear",
                                          getSentimentDescription(10),
                                        ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                    ),
                                    child: const Text("Extreme Fear"),
                                  ),
                                  ElevatedButton(
                                    onPressed:
                                        () => showZoneInfo(
                                          "Fear",
                                          getSentimentDescription(30),
                                        ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                    ),
                                    child: const Text("Fear"),
                                  ),
                                  ElevatedButton(
                                    onPressed:
                                        () => showZoneInfo(
                                          "Greed",
                                          getSentimentDescription(60),
                                        ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                    ),
                                    child: const Text("Greed"),
                                  ),
                                  ElevatedButton(
                                    onPressed:
                                        () => showZoneInfo(
                                          "Extreme Greed",
                                          getSentimentDescription(90),
                                        ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                    ),
                                    child: const Text("Extreme Greed"),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  getSentimentDescription(fgiScore),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Tooltip(
                                message: "View Past FGI Data",
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const FgiDataScreen(),
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.history,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
