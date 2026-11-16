import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agroedge_shared/models/farm-profile.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/api_client.dart';
import '../../core/app_services.dart';
import '../../core/data/country_data.dart';
import '../../core/design_system/app_button.dart';
import '../../core/design_system/app_card.dart';
import '../../core/design_system/app_states.dart';
import '../../core/theme.dart';
import '../../core/services/locale_service.dart';
import '../../l10n/app_localizations.dart';
import '../../core/components/map_widget.dart';
import '../../core/services/location_service.dart';

/// One-time farm setup, shown after sign-in when the farmer has no
/// farm_profile yet. Includes country selectors, interactive Leaflet Map picker,
/// geocoding search, and multi-crop chip picker.
class FarmSetupScreen extends StatefulWidget {
  const FarmSetupScreen({required this.onSaved, super.key});

  final VoidCallback onSaved;

  @override
  State<FarmSetupScreen> createState() => _FarmSetupScreenState();
}

class _FarmSetupScreenState extends State<FarmSetupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _farmNameController = TextEditingController();
  final _farmSizeController = TextEditingController();
  final _cropSearchController = TextEditingController();
  final _currencyController = TextEditingController();
  final _searchLocationController = TextEditingController();

  AgroCountry? _selectedCountry;
  final List<String> _selectedCrops = [];
  List<String> _cropSuggestions = [];
  bool _showCropSuggestions = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _shouldShake = false;

  Locale _selectedLocale = const Locale('en');
  String _selectedTempUnit = 'Celsius';

  // Location details
  double _pickedLatitude = -17.82485; // Default to Harare
  double _pickedLongitude = 31.05303;
  String _placeName = 'Harare, Zimbabwe';
  String _district = 'Harare';
  String _timezone = 'Africa/Harare';
  bool _isLocating = false;
  List<Map<String, dynamic>> _geocodeResults = [];
  bool _showGeocodeSuggestions = false;

  late AnimationController _headerAnimCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _selectedLocale = LocaleService.instance.locale;
    _headerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFade = CurvedAnimation(
      parent: _headerAnimCtrl,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnimCtrl, curve: Curves.easeOut));
    _headerAnimCtrl.forward();

    // Default country selection
    _onCountryChanged(CountryData.countries[0]);
  }

  @override
  void dispose() {
    _headerAnimCtrl.dispose();
    _farmNameController.dispose();
    _farmSizeController.dispose();
    _cropSearchController.dispose();
    _currencyController.dispose();
    _searchLocationController.dispose();
    super.dispose();
  }

  void _onCountryChanged(AgroCountry? country) {
    setState(() {
      _selectedCountry = country;
      _currencyController.text = country != null
          ? '${country.currencySymbol}  (${country.currency})'
          : '';
      if (country != null && country.regions.isNotEmpty) {
        _pickedLatitude = country.regions.first.lat;
        _pickedLongitude = country.regions.first.lng;
        _placeName = '${country.regions.first.name}, ${country.name}';
        _district = country.regions.first.name;
        _timezone = 'Africa/Harare';
        _reverseGeocodeCoords(_pickedLatitude, _pickedLongitude);
      }
    });
  }

  Future<void> _reverseGeocodeCoords(double lat, double lng) async {
    final details = await LocationService.instance.reverseGeocode(lat, lng);
    if (details != null && mounted) {
      setState(() {
        _pickedLatitude = details.lat;
        _pickedLongitude = details.lng;
        _placeName = details.placeName;
        _district = details.district;
        _timezone = details.timezone;

        // Try matching country
        final matchingCountry = CountryData.countries.firstWhere(
          (c) => c.code.toLowerCase() == details.countryCode.toLowerCase(),
          orElse: () => CountryData.countries[0],
        );
        if (_selectedCountry?.code != matchingCountry.code) {
          _selectedCountry = matchingCountry;
          _currencyController.text =
              '${matchingCountry.currencySymbol}  (${matchingCountry.currency})';
        }
      });
    }
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<void> _useMyLocation() async {
    setState(() => _isLocating = true);
    try {
      final pos = await _getCurrentLocation();
      if (pos != null) {
        await _reverseGeocodeCoords(pos.latitude, pos.longitude);
      } else {
        setState(
          () => _errorMessage =
              'Could not fetch device location. Check permissions.',
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Location error: $e');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _onLocationSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _geocodeResults = [];
        _showGeocodeSuggestions = false;
      });
      return;
    }
    final results = await LocationService.instance.search(query);
    if (mounted) {
      setState(() {
        _geocodeResults = results;
        _showGeocodeSuggestions = results.isNotEmpty;
      });
    }
  }

  void _selectGeocodeResult(Map<String, dynamic> res) async {
    final lat = (res['latitude'] as num).toDouble();
    final lng = (res['longitude'] as num).toDouble();
    setState(() {
      _showGeocodeSuggestions = false;
      _geocodeResults = [];
      _searchLocationController.clear();
    });
    await _reverseGeocodeCoords(lat, lng);
  }

  void _onCropSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _cropSuggestions = [];
        _showCropSuggestions = false;
      });
      return;
    }
    final lower = query.toLowerCase();
    final suggestions = commonCrops
        .where(
          (c) => c.toLowerCase().contains(lower) && !_selectedCrops.contains(c),
        )
        .take(6)
        .toList();
    setState(() {
      _cropSuggestions = suggestions;
      _showCropSuggestions = suggestions.isNotEmpty;
    });
  }

  void _addCrop(String crop) {
    if (!_selectedCrops.contains(crop)) {
      setState(() {
        _selectedCrops.add(crop);
        _cropSearchController.clear();
        _cropSuggestions = [];
        _showCropSuggestions = false;
      });
    }
  }

  void _removeCrop(String crop) {
    setState(() => _selectedCrops.remove(crop));
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;

    if (_selectedCrops.isEmpty) {
      setState(() {
        _errorMessage = 'Please select at least one crop.';
        _shouldShake = true;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _shouldShake = false);
      });
      return;
    }

    if (!_formKey.currentState!.validate()) {
      setState(() => _shouldShake = true);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _shouldShake = false);
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('locale_code', _selectedLocale.languageCode);
      await prefs.setString('temperature_unit', _selectedTempUnit);
      await LocaleService.instance.setLocale(_selectedLocale);

      final prefPayload = jsonEncode({
        'language': _selectedLocale.languageCode,
        'temperatureUnit': _selectedTempUnit,
      });

      final locationObj = LocationDetails(
        lat: _pickedLatitude,
        lng: _pickedLongitude,
        placeName: _placeName,
        district: _district,
        region: _district,
        countryCode: _selectedCountry?.code ?? 'ZW',
        timezone: _timezone,
      );

      await AppServices.instance.farmProfiles.create(
        FarmProfileCreate(
          farmName: _farmNameController.text.trim(),
          farmSize: double.tryParse(_farmSizeController.text.trim()),
          farmType: prefPayload,
          primaryCrop: _selectedCrops.isNotEmpty ? _selectedCrops.first : null,
          secondaryCrop: _selectedCrops.length > 1 ? _selectedCrops[1] : null,
          region: locationObj.serialize(),
          country: _selectedCountry?.name ?? 'Zimbabwe',
          gpsLat: _pickedLatitude,
          gpsLng: _pickedLongitude,
        ),
      );
      widget.onSaved();
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
      _triggerErrorFeedback();
    } catch (_) {
      setState(() => _errorMessage = l10n.commonSomethingWentWrong);
      _triggerErrorFeedback();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _triggerErrorFeedback() {
    setState(() => _shouldShake = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _shouldShake = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF000000)
          : AppColors.cream100,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 220,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.forest900, AppColors.forest700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.xl,
                        AppSpacing.xl,
                        AppSpacing.lg,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.eco_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            l10n.farmSetupTitle,
                            style: textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            l10n.farmSetupIntro,
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.80),
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.xxl,
                        ),
                        child: AppValidationShake(
                          shouldShake: _shouldShake,
                          child: AppCard(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _SectionLabel(
                                    icon: Icons.business_outlined,
                                    label: l10n.farmSetupFarmNameLabel,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  TextFormField(
                                    controller: _farmNameController,
                                    decoration: const InputDecoration(
                                      hintText: 'e.g. Sunrise Farm',
                                    ),
                                    validator: (value) =>
                                        (value == null || value.trim().isEmpty)
                                        ? l10n.farmSetupRequiredField
                                        : null,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  const _Divider(),
                                  const SizedBox(height: AppSpacing.lg),

                                  _SectionLabel(
                                    icon: Icons.flag_outlined,
                                    label: 'Country',
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  _CountrySelector(
                                    selectedCountry: _selectedCountry,
                                    onChanged: _onCountryChanged,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  const _Divider(),
                                  const SizedBox(height: AppSpacing.lg),

                                  _SectionLabel(
                                    icon: Icons.location_on_outlined,
                                    label: 'Farm Location',
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _searchLocationController,
                                          onChanged: _onLocationSearchChanged,
                                          decoration: const InputDecoration(
                                            hintText:
                                                'Search place (e.g. Gaborone)…',
                                            prefixIcon: Icon(
                                              Icons.search_rounded,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      IconButton(
                                        onPressed: _isLocating
                                            ? null
                                            : _useMyLocation,
                                        icon: _isLocating
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color:
                                                          AppColors.forest700,
                                                    ),
                                              )
                                            : const Icon(
                                                Icons.my_location_rounded,
                                              ),
                                        color: AppColors.forest700,
                                      ),
                                    ],
                                  ),
                                  if (_showGeocodeSuggestions) ...[
                                    const SizedBox(height: AppSpacing.xs),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFFE5DDD0),
                                        ),
                                      ),
                                      child: Column(
                                        children: _geocodeResults.map((res) {
                                          return ListTile(
                                            title: Text(res['name'] ?? ''),
                                            subtitle: Text(
                                              '${res['admin1'] ?? ''}, ${res['country'] ?? ''}',
                                            ),
                                            onTap: () =>
                                                _selectGeocodeResult(res),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: AppSpacing.md),
                                  Container(
                                    height: 250,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.forest700.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: buildLeafletMapPicker(
                                      initialLat: _pickedLatitude,
                                      initialLng: _pickedLongitude,
                                      isDark:
                                          Theme.of(context).brightness ==
                                          Brightness.dark,
                                      onLocationSelected: (lat, lng) {
                                        _reverseGeocodeCoords(lat, lng);
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Container(
                                    padding: const EdgeInsets.all(
                                      AppSpacing.md,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.forest100.withValues(
                                        alpha: 0.3,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _placeName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.forest900,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Coords: ${_pickedLatitude.toStringAsFixed(5)}, ${_pickedLongitude.toStringAsFixed(5)}  |  Tz: $_timezone',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.ink500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  const _Divider(),
                                  const SizedBox(height: AppSpacing.lg),

                                  _SectionLabel(
                                    icon: Icons.grass_outlined,
                                    label: 'Crops grown',
                                    subtitle: 'Select all that apply',
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  _CropChipSelector(
                                    searchController: _cropSearchController,
                                    selectedCrops: _selectedCrops,
                                    suggestions: _cropSuggestions,
                                    showSuggestions: _showCropSuggestions,
                                    onSearchChanged: _onCropSearchChanged,
                                    onCropAdded: _addCrop,
                                    onCropRemoved: _removeCrop,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  const _Divider(),
                                  const SizedBox(height: AppSpacing.lg),

                                  _SectionLabel(
                                    icon: Icons.landscape_outlined,
                                    label: l10n.farmSetupFarmSizeLabel,
                                    subtitle: l10n.commonOptional,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  TextFormField(
                                    controller: _farmSizeController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: const InputDecoration(
                                      hintText: 'e.g. 5.0',
                                      suffixText: 'ha',
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return null;
                                      }
                                      return double.tryParse(value.trim()) ==
                                              null
                                          ? 'Please enter a valid number'
                                          : null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  const _Divider(),
                                  const SizedBox(height: AppSpacing.lg),

                                  _SectionLabel(
                                    icon: Icons.language_outlined,
                                    label: 'Preferred Language',
                                    subtitle: 'Lugha ya Programu',
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  DropdownButtonFormField<Locale>(
                                    // ignore: deprecated_member_use
                                    value: _selectedLocale,
                                    decoration: const InputDecoration(
                                      hintText: 'Select language',
                                    ),
                                    items: LocaleService.supportedLocales.map((
                                      lang,
                                    ) {
                                      return DropdownMenuItem<Locale>(
                                        value: lang.locale,
                                        child: Text(lang.displayName),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          _selectedLocale = val;
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.lg),

                                  _SectionLabel(
                                    icon: Icons.thermostat_outlined,
                                    label: 'Temperature Unit',
                                    subtitle: 'Celsius / Fahrenheit',
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ChoiceChip(
                                          label: const Text('Celsius (°C)'),
                                          selected:
                                              _selectedTempUnit == 'Celsius',
                                          selectedColor: AppColors.forest100,
                                          labelStyle: TextStyle(
                                            color:
                                                _selectedTempUnit == 'Celsius'
                                                ? AppColors.forest700
                                                : AppColors.ink900,
                                            fontWeight:
                                                _selectedTempUnit == 'Celsius'
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                          onSelected: (selected) {
                                            if (selected) {
                                              setState(() {
                                                _selectedTempUnit = 'Celsius';
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: ChoiceChip(
                                          label: const Text('Fahrenheit (°F)'),
                                          selected:
                                              _selectedTempUnit == 'Fahrenheit',
                                          selectedColor: AppColors.forest100,
                                          labelStyle: TextStyle(
                                            color:
                                                _selectedTempUnit ==
                                                    'Fahrenheit'
                                                ? AppColors.forest700
                                                : AppColors.ink900,
                                            fontWeight:
                                                _selectedTempUnit ==
                                                    'Fahrenheit'
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                          onSelected: (selected) {
                                            if (selected) {
                                              setState(() {
                                                _selectedTempUnit =
                                                    'Fahrenheit';
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                  if (_selectedCountry != null) ...[
                                    const SizedBox(height: AppSpacing.lg),
                                    const _Divider(),
                                    const SizedBox(height: AppSpacing.lg),
                                    _SectionLabel(
                                      icon: Icons.currency_exchange_outlined,
                                      label: 'Currency',
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    TextFormField(
                                      controller: _currencyController,
                                      readOnly: true,
                                      style: const TextStyle(
                                        color: AppColors.forest700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: AppColors.forest700
                                            .withValues(alpha: 0.06),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.forest700
                                                .withValues(alpha: 0.3),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: const BorderSide(
                                            color: AppColors.forest700,
                                            width: 2,
                                          ),
                                        ),
                                        suffixIcon: const Icon(
                                          Icons.lock_outline,
                                          size: 16,
                                          color: AppColors.ink500,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (_errorMessage != null) ...[
                                    const SizedBox(height: AppSpacing.md),
                                    Container(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.md,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.errorRed.withValues(
                                          alpha: 0.07,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColors.errorRed.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            size: 16,
                                            color: AppColors.errorRed,
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Expanded(
                                            child: Text(
                                              _errorMessage!,
                                              style: textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: AppColors.errorRed,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: AppSpacing.xl),
                                  AppButton(
                                    label: l10n.farmSetupSaveButton,
                                    onPressed: _isSubmitting ? null : _submit,
                                    isLoading: _isSubmitting,
                                    variant: AppButtonVariant.filled,
                                    icon: Icons.check_circle_outline_rounded,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label, this.subtitle});

  final IconData icon;
  final String label;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.forest700),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Calibri',
            fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.ink900,
            letterSpacing: 0.3,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            '· $subtitle',
            style: const TextStyle(
              fontFamily: 'Calibri',
              fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
              fontSize: 12,
              color: AppColors.ink500,
            ),
          ),
        ],
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: AppColors.ink200);
  }
}

class _CountrySelector extends StatelessWidget {
  const _CountrySelector({
    required this.selectedCountry,
    required this.onChanged,
  });

  final AgroCountry? selectedCountry;
  final ValueChanged<AgroCountry?> onChanged;

  Future<void> _showSheet(BuildContext context) async {
    final result = await showModalBottomSheet<AgroCountry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CountrySearchSheet(selected: selectedCountry),
    );
    if (result != null) onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = selectedCountry != null;
    return GestureDetector(
      onTap: () => _showSheet(context),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.cream100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasValue ? AppColors.forest700 : const Color(0xFFE5DDD0),
            width: hasValue ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.flag_outlined, size: 18, color: AppColors.ink500),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                hasValue ? selectedCountry!.name : 'Select country…',
                style: TextStyle(
                  fontFamily: 'Calibri',
                  fontFamilyFallback: const ['Liberation Sans', 'sans-serif'],
                  fontSize: 15,
                  color: hasValue ? AppColors.ink900 : AppColors.ink500,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.ink500,
            ),
          ],
        ),
      ),
    );
  }
}

class _CountrySearchSheet extends StatefulWidget {
  const _CountrySearchSheet({this.selected});
  final AgroCountry? selected;

  @override
  State<_CountrySearchSheet> createState() => _CountrySearchSheetState();
}

class _CountrySearchSheetState extends State<_CountrySearchSheet> {
  final _searchCtrl = TextEditingController();
  List<AgroCountry> _filtered = CountryData.countries;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    final lower = q.toLowerCase();
    setState(() {
      _filtered = CountryData.countries
          .where((c) => c.name.toLowerCase().contains(lower))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.92,
      minChildSize: 0.45,
      expand: false,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.ink200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearch,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search country…',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.ink500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5DDD0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5DDD0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.forest700,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.cream100,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) {
                    final country = _filtered[i];
                    final isSelected = widget.selected?.name == country.name;
                    return ListTile(
                      onTap: () => Navigator.pop(context, country),
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? AppColors.forest700
                            : AppColors.cream100,
                        radius: 18,
                        child: Text(
                          country.code,
                          style: TextStyle(
                            fontFamily: 'Calibri',
                            fontFamilyFallback: const [
                              'Liberation Sans',
                              'sans-serif',
                            ],
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : AppColors.ink500,
                          ),
                        ),
                      ),
                      title: Text(
                        country.name,
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontFamilyFallback: const [
                            'Liberation Serif',
                            'serif',
                          ],
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: isSelected
                              ? AppColors.forest700
                              : AppColors.ink900,
                        ),
                      ),
                      trailing: Text(
                        '${country.currencySymbol} ${country.currency}',
                        style: const TextStyle(
                          fontFamily: 'Calibri',
                          fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
                          fontSize: 12,
                          color: AppColors.ink500,
                        ),
                      ),
                      selected: isSelected,
                      selectedTileColor: AppColors.forest700.withValues(
                        alpha: 0.05,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CropChipSelector extends StatelessWidget {
  const _CropChipSelector({
    required this.searchController,
    required this.selectedCrops,
    required this.suggestions,
    required this.showSuggestions,
    required this.onSearchChanged,
    required this.onCropAdded,
    required this.onCropRemoved,
  });

  final TextEditingController searchController;
  final List<String> selectedCrops;
  final List<String> suggestions;
  final bool showSuggestions;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCropAdded;
  final ValueChanged<String> onCropRemoved;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedCrops.isNotEmpty) ...[
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: selectedCrops
                .map(
                  (crop) => AnimatedScale(
                    scale: 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: InputChip(
                      label: Text(
                        crop,
                        style: const TextStyle(
                          fontFamily: 'Calibri',
                          fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: AppColors.forest700,
                      deleteIconColor: Colors.white.withValues(alpha: 0.8),
                      side: const BorderSide(color: AppColors.forest700),
                      onDeleted: () => onCropRemoved(crop),
                      avatar: const Icon(
                        Icons.grass_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: selectedCrops.isEmpty
                ? 'Type to search crops (e.g. Maize)…'
                : 'Add another crop…',
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.ink500,
            ),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    color: AppColors.ink500,
                    onPressed: () {
                      searchController.clear();
                      onSearchChanged('');
                    },
                  )
                : null,
          ),
        ),
        if (showSuggestions) ...[
          const SizedBox(height: AppSpacing.xs),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5DDD0)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.forest900.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: suggestions.map((crop) {
                return InkWell(
                  onTap: () => onCropAdded(crop),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.grass_rounded,
                          size: 16,
                          color: AppColors.forest500,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          crop,
                          style: const TextStyle(
                            fontFamily: 'Calibri',
                            fontFamilyFallback: [
                              'Liberation Sans',
                              'sans-serif',
                            ],
                            fontSize: 14,
                            color: AppColors.ink900,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.add_circle_outline_rounded,
                          size: 16,
                          color: AppColors.forest500,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
