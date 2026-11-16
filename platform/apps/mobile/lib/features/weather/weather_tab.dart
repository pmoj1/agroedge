import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agroedge_shared/models/farm-profile.dart';
import '../../core/app_services.dart';
import '../../core/design_system/app_card.dart';
import '../../core/design_system/app_states.dart';
import '../../core/services/weather_service.dart';
import '../../core/services/ai_service.dart';
import '../../core/theme.dart';

class WeatherTab extends StatefulWidget {
  const WeatherTab({super.key});

  @override
  State<WeatherTab> createState() => _WeatherTabState();
}

class _WeatherTabState extends State<WeatherTab> {
  late Future<List<dynamic>> _weatherDataFuture;
  bool isCelsius = true;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  void _loadWeatherData() {
    _weatherDataFuture = Future.wait([AppServices.instance.farmProfiles.list()]).then((
      results,
    ) async {
      final List<FarmProfile> profiles = results[0];
      final profile = profiles.isNotEmpty ? profiles.first : null;

      double lat = profile?.gpsLat ?? -17.8252;
      double lng = profile?.gpsLng ?? 31.0335;

      final weather = await WeatherService.instance.getWeather(lat, lng);

      final cropsList = [
        profile?.primaryCrop,
        profile?.secondaryCrop,
      ].whereType<String>().toList();

      final cropsStr = cropsList.isNotEmpty
          ? cropsList.join(', ')
          : 'general crops';
      final forecastSummary =
          'Today: ${weather.temperatureC}°C, ${weather.conditionLabel}. '
          'Upcoming precip: ${weather.daily.map((d) => "${d.date}: ${d.precipitationMm}mm").join(", ")}';

      final prompt =
          'Given a smallholder farm in ${profile?.region ?? "Harare"}, ${profile?.country ?? "Zimbabwe"} growing $cropsStr. '
          'The 7-day weather forecast is:\n$forecastSummary\n\n'
          'Provide 2-3 specific, actionable farming recommendations for this week. '
          'Keep it under 100 words, practical, and list-based.';

      final advice = await AIService.instance.complete(
        prompt,
        systemInstruction:
            'You are a senior agronomist giving short weekly advice to smallholders.',
      );

      return [weather, profile, advice];
    });
  }

  DateTime _getTimeInTimezone(String tz) {
    final nowUtc = DateTime.now().toUtc();
    int offsetHours = 0;
    if (tz.contains('Harare') ||
        tz.contains('Maputo') ||
        tz.contains('Lusaka') ||
        tz.contains('Gaborone')) {
      offsetHours = 2;
    } else if (tz.contains('Nairobi') ||
        tz.contains('Kampala') ||
        tz.contains('Dar_es_Salaam') ||
        tz.contains('Tanzania')) {
      offsetHours = 3;
    } else if (tz.contains('+')) {
      final match = RegExp(r'\+(\d+)').firstMatch(tz);
      if (match != null) {
        offsetHours = int.parse(match.group(1)!);
      }
    } else if (tz.contains('-')) {
      final match = RegExp(r'-(\d+)').firstMatch(tz);
      if (match != null) {
        offsetHours = -int.parse(match.group(1)!);
      }
    }
    return nowUtc.add(Duration(hours: offsetHours));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _weatherDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.forest700),
          );
        }

        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data![0] == null) {
          return Center(
            child: AppErrorState(
              title: 'Weather Forecast Unavailable',
              errorMessage:
                  'Could not retrieve dynamic weather forecast at this time.',
              onRetry: () => setState(() => _loadWeatherData()),
            ),
          );
        }

        final weather = snapshot.data![0] as WeatherData;
        final profile = snapshot.data![1] as FarmProfile?;
        final advice = snapshot.data![2] as String;
        final tzNow = _getTimeInTimezone(weather.timezone);
        final regionLabel = profile?.region ?? 'Harare';
        final countryLabel = profile?.country ?? 'Zimbabwe';

        final cropsList = [
          profile?.primaryCrop,
          profile?.secondaryCrop,
        ].whereType<String>().toList();

        final double calculatedEvt = weather.evapotranspiration;
        final double calculatedUv = weather.uvIndex;
        final String sunrise = weather.sunrise;
        final String sunset = weather.sunset;

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _loadWeatherData();
            });
          },
          color: AppColors.forest700,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              // Weather Tab Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weather Forecast',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontFamilyFallback: ['Liberation Serif', 'serif'],
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dynamic updates for $regionLabel, $countryLabel',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.ink500,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      isCelsius
                          ? Icons.thermostat_rounded
                          : Icons.opacity_rounded,
                      color: AppColors.forest700,
                    ),
                    onPressed: () => setState(() => isCelsius = !isCelsius),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // 1. Current Weather Card
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${isCelsius ? weather.temperatureC.round() : (weather.temperatureC * 9 / 5 + 32).round()}°${isCelsius ? "C" : "F"}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppColors.forest900,
                          ),
                        ),
                        Text(
                          weather.conditionLabel,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.opacity,
                              size: 14,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${weather.humidity}% humidity',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.ink500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.air,
                              size: 14,
                              color: AppColors.forest700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${weather.windSpeed} km/h',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.ink500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      weather.conditionEmoji,
                      style: const TextStyle(fontSize: 64),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 2. Hourly Forecast Strip
              const Text(
                'HOURLY FORECAST (TODAY)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink500,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    final hourStr =
                        '${(8 + index * 3) % 12 == 0 ? 12 : (8 + index * 3) % 12}:00 ${(8 + index * 3) >= 12 && (8 + index * 3) < 24 ? 'PM' : 'AM'}';
                    // Diurnal temperature curve modification
                    final hourDiff = index == 0
                        ? -2.0
                        : (index == 2 ? 3.0 : (index == 4 ? -1.0 : 0.0));
                    final tempC = weather.temperatureC + hourDiff;
                    final tempDisp = isCelsius
                        ? tempC.round()
                        : (tempC * 9 / 5 + 32).round();

                    final hourIcon = index == 5
                        ? Icons.nights_stay_rounded
                        : _weatherIcon(weather.weatherCode);
                    final hourIconColor = index == 5
                        ? Colors.indigo.shade300
                        : _weatherIconColor(weather.weatherCode);

                    return Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: AppSpacing.sm),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0x22FFFFFF)
                              : const Color(0xFFE5DDD0),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            hourStr,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.ink500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Icon(hourIcon, color: hourIconColor, size: 20),
                          const SizedBox(height: 4),
                          Text(
                            '$tempDisp°',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 3. Current Conditions Grid
              const Text(
                'DETAILS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink500,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                children: [
                  _buildConditionTile(
                    Icons.wb_sunny_rounded,
                    'UV Index',
                    '$calculatedUv / 10',
                  ),
                  _buildConditionTile(
                    Icons.air_rounded,
                    'Wind Direction',
                    weather.windDirection,
                  ),
                  _buildConditionTile(
                    Icons.water_drop_rounded,
                    'Evapotranspiration',
                    '${calculatedEvt.toStringAsFixed(1)} mm/d',
                  ),
                  _buildConditionTile(
                    Icons.device_thermostat_rounded,
                    'Apparent Temp',
                    '${isCelsius ? weather.apparentTemperatureC.round() : (weather.apparentTemperatureC * 9 / 5 + 32).round()}°',
                  ),
                  _buildConditionTile(
                    Icons.wb_twilight_rounded,
                    'Sunrise',
                    sunrise,
                  ),
                  _buildConditionTile(
                    Icons.nights_stay_rounded,
                    'Sunset',
                    sunset,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // 4. Rainfall Outlook Chart
              const Text(
                'RAINFALL OUTLOOK (COMING DAYS)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink500,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: weather.daily.asMap().entries.take(5).map((
                      entry,
                    ) {
                      final idx = entry.key;
                      final day = entry.value;
                      final dateParsed = tzNow.add(Duration(days: idx));
                      final dayLabel = DateFormat('E').format(dateParsed);
                      final rainMm = day.precipitationMm;

                      // Max precip to scale heights
                      final maxRain = weather.daily
                          .map((d) => d.precipitationMm)
                          .reduce((a, b) => a > b ? a : b);
                      final double normHeight = maxRain > 0
                          ? (rainMm / maxRain) * 60
                          : 0.0;

                      return Column(
                        children: [
                          Text(
                            '${rainMm.toStringAsFixed(1)}m',
                            style: const TextStyle(
                              fontSize: 8,
                              color: AppColors.ink500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 24,
                            height: math.max(normHeight, 4.0),
                            decoration: BoxDecoration(
                              color: rainMm > 0
                                  ? Colors.blue.shade300
                                  : const Color(0xFFF0EAE1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dayLabel,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 5. 5-Day Expandable Forecast
              const Text(
                '5-DAY DETAILED FORECAST',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink500,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...weather.daily.asMap().entries.skip(1).take(5).map((entry) {
                final index = entry.key;
                final day = entry.value;
                final dateParsed = tzNow.add(Duration(days: index));
                final dayLabel = DateFormat('EEEE').format(dateParsed);
                final dateLabel = DateFormat('d MMM yyyy').format(dateParsed);

                final forecastIcon = _weatherIcon(day.weatherCode);
                final forecastIconColor = _weatherIconColor(day.weatherCode);
                String label = 'Sunny';
                if (day.weatherCode > 0 && day.weatherCode <= 3) {
                  label = 'Partly Cloudy';
                } else if (day.weatherCode > 3 && day.weatherCode <= 9) {
                  label = 'Overcast';
                } else if (day.weatherCode > 9 && day.weatherCode <= 59) {
                  label = 'Drizzle';
                } else if (day.weatherCode > 59 && day.weatherCode <= 69) {
                  label = 'Rain';
                } else if (day.weatherCode > 69 && day.weatherCode <= 79) {
                  label = 'Snow';
                } else if (day.weatherCode > 79 && day.weatherCode <= 84) {
                  label = 'Showers';
                } else if (day.weatherCode > 84) {
                  label = 'Stormy';
                }

                final high = isCelsius
                    ? day.maxTempC.round()
                    : (day.maxTempC * 9 / 5 + 32).round();
                final low = isCelsius
                    ? day.minTempC.round()
                    : (day.minTempC * 9 / 5 + 32).round();

                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFF0EAE1)),
                  ),
                  color: Colors.white,
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dayLabel,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.ink900,
                              ),
                            ),
                            Text(
                              dateLabel,
                              style: const TextStyle(
                                color: AppColors.ink500,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              forecastIcon,
                              color: forecastIconColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.ink500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Text(
                      '$high° / $low°',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.ink900,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildExpandDetail(
                              Icons.water,
                              'Precipitation',
                              '${day.precipitationMm.toStringAsFixed(1)} mm',
                            ),
                            _buildExpandDetail(
                              Icons.wind_power,
                              'Avg Wind',
                              '${(weather.windSpeed * 0.9).toStringAsFixed(0)} km/h',
                            ),
                            _buildExpandDetail(
                              Icons.device_thermostat,
                              'Min/Max',
                              '$low°C / $high°C',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.lg),

              // 6. Dynamic Agronomic Advice Card
              const Text(
                'CROP-SPECIFIC WEATHER ADVISORY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink500,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF14261C)
                    : AppColors.forest100.withValues(alpha: 0.3),
                borderColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0x22FFFFFF)
                    : const Color(0xFFE5DDD0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.spa_rounded, color: AppColors.forest700),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cropsList.isNotEmpty
                                ? 'AI Advisory for ${cropsList.join(" & ")}'
                                : 'AI General Farming Advisory',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontFamilyFallback: const [
                                'Liberation Serif',
                                'serif',
                              ],
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFFFBF4E4)
                                  : AppColors.forest900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            advice,
                            style: TextStyle(
                              fontFamily: 'Calibri',
                              fontFamilyFallback: const [
                                'Liberation Sans',
                                'sans-serif',
                              ],
                              fontSize: 13,
                              height: 1.4,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFFA8B5AC)
                                  : AppColors.ink900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConditionTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0x22FFFFFF)
              : const Color(0xFFE5DDD0),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.forest700),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 9, color: AppColors.ink500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.forest700),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: AppColors.ink500),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.ink900,
          ),
        ),
      ],
    );
  }

  IconData _weatherIcon(int weatherCode) {
    if (weatherCode == 0) return Icons.wb_sunny_rounded;
    if (weatherCode <= 3) return Icons.cloud_queue_rounded;
    if (weatherCode <= 9) return Icons.cloud_rounded;
    if (weatherCode <= 19) return Icons.blur_on_rounded;
    if (weatherCode <= 49) return Icons.blur_on_rounded;
    if (weatherCode <= 69) return Icons.umbrella_rounded;
    if (weatherCode <= 79) return Icons.ac_unit_rounded;
    if (weatherCode <= 84) return Icons.grain_rounded;
    return Icons.thunderstorm_rounded;
  }

  Color _weatherIconColor(int weatherCode) {
    if (weatherCode == 0) return AppColors.gold500;
    if (weatherCode <= 3) return Colors.blueGrey.shade300;
    if (weatherCode <= 9) return Colors.blueGrey;
    if (weatherCode <= 19) return Colors.grey;
    if (weatherCode <= 49) return Colors.grey;
    if (weatherCode <= 69) return Colors.blue;
    if (weatherCode <= 79) return Colors.lightBlue.shade200;
    if (weatherCode <= 84) return Colors.blue.shade300;
    return Colors.deepPurple;
  }
}
