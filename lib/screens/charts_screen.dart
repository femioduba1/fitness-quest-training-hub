import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/ml_analysis_service.dart';
import '../database/crud/workout_log_crud.dart';
import '../theme/app_theme.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen>
    with SingleTickerProviderStateMixin {
  final MLAnalysisService _ml = MLAnalysisService.instance;
  final WorkoutLogCrud _logCrud = WorkoutLogCrud();

  late TabController _tabController;

  List<WeeklyChartData> _weeklyData = [];
  List<MonthlyChartData> _monthlyData = [];
  List<Map<String, dynamic>> _todaysLogs = [];
  MLAnalysisResult? _analysis;
  bool _isLoading = true;
  int _touchedBarIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _ml.getWeeklyChartData(),
        _ml.getMonthlyChartData(),
        _ml.getTodaysLogs(),
        _ml.analyzeAll(),
      ]);

      setState(() {
        _weeklyData = results[0] as List<WeeklyChartData>;
        _monthlyData = results[1] as List<MonthlyChartData>;
        _todaysLogs =
            results[2] as List<Map<String, dynamic>>;
        _analysis = results[3] as MLAnalysisResult;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor =
        isDark ? AppTheme.darkDivider : AppTheme.lightDivider;
    final primaryText = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;
    final secondaryText = isDark
        ? AppTheme.darkTextSecondary
        : AppTheme.lightTextSecondary;
    final bgColor = isDark
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ANALYTICS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.orange,
          labelColor: AppTheme.orange,
          unselectedLabelColor: secondaryText,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1),
          tabs: const [
            Tab(text: 'TODAY'),
            Tab(text: 'WEEKLY'),
            Tab(text: 'MONTHLY'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(color: AppTheme.orange))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTodayTab(cardColor, borderColor,
                    primaryText, secondaryText, bgColor),
                _buildWeeklyTab(cardColor, borderColor,
                    primaryText, secondaryText),
                _buildMonthlyTab(cardColor, borderColor,
                    primaryText, secondaryText),
              ],
            ),
    );
  }

  // ── TODAY TAB ─────────────────────────────────────────────
  Widget _buildTodayTab(
      Color cardColor,
      Color borderColor,
      Color primaryText,
      Color secondaryText,
      Color bgColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Consistency score ring
        _SectionLabel(label: 'CONSISTENCY SCORE', color: secondaryText),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        startDegreeOffset: -90,
                        sectionsSpace: 0,
                        centerSpaceRadius: 28,
                        sections: [
                          PieChartSectionData(
                            value: _analysis?.consistencyScore ?? 0,
                            color: AppTheme.orange,
                            radius: 12,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: 100 -
                                (_analysis?.consistencyScore ?? 0),
                            color: borderColor,
                            radius: 12,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Text(
                        '${(_analysis?.consistencyScore ?? 0).toInt()}%',
                        style: TextStyle(
                          color: primaryText,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _consistencyLabel(
                          _analysis?.consistencyScore ?? 0),
                      style: TextStyle(
                        color: primaryText,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Based on your last 30 days of training activity.',
                      style: TextStyle(
                          color: secondaryText, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Muscle balance pie chart
        if (_analysis != null &&
            _analysis!.muscleBalance.isNotEmpty) ...[
          _SectionLabel(
              label: 'MUSCLE GROUP BALANCE',
              color: secondaryText),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 50,
                      sections: _buildMuscleBalanceSections(
                          primaryText),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: _muscleColors.entries
                      .where((e) => _analysis!.muscleBalance
                          .containsKey(e.key))
                      .map((e) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: e.value,
                                  borderRadius:
                                      BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                e.key,
                                style: TextStyle(
                                    color: secondaryText,
                                    fontSize: 11),
                              ),
                            ],
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Today's workout log
        _SectionLabel(
            label: "TODAY'S WORKOUT LOG",
            color: secondaryText),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: _todaysLogs.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No workouts logged today.\nHead to the Library to get started!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: secondaryText, fontSize: 14),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _todaysLogs
                      .where((l) => l['logged_at']
                          .toString()
                          .startsWith(DateTime.now()
                              .toIso8601String()
                              .substring(0, 10)))
                      .length,
                  separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: borderColor),
                  itemBuilder: (context, index) {
                    final todayOnly = _todaysLogs
                        .where((l) => l['logged_at']
                            .toString()
                            .startsWith(DateTime.now()
                                .toIso8601String()
                                .substring(0, 10)))
                        .toList();
                    if (index >= todayOnly.length) {
                      return const SizedBox.shrink();
                    }
                    final log = todayOnly[index];
                    return _WorkoutLogTile(
                      log: log,
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                    );
                  },
                ),
        ),

        const SizedBox(height: 20),

        // ML Recommendations
        _SectionLabel(
            label: 'ML RECOMMENDATIONS',
            color: secondaryText),
        const SizedBox(height: 10),
        if (_analysis != null)
          ..._analysis!.recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: rec.color.withOpacity(0.4),
                        width: 1.5),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: rec.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(rec.icon,
                              style:
                                  const TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              rec.title,
                              style: TextStyle(
                                color: primaryText,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              rec.message,
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),

        const SizedBox(height: 24),
      ],
    );
  }

  // ── WEEKLY TAB ────────────────────────────────────────────
  Widget _buildWeeklyTab(Color cardColor, Color borderColor,
      Color primaryText, Color secondaryText) {
    final maxY = _weeklyData.isEmpty
        ? 10.0
        : _weeklyData
                .map((d) => d.workoutCount.toDouble())
                .reduce((a, b) => a > b ? a : b) +
            2;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionLabel(
            label: 'WORKOUTS PER WEEK (LAST 8 WEEKS)',
            color: secondaryText),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    maxY: maxY,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem:
                            (group, groupIndex, rod, rodIndex) {
                          final data = _weeklyData[groupIndex];
                          return BarTooltipItem(
                            '${data.weekLabel}\n${rod.toY.toInt()} workouts',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                      touchCallback:
                          (FlTouchEvent event, barTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              barTouchResponse == null ||
                              barTouchResponse.spot == null) {
                            _touchedBarIndex = -1;
                            return;
                          }
                          _touchedBarIndex = barTouchResponse
                              .spot!.touchedBarGroupIndex;
                        });
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 ||
                                index >= _weeklyData.length) {
                              return const SizedBox.shrink();
                            }
                            final label =
                                _weeklyData[index].weekLabel;
                            final parts = label.split(' ');
                            return Padding(
                              padding:
                                  const EdgeInsets.only(top: 6),
                              child: Text(
                                parts.length > 1
                                    ? parts[1]
                                    : label,
                                style: TextStyle(
                                  color: secondaryText,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          },
                          reservedSize: 28,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            if (value % 2 != 0) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                  color: secondaryText,
                                  fontSize: 10),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) =>
                          FlLine(
                        color: borderColor,
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups:
                        List.generate(_weeklyData.length, (i) {
                      final isTouched = i == _touchedBarIndex;
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: _weeklyData[i]
                                .workoutCount
                                .toDouble(),
                            color: isTouched
                                ? Colors.white
                                : AppTheme.orange,
                            width: 22,
                            borderRadius:
                                const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                            backDrawRodData:
                                BackgroundBarChartRodData(
                              show: true,
                              toY: maxY,
                              color: borderColor,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  swapAnimationDuration:
                      const Duration(milliseconds: 500),
                  swapAnimationCurve: Curves.easeInOut,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Volume trend
        if (_analysis != null &&
            _analysis!.volumeTrend.weeklyVolumes.isNotEmpty) ...[
          _SectionLabel(
              label: 'VOLUME TREND', color: secondaryText),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _analysis!.volumeTrend.trend ==
                              TrendDirection.up
                          ? Icons.trending_up
                          : _analysis!.volumeTrend.trend ==
                                  TrendDirection.down
                              ? Icons.trending_down
                              : Icons.trending_flat,
                      color: _analysis!.volumeTrend.trend ==
                              TrendDirection.up
                          ? const Color(0xFF4CAF50)
                          : _analysis!.volumeTrend.trend ==
                                  TrendDirection.down
                              ? const Color(0xFFF44336)
                              : secondaryText,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _analysis!.volumeTrend.trend ==
                              TrendDirection.up
                          ? 'Volume Increasing'
                          : _analysis!.volumeTrend.trend ==
                                  TrendDirection.down
                              ? 'Volume Declining'
                              : 'Volume Stable',
                      style: TextStyle(
                        color: primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) =>
                            FlLine(
                          color: borderColor,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) =>
                                Text(
                              'W${value.toInt() + 1}',
                              style: TextStyle(
                                  color: secondaryText,
                                  fontSize: 10),
                            ),
                            reservedSize: 22,
                          ),
                        ),
                        leftTitles: const AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            _analysis!
                                .volumeTrend.weeklyVolumes.length,
                            (i) => FlSpot(
                              i.toDouble(),
                              _analysis!
                                  .volumeTrend.weeklyVolumes[i],
                            ),
                          ),
                          isCurved: true,
                          color: AppTheme.orange,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color:
                                AppTheme.orange.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  // ── MONTHLY TAB ───────────────────────────────────────────
  Widget _buildMonthlyTab(Color cardColor, Color borderColor,
      Color primaryText, Color secondaryText) {
    final spots = List.generate(
      _monthlyData.length,
      (i) => FlSpot(
          i.toDouble(), _monthlyData[i].workoutCount.toDouble()),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionLabel(
            label: 'MONTHLY PROGRESS (LAST 6 MONTHS)',
            color: secondaryText),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: SizedBox(
            height: 240,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems:
                        (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final index = barSpot.x.toInt();
                        if (index < 0 ||
                            index >= _monthlyData.length) {
                          return null;
                        }
                        return LineTooltipItem(
                          '${_monthlyData[index].monthLabel}\n${barSpot.y.toInt()} workouts',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: borderColor,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 ||
                            index >= _monthlyData.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _monthlyData[index].monthLabel,
                            style: TextStyle(
                                color: secondaryText,
                                fontSize: 11),
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: TextStyle(
                            color: secondaryText, fontSize: 10),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.orange,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter:
                          (spot, percent, barData, index) =>
                              FlDotCirclePainter(
                        radius: 5,
                        color: AppTheme.orange,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.orange.withOpacity(0.3),
                          AppTheme.orange.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Monthly summary stats
        _SectionLabel(
            label: 'MONTHLY SUMMARY', color: secondaryText),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: _monthlyData.map((data) {
              final maxCount = _monthlyData
                  .map((d) => d.workoutCount)
                  .reduce((a, b) => a > b ? a : b);
              final progress = maxCount == 0
                  ? 0.0
                  : data.workoutCount / maxCount;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      child: Text(
                        data.monthLabel,
                        style: TextStyle(
                          color: primaryText,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: borderColor,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(
                                  AppTheme.orange),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${data.workoutCount}',
                      style: TextStyle(
                        color: AppTheme.orange,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  // ── HELPERS ───────────────────────────────────────────────
  List<PieChartSectionData> _buildMuscleBalanceSections(
      Color primaryText) {
    final balance = _analysis!.muscleBalance;
    return balance.entries.map((e) {
      final color = _muscleColors[e.key] ?? Colors.grey;
      return PieChartSectionData(
        value: e.value,
        color: color,
        title: '${e.value.toInt()}%',
        radius: 50,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      );
    }).toList();
  }

  String _consistencyLabel(double score) {
    if (score >= 80) return 'Elite Athlete 🏆';
    if (score >= 60) return 'Very Consistent 💪';
    if (score >= 40) return 'Building Habits 📈';
    if (score >= 20) return 'Getting Started 🌱';
    return 'Just Beginning 🎯';
  }

  static const Map<String, Color> _muscleColors = {
    'Chest': Color(0xFFFF6000),
    'Back': Color(0xFF2196F3),
    'Legs': Color(0xFF4CAF50),
    'Core': Color(0xFFFF9800),
    'Arms': Color(0xFF9C27B0),
    'Shoulders': Color(0xFFF44336),
  };
}

// Workout log tile
class _WorkoutLogTile extends StatelessWidget {
  final Map<String, dynamic> log;
  final Color primaryText;
  final Color secondaryText;

  const _WorkoutLogTile({
    required this.log,
    required this.primaryText,
    required this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    final weight = log['weight'];
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                log['exercise_name']
                    .toString()
                    .substring(0, 1)
                    .toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.orange,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log['exercise_name'],
                  style: TextStyle(
                    color: primaryText,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${log['sets']} sets × ${log['reps']} reps'
                  '${weight != null ? ' • ${weight}lbs' : ''}',
                  style: TextStyle(
                      color: secondaryText, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'TODAY',
              style: TextStyle(
                color: AppTheme.orange,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Section label widget
class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    );
  }
}