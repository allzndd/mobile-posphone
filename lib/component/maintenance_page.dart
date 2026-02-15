import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../config/theme_provider.dart';

class MaintenancePage extends StatefulWidget {
  final String? title;
  final String? message;
  final DateTime? estimatedEnd;
  final VoidCallback? onCheckStatus;
  final bool showTimer;

  const MaintenancePage({
    super.key,
    this.title,
    this.message,
    this.estimatedEnd,
    this.onCheckStatus,
    this.showTimer = true,
  });

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();

  // Static helper methods for easy usage
  static void show(
    BuildContext context, {
    String? title,
    String? message,
    DateTime? estimatedEnd,
    VoidCallback? onCheckStatus,
    bool showTimer = true,
  }) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MaintenancePage(
          title: title,
          message: message,
          estimatedEnd: estimatedEnd,
          onCheckStatus: onCheckStatus,
          showTimer: showTimer,
        ),
      ),
    );
  }

  static Widget widget({
    String? title,
    String? message,
    DateTime? estimatedEnd,
    VoidCallback? onCheckStatus,
    bool showTimer = true,
  }) {
    return MaintenancePage(
      title: title,
      message: message,
      estimatedEnd: estimatedEnd,
      onCheckStatus: onCheckStatus,
      showTimer: showTimer,
    );
  }
}

class _MaintenancePageState extends State<MaintenancePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  Timer? _timer;
  Duration? _remainingTime;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _calculateRemainingTime();
    _startTimer();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _calculateRemainingTime() {
    final maintenanceEndTime = widget.estimatedEnd;
    if (maintenanceEndTime == null) return;
    
    final now = DateTime.now();
    if (maintenanceEndTime.isAfter(now)) {
      if (mounted) {
        setState(() {
          _remainingTime = maintenanceEndTime.difference(now);
        });
      }
    }
  }

  void _startTimer() {
    final maintenanceEndTime = widget.estimatedEnd;
    final isTimerEnabled = widget.showTimer;
    
    if (maintenanceEndTime == null || !isTimerEnabled) return;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (periodicTimer) {
      _calculateRemainingTime();
      final currentRemaining = _remainingTime;
      if (currentRemaining != null && currentRemaining.inSeconds <= 0) {
        periodicTimer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 24 : 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated maintenance icon
                _buildMaintenanceIcon(themeProvider, isMobile),

                SizedBox(height: isMobile ? 32 : 48),

                // Title
                Text(
                  widget.title ?? 'System Maintenance',
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: isMobile ? 16 : 24),

                // Message
                Container(
                  constraints: BoxConstraints(maxWidth: isMobile ? 320 : 600),
                  child: Text(
                    widget.message ??
                        'We\'re currently performing scheduled maintenance to improve our services. We\'ll be back shortly.',
                    style: TextStyle(
                      fontSize: isMobile ? 15 : 18,
                      color: themeProvider.textSecondary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Countdown Timer
                if (widget.showTimer && _remainingTime != null) ...[
                  SizedBox(height: isMobile ? 32 : 48),
                  _buildCountdownTimer(themeProvider, isMobile),
                ],

                SizedBox(height: isMobile ? 32 : 48),

                // Status indicators
                _buildStatusIndicators(themeProvider, isMobile),

                SizedBox(height: isMobile ? 32 : 48),

                // Action button
                if (widget.onCheckStatus != null)
                  _buildCheckStatusButton(themeProvider, isMobile),

                SizedBox(height: isMobile ? 24 : 32),

                // Contact info
                _buildContactInfo(themeProvider, isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMaintenanceIcon(ThemeProvider themeProvider, bool isMobile) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: isMobile ? 140 : 180,
            height: isMobile ? 140 : 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  themeProvider.primaryMain.withOpacity(0.2),
                  themeProvider.secondaryMain.withOpacity(0.2),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: themeProvider.primaryMain.withOpacity(0.3),
                  blurRadius: 40,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.construction,
                  size: isMobile ? 70 : 90,
                  color: themeProvider.primaryMain,
                ),
                Positioned(
                  right: isMobile ? 20 : 30,
                  top: isMobile ? 20 : 30,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: themeProvider.warningMain,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.settings,
                      size: isMobile ? 20 : 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCountdownTimer(ThemeProvider themeProvider, bool isMobile) {
    final Duration? remaining = _remainingTime;
    if (remaining == null || remaining.inSeconds <= 0) {
      return const SizedBox.shrink();
    }

    final int hours = remaining.inHours;
    final int minutes = remaining.inMinutes.remainder(60);
    final int seconds = remaining.inSeconds.remainder(60);

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: themeProvider.primaryMain.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: themeProvider.primaryMain.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Estimated Time Remaining',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: themeProvider.textSecondary,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeUnit(
                hours.toString().padLeft(2, '0'),
                'Hours',
                themeProvider,
                isMobile,
              ),
              _buildTimeSeparator(themeProvider, isMobile),
              _buildTimeUnit(
                minutes.toString().padLeft(2, '0'),
                'Minutes',
                themeProvider,
                isMobile,
              ),
              _buildTimeSeparator(themeProvider, isMobile),
              _buildTimeUnit(
                seconds.toString().padLeft(2, '0'),
                'Seconds',
                themeProvider,
                isMobile,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(
    String value,
    String label,
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 8 : 12,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                themeProvider.primaryMain,
                themeProvider.primaryMain.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: themeProvider.primaryMain.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 11 : 12,
            color: themeProvider.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator(ThemeProvider themeProvider, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: isMobile ? 28 : 36,
          fontWeight: FontWeight.bold,
          color: themeProvider.primaryMain,
        ),
      ),
    );
  }

  Widget _buildStatusIndicators(ThemeProvider themeProvider, bool isMobile) {
    final indicators = [
      {
        'icon': Icons.cloud_done,
        'label': 'Database',
        'status': 'Updating',
      },
      {
        'icon': Icons.security,
        'label': 'Security',
        'status': 'Checking',
      },
      {
        'icon': Icons.speed,
        'label': 'Performance',
        'status': 'Optimizing',
      },
    ];

    return Container(
      constraints: BoxConstraints(maxWidth: isMobile ? 320 : 600),
      child: Wrap(
        spacing: isMobile ? 12 : 16,
        runSpacing: isMobile ? 12 : 16,
        alignment: WrapAlignment.center,
        children: indicators.map((indicator) {
          return Container(
            width: isMobile ? 95 : 110,
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: themeProvider.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeProvider.borderColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: themeProvider.infoMain.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    indicator['icon'] as IconData,
                    size: isMobile ? 20 : 24,
                    color: themeProvider.infoMain,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  indicator['label'] as String,
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  indicator['status'] as String,
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11,
                    color: themeProvider.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCheckStatusButton(ThemeProvider themeProvider, bool isMobile) {
    return ElevatedButton.icon(
      onPressed: widget.onCheckStatus,
      icon: const Icon(Icons.refresh, size: 20),
      label: const Text('Check Status'),
      style: ElevatedButton.styleFrom(
        backgroundColor: themeProvider.primaryMain,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 32 : 40,
          vertical: isMobile ? 16 : 18,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        shadowColor: themeProvider.primaryMain.withOpacity(0.3),
      ),
    );
  }

  Widget _buildContactInfo(ThemeProvider themeProvider, bool isMobile) {
    return Container(
      constraints: BoxConstraints(maxWidth: isMobile ? 280 : 400),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: themeProvider.infoMain.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeProvider.infoMain.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: isMobile ? 18 : 20,
            color: themeProvider.infoMain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'For urgent matters, please contact our support team',
              style: TextStyle(
                fontSize: isMobile ? 12 : 13,
                color: themeProvider.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
