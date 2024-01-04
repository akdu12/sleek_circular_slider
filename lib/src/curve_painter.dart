part of circular_slider;

class _CurvePainter extends CustomPainter {
  final double angle;
  final double secondAngle;
  final CircularSliderAppearance appearance;
  final double startAngle;
  final double angleRange;

  Offset? handler;
  Offset? center;
  late double radius;

  _CurvePainter({
    required this.appearance,
    this.angle = 30,
    required this.startAngle,
    required this.angleRange,
    required this.secondAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    radius = math.min(size.width / 2, size.height / 2) -
        appearance.progressBarWidth * 0.5;
    center = Offset(size.width / 2, size.height / 2);

    final progressBarRect = Rect.fromLTWH(0.0, 0.0, size.width, size.width);

    Paint trackPaint;
    if (appearance.trackColors != null) {
      final trackGradient = SweepGradient(
        startAngle: degreeToRadians(appearance.trackGradientStartAngle),
        endAngle: degreeToRadians(appearance.trackGradientStopAngle),
        tileMode: TileMode.mirror,
        colors: appearance.trackColors!,
      );
      trackPaint = Paint()
        ..shader = trackGradient.createShader(progressBarRect)
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = appearance.trackWidth;
    } else {
      trackPaint = Paint()
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = appearance.trackWidth
        ..color = appearance.trackColor;
    }
    drawCircularArc(
        angle: angle,
        canvas: canvas,
        size: size,
        paint: trackPaint,
        ignoreAngle: true,
        spinnerMode: appearance.spinnerMode);

    if (!appearance.hideShadow) {
      drawShadow(canvas: canvas, size: size);
    }

    final currentAngle = appearance.counterClockwise ? -angle : angle;
    final currentSecondAngle =
        appearance.counterClockwise ? -secondAngle : secondAngle;
    final dynamicGradient = appearance.dynamicGradient;
    final gradientRotationAngle = dynamicGradient
        ? appearance.counterClockwise
            ? startAngle + 10.0
            : startAngle - 10.0
        : 0.0;
    final GradientRotation rotation =
        GradientRotation(degreeToRadians(gradientRotationAngle));

    final gradientStartAngle = dynamicGradient
        ? appearance.counterClockwise
            ? 360.0 - currentAngle.abs()
            : 0.0
        : appearance.gradientStartAngle;
    final gradientEndAngle = dynamicGradient
        ? appearance.counterClockwise
            ? 360.0
            : currentAngle.abs()
        : appearance.gradientStopAngle;

    final secondGradientStartAngle = dynamicGradient
        ? appearance.counterClockwise
            ? 360.0 - currentSecondAngle.abs()
            : 0.0
        : appearance.gradientStartAngle;
    final secondGradientEndAngle = dynamicGradient
        ? appearance.counterClockwise
            ? 360.0
            : currentSecondAngle.abs()
        : appearance.gradientStopAngle;

    final colors = dynamicGradient && appearance.counterClockwise
        ? appearance.progressBarColors.reversed.toList()
        : appearance.progressBarColors;

    final secondColors = dynamicGradient && appearance.counterClockwise
        ? appearance.secondProgressBarColors.reversed.toList()
        : appearance.secondProgressBarColors;

    final progressBarGradient = kIsWeb
        ? LinearGradient(
            tileMode: TileMode.mirror,
            colors: colors,
          )
        : SweepGradient(
            transform: rotation,
            startAngle: degreeToRadians(gradientStartAngle),
            endAngle: degreeToRadians(gradientEndAngle),
            tileMode: TileMode.mirror,
            colors: colors,
          );

    final secondProgressBarGradient = kIsWeb
        ? LinearGradient(
            tileMode: TileMode.mirror,
            colors: secondColors,
          )
        : SweepGradient(
            transform: rotation,
            startAngle: degreeToRadians(secondGradientStartAngle),
            endAngle: degreeToRadians(secondGradientEndAngle),
            tileMode: TileMode.mirror,
            colors: secondColors,
          );

    final progressBarPaint = Paint()
      ..shader = progressBarGradient.createShader(progressBarRect)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = appearance.progressBarWidth;

    final secondProgressBarPaint = Paint()
      ..shader = secondProgressBarGradient.createShader(progressBarRect)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = appearance.progressBarWidth;

    drawCircularArc(
        angle: angle, canvas: canvas, size: size, paint: progressBarPaint);

    drawCircularArc(
        angle: secondAngle,
        canvas: canvas,
        size: size,
        paint: secondProgressBarPaint);

    var dotPaint = Paint()..color = appearance.dotColor;

    final handlerGradient = kIsWeb
        ? LinearGradient(
            tileMode: TileMode.mirror,
            colors: secondColors,
          )
        : SweepGradient(
            transform: rotation,
            startAngle: degreeToRadians(secondGradientStartAngle),
            endAngle: degreeToRadians(secondGradientEndAngle),
            tileMode: TileMode.mirror,
            colors: [colors.first, secondColors.first],
          );
    Offset handler = degreesToCoordinates(
        center!, -math.pi / 2 + startAngle + currentAngle + 1.5, radius);
    canvas.drawCircle(
        handler,
        appearance.handlerSize,
        dotPaint
          ..shader = handlerGradient.createShader(handler &
              Size(appearance.handlerSize * 2, appearance.handlerSize * 2)));
    canvas.drawCircle(
        handler,
        appearance.handlerSize - 5,
        dotPaint
          ..shader = null
          ..strokeWidth = 1.5
          ..color = Colors.white.withOpacity(0.65)
          ..style = PaintingStyle.stroke);
    canvas.drawCircle(
        handler,
        appearance.handlerSize - 10,
        dotPaint
          ..shader = null
          ..strokeWidth = 1.5
          ..color = Colors.white.withOpacity(0.65)
          ..style = PaintingStyle.stroke);
  }

  drawCircularArc(
      {required double angle,
      required Canvas canvas,
      required Size size,
      required Paint paint,
      bool ignoreAngle = false,
      bool spinnerMode = false}) {
    final double angleValue = ignoreAngle ? 0 : (angleRange - angle);
    final range = appearance.counterClockwise ? -angleRange : angleRange;
    final currentAngle = appearance.counterClockwise ? angleValue : -angleValue;
    canvas.drawArc(
        Rect.fromCircle(center: center!, radius: radius),
        degreeToRadians(spinnerMode ? 0 : startAngle),
        degreeToRadians(spinnerMode ? 360 : range + currentAngle),
        false,
        paint);
  }

  drawShadow({required Canvas canvas, required Size size}) {
    final shadowStep = appearance.shadowStep != null
        ? appearance.shadowStep!
        : math.max(
            1, (appearance.shadowWidth - appearance.progressBarWidth) ~/ 10);
    final maxOpacity = math.min(1.0, appearance.shadowMaxOpacity);
    final repetitions = math.max(1,
        ((appearance.shadowWidth - appearance.progressBarWidth) ~/ shadowStep));
    final opacityStep = maxOpacity / repetitions;
    final shadowPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int i = 1; i <= repetitions; i++) {
      shadowPaint.strokeWidth = appearance.progressBarWidth + i * shadowStep;
      shadowPaint.color = appearance.shadowColor
          .withOpacity(maxOpacity - (opacityStep * (i - 1)));
      drawCircularArc(
          angle: angle, canvas: canvas, size: size, paint: shadowPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
