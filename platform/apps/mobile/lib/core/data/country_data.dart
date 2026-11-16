/// Pre-loaded data for countries, their regions, currencies and GPS coordinates.
/// Used in farm setup for country/region selection and weather lookups.
class CountryData {
  CountryData._();

  static const List<AgroCountry> countries = [
    AgroCountry(
      name: 'Zimbabwe',
      code: 'ZW',
      currency: 'USD',
      currencySymbol: r'$',
      regions: [
        AgroRegion('Harare', -17.8252, 31.0335),
        AgroRegion('Bulawayo', -20.1325, 28.6264),
        AgroRegion('Mashonaland Central', -17.0, 31.2),
        AgroRegion('Mashonaland East', -18.2, 32.0),
        AgroRegion('Mashonaland West', -17.5, 29.9),
        AgroRegion('Matabeleland North', -19.0, 27.5),
        AgroRegion('Matabeleland South', -21.0, 29.0),
        AgroRegion('Midlands', -19.5, 29.8),
        AgroRegion('Masvingo', -20.0, 30.8),
        AgroRegion('Manicaland', -19.0, 32.7),
      ],
    ),
    AgroCountry(
      name: 'Zambia',
      code: 'ZM',
      currency: 'ZMW',
      currencySymbol: 'K',
      regions: [
        AgroRegion('Lusaka', -15.4167, 28.2833),
        AgroRegion('Copperbelt', -12.8, 28.2),
        AgroRegion('Southern Province', -16.5, 26.9),
        AgroRegion('Eastern Province', -13.5, 32.5),
        AgroRegion('Northern Province', -10.0, 31.5),
        AgroRegion('Western Province', -15.5, 23.5),
        AgroRegion('Central Province', -14.5, 28.5),
        AgroRegion('Luapula Province', -11.0, 29.0),
        AgroRegion('North-Western Province', -13.0, 24.5),
        AgroRegion('Muchinga Province', -11.5, 32.0),
      ],
    ),
    AgroCountry(
      name: 'Kenya',
      code: 'KE',
      currency: 'KES',
      currencySymbol: 'KSh',
      regions: [
        AgroRegion('Nairobi', -1.2921, 36.8219),
        AgroRegion('Rift Valley', 0.5, 35.5),
        AgroRegion('Western', 0.4, 34.7),
        AgroRegion('Nyanza', -0.5, 34.5),
        AgroRegion('Coast', -4.0, 39.7),
        AgroRegion('Eastern', 0.5, 38.0),
        AgroRegion('Central', -0.5, 37.0),
        AgroRegion('North Eastern', 1.5, 40.0),
      ],
    ),
    AgroCountry(
      name: 'Tanzania',
      code: 'TZ',
      currency: 'TZS',
      currencySymbol: 'TSh',
      regions: [
        AgroRegion('Dar es Salaam', -6.7924, 39.2083),
        AgroRegion('Arusha', -3.3667, 36.6833),
        AgroRegion('Dodoma', -6.1722, 35.7395),
        AgroRegion('Kilimanjaro', -3.3, 37.3),
        AgroRegion('Mwanza', -2.5167, 32.9),
        AgroRegion('Morogoro', -6.8, 37.7),
        AgroRegion('Mbeya', -8.9, 33.5),
        AgroRegion('Tanga', -5.1, 39.1),
        AgroRegion('Iringa', -7.8, 35.7),
        AgroRegion('Kagera', -1.5, 31.5),
      ],
    ),
    AgroCountry(
      name: 'Mozambique',
      code: 'MZ',
      currency: 'MZN',
      currencySymbol: 'MT',
      regions: [
        AgroRegion('Maputo', -25.9653, 32.5892),
        AgroRegion('Sofala', -19.8437, 34.8389),
        AgroRegion('Manica', -19.1, 33.5),
        AgroRegion('Zambézia', -17.0, 36.5),
        AgroRegion('Nampula', -15.1, 39.3),
        AgroRegion('Gaza', -23.5, 33.0),
        AgroRegion('Inhambane', -23.9, 35.4),
        AgroRegion('Tete', -16.2, 33.6),
        AgroRegion('Niassa', -13.0, 35.5),
        AgroRegion('Cabo Delgado', -12.0, 39.0),
      ],
    ),
    AgroCountry(
      name: 'South Africa',
      code: 'ZA',
      currency: 'ZAR',
      currencySymbol: 'R',
      regions: [
        AgroRegion('Limpopo', -23.9045, 29.4685),
        AgroRegion('Mpumalanga', -25.5653, 30.5279),
        AgroRegion('KwaZulu-Natal', -29.0, 30.5),
        AgroRegion('North West', -26.7, 25.8),
        AgroRegion('Free State', -28.5, 26.2),
        AgroRegion('Northern Cape', -29.0, 23.0),
        AgroRegion('Eastern Cape', -32.0, 26.5),
        AgroRegion('Western Cape', -33.9, 18.4),
        AgroRegion('Gauteng', -26.2, 28.0),
      ],
    ),
    AgroCountry(
      name: 'Malawi',
      code: 'MW',
      currency: 'MWK',
      currencySymbol: 'MK',
      regions: [
        AgroRegion('Lilongwe', -13.9669, 33.7873),
        AgroRegion('Blantyre', -15.7861, 35.0058),
        AgroRegion('Mzuzu', -11.4658, 34.0207),
        AgroRegion('Zomba', -15.3833, 35.3167),
        AgroRegion('Northern Region', -11.0, 34.0),
        AgroRegion('Central Region', -13.5, 33.5),
        AgroRegion('Southern Region', -15.5, 35.0),
      ],
    ),
    AgroCountry(
      name: 'Uganda',
      code: 'UG',
      currency: 'UGX',
      currencySymbol: 'USh',
      regions: [
        AgroRegion('Kampala', 0.3476, 32.5825),
        AgroRegion('Gulu', 2.7667, 32.3),
        AgroRegion('Mbarara', -0.6, 30.7),
        AgroRegion('Jinja', 0.4244, 33.2042),
        AgroRegion('Central Region', 0.3, 32.5),
        AgroRegion('Eastern Region', 1.0, 34.0),
        AgroRegion('Northern Region', 2.5, 32.5),
        AgroRegion('Western Region', -0.5, 30.5),
      ],
    ),
    AgroCountry(
      name: 'Rwanda',
      code: 'RW',
      currency: 'RWF',
      currencySymbol: 'Fr',
      regions: [
        AgroRegion('Kigali', -1.9441, 30.0619),
        AgroRegion('Northern Province', -1.5, 30.0),
        AgroRegion('Southern Province', -2.5, 29.7),
        AgroRegion('Eastern Province', -1.8, 30.8),
        AgroRegion('Western Province', -2.0, 29.2),
      ],
    ),
  ];

  static AgroCountry? findByName(String name) {
    try {
      return countries.firstWhere((c) => c.name == name);
    } catch (_) {
      return null;
    }
  }
}

class AgroCountry {
  const AgroCountry({
    required this.name,
    required this.code,
    required this.currency,
    required this.currencySymbol,
    required this.regions,
  });

  final String name;
  final String code;
  final String currency;
  final String currencySymbol;
  final List<AgroRegion> regions;
}

class AgroRegion {
  const AgroRegion(this.name, this.lat, this.lng);

  final String name;
  final double lat;
  final double lng;
}

/// Pre-loaded common crops for African smallholder farmers.
const List<String> commonCrops = [
  'Maize',
  'Tobacco',
  'Cotton',
  'Wheat',
  'Soya Beans',
  'Groundnuts',
  'Sunflower',
  'Sorghum',
  'Millet',
  'Rice',
  'Barley',
  'Sugar Cane',
  'Tea',
  'Coffee',
  'Cassava',
  'Sweet Potato',
  'Irish Potato',
  'Tomato',
  'Onion',
  'Cabbage',
  'Beans',
  'Cowpeas',
  'Pigeon Peas',
  'Chickpeas',
  'Macadamia',
  'Avocado',
  'Mango',
  'Banana',
  'Papaya',
  'Citrus',
  'Watermelon',
  'Pumpkin',
  'Garlic',
  'Ginger',
  'Chilli',
  'Hibiscus',
  'Sesame',
  'Lentils',
];
