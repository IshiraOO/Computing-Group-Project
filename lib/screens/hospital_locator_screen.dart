import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/medical_facility.dart';
import '../services/data_service.dart';
import '../services/location_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/screen_header.dart';

class HospitalLocatorScreen extends StatefulWidget {
  const HospitalLocatorScreen({super.key});

  @override
  State<HospitalLocatorScreen> createState() => _HospitalLocatorScreenState();
}

class _HospitalLocatorScreenState extends State<HospitalLocatorScreen> {
  final DataService _dataService = DataService();
  GoogleMapController? _mapController;
  Position? _currentPosition;
  List<MedicalFacility> _facilities = [];
  bool _isLoading = true;
  bool _isMapLoading = true;
  String _selectedFacilityType = 'All';
  MedicalFacility? _selectedFacility;

  final List<String> _facilityTypes = [
    'All',
    'Hospital',
    'Clinic',
    'Pharmacy',
    'Emergency Room'
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _isMapLoading = true;
    });

    try {
      final position = await LocationService.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _isMapLoading = false;
      });
      _loadNearbyFacilities();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isMapLoading = false;
      });
      CustomSnackBar.show(
        context: context,
        message: 'Error getting location: $e',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _loadNearbyFacilities() async {
    if (_currentPosition == null) return;

    try {
      final facilities = await _dataService.getNearbyMedicalFacilities(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        radius: 10000, // 10km radius
      );

      if (!mounted) return;
      setState(() {
        _facilities = facilities;
        _isLoading = false;
      });

      if (_mapController != null && _facilities.isNotEmpty) {
        _updateCameraPosition();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      CustomSnackBar.show(
        context: context,
        message: 'Error loading facilities: $e',
        type: SnackBarType.error,
      );
    }
  }

  void _updateCameraPosition() {
    if (_currentPosition == null || _mapController == null) return;

    final bounds = _createBounds();
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  LatLngBounds _createBounds() {
    double minLat = _currentPosition!.latitude;
    double maxLat = _currentPosition!.latitude;
    double minLng = _currentPosition!.longitude;
    double maxLng = _currentPosition!.longitude;

    for (final facility in _filteredFacilities) {
      if (facility.latitude < minLat) minLat = facility.latitude;
      if (facility.latitude > maxLat) maxLat = facility.latitude;
      if (facility.longitude < minLng) minLng = facility.longitude;
      if (facility.longitude > maxLng) maxLng = facility.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat - 0.01, minLng - 0.01),
      northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
    );
  }

  List<MedicalFacility> get _filteredFacilities {
    if (_selectedFacilityType == 'All') {
      return _facilities;
    }
    return _facilities
        .where((facility) =>
            facility.facilityType.toLowerCase() ==
            _selectedFacilityType.toLowerCase())
        .toList();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null && _facilities.isNotEmpty) {
      _updateCameraPosition();
    }
  }

  void _selectFacility(MedicalFacility facility) {
    setState(() {
      _selectedFacility = facility;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(facility.latitude, facility.longitude),
        15,
      ),
    );
  }

  Future<void> _openDirections(MedicalFacility facility) async {
    if (_currentPosition == null) return;

    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=${facility.latitude},${facility.longitude}&travelmode=driving');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        message: 'Could not open directions',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _callFacility(MedicalFacility facility) async {
    if (facility.phoneNumber.isEmpty) {
      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        message: 'No phone number available',
        type: SnackBarType.warning,
      );
      return;
    }

    final url = Uri(scheme: 'tel', path: facility.phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        message: 'Could not make call',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _openWebsite(MedicalFacility facility) async {
    if (facility.website.isEmpty) {
      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        message: 'No website available',
        type: SnackBarType.warning,
      );
      return;
    }

    final url = Uri.parse(facility.website);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        message: 'Could not open website',
        type: SnackBarType.error,
      );
    }
  }

  void _panToCurrentLocation() {
    if (_currentPosition == null || _mapController == null) return;

    _mapController!.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      ),
    );
  }

  BitmapDescriptor _getMarkerIcon(String facilityType) {
    switch (facilityType.toLowerCase()) {
      case 'hospital':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'clinic':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'pharmacy':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case 'emergency room':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Hospital Locator',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingIndicator()
          : Column(
              children: [
                ScreenHeader(
                  title: 'Find Medical Facilities',
                  subtitle: 'Locate nearby healthcare centers',
                  icon: Icons.local_hospital,
                  cardTitle: 'Nearby Facilities',
                  cardSubtitle: 'Find hospitals, clinics, and pharmacies in your area',
                  cardIcon: Icons.location_on,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Facility Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _facilityTypes.map((type) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(
                                  type,
                                  style: TextStyle(
                                    color: _selectedFacilityType == type
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                                    fontWeight: _selectedFacilityType == type
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                selected: _selectedFacilityType == type,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedFacilityType = type;
                                    });
                                  }
                                },
                                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                selectedColor: theme.colorScheme.primary.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _isMapLoading
                      ? _buildMapLoadingIndicator()
                      : Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.shadow.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  children: [
                                    GoogleMap(
                                      onMapCreated: _onMapCreated,
                                      initialCameraPosition: CameraPosition(
                                        target: _currentPosition != null
                                            ? LatLng(_currentPosition!.latitude,
                                                _currentPosition!.longitude)
                                            : const LatLng(0, 0),
                                        zoom: 13,
                                      ),
                                      myLocationEnabled: true,
                                      myLocationButtonEnabled: false,
                                      markers: _filteredFacilities.map((facility) {
                                        return Marker(
                                          markerId: MarkerId(facility.id),
                                          position: LatLng(
                                              facility.latitude, facility.longitude),
                                          icon: _getMarkerIcon(facility.facilityType),
                                          onTap: () => _selectFacility(facility),
                                        );
                                      }).toSet(),
                                      mapToolbarEnabled: false,
                                      zoomControlsEnabled: false,
                                      compassEnabled: false,
                                      rotateGesturesEnabled: false,
                                      tiltGesturesEnabled: false,
                                      scrollGesturesEnabled: true,
                                      zoomGesturesEnabled: true,
                                      mapType: MapType.normal,
                                      style: theme.brightness == Brightness.dark
                                          ? '''[
                                            {
                                              "elementType": "geometry",
                                              "stylers": [{"color": "#242f3e"}]
                                            },
                                            {
                                              "elementType": "labels.text.stroke",
                                              "stylers": [{"color": "#242f3e"}]
                                            },
                                            {
                                              "elementType": "labels.text.fill",
                                              "stylers": [{"color": "#746855"}]
                                            },
                                            {
                                              "featureType": "administrative.locality",
                                              "elementType": "labels.text.fill",
                                              "stylers": [{"color": "#d59563"}]
                                            },
                                            {
                                              "featureType": "poi",
                                              "elementType": "labels.text.fill",
                                              "stylers": [{"color": "#d59563"}]
                                            },
                                            {
                                              "featureType": "poi.park",
                                              "elementType": "geometry",
                                              "stylers": [{"color": "#263c3f"}]
                                            },
                                            {
                                              "featureType": "poi.park",
                                              "elementType": "labels.text.fill",
                                              "stylers": [{"color": "#6b9a76"}]
                                            },
                                            {
                                              "featureType": "road",
                                              "elementType": "geometry",
                                              "stylers": [{"color": "#38414e"}]
                                            },
                                            {
                                              "featureType": "road",
                                              "elementType": "geometry.stroke",
                                              "stylers": [{"color": "#212a37"}]
                                            },
                                            {
                                              "featureType": "road",
                                              "elementType": "labels.text.fill",
                                              "stylers": [{"color": "#9ca5b3"}]
                                            },
                                            {
                                              "featureType": "road.highway",
                                              "elementType": "geometry",
                                              "stylers": [{"color": "#746855"}]
                                            },
                                            {
                                              "featureType": "road.highway",
                                              "elementType": "geometry.stroke",
                                              "stylers": [{"color": "#1f2835"}]
                                            },
                                            {
                                              "featureType": "road.highway",
                                              "elementType": "labels.text.fill",
                                              "stylers": [{"color": "#f3d19c"}]
                                            },
                                            {
                                              "featureType": "water",
                                              "elementType": "geometry",
                                              "stylers": [{"color": "#17263c"}]
                                            },
                                            {
                                              "featureType": "water",
                                              "elementType": "labels.text.fill",
                                              "stylers": [{"color": "#515c6d"}]
                                            },
                                            {
                                              "featureType": "water",
                                              "elementType": "labels.text.stroke",
                                              "stylers": [{"color": "#17263c"}]
                                            }
                                          ]'''
                                          : null,
                                    ),
                                    Positioned(
                                      right: 16,
                                      bottom: 16,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surface,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.colorScheme.shadow.withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(12),
                                            onTap: _panToCurrentLocation,
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Icon(
                                                Icons.my_location_rounded,
                                                color: theme.colorScheme.primary,
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_selectedFacility != null)
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: 1.0,
                                child: _buildFacilityDetails(),
                              ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildLoadingIndicator() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading facilities...',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapLoadingIndicator() {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildFacilityCard(MedicalFacility facility, bool isSelected) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isSelected
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.colorScheme.surface,
            isSelected
                ? theme.colorScheme.primary.withOpacity(0.05)
                : theme.colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.2)
              : theme.colorScheme.outlineVariant.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectFacility(facility),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getFacilityIcon(facility.facilityType),
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        facility.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.directions_walk,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(facility.distanceInMeters / 1000).toStringAsFixed(1)} km',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          facility.address,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: facility.isOpen24Hours
                            ? theme.colorScheme.tertiary.withOpacity(0.1)
                            : theme.colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: facility.isOpen24Hours
                              ? theme.colorScheme.tertiary.withOpacity(0.2)
                              : theme.colorScheme.error.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            facility.isOpen24Hours
                                ? Icons.access_time
                                : Icons.schedule,
                            size: 16,
                            color: facility.isOpen24Hours
                                ? theme.colorScheme.tertiary
                                : theme.colorScheme.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            facility.isOpen24Hours ? 'Open 24 Hours' : 'Check Hours',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: facility.isOpen24Hours
                                  ? theme.colorScheme.tertiary
                                  : theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.secondary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        facility.facilityType.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: Icons.directions,
                        label: 'Directions',
                        onPressed: () => _openDirections(facility),
                      ),
                      _buildActionButton(
                        icon: Icons.phone,
                        label: 'Call',
                        onPressed: () => _callFacility(facility),
                      ),
                      _buildActionButton(
                        icon: Icons.public,
                        label: 'Website',
                        onPressed: () => _openWebsite(facility),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFacilityIcon(String facilityType) {
    switch (facilityType.toLowerCase()) {
      case 'hospital':
        return Icons.local_hospital;
      case 'clinic':
        return Icons.medical_services;
      case 'pharmacy':
        return Icons.local_pharmacy;
      case 'emergency room':
        return Icons.emergency;
      default:
        return Icons.health_and_safety;
    }
  }

  Widget _buildFacilityDetails() {
    final theme = Theme.of(context);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.5),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _selectedFacility!.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      _buildFacilityCard(_selectedFacility!, true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: theme.colorScheme.onSurface,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedFacility = null;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}