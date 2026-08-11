import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class PastPredictionsScreen extends StatefulWidget {
  const PastPredictionsScreen({super.key});

  @override
  _PastPredictionsScreenState createState() => _PastPredictionsScreenState();
}

class _PastPredictionsScreenState extends State<PastPredictionsScreen> {
  List<Map<String, dynamic>> pastPredictions = [];
  bool isLoading = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchPastPredictions();
  }

  void fetchPastPredictions() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final result = await ApiService.getPastPredictions();

      if (result.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = "No past prediction data available.";
        });
        return;
      }

      setState(() {
        isLoading = false;
        pastPredictions =
            result.length > 7 ? result.sublist(result.length - 7) : result;

        pastPredictions.sort((a, b) {
          DateTime dateA = DateFormat("yyyy/M/d").parse(a['Date']);
          DateTime dateB = DateFormat("yyyy/M/d").parse(b['Date']);
          return dateA.compareTo(dateB);
        });
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = "Failed to load predictions. Error: $error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the height of the AppBar dynamically
    double appBarHeight = AppBar().preferredSize.height;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background9.jpg'), // ✅ Set background image
          fit: BoxFit.cover, // ✅ Stretch to cover the screen
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // ✅ Make scaffold transparent
        extendBodyBehindAppBar: true, // ✅ Extends background to AppBar
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0, // ✅ Remove shadow
          title: const Text(
            "", // ✅ Title in AppBar
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
          ), // White navigation button
        ),
        body:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ), // White text
                  ),
                )
                : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: appBarHeight,
                      ), // Dynamic space below AppBar
                      const SizedBox(
                        height: 20,
                      ), // Adds space between AppBar and the graph
                      _buildPredictionGraph(),
                      const SizedBox(height: 16),
                      _buildPredictionTable(),
                    ],
                  ),
                ),
      ),
    );
  }

  /// 📊 Graph with Actual and Predicted Prices
  Widget _buildPredictionGraph() {
    if (pastPredictions.isEmpty) {
      return const Center(
        child: Text(
          "No data available.",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    double minY =
        pastPredictions.map((e) => e['Close']).reduce((a, b) => a < b ? a : b) *
        0.95;
    double maxY =
        pastPredictions.map((e) => e['Close']).reduce((a, b) => a > b ? a : b) *
        1.05;

    // Adjust for better display
    minY = (minY / 500).floor() * 500;
    maxY = (maxY / 500).ceil() * 500;

    double yInterval = ((maxY - minY) / 5).ceilToDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "📊 Actual vs Predicted Stock Prices",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ), // White text
            ),
          ),

          const SizedBox(height: 10),
          SizedBox(
            height: 350,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: yInterval,
                  getDrawingHorizontalLine:
                      (value) =>
                          FlLine(color: Colors.grey.shade300, strokeWidth: 1),
                  getDrawingVerticalLine:
                      (value) =>
                          FlLine(color: Colors.grey.shade300, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: yInterval,
                      getTitlesWidget: (value, _) {
                        if (value == minY) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ), // White text
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, _) {
                        int index = value.toInt();
                        if (index >= 0 && index < pastPredictions.length) {
                          DateTime parsedDate = DateFormat(
                            "yyyy/M/d",
                          ).parse(pastPredictions[index]['Date']);
                          return Text(
                            DateFormat('dd/MM').format(parsedDate),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ), // White text
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  ), // White border
                ),
                minX: 0,
                maxX: (pastPredictions.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots:
                        pastPredictions
                            .asMap()
                            .entries
                            .map(
                              (entry) => FlSpot(
                                entry.key.toDouble(),
                                double.parse(
                                  entry.value['Close'].toStringAsFixed(1),
                                ),
                              ),
                            )
                            .toList(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots:
                        pastPredictions
                            .asMap()
                            .entries
                            .map(
                              (entry) => FlSpot(
                                entry.key.toDouble(),
                                double.parse(
                                  entry.value['Predicted_Price']
                                      .toStringAsFixed(1),
                                ),
                              ),
                            )
                            .toList(),
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(Colors.blue, "Actual Prices"),
              const SizedBox(width: 10),
              _buildLegend(Colors.green, "Predicted Prices"),
            ],
          ),
        ],
      ),
    );
  }

  /// 🗂️ Scrollable Table with Prediction Data
  Widget _buildPredictionTable() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(
              label: Text(
                "Date",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ), // White text
              ),
            ),
            DataColumn(
              label: Text(
                "Close Price",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ), // White text
              ),
            ),
            DataColumn(
              label: Text(
                "Predicted Price",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ), // White text
              ),
            ),
          ],
          rows:
              pastPredictions.map((data) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        data['Date'],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ), // White text
                    DataCell(
                      Text(
                        "₹${data['Close'].toStringAsFixed(1)}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ), // White text
                    DataCell(
                      Text(
                        "₹${data['Predicted_Price'].toStringAsFixed(1)}",
                        style: const TextStyle(color: Colors.white),
                      ), // White text
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  /// 🎯 Legend Widget
  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white)), // White text
      ],
    );
  }
}
