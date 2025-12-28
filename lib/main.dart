import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const DoctorApp());
}

class DoctorApp extends StatelessWidget {
  const DoctorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final darkBlue = const Color(0xFF0a2351);
    final brightRed = Colors.red;

    return MaterialApp(
      title: "Doctor's Monitor",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brightRed,
          primary: brightRed,
          primaryContainer: darkBlue,
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brightRed,
          primary: brightRed,
          primaryContainer: darkBlue,
          brightness: Brightness.dark,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer,
              colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Icon(
                  Icons.monitor_heart,
                  size: 100,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      "Doctor's Monitor",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 48),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const MenuPage()),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Start'),
                    ),
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

// Menu screen: select patient
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Patient')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('patients').snapshots(),
        builder: (context, patientSnapshot) {
          if (!patientSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final patients = patientSnapshot.data!.docs;

          if (patients.isEmpty) {
            return const Center(child: Text("No patients found"));
          }

          // 🔑 ONE stream for patient names
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('patientNames')
                .doc('names')
                .snapshots(),
            builder: (context, nameSnapshot) {
              Map<String, dynamic> namesMap = {};

              if (nameSnapshot.hasData && nameSnapshot.data!.exists) {
                namesMap =
                    nameSnapshot.data!.data() as Map<String, dynamic>;
              }

              return ListView.builder(
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  final patientId = patients[index].id;

                  // ✅ Get name from names document
                  final displayName =
                      namesMap[patientId] ?? patientId;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(
                        displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HealthMonitorPageForDoctor(
                              patientId: patientId,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// Patient monitor screen
class HealthMonitorPageForDoctor extends StatefulWidget {
  final String patientId;
  const HealthMonitorPageForDoctor({super.key, required this.patientId});

  @override
  State<HealthMonitorPageForDoctor> createState() => _HealthMonitorPageForDoctorState();
}

class _HealthMonitorPageForDoctorState extends State<HealthMonitorPageForDoctor>
    with TickerProviderStateMixin {
  int _heartRate = 0;
  double _temperature = 0.0;
  int _spO2 = 0;
  String _status = "Normal";
  String _patientName = "";
  DateTime _lastUpdated = DateTime.now();

  late Stream<DocumentSnapshot> _patientStream;

  // Gradient animation
  late AnimationController _gradientController;
  late Animation<Alignment> _gradientStartAnimation;
  late Animation<Alignment> _gradientEndAnimation;

  @override
  void initState() {
    super.initState();

    // Firestore stream for health data
    _patientStream = FirebaseFirestore.instance
        .collection('patients')
        .doc(widget.patientId)
        .snapshots();

    // Load patient name from patientNames document
    _loadPatientName();

    // Gradient animation
    _gradientController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _gradientStartAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1),
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1),
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1),
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.bottomLeft, end: Alignment.topLeft), weight: 1),
    ]).animate(_gradientController);

    _gradientEndAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1),
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.bottomLeft, end: Alignment.topLeft), weight: 1),
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1),
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1),
    ]).animate(_gradientController);

    _gradientController.repeat();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientName() async {
    final doc = await FirebaseFirestore.instance.collection('patientNames').doc('names').get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _patientName = data[widget.patientId] ?? widget.patientId;
      });
    } else {
      // If the document doesn't exist, create it with this patient
      await FirebaseFirestore.instance.collection('patientNames').doc('names').set({
        widget.patientId: widget.patientId,
      });
      setState(() {
        _patientName = widget.patientId;
      });
    }
  }

  // Function to update patient name
  void _updatePatientName() async {
    final TextEditingController controller = TextEditingController(text: _patientName);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Patient Name"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Patient Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text;
              // Update in patientNames document
              await FirebaseFirestore.instance
                  .collection('patientNames')
                  .doc('names')
                  .update({widget.patientId: newName});
              setState(() => _patientName = newName);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return DateFormat('hh:mm a').format(dt); // 12-hour format
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<DocumentSnapshot>(
      stream: _patientStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          _heartRate = data['heartRate'] ?? 0;
          _temperature = (data['temperature'] ?? 0.0).toDouble();
          _spO2 = data['spO2'] ?? 0;
          _status = data['status'] ?? "Normal";
          Timestamp ts = data['lastUpdated'] ?? Timestamp.now();
          _lastUpdated = ts.toDate();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Patient: $_patientName'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _updatePatientName,
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.surface,
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildHealthMetricCard(
                        title: 'Heart Rate',
                        value: '$_heartRate bpm',
                        icon: Icons.favorite, // heart icon
                        color: Colors.red,
                      ),
                      const SizedBox(height: 12),
                      _buildHealthMetricCard(
                        title: 'Temperature',
                        value: '${_temperature.toStringAsFixed(1)} °C',
                        icon: Icons.thermostat, // temperature icon
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildHealthMetricCard(
                        title: 'SpO₂',
                        value: '$_spO2 %',
                        icon: Icons.bloodtype,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildHealthMetricCard(
                        title: 'Status',
                        value: _status,
                        icon: Icons.health_and_safety,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildHealthMetricCard(
                        title: 'Last Updated',
                        value: _formatTime(_lastUpdated),
                        icon: Icons.access_time,
                        color: Colors.purple,
                      ),
                      const SizedBox(height: 24),
                      _buildHeartRateChart(),
                      const SizedBox(height: 12),
                      _buildTemperatureChart(),
                      const SizedBox(height: 12),
                      _buildSpO2Chart(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeartRateChart() {
    return _buildHistoryChart(
      title: 'Heart Rate History (BPM)',
      fieldName: 'heartRate',
      color: Colors.red,
      minY: 0,
      maxY: 180,
      interval: 40,
    );
  }

  Widget _buildTemperatureChart() {
    return _buildHistoryChart(
      title: 'Temperature History (°C)',
      fieldName: 'temperature',
      color: Colors.orange,
      minY: 30,
      maxY: 45,
      interval: 5,
    );
  }

  Widget _buildSpO2Chart() {
    return _buildHistoryChart(
      title: 'SpO₂ History (%)',
      fieldName: 'spO2',
      color: Colors.blue,
      minY: 70,
      maxY: 100,
      interval: 10,
    );
  }

  Widget _buildHistoryChart({
    required String title,
    required String fieldName,
    required Color color,
    required double minY,
    required double maxY,
    required double interval,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('patients')
                    .doc(widget.patientId)
                    .collection('readings')
                    .orderBy('timestamp', descending: true)
                    .limit(20)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No history available'));
                  }

                  final docs = snapshot.data!.docs.reversed.toList();
                  List<FlSpot> spots = [];
                  for (int i = 0; i < docs.length; i++) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final rawValue = data[fieldName];
                    double value = 0;
                    if (rawValue is num) {
                      value = rawValue.toDouble();
                    } else if (rawValue is String) {
                      value = double.tryParse(rawValue) ?? 0;
                    }
                    spots.add(FlSpot(i.toDouble(), value));
                  }

                  return LineChart(
                    LineChartData(
                      minY: minY,
                      maxY: maxY,
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: interval,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                  fieldName == 'temperature' 
                                      ? value.toStringAsFixed(1) 
                                      : value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: color,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: color.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetricCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) {
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 6,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: _gradientStartAnimation.value,
                end: _gradientEndAnimation.value,
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.05),
                  color.withOpacity(0.15),
                ],
              ),
            ),
            child: Center(
              child: ListTile(
                leading: Icon(icon, size: 32, color: color),
                title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              ),
            ),
          ),
        );
      },
    );
  }
}
