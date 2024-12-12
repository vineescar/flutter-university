import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import '../common_app_bar.dart';

// Model for Sensor Data
class SensorData {
  final String id;
  final double turbidity;
  final double temperature;
  final double conductivity;
  final double ph;
  final DateTime timestamp;
  final String location;

  SensorData({
    required this.id,
    required this.turbidity,
    required this.temperature,
    required this.conductivity,
    required this.ph,
    required this.timestamp,
    required this.location,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      id: json['id'],
      turbidity: double.parse(json['turbidity']),
      temperature: double.parse(json['temperature']),
      conductivity: double.parse(json['conductivity']),
      ph: double.parse(json['ph']),
      timestamp: DateTime.parse(json['timestamp']),
      location: json['location'],
    );
  }
}

// Data Fetcher
class DataFetcher {
  final String apiUrl = 'http://54.173.219.44:8080/api/sensors/last-10';

  Future<List<SensorData>> fetchData() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => SensorData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load sensor data');
    }
  }
}

// Sensor Graph Widget
class SensorGraph extends StatelessWidget {
  final List<SensorData> data;
  final String title;

  SensorGraph({required this.data, required this.title});

  // Map to define colors for different graphs
  final Map<String, Color> graphColors = {
    'Turbidity': Colors.blue,
    'Temperature': Colors.red,
    'Conductivity': Colors.green,
    'pH': Colors.orange,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 10),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 1, // Regular interval for the x-axis
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            final sensorPoint = data[index];
                            return Text(
                              '${sensorPoint.timestamp.hour}:${sensorPoint.timestamp.minute}',
                              style: TextStyle(fontSize: 10),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        data.length,
                            (index) {
                          final sensorPoint = data[index];
                          switch (title) {
                            case 'Turbidity':
                              return FlSpot(index.toDouble(), sensorPoint.turbidity);
                            case 'Temperature':
                              return FlSpot(index.toDouble(), sensorPoint.temperature);
                            case 'Conductivity':
                              return FlSpot(index.toDouble(), sensorPoint.conductivity);
                            case 'pH':
                              return FlSpot(index.toDouble(), sensorPoint.ph);
                            default:
                              return FlSpot(0, 0);
                          }
                        },
                      ),
                      isCurved: true,
                      color: graphColors[title] ?? Colors.blue, // Select color based on title
                      barWidth: 2,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [graphColors[title]!.withOpacity(0.3), graphColors[title]!.withOpacity(0)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// Page2 Widget
class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  late DataFetcher dataFetcher;
  List<SensorData> sensorData = [];

  @override
  void initState() {
    super.initState();
    dataFetcher = DataFetcher();
    fetchDataPeriodically();
  }

  void fetchDataPeriodically() {
    Timer.periodic(Duration(seconds: 3), (timer) async {
      try {
        List<SensorData> newData = await dataFetcher.fetchData();
        setState(() {
          sensorData = newData.reversed.toList();;
        });
      } catch (e) {
        // Handle error
        print('Error fetching data: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Datas'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300, // Set height for each chart
              child: SensorGraph(data: sensorData, title: 'Turbidity'),
            ),
            SizedBox(
              height: 300,
              child: SensorGraph(data: sensorData, title: 'Temperature'),
            ),
            SizedBox(
              height: 300,
              child: SensorGraph(data: sensorData, title: 'Conductivity'),
            ),
            SizedBox(
              height: 300,
              child: SensorGraph(data: sensorData, title: 'pH'),
            ),
          ],
        ),
      ),
    );
  }
}
