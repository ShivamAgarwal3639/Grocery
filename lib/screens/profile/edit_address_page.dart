import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grocerry/firebase/tax_delivery_service.dart';
import 'package:grocerry/models/tax_delivery_model.dart';
import 'package:grocerry/models/user_model.dart';
import 'package:grocerry/notifier/address_provider.dart';
import 'package:provider/provider.dart';

class AddEditAddressPage extends StatefulWidget {
  final AddressModel? address;

  const AddEditAddressPage({super.key, this.address});

  @override
  State<AddEditAddressPage> createState() => _AddEditAddressPageState();
}

class _AddEditAddressPageState extends State<AddEditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _streetController;
  late TextEditingController _numberController;
  bool _isDefault = false;
  bool _isSaving = false;

  // Map related variables
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  LatLng? _storeLocation;
  double? _maxDeliveryDistance;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  bool _isOutOfBounds = false;

  String _city = '';
  String _state = '';
  String _country = '';
  String _postalCode = '';

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.address?.label ?? '');
    _streetController = TextEditingController(text: widget.address?.street ?? '');
    _numberController = TextEditingController(text: widget.address?.number ?? '');
    _isDefault = widget.address?.isDefault ?? false;
    _loadStoreLocation();
  }

  Future<void> _loadStoreLocation() async {
    try {
      TaxAndDeliveryService taxAndDeliveryService = TaxAndDeliveryService();
      TaxAndDeliveryModel? storeSettings =
      await taxAndDeliveryService.getTaxAndDelivery('default');

      if (storeSettings != null &&
          storeSettings.deliveryCordinate != null &&
          storeSettings.deliveryDistance != null) {
        setState(() {
          _storeLocation = LatLng(
            storeSettings.deliveryCordinate!['latitude']!,
            storeSettings.deliveryCordinate!['longitude']!,
          );
          _maxDeliveryDistance = storeSettings.deliveryDistance;
        });

        _updateStoreMarkerAndCircle();
        await _initializeLocation();
      } else {
        Get.snackbar(
          'Error',
          'Store location or delivery distance not set',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load store location',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _updateStoreMarkerAndCircle() {
    if (_storeLocation == null || _maxDeliveryDistance == null) return;

    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('store_location'),
          position: _storeLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Store Location'),
        ),
      );

      _circles.add(
        Circle(
          circleId: const CircleId('delivery_radius'),
          center: _storeLocation!,
          radius: _maxDeliveryDistance! * 1000,
          fillColor: Colors.blue.withOpacity(0.1),
          strokeColor: Colors.blue,
          strokeWidth: 1,
        ),
      );
    });
  }

  Future<void> _initializeLocation() async {
    if (widget.address != null && widget.address!.lat != 0) {
      _selectedLocation = LatLng(widget.address!.lat!, widget.address!.long!);
      _updateMarker(_selectedLocation!);
    } else {
      try {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          await Geolocator.requestPermission();
        }

        Position position = await Geolocator.getCurrentPosition();
        final userLocation = LatLng(position.latitude, position.longitude);

        if (!_isLocationWithinDeliveryRadius(userLocation)) {
          position = Position(
            latitude: _storeLocation?.latitude ?? 12.9716,
            longitude: _storeLocation?.longitude ?? 77.5946,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 1,
            headingAccuracy: 1,
          );
        }

        setState(() {
          _selectedLocation = LatLng(position.latitude, position.longitude);
          _updateMarker(_selectedLocation!);
        });
        _getAddressFromLatLng(_selectedLocation!);
      } catch (e) {
        _selectedLocation = _storeLocation ?? const LatLng(12.9716, 77.5946);
        _updateMarker(_selectedLocation!);
      }
    }
  }

  bool _isLocationWithinDeliveryRadius(LatLng position) {
    if (_storeLocation == null || _maxDeliveryDistance == null) return true;

    final distanceInMeters = Geolocator.distanceBetween(
      _storeLocation!.latitude,
      _storeLocation!.longitude,
      position.latitude,
      position.longitude,
    );

    return distanceInMeters <= (_maxDeliveryDistance! * 1000);
  }

  void _updateMarker(LatLng position) {
    final isWithinRadius = _isLocationWithinDeliveryRadius(position);
    final isValidLocation = isWithinRadius;

    setState(() {
      _isOutOfBounds = !isValidLocation;

      _markers.removeWhere(
            (marker) => marker.markerId.value == 'selected_location',
      );
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          draggable: true,
          onDragStart: (_) {
            setState(() => _isOutOfBounds = false);
          },
          onDragEnd: (newPosition) {
            final isValid = _isLocationWithinDeliveryRadius(newPosition);
            if (isValid) {
              _getAddressFromLatLng(newPosition);
              setState(() => _isOutOfBounds = false);
            } else {
              setState(() => _isOutOfBounds = true);
              Get.snackbar(
                'Invalid Location',
                'Please select a location within delivery radius',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          },
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isValidLocation ? BitmapDescriptor.hueRed : BitmapDescriptor.hueAzure,
          ),
        ),
      );
    });
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    if (!_isLocationWithinDeliveryRadius(position)) {
      setState(() {
        _isOutOfBounds = true;
        _city = '';
        _state = '';
        _country = '';
        _postalCode = '';
        _streetController.text = '';
      });
      return;
    }

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        setState(() {
          _city = place.locality ?? '';
          _state = place.administrativeArea ?? '';
          _country = place.country ?? '';
          _postalCode = place.postalCode ?? '';
          _selectedLocation = position;
          _isOutOfBounds = false;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get address details',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.address != null ? 'Edit Address' : 'Add New Address',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _storeLocation == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLocation ?? _storeLocation!,
                zoom: 17,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                controller.setMapStyle(_mapStyle);
              },
              markers: _markers,
              circles: _circles,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
              compassEnabled: true,
              onTap: (position) {
                _updateMarker(position);
                _getAddressFromLatLng(position);
              },
            ),
          ),
          if (_isOutOfBounds)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Please select a location within delivery radius',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputLabel('Label'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _labelController,
                        hintText: 'Home, Work, etc.',
                        prefixIcon: Icons.label_outlined,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter a label'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildInputLabel('Street Address'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _streetController,
                        hintText: 'Enter street address',
                        prefixIcon: Icons.location_on_outlined,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter street address'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildInputLabel('Phone Number'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _numberController,
                        hintText: 'Enter phone number',
                        prefixIcon: Icons.phone,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter phone number'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildDefaultAddressSwitch(),
                      const SizedBox(height: 12),
                      _buildSaveButton(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const String _mapStyle = '''
    [
      {
        "featureType": "poi",
        "elementType": "labels",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "featureType": "transit",
        "elementType": "labels",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      }
    ]
  ''';

  Widget _buildAddressDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('City: $_city'),
          const SizedBox(height: 4),
          Text('State: $_state'),
          const SizedBox(height: 4),
          Text('Country: $_country'),
          const SizedBox(height: 4),
          Text('Postal Code: $_postalCode'),
        ],
      ),
    );
  }

  Widget _buildDefaultAddressSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: SwitchListTile(
        title: const Text(
          'Set as default address',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        subtitle: Text(
          'This address will be selected by default',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        value: _isDefault,
        activeColor: Colors.green,
        onChanged: (value) => setState(() => _isDefault = value),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isOutOfBounds || _isSaving ? null : _saveAddress,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                widget.address != null ? 'Update Address' : 'Save Address',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_isOutOfBounds) {
        Get.snackbar(
          'Error',
          'Please select a location within Bangalore city limits',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      setState(() => _isSaving = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar(
          'Error',
          'You must be logged in to save addresses',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        setState(() => _isSaving = false);
        return;
      }

      try {
        final addressProvider =
            Provider.of<AddressProvider>(context, listen: false);
        final address = AddressModel(
          id: widget.address?.id ?? DateTime.now().toString(),
          label: _labelController.text.trim(),
          street: _streetController.text.trim(),
          number: _numberController.text.trim(),
          city: _city,
          state: _state,
          country: _country,
          postalCode: _postalCode,
          isDefault: _isDefault,
          lat: _selectedLocation?.latitude ?? 0,
          long: _selectedLocation?.longitude ?? 0,
        );

        if (widget.address != null) {
          await addressProvider.updateAddress(user.uid, address);
        } else {
          await addressProvider.addAddress(user.uid, address);
        }

        Get.back();
        Get.snackbar(
          'Success',
          widget.address != null
              ? 'Address updated successfully'
              : 'Address added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        // Get.snackbar(
        //   'Error',
        //   'Failed to save address: $e',
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Colors.red,
        //   colorText: Colors.white,
        // );
      } finally {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
        prefixIcon: Icon(prefixIcon, color: Colors.grey[600], size: 22),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[400]!),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
        ),
        errorStyle: TextStyle(color: Colors.red[400]),
      ),
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15),
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}
