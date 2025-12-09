import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/dashboard_controller.dart';
import '../../controllers/results_controller.dart';
import '../../utils/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/gradient_text.dart';
import '../home/home_screen.dart';

class ResultDetailScreen extends StatefulWidget {
  final int scanResultId;
  final String goto;

  const ResultDetailScreen({
    super.key,
    required this.scanResultId,
    this.goto = 'result_screen',
  });

  @override
  State<ResultDetailScreen> createState() => _ResultDetailScreenState();
}

class _ResultDetailScreenState extends State<ResultDetailScreen> {
  final resultsController = Get.put(ResultsController());
  final dashboardController = Get.find<DashboardController>();
  final globalKey = GlobalKey();
  ScreenshotController screenshotController = ScreenshotController();
  final noScreenshot = NoScreenshot.instance;
  bool isListeningToScreenshotSnapshot = false;

  @override
  void initState() {
    super.initState();
    _loadResults();
    listenForScreenshot();
  }

  void listenForScreenshot() async {
    bool result = await noScreenshot.screenshotOff();
    print('result: $result');
    noScreenshot.screenshotStream.listen((value) {});
  }

  void stopScreenshotListening() async {
    await noScreenshot.stopScreenshotListening();
    setState(() {
      isListeningToScreenshotSnapshot = false;
    });
  }

  void startScreenshotListening() async {
    await noScreenshot.startScreenshotListening();
    setState(() {
      isListeningToScreenshotSnapshot = true;
    });
  }

  Future<void> _loadResults() async {
    await resultsController.loadResult(widget.scanResultId);

    if (resultsController.currentResult != null) {}
  }

  Color _getLevelColor(String color) {
    switch (color.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'yellow':
        return Colors.yellow.shade700;
      case 'green':
        return Colors.green;
      default:
        return AppTheme.brandOrange;
    }
  }

  Future<void> _showDeleteConfirmation() async {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2a3342),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Delete Results',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to permanently delete these results?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              Get.dialog(
                const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.brandOrange,
                  ),
                ),
                barrierDismissible: false,
              );

              final success = await resultsController.deleteResult(widget.scanResultId);

              if (success) {
                var snack = Get.snackbar(
                  'Success',
                  'Results deleted successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.green,
                  colorText: Colors.white,
                );
                Future.delayed(Duration(milliseconds: 2900), () {
                  snack.close();
                  if (widget.goto == 'result_screen') {
                    dashboardController.dashboard?.recentResults.clear();
                    dashboardController.refresh();
                    Navigator.of(Get.context!).pop();
                    Navigator.of(Get.context!).pop();
                  } else if (widget.goto == 'home_screen') {
                    Get.offAll(() => HomeScreen());
                  }
                });
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to delete results',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.darkOrange),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            if (resultsController.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.brandOrange,
                ),
              );
            }

            final result = resultsController.currentResult;

            if (result == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppTheme.darkOrange,
                      size: 80,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Results Not Found',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.brandOrange,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: Text(
                        'Go Back',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final score = result.catfishScore;
            final level = result.catfishLevel.label;
            final levelDescription = result.catfishLevel.description;
            final levelColor = _getLevelColor(result.catfishLevel.color);
            final detections = result.detectionsByCategory;
            final imageURL = result.imageURL;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 10.0),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (widget.goto == 'direct_home') {
                                Get.offAll(() => const HomeScreen());
                              } else {
                                Get.back();
                              }
                            },
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GradientText(
                            text: 'Analysis Results',
                            gradient: AppTheme.primaryGradient,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: _showDeleteConfirmation,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.white70,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await screenshotController.capture(delay: const Duration(milliseconds: 10)).then((Uint8List? image) async {
                            if (image != null) {
                              final directory = await getApplicationDocumentsDirectory();
                              final imagePath = await File('${directory.path}/image-${DateTime.now().microsecondsSinceEpoch}.png').create();
                              await imagePath.writeAsBytes(image);

                              /// Share Plugin
                              final params = ShareParams(
                                files: [
                                  XFile(imagePath.path),
                                ],
                              );

                              final result = await SharePlus.instance.share(params);
                              if (result.status == ShareResultStatus.dismissed) {
                                print('Did you not like the pictures?');
                              }
                              // await SharePlus.instance.share([imagePath.path]);
                            }
                          });
                        },
                        icon: const Icon(
                          Icons.share_outlined,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20.0),
                        Screenshot(
                          controller: screenshotController,
                          child: _buildScoreGauge(
                            score,
                            levelColor,
                            level,
                            imageURL,
                            levelDescription,
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        GlassContainer(
                          padding: const EdgeInsets.all(24),
                          blur: 15,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Detection Summary',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildSummaryItem(
                                Icons.category_outlined,
                                'Categories Detected',
                                '${detections.length}',
                              ),
                              const SizedBox(height: 12),
                              _buildSummaryItem(
                                Icons.warning_amber_outlined,
                                'Total Modifications',
                                '${detections.fold(0, (sum, cat) => sum + (cat.detections as List).length)}',
                              ),
                              const SizedBox(height: 12),
                              // _buildSummaryItem(
                              //   Icons.speed,
                              //   'Confidence Level',
                              //   levelDescription,
                              // ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.speed,
                                    color: const Color(0xFF00D4FF),
                                    size: 20.0,
                                  ),
                                  SizedBox(width: 12),
                                  // Expanded(
                                  //   child: Text(
                                  //     label,
                                  //     style: TextStyle(
                                  //       color: Colors.white.withOpacity(0.7),
                                  //       fontSize: 14,
                                  //     ),
                                  //   ),
                                  // ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width / 1.6,
                                    child: Text(
                                      levelDescription,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
                        const SizedBox(height: 30),
                        ...detections.asMap().entries.map((entry) {
                          final index = entry.key;
                          final category = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _buildCategoryCard(
                              category.categoryName,
                              category.detections,
                            ).animate().fadeIn(delay: (600 + index * 100).ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
                          );
                        }),
                        const SizedBox(height: 20),
                        GlassContainer(
                          padding: const EdgeInsets.all(20),
                          blur: 10,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.warningGradient,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.info_outline,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  // 'Results are stored until manually deleted',
                                  'Output is a probability rating only. CatFish Scan does not confirm authenticity or identity.',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        GradientButton(
                          text: 'Analyze Another Photo',
                          onPressed: () {
                            Get.offAll(() => const HomeScreen());
                          },
                          gradient: AppTheme.primaryGradient,
                          icon: Icons.camera_alt_outlined,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildScoreGauge(score, levelColor, level, imageURL, levelDescription) {
    return GlassContainer(
      padding: const EdgeInsets.all(32),
      width: MediaQuery.of(context).size.width,
      showImage: true,
      imageURL: imageURL,
      blur: 0,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: CustomPaint(
                  painter: ScoreGaugePainter(
                    score: score,
                    color: levelColor,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    score.toString(),
                    style: TextStyle(
                      color: levelColor,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'out of 10',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: levelColor.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Text(
              level.toUpperCase(),
              style: TextStyle(
                color: levelColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
          const SizedBox(height: 12),
          Text(
            // 'Significant deception detected',
            '$levelDescription',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildSummaryItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF00D4FF),
          size: 20.0,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String category, detections) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      blur: 15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.category,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...detections.map((detection) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildDetectionItem(detection),
              )),
        ],
      ),
    );
  }

  Widget _buildDetectionItem(detection) {
    print('detection: $detection');
    print('detection.label: ${detection.label}');
    print('detection.scoreContribution: ${detection.scoreContribution}');
    print('detection.confidence: ${detection.confidence}');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  detection.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppTheme.warningGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${detection.scoreContribution}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            detection.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Confidence: ',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: detection.confidence / 10,
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.lerp(
                        Colors.yellow,
                        Colors.red,
                        detection.confidence / 10,
                      )!,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${detection.confidence}/10',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // void _showDeleteConfirmation() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: const Color(0xFF1A1A2E),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(20),
  //       ),
  //       title: const Text(
  //         'Delete Results',
  //         style: TextStyle(color: Colors.white),
  //       ),
  //       content: const Text(
  //         'Are you sure you want to permanently delete these results?',
  //         style: TextStyle(color: Colors.white70),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(),
  //           child: const Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Get.back();
  //             Get.offAll(() => const HomeScreen());
  //           },
  //           child: const Text(
  //             'Delete',
  //             style: TextStyle(color: Color(0xFFFF4B2B)),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

class ScoreGaugePainter extends CustomPainter {
  final int score;
  final Color color;

  ScoreGaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [color, color.withOpacity(0.6)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / 10) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
