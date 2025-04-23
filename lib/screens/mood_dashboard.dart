import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoodDashboard extends StatefulWidget {
  const MoodDashboard({super.key});

  @override
  State<MoodDashboard> createState() => _MoodDashboardState();
}

class _MoodDashboardState extends State<MoodDashboard> {
  Map<String, int> moodCounts = {};
  DateTime selectedMonth = DateTime.now();
  List<BarChartGroupData> weeklyBars = [];
  int moodStreak = 0;

  @override
  void initState() {
    super.initState();
    fetchMoodStats();
    fetchWeeklyTrend();
    fetchMoodStreak();
  }

  Future<void> fetchMoodStats() async {
    final formattedMonth = DateFormat('yyyy-MM').format(selectedMonth);
    final url =
        // Uri.parse('http://localhost:5002/api/mood/stats?month=$formattedMonth');
                Uri.parse('http://192.168.1.18:5002/api/mood/stats?month=$formattedMonth');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        moodCounts = data.isEmpty
            ? {}
            : {for (var stat in data) stat['_id']: stat['count']};
      });
    } else {
      print("❌ Error fetching stats: ${res.body}");
    }
  }

  Future<void> fetchWeeklyTrend() async {
    final formattedMonth = DateFormat('yyyy-MM').format(selectedMonth);
    final url = Uri.parse(
             'http://192.168.1.18:5002/api/mood/weekly-stats?month=$formattedMonth');

        // 'http://localhost:5002/api/mood/weekly-stats?month=$formattedMonth');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      setState(() {
        weeklyBars = data.map<BarChartGroupData>((e) {
          final double mood = (e['moodAvg'] as num).toDouble();
          final int week = e['week'];
          return BarChartGroupData(
            x: week,
            barRods: [
              BarChartRodData(
                toY: mood,
                color: mood == 3
                    ? Colors.green
                    : (mood == 2 ? Colors.orange : Colors.red),
                width: 20,
                borderRadius: BorderRadius.circular(6),
              )
            ],
          );
        }).toList();
      });
    } else {
      print("❌ Weekly trend error: ${res.body}");
    }
  }

  List<PieChartSectionData> getSections() {
    final total = moodCounts.values.fold(0, (sum, count) => sum + count);
    final colors = {
      'Pleasant': Colors.green,
      'Neutral': Colors.orange,
      'Unpleasant': Colors.red,
    };

    return moodCounts.entries.map((entry) {
      final percentage = total == 0 ? 0.0 : (entry.value / total) * 100;
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: "${entry.key}\n${percentage.toStringAsFixed(1)}%",
        color: colors[entry.key] ?? Colors.grey,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        radius: 90,
      );
    }).toList();
  }

  String getMostFrequentMood() {
    if (moodCounts.isEmpty) return "None";
    return moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  Future<void> fetchMoodStreak() async {
    final url = Uri.parse('http://192.168.1.18:5002/api/mood/streak');
        // final url = Uri.parse('http://localhost:5002/api/mood/streak');


    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        moodStreak = data['streak'] ?? 0;
      });
    } else {
      print("❌ Mood streak error: ${res.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final mostFrequent = getMostFrequentMood();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: const [
                  SizedBox(width: 8),
                  Padding(
                    padding: EdgeInsets.fromLTRB(110, 0, 0, 0),
                    child: Text(
                      'Dash Board',
                      style: TextStyle(
                        color: Colors.brown,
                        fontSize: 30,
                        fontFamily: 'Gayathri',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Month: ${DateFormat('yyyy-MM').format(selectedMonth)}"),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedMonth,
                        firstDate: DateTime(2023),
                        lastDate: DateTime.now(),
                        helpText: "Select a Month",
                      );
                      if (picked != null) {
                        setState(() {
                          selectedMonth = picked;
                        });
                        fetchMoodStats();
                        fetchWeeklyTrend();
                      }
                    },
                    child: const Text("Change Month"),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              /// PIE CHART
              moodCounts.isEmpty
                  ? const Center(child: Text("No mood data for this month."))
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: AspectRatio(
                        aspectRatio: 1.3,
                        child: PieChart(
                          PieChartData(
                            sections: getSections(),
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                          ),
                        ),
                      ),
                    ),

              /// MOST FREQUENT MOOD
              Card(
                elevation: 3,
                color: const Color.fromARGB(255, 247, 245, 245),
                child: ListTile(
                  leading:
                      const Icon(Icons.emoji_emotions, color: Colors.brown),
                  title: Text("Most Frequent Mood: $mostFrequent"),
                ),
              ),
              const SizedBox(height: 16),

              /// WEEKLY BAR CHART
              Card(
                elevation: 3,
                color: const Color.fromARGB(255, 247, 245, 245),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        "Weekly Mood Trend",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: weeklyBars.isEmpty
                            ? const Center(child: Text("No data"))
                            : BarChart(
                                BarChartData(
                                  barGroups: weeklyBars,
                                  minY: 0,
                                  maxY: 3,
                                  gridData: FlGridData(show: false),
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, _) =>
                                            Text("W${value.toInt()}"),
                                        interval: 1,
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 1,
                                        reservedSize: 35,
                                        getTitlesWidget: (value, meta) {
                                          String label = '';
                                          switch (value.toInt()) {
                                            case 1:
                                              label = '😞';
                                              break;
                                            case 2:
                                              label = '😐';
                                              break;
                                            case 3:
                                              label = '😊';
                                              break;
                                          }

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: Text(
                                              label,
                                              
style: const TextStyle(fontSize: 20),                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    topTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                    rightTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              /// MOOD STREAK MOCK
        Card(
                elevation: 3,
                color: const Color.fromARGB(255, 247, 245, 245),
                child: ListTile(
                  leading: const Icon(Icons.local_fire_department,
                      color: Colors.deepOrange),
                  title: Text("Mood Log Streak: $moodStreak days 🔥"),
                ),
              ),
              const SizedBox(height: 16),

              /// EXPORT PLACEHOLDER
              const Text(
                "📸 Export feature temporarily disabled. We’ll bring it back soon!",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
