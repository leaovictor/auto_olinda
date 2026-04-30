import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart' hide RouteData;
import 'package:url_launcher/url_launcher.dart';

import '../../booking/domain/booking.dart';
import '../domain/location_service.dart';
import '../domain/routes_service.dart';

class SmartMapScreen extends ConsumerStatefulWidget {
  final Booking booking;

  const SmartMapScreen({super.key, required this.booking});

  @override
  ConsumerState<SmartMapScreen> createState() => _SmartMapScreenState();
}

class _SmartMapScreenState extends ConsumerState<SmartMapScreen>
    with TickerProviderStateMixin {
  // Olinda coordinates (Placeholder)
  // TODO: Replace with actual CleanFlow coordinates from config
  final LatLng _shopLocation = const LatLng(-7.977104, -34.841492);

  late final AnimatedMapController _mapController;
  LatLng? _userLocation;
  RouteData? _currentRoute;
  bool _isLoadingRoute = false;
  Timer? _positionTimer;
  Timer? _etaTimer;

  @override
  void initState() {
    super.initState();
    _mapController = AnimatedMapController(vsync: this);

    // Start tracking location
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _etaTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    final locationService = ref.read(locationServiceProvider);

    // Initial position
    final position = await locationService.getCurrentLocation();
    if (position != null) {
      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
        });
        _fetchRoute();
        // Center map initially to fit both points
        _fitBounds();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível obter sua localização. Verifique as permissões do navegador.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }

    // Continuous tracking
    locationService.getPositionStream().listen((position) {
      if (!mounted) return;
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
      // Re-fetch route periodically or on significant movement?
      // For now, let's refresh route every minute if user is moving
    });

    // ETA Refresh timer (every 2 minutes)
    _etaTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      _fetchRoute();
    });
  }

  Future<void> _fetchRoute() async {
    if (_userLocation == null) return;

    setState(() => _isLoadingRoute = true);

    final routesService = ref.read(routesServiceProvider);
    final route = await routesService.getRoute(_userLocation!, _shopLocation);

    if (mounted) {
      setState(() {
        _currentRoute = route;
        _isLoadingRoute = false;
      });
    }
  }

  void _fitBounds() {
    if (_userLocation == null) return;

    // Calculate bounds
    final bounds = LatLngBounds.fromPoints([_userLocation!, _shopLocation]);
    // Add some padding
    _mapController.animatedFitCamera(
      cameraFit: CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  Future<void> _openGoogleMaps() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${_shopLocation.latitude},${_shopLocation.longitude}&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNightMode = theme.brightness == Brightness.dark;

    // Calculate ETA logic
    final now = DateTime.now();
    final scheduledTime = widget.booking.scheduledTime;
    final timeUntilAppointment = scheduledTime.difference(now);
    final travelTimeMinutes = _currentRoute?.durationMinutes ?? 0;

    // "Leave Now" logic: if travel time is within 15 mins of appointment time

    final bufferMinutes = timeUntilAppointment.inMinutes - travelTimeMinutes;

    bool showLeaveNowAlert = false;
    bool showLateAlert = false;
    String alertMessage = '';

    if (bufferMinutes < 0) {
      showLateAlert = true;
      alertMessage =
          'Você está atrasado! O sistema de No-Show pode ser ativado.';
    } else if (bufferMinutes <= 15) {
      showLeaveNowAlert = true;
      alertMessage = 'Saia agora para não perder seu horário!';
    } else {
      alertMessage =
          'Você tem ${bufferMinutes.toStringAsFixed(0)} min de folga.';
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController.mapController,
            options: MapOptions(initialCenter: _shopLocation, initialZoom: 13),
            children: [
              TileLayer(
                urlTemplate: isNightMode
                    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                    : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                // subdomains: const ['a', 'b', 'c', 'd'], // Removed as it might default or error if unexpected
              ),
              if (_currentRoute != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _currentRoute!.points,
                      strokeWidth: 4.0,
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
              // Markers Layer
              MarkerLayer(
                markers: [
                  // Shop Marker (Static)
                  Marker(
                    point: _shopLocation,
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.local_car_wash,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),
                ],
              ),
              // Animated Marker Layer for User
              if (_userLocation != null)
                AnimatedMarkerLayer(
                  markers: [
                    AnimatedMarker(
                      point: _userLocation!,
                      builder: (context, animation) {
                        final size = 40.0 * animation.value;
                        return Icon(
                          Icons.directions_car,
                          color: Colors.green,
                          size: size,
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),

          // Back Button and Refresh
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.canvasColor,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: theme.canvasColor,
                  child: IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: () {
                      _startLocationTracking();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tentando obter localização...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Alert Overlay (Top)
          if (showLeaveNowAlert || showLateAlert)
            Positioned(
              top: MediaQuery.of(context).padding.top + 70,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: showLateAlert ? Colors.red : Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      showLateAlert ? Icons.warning : Icons.timer,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        alertMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Floating Action Button to Request Location (Visible only if location is missing)
          if (_userLocation == null)
            Positioned(
              bottom: 150,
              right: 16,
              child: FloatingActionButton.extended(
                heroTag: 'enableLocationFab',
                onPressed: () {
                  _startLocationTracking();
                },
                label: const Text('Ativar GPS'),
                icon: const Icon(Icons.location_searching),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),

          // Bottom Info Card
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blueAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'R. Santa Teresinha, 440 - Jardim Atlântico',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tempo Estimado',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          Text(
                            _currentRoute != null
                                ? '${_currentRoute!.durationMinutes.toStringAsFixed(0)} min'
                                : '--',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Distância',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          Text(
                            _currentRoute != null
                                ? '${_currentRoute!.distanceKm.toStringAsFixed(1)} km'
                                : '--',
                            style: theme.textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openGoogleMaps,
                      icon: const Icon(Icons.map),
                      label: const Text('Abrir no Google Maps'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
