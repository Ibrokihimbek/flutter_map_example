import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FlutterMapZoomButtons extends StatefulWidget {
  final double minZoom;
  final double maxZoom;
  final bool mini;
  final double padding;
  final Alignment alignment;
  final Color? zoomInColor;
  final Color? zoomInColorIcon;
  final Color? zoomOutColor;
  final Color? zoomOutColorIcon;
  final Color? userLocationColor;
  final IconData zoomInIcon;
  final IconData zoomOutIcon;
  final IconData userLocationIcon;
  final LatLng? userLocation;
  final MapController mapController;

  const FlutterMapZoomButtons({
    super.key,
    required this.mapController,
    this.minZoom = 1,
    this.maxZoom = 18,
    this.mini = true,
    this.padding = 2.0,
    this.alignment = Alignment.topRight,
    this.zoomInColor,
    this.zoomInColorIcon,
    this.zoomInIcon = Icons.zoom_in,
    this.zoomOutColor,
    this.zoomOutColorIcon,
    this.zoomOutIcon = Icons.zoom_out,
    this.userLocation,
    this.userLocationColor,
    this.userLocationIcon = Icons.my_location,
  });

  @override
  State<FlutterMapZoomButtons> createState() => _FlutterMapZoomButtonsState();
}

class _FlutterMapZoomButtonsState extends State<FlutterMapZoomButtons> with TickerProviderStateMixin {

  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final camera = widget.mapController.camera;
    final latTween = Tween<double>(
        begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);
    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    final Animation<double> animation =
    CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
    final startIdWithTarget =
        '$_startedId#${destLocation.latitude},${destLocation.longitude},$destZoom';
    bool hasTriggeredMove = false;

    controller.addListener(() {
      final String id;
      if (animation.value == 1.0) {
        id = _finishedId;
      } else if (!hasTriggeredMove) {
        id = startIdWithTarget;
      } else {
        id = _inProgressId;
      }

      hasTriggeredMove |= widget.mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
        id: id,
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: widget.alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding:
            EdgeInsets.only(left: widget.padding, top: widget.padding, right: widget.padding),
            child: FloatingActionButton(
              heroTag: 'zoomInButton',
              mini: widget.mini,
              backgroundColor: widget.zoomInColor ?? theme.primaryColor,
              onPressed: () {
                final zoom = min(widget.mapController.camera.zoom + 1, widget.maxZoom);
                _animatedMapMove(widget.mapController.camera.center, zoom);
              },
              child: Icon(widget.zoomInIcon,
                  color: widget.zoomInColorIcon ?? theme.iconTheme.color),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(widget.padding),
            child: FloatingActionButton(
              heroTag: 'zoomOutButton',
              mini: widget.mini,
              backgroundColor: widget.zoomOutColor ?? theme.primaryColor,
              onPressed: () {
                final zoom = max(widget.mapController.camera.zoom - 1, widget.minZoom);
                _animatedMapMove(widget.mapController.camera.center, zoom);
              },
              child: Icon(widget.zoomOutIcon,
                  color: widget.zoomOutColorIcon ?? theme.iconTheme.color),
            ),
          ),
          if(widget.userLocation != null)
            Padding(
              padding: EdgeInsets.all(widget.padding),
              child: FloatingActionButton(
                heroTag: 'userLocationButton',
                mini: widget.mini,
                backgroundColor: widget.userLocationColor ?? theme.primaryColor,
                onPressed: () {
                  _animatedMapMove(widget.userLocation!, 15);
                },
                child: Icon(widget.userLocationIcon,
                    color: widget.zoomOutColorIcon ?? theme.iconTheme.color),
              ),
            ),
        ],
      ),
    );
  }
}