import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// An interesting and practical switch component.
/// Supports setting tips, slider decorations, shadows, and good interaction.
// ignore: must_be_immutable
class FSwitch extends StatefulWidget {
  /// Whether it is open. The default value is false.
  bool open;

  /// This function will be called back when the switch state changes.
  ValueChanged<bool> onChanged;

  /// width. Default 59.23, in line with aesthetics
  double width;

  /// height. By default, it will be calculated according to [width], which is in line with aesthetics
  double height;

  /// Distance between slider and edge
  double offset;

  /// Prompt style of open state
  Widget openChild;

  /// Prompt style of closed state
  Widget closeChild;

  /// Prompt to edge distance
  double childOffset;

  /// Background color when off
  Color color;

  /// Background color when open
  Color openColor;

  /// Slider color
  Color sliderColor;

  /// Components in the slider。Beyond the range will be cropped。
  Widget sliderChild;

  /// it's usable or not
  bool enable;

  Color borderSliderColor;

  /// Set component shadow color
  Color shadowSliderColor;

  /// Set component shadow offset
  Offset shadowSliderOffset;

  /// Sets the standard deviation of the component's Gaussian convolution with the shadow shape.
  double shadowSliderBlur;

  /// Set component shadow color
  Color shadowCircleColor;

  /// Set component shadow offset
  Offset shadowCircleOffset;

  /// Sets the standard deviation of the component's Gaussian convolution with the shadow shape.
  double shadowCircleBlur;

  FSwitch({
    Key key,
    @required this.onChanged,
    this.open = false,
    this.width = 59.23,
    this.height,
    this.offset,
    this.childOffset,
    this.closeChild,
    this.openChild,
    this.color,
    this.openColor,
    this.sliderColor,
    this.sliderChild,
    this.enable = true,
    this.borderSliderColor,
    this.shadowSliderColor,
    this.shadowSliderOffset,
    this.shadowSliderBlur = 0.0,
    this.shadowCircleColor,
    this.shadowCircleOffset,
    this.shadowCircleBlur = 0,
  })  : assert(open != null && onChanged != null,
  "open and onChanged can't be None!"),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FSwitch();
  }
}

class _FSwitch extends State<FSwitch> {
  double fixOffset;
  bool draging = false;
  double dragDxW = 10.0;

  @override
  void initState() {
    super.initState();
    fixOffset = widget.open
        ? widget.width -
        (widget.offset ??
            2.0 / 36.0 * ((widget.height ?? widget.width * 0.608))) *
            2.0 -
        (widget.height ?? widget.width * 0.608) * (32.52 / 36.0)
        : 0;
  }

  @override
  void didUpdateWidget(FSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    fixOffset = widget.open
        ? widget.width -
        (widget.offset ??
            2.0 / 36.0 * ((widget.height ?? widget.width * 0.608))) *
            2.0 -
        (widget.height ?? widget.width * 0.608) * (32.52 / 36.0)
        : 0;
  }

  @override
  Widget build(BuildContext context) {
    double height = widget.height ?? widget.width * 0.608;
    double circleSize = (height * (32.52 / 36.0));
    widget.offset = widget.offset ?? 2.0 / 36.0 * height;
    double childOffset = widget.childOffset ?? height / 5.0;
    widget.color = widget.color ?? Color(0xffcccccc);
    widget.openColor = widget.openColor ?? Color(0xffffc900);

    List<Widget> children = [];

    /// background
    var showSliderShadow = widget.shadowSliderColor != null && widget.shadowSliderBlur != 0;
    var showCircleShadow = widget.shadowCircleColor != null && widget.shadowCircleBlur != 0;
    var background = AnimatedContainer(
      duration: Duration(milliseconds: 350),
      decoration: BoxDecoration(
        color: (widget.open ? widget.openColor : widget.color) ?? widget.color,
        border: Border.all(
          color: widget.borderSliderColor ?? Colors.black,
          width: 1,
        ),
        borderRadius: BorderRadius.all(Radius.circular(height / 2.0)),
        boxShadow: showSliderShadow
            ? [
          BoxShadow(
            color: widget.shadowSliderColor,
            offset: widget.shadowSliderOffset ?? Offset(0, 0),
            blurRadius: widget.shadowSliderBlur,
          )
        ]: null,
      ),
      child: Container(
        width: widget.width,
        height: height,
      ),
    );
    children.add(background);

    /// Prompt
    var showChild = widget.open ? widget.openChild : widget.closeChild;
    if (showChild != null) {
      showChild = Positioned(
        left: widget.open ? childOffset : null,
        right: widget.open ? null : childOffset,
        child: showChild,
      );
      children.add(showChild);
    }

    /// slider
    var slider = AnimatedContainer(
      margin: EdgeInsets.fromLTRB(widget.offset + fixOffset, 0, 0, 0),
      duration: Duration(milliseconds: 200),
      width: circleSize + (draging ? dragDxW : 0.0),
      child: Container(
        height: circleSize,
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.sliderColor ?? Color(0xffffffff),
          borderRadius: BorderRadius.all(Radius.circular(circleSize / 2.0)),
          boxShadow: showCircleShadow
              ? [
            BoxShadow(
              color: widget.shadowCircleColor,
              offset: widget.shadowCircleOffset ?? Offset(0, 0),
              blurRadius: widget.shadowCircleBlur,
            )
          ] : null,
        ),
        child: widget.sliderChild,
      ),
    );
    children.add(slider);

    /// When in an unavailable state, add a mask
    if (!widget.enable) {
      var disableMask = Opacity(
        opacity: 0.6,
        child: Container(
          width: widget.width,
          height: height,
          decoration: BoxDecoration(
              color: Color(0xfff1f1f1),
              borderRadius: BorderRadius.all(Radius.circular(height / 2.0))),
        ),
      );
      children.add(disableMask);
    }

    return GestureDetector(
      onTap: widget.enable ? _handleOnTap : null,
      onHorizontalDragEnd: widget.enable ? _handleOnHorizontalDragEnd : null,
      onHorizontalDragUpdate:
      widget.enable ? _handleOnHorizontalDragUpdate : null,
      onHorizontalDragCancel: widget.enable ? _handleDragCancel : null,
      onHorizontalDragStart: widget.enable ? _handleDragStart : null,
      child: Container(
        child: Stack(
          alignment: Alignment.centerLeft,
          children: children,
        ),
      ),
    );
  }

  void _handleOnTap() {
    setState(() {
      widget.open = !widget.open;
      double height = widget.height ?? widget.width * 0.608;
      double circleSize = (height * (32.52 / 36.0));
      if (widget.open) {
        fixOffset = widget.width - widget.offset - circleSize - widget.offset;
      } else {
        fixOffset = 0;
      }
      widget.onChanged(widget.open);
    });
  }

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      draging = true;
    });
  }

  void _handleOnHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      double height = widget.height ?? widget.width * 0.608;
      double circleSize = (height * (32.52 / 36.0));
      fixOffset = fixOffset + details.delta.dx;
      if (fixOffset < 0) {
        fixOffset = 0;
      } else if (fixOffset >
          widget.width -
              widget.offset -
              circleSize -
              (draging ? dragDxW : 0.0) -
              widget.offset) {
        fixOffset = widget.width -
            widget.offset -
            circleSize -
            (draging ? dragDxW : 0.0) -
            widget.offset;
      }
    });
  }

  void _handleOnHorizontalDragEnd(DragEndDetails details) {
    setState(() {
      draging = false;
      double height = widget.height ?? widget.width * 0.608;
      double circleSize = (height * (32.52 / 36.0));
      double center = (widget.width -
          widget.offset -
          circleSize -
          (draging ? dragDxW : 0.0) -
          widget.offset) /
          2;
      bool cacheValue = widget.open;
      if (fixOffset < center) {
        fixOffset = 0;
        widget.open = false;
      } else {
        fixOffset = center * 2;
        widget.open = true;
      }
      if (cacheValue != widget.open) {
        widget.onChanged(widget.open);
      }
    });
  }

  void _handleDragCancel() {
    setState(() {
      draging = false;
    });
  }
}
