import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_example/feature/home/data/modles/get_company_logo.dart';
import 'package:flutter_map_example/feature/home/presentation/bloc/home_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../../mixin/location_mixin.dart';
import '../../../../widgets/custom_point.dart';
import '../../../../widgets/zoom_button.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with LocationMixin, TickerProviderStateMixin {
  final MapController mapController = MapController();
  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';

  List<Marker> allMarkers = [];
  LatLng userPosition = const LatLng(41.335810, 69.289293);

  @override
  void initState() {
    super.initState();
    determinePosition().then((value) {
      userPosition = value;
    });
  }

  void setMarkers(List<Results> companies) {
    for (var x = 0; x < companies.length; x++) {
      String image = companies[x].logo ?? '';
      allMarkers.add(
        Marker(
          width: 30,
          height: 30,
          point: LatLng(
            companies[x].latitude ?? 0,
            companies[x].longitude ?? 0,
          ),
          child: GestureDetector(
            onTap: () {
              _animatedMapMove(
                LatLng(
                  companies[x].latitude ?? 0,
                  companies[x].longitude ?? 0,
                ),
                15,
              );
              showModalBottomSheet(
                context: context,
                builder: (_) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  height: 300,
                  child: Center(
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: NetworkImage(
                        image,
                      ),
                    ),
                  ),
                ),
              );
            },
            child: CustomPoint(
              url: image,
              scale: 1.5,
            ),
          ),
        ),
      );
    }
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final camera = mapController.camera;
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

      hasTriggeredMove |= mapController.move(
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

  final _animatedMoveTileUpdateTransformer =
  TileUpdateTransformer.fromHandlers(handleData: (updateEvent, sink) {
    final mapEvent = updateEvent.mapEvent;

    final id = mapEvent is MapEventMove ? mapEvent.id : null;
    if (id?.startsWith(_HomePageState._startedId) ?? false) {
      final parts = id!.split('#')[2].split(',');
      final lat = double.parse(parts[0]);
      final lon = double.parse(parts[1]);
      final zoom = double.parse(parts[2]);

      // When animated movement starts load tiles at the target location and do
      // not prune. Disabling pruning means existing tiles will remain visible
      // whilst animating.
      sink.add(
        updateEvent.loadOnly(
          loadCenterOverride: LatLng(lat, lon),
          loadZoomOverride: zoom,
        ),
      );
    } else if (id == _HomePageState._inProgressId) {
      // Do not prune or load whilst animating so that any existing tiles remain
      // visible. A smarter implementation may start pruning once we are close to
      // the target zoom/location.
    } else if (id == _HomePageState._finishedId) {
      // We already prefetched the tiles when animation started so just prune.
      sink.add(updateEvent.pruneOnly());
    } else {
      sink.add(updateEvent);
    }
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state.getCompaniesStatus.isSuccess) {
            Future.delayed(const Duration(milliseconds: 50), () {
              _animatedMapMove(userPosition, 15);
            });
            setMarkers(state.companies);
          }
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return state.getCompaniesStatus.isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : Stack(
                    children: [
                      FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          initialCenter: const LatLng(41.335810, 69.289293),
                          initialZoom: 13,
                          cameraConstraint: CameraConstraint.contain(
                            bounds: LatLngBounds(
                              const LatLng(-90, -180),
                              const LatLng(90, 180),
                            ),
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=$mapToken',
                            userAgentPackageName:
                                'dev.fleaflet.flutter_map.example',
                            tileProvider: CancellableNetworkTileProvider(),
                            tileUpdateTransformer:
                                _animatedMoveTileUpdateTransformer,
                            additionalOptions: const {
                              'id': 'mapbox/outdoors-v12',
                            }),
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 40,
                                height: 40,
                                point: userPosition,
                                child: const Icon(
                                  size: 40,
                                  Icons.location_on,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          FlutterMapZoomButtons(
                            mapController: mapController,
                            alignment: Alignment.centerRight,
                            zoomInIcon: Icons.add,
                            zoomOutIcon: Icons.remove,
                            zoomInColor: Colors.white,
                            zoomOutColor: Colors.white,
                            userLocationColor: Colors.white,
                            userLocationIcon: Icons.my_location,
                            userLocation: userPosition,
                          ),
                        ],
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }
}

String mapToken =
      'pk.eyJ1IjoiaWRhdnJvbmJla292Nzc3NyIsImEiOiJjbHlmcTR5cmowMjR0MmtxeWMwNWgzbnhlIn0.tpmQpj1RdOYNm11-vithzA';