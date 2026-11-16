enum SubsidyType { voucherPerHectare, inputPackPerPlot, efulfilmentEvoucher }

class CountryConfig {
  const CountryConfig({
    required this.countryCode,
    required this.countryName,
    required this.defaultLanguage,
    required this.currencyCode,
    required this.currencySymbol,
    required this.programmeName,
    required this.registryName,
    required this.subsidyType,
    required this.voucherValue,
    required this.coveredCategories,
    required this.hectareCap,
    required this.packName,
    required this.standardPlotSize,
    required this.includedInputs,
    required this.subsidisedInput,
    required this.redemptionNote,
    required this.priorityCrops,
    required this.seasons,
    required this.dataResidencyNote,
    required this.marketSource,
  });

  final String countryCode;
  final String countryName;
  final String defaultLanguage;
  final String currencyCode;
  final String currencySymbol;
  final String programmeName;
  final String registryName;
  final SubsidyType subsidyType;

  // For voucher_per_hectare
  final double voucherValue;
  final List<String> coveredCategories;
  final int hectareCap;

  // For input_pack_per_plot
  final String packName;
  final double standardPlotSize;
  final List<String> includedInputs;

  // For efulfilment_evoucher
  final String subsidisedInput;
  final String redemptionNote;

  final List<Map<String, String>>
  priorityCrops; // [{ 'crop': 'Maize', 'local': 'Mhudhi' }]
  final List<SeasonWindow> seasons;
  final String dataResidencyNote;
  final String marketSource;

  static const List<CountryConfig> configs = [
    CountryConfig(
      countryCode: 'BW',
      countryName: 'Botswana',
      defaultLanguage: 'Setswana',
      currencyCode: 'BWP',
      currencySymbol: 'P',
      programmeName: 'Lemang Dijo',
      registryName: 'Crop Management System',
      subsidyType: SubsidyType.voucherPerHectare,
      voucherValue: 4400.0,
      coveredCategories: ['tillage', 'pesticides'],
      hectareCap: 1,
      packName: '',
      standardPlotSize: 0,
      includedInputs: [],
      subsidisedInput: '',
      redemptionNote: '',
      priorityCrops: [
        {'crop': 'Sorghum', 'local': 'Mabele'},
        {'crop': 'Maize', 'local': 'Mmopo'},
        {'crop': 'Millet', 'local': 'Lebelebele'},
        {'crop': 'Cowpeas', 'local': 'Dinawa'},
      ],
      seasons: [
        SeasonWindow(
          name: 'Summer Season',
          startMonthDay: '11-01',
          endMonthDay: '03-31',
        ),
      ],
      dataResidencyNote: 'Data stored locally in Gaborone compliance center.',
      marketSource: 'BAMB',
    ),
    CountryConfig(
      countryCode: 'ZW',
      countryName: 'Zimbabwe',
      defaultLanguage: 'Shona',
      currencyCode: 'USD',
      currencySymbol: r'$',
      programmeName: 'Pfumvudza/Intwasa',
      registryName: 'FAO IDEA',
      subsidyType: SubsidyType.inputPackPerPlot,
      voucherValue: 0.0,
      coveredCategories: [],
      hectareCap: 0,
      packName: 'Standard Pfumvudza Pack',
      standardPlotSize: 0.06,
      includedInputs: [
        'Maize Seed (TO CONFIRM)',
        'Compound D Fertiliser (TO CONFIRM)',
        'Top Dressing (TO CONFIRM)',
      ],
      subsidisedInput: '',
      redemptionNote: '',
      priorityCrops: [
        {'crop': 'Maize', 'local': 'Chibage'},
        {'crop': 'Sorghum', 'local': 'Mapfunde'},
        {'crop': 'Pearl Millet', 'local': 'Mhunga'},
        {'crop': 'Groundnuts', 'local': 'Nzungu'},
      ],
      seasons: [
        SeasonWindow(
          name: 'Main Rainy Season',
          startMonthDay: '10-15',
          endMonthDay: '04-15',
        ),
      ],
      dataResidencyNote:
          'Data residency subject to FAO country compliance directives.',
      marketSource: 'GMB',
    ),
    CountryConfig(
      countryCode: 'KE',
      countryName: 'Kenya',
      defaultLanguage: 'Kiswahili',
      currencyCode: 'KES',
      currencySymbol: 'KSh',
      programmeName: 'KIAMIS Fertilizer Subsidy',
      registryName: 'KIAMIS',
      subsidyType: SubsidyType.efulfilmentEvoucher,
      voucherValue: 0.0,
      coveredCategories: [],
      hectareCap: 0,
      packName: '',
      standardPlotSize: 0,
      includedInputs: [],
      subsidisedInput: 'DAP/CAN Fertiliser (TO CONFIRM)',
      redemptionNote: 'Redeem evoucher code at registered KIAMIS agro-dealers.',
      priorityCrops: [
        {'crop': 'Maize', 'local': 'Mahindi'},
        {'crop': 'Beans', 'local': 'Maharagwe'},
        {'crop': 'Potatoes', 'local': 'Viazi'},
        {'crop': 'Cassava', 'local': 'Muhogo'},
      ],
      seasons: [
        SeasonWindow(
          name: 'Long Rains',
          startMonthDay: '03-01',
          endMonthDay: '06-30',
        ),
        SeasonWindow(
          name: 'Short Rains',
          startMonthDay: '10-01',
          endMonthDay: '12-31',
        ),
      ],
      dataResidencyNote: 'KIAMIS data registry compliance node in Nairobi.',
      marketSource: 'AMIS',
    ),
  ];

  static CountryConfig findByCountryName(String name) {
    return configs.firstWhere(
      (c) =>
          c.countryName.toLowerCase() == name.toLowerCase() ||
          c.countryCode.toLowerCase() == name.toLowerCase(),
      orElse: () => configs[1], // Fallback to Zimbabwe
    );
  }
}

class SeasonWindow {
  const SeasonWindow({
    required this.name,
    required this.startMonthDay,
    required this.endMonthDay,
  });

  final String name;
  final String startMonthDay; // MM-DD
  final String endMonthDay; // MM-DD
}
