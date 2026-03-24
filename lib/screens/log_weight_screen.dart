import 'package:flutter/material.dart';
import '../services/bmi_service.dart';
import '../database/crud/body_measurement_crud.dart';
import '../services/preferences_service.dart';
import '../theme/app_theme.dart';

/// Log Weight Screen — allows user to log their current weight
/// Calculates and shows BMI immediately after logging
class LogWeightScreen extends StatefulWidget {
  const LogWeightScreen({super.key});

  @override
  State<LogWeightScreen> createState() =>
      _LogWeightScreenState();
}

class _LogWeightScreenState
    extends State<LogWeightScreen> {
  double _weightKg = 70;
  double _heightCm = 170;
  bool _isSaving = false;
  final TextEditingController _notesController =
      TextEditingController();

  double get _bmi =>
      BMIService.instance.calculateBMI(_weightKg, _heightCm);

  @override
  void initState() {
    super.initState();
    _loadCurrentHeight();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentHeight() async {
    final height =
        await PreferencesService.instance.getHeightCm();
    final latest = await BodyMeasurementCrud()
        .getLatestMeasurement();
    setState(() {
      _heightCm = height > 0 ? height : 170;
      if (latest != null) {
        _weightKg =
            (latest['weight_kg'] as double?) ?? 70;
      }
    });
  }

  Future<void> _saveWeight() async {
    setState(() => _isSaving = true);
    try {
      await BMIService.instance.logWeight(
        weightKg: _weightKg,
        notes: _notesController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Weight logged! BMI: ${_bmi.toStringAsFixed(1)}'),
            backgroundColor: AppTheme.orange,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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

    final bmiColor = BMIService.instance.getBMIColor(_bmi);
    final bmiCategory =
        BMIService.instance.getBMICategory(_bmi);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LOG WEIGHT'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── LIVE BMI DISPLAY ──────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: bmiColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: bmiColor.withOpacity(0.4),
                    width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    _bmi.toStringAsFixed(1),
                    style: TextStyle(
                      color: bmiColor,
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  Text(
                    'BMI — $bmiCategory',
                    style: TextStyle(
                      color: bmiColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── WEIGHT SLIDER ─────────────────────────
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CURRENT WEIGHT',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  '${_weightKg.toStringAsFixed(1)} kg  (${(_weightKg * 2.205).toStringAsFixed(1)} lbs)',
                  style: const TextStyle(
                    color: AppTheme.orange,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppTheme.orange,
                inactiveTrackColor:
                    isDark
                        ? AppTheme.darkCardLight
                        : AppTheme.lightCardLight,
                thumbColor: AppTheme.orange,
                overlayColor:
                    AppTheme.orange.withOpacity(0.2),
                thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 14),
                trackHeight: 6,
              ),
              child: Slider(
                value: _weightKg,
                min: 40,
                max: 150,
                divisions: 110,
                onChanged: (value) =>
                    setState(() => _weightKg = value),
              ),
            ),

            const SizedBox(height: 20),

            // ── NOTES ─────────────────────────────────
            Text(
              'NOTES (OPTIONAL)',
              style: TextStyle(
                color: secondaryText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              style: TextStyle(color: primaryText),
              decoration: InputDecoration(
                hintText:
                    'e.g. After morning workout, fasted...',
                hintStyle:
                    TextStyle(color: secondaryText),
                prefixIcon: const Icon(Icons.notes,
                    color: AppTheme.orange),
              ),
            ),

            const SizedBox(height: 32),

            // ── SAVE BUTTON ───────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveWeight,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white),
                      )
                    : const Text('LOG WEIGHT'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}