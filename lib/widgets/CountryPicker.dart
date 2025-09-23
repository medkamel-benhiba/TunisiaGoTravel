import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tunisiagotravel/theme/color.dart';

class Country {
  final String name;
  final String code;
  final String flag;

  Country({required this.name, required this.code, required this.flag});
}

class CountryPickerDialog extends StatefulWidget {
  final String? selectedCountry;
  final Function(Country) onCountrySelected;

  const CountryPickerDialog({
    Key? key,
    this.selectedCountry,
    required this.onCountrySelected,
  }) : super(key: key);

  @override
  State<CountryPickerDialog> createState() => _CountryPickerDialogState();
}

class _CountryPickerDialogState extends State<CountryPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Country> _allCountries = [];
  List<Country> _filteredCountries = [];
  int _currentPage = 0;
  final int _itemsPerPage = 20;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeCountries();
    _filterCountries();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeCountries() {
    _allCountries = [
      Country(name: 'Afghanistan', code: 'AF', flag: '🇦🇫'),
      Country(name: 'Albania', code: 'AL', flag: '🇦🇱'),
      Country(name: 'Algeria', code: 'DZ', flag: '🇩🇿'),
      Country(name: 'Andorra', code: 'AD', flag: '🇦🇩'),
      Country(name: 'Angola', code: 'AO', flag: '🇦🇴'),
      Country(name: 'Argentina', code: 'AR', flag: '🇦🇷'),
      Country(name: 'Armenia', code: 'AM', flag: '🇦🇲'),
      Country(name: 'Australia', code: 'AU', flag: '🇦🇺'),
      Country(name: 'Austria', code: 'AT', flag: '🇦🇹'),
      Country(name: 'Azerbaijan', code: 'AZ', flag: '🇦🇿'),
      Country(name: 'Bahrain', code: 'BH', flag: '🇧🇭'),
      Country(name: 'Bangladesh', code: 'BD', flag: '🇧🇩'),
      Country(name: 'Belarus', code: 'BY', flag: '🇧🇾'),
      Country(name: 'Belgium', code: 'BE', flag: '🇧🇪'),
      Country(name: 'Belize', code: 'BZ', flag: '🇧🇿'),
      Country(name: 'Benin', code: 'BJ', flag: '🇧🇯'),
      Country(name: 'Bhutan', code: 'BT', flag: '🇧🇹'),
      Country(name: 'Bolivia', code: 'BO', flag: '🇧🇴'),
      Country(name: 'Bosnia and Herzegovina', code: 'BA', flag: '🇧🇦'),
      Country(name: 'Botswana', code: 'BW', flag: '🇧🇼'),
      Country(name: 'Brazil', code: 'BR', flag: '🇧🇷'),
      Country(name: 'Brunei', code: 'BN', flag: '🇧🇳'),
      Country(name: 'Bulgaria', code: 'BG', flag: '🇧🇬'),
      Country(name: 'Burkina Faso', code: 'BF', flag: '🇧🇫'),
      Country(name: 'Burundi', code: 'BI', flag: '🇧🇮'),
      Country(name: 'Cambodia', code: 'KH', flag: '🇰🇭'),
      Country(name: 'Cameroon', code: 'CM', flag: '🇨🇲'),
      Country(name: 'Canada', code: 'CA', flag: '🇨🇦'),
      Country(name: 'Cape Verde', code: 'CV', flag: '🇨🇻'),
      Country(name: 'Central African Republic', code: 'CF', flag: '🇨🇫'),
      Country(name: 'Chad', code: 'TD', flag: '🇹🇩'),
      Country(name: 'Chile', code: 'CL', flag: '🇨🇱'),
      Country(name: 'China', code: 'CN', flag: '🇨🇳'),
      Country(name: 'Colombia', code: 'CO', flag: '🇨🇴'),
      Country(name: 'Comoros', code: 'KM', flag: '🇰🇲'),
      Country(name: 'Congo', code: 'CG', flag: '🇨🇬'),
      Country(name: 'Costa Rica', code: 'CR', flag: '🇨🇷'),
      Country(name: 'Croatia', code: 'HR', flag: '🇭🇷'),
      Country(name: 'Cuba', code: 'CU', flag: '🇨🇺'),
      Country(name: 'Cyprus', code: 'CY', flag: '🇨🇾'),
      Country(name: 'Czech Republic', code: 'CZ', flag: '🇨🇿'),
      Country(name: 'Denmark', code: 'DK', flag: '🇩🇰'),
      Country(name: 'Djibouti', code: 'DJ', flag: '🇩🇯'),
      Country(name: 'Dominican Republic', code: 'DO', flag: '🇩🇴'),
      Country(name: 'Ecuador', code: 'EC', flag: '🇪🇨'),
      Country(name: 'Egypt', code: 'EG', flag: '🇪🇬'),
      Country(name: 'El Salvador', code: 'SV', flag: '🇸🇻'),
      Country(name: 'Equatorial Guinea', code: 'GQ', flag: '🇬🇶'),
      Country(name: 'Eritrea', code: 'ER', flag: '🇪🇷'),
      Country(name: 'Estonia', code: 'EE', flag: '🇪🇪'),
      Country(name: 'Ethiopia', code: 'ET', flag: '🇪🇹'),
      Country(name: 'Fiji', code: 'FJ', flag: '🇫🇯'),
      Country(name: 'Finland', code: 'FI', flag: '🇫🇮'),
      Country(name: 'France', code: 'FR', flag: '🇫🇷'),
      Country(name: 'Gabon', code: 'GA', flag: '🇬🇦'),
      Country(name: 'Gambia', code: 'GM', flag: '🇬🇲'),
      Country(name: 'Georgia', code: 'GE', flag: '🇬🇪'),
      Country(name: 'Germany', code: 'DE', flag: '🇩🇪'),
      Country(name: 'Ghana', code: 'GH', flag: '🇬🇭'),
      Country(name: 'Greece', code: 'GR', flag: '🇬🇷'),
      Country(name: 'Guatemala', code: 'GT', flag: '🇬🇹'),
      Country(name: 'Guinea', code: 'GN', flag: '🇬🇳'),
      Country(name: 'Guinea-Bissau', code: 'GW', flag: '🇬🇼'),
      Country(name: 'Guyana', code: 'GY', flag: '🇬🇾'),
      Country(name: 'Haiti', code: 'HT', flag: '🇭🇹'),
      Country(name: 'Honduras', code: 'HN', flag: '🇭🇳'),
      Country(name: 'Hungary', code: 'HU', flag: '🇭🇺'),
      Country(name: 'Iceland', code: 'IS', flag: '🇮🇸'),
      Country(name: 'India', code: 'IN', flag: '🇮🇳'),
      Country(name: 'Indonesia', code: 'ID', flag: '🇮🇩'),
      Country(name: 'Iran', code: 'IR', flag: '🇮🇷'),
      Country(name: 'Iraq', code: 'IQ', flag: '🇮🇶'),
      Country(name: 'Ireland', code: 'IE', flag: '🇮🇪'),
      Country(name: 'Italy', code: 'IT', flag: '🇮🇹'),
      Country(name: 'Jamaica', code: 'JM', flag: '🇯🇲'),
      Country(name: 'Japan', code: 'JP', flag: '🇯🇵'),
      Country(name: 'Jordan', code: 'JO', flag: '🇯🇴'),
      Country(name: 'Kazakhstan', code: 'KZ', flag: '🇰🇿'),
      Country(name: 'Kenya', code: 'KE', flag: '🇰🇪'),
      Country(name: 'Kuwait', code: 'KW', flag: '🇰🇼'),
      Country(name: 'Kyrgyzstan', code: 'KG', flag: '🇰🇬'),
      Country(name: 'Laos', code: 'LA', flag: '🇱🇦'),
      Country(name: 'Latvia', code: 'LV', flag: '🇱🇻'),
      Country(name: 'Lebanon', code: 'LB', flag: '🇱🇧'),
      Country(name: 'Lesotho', code: 'LS', flag: '🇱🇸'),
      Country(name: 'Liberia', code: 'LR', flag: '🇱🇷'),
      Country(name: 'Libya', code: 'LY', flag: '🇱🇾'),
      Country(name: 'Lithuania', code: 'LT', flag: '🇱🇹'),
      Country(name: 'Luxembourg', code: 'LU', flag: '🇱🇺'),
      Country(name: 'Madagascar', code: 'MG', flag: '🇲🇬'),
      Country(name: 'Malawi', code: 'MW', flag: '🇲🇼'),
      Country(name: 'Malaysia', code: 'MY', flag: '🇲🇾'),
      Country(name: 'Maldives', code: 'MV', flag: '🇲🇻'),
      Country(name: 'Mali', code: 'ML', flag: '🇲🇱'),
      Country(name: 'Malta', code: 'MT', flag: '🇲🇹'),
      Country(name: 'Mauritania', code: 'MR', flag: '🇲🇷'),
      Country(name: 'Mauritius', code: 'MU', flag: '🇲🇺'),
      Country(name: 'Mexico', code: 'MX', flag: '🇲🇽'),
      Country(name: 'Moldova', code: 'MD', flag: '🇲🇩'),
      Country(name: 'Monaco', code: 'MC', flag: '🇲🇨'),
      Country(name: 'Mongolia', code: 'MN', flag: '🇲🇳'),
      Country(name: 'Montenegro', code: 'ME', flag: '🇲🇪'),
      Country(name: 'Morocco', code: 'MA', flag: '🇲🇦'),
      Country(name: 'Mozambique', code: 'MZ', flag: '🇲🇿'),
      Country(name: 'Myanmar', code: 'MM', flag: '🇲🇲'),
      Country(name: 'Namibia', code: 'NA', flag: '🇳🇦'),
      Country(name: 'Nepal', code: 'NP', flag: '🇳🇵'),
      Country(name: 'Netherlands', code: 'NL', flag: '🇳🇱'),
      Country(name: 'New Zealand', code: 'NZ', flag: '🇳🇿'),
      Country(name: 'Nicaragua', code: 'NI', flag: '🇳🇮'),
      Country(name: 'Niger', code: 'NE', flag: '🇳🇪'),
      Country(name: 'Nigeria', code: 'NG', flag: '🇳🇬'),
      Country(name: 'North Korea', code: 'KP', flag: '🇰🇵'),
      Country(name: 'North Macedonia', code: 'MK', flag: '🇲🇰'),
      Country(name: 'Norway', code: 'NO', flag: '🇳🇴'),
      Country(name: 'Oman', code: 'OM', flag: '🇴🇲'),
      Country(name: 'Pakistan', code: 'PK', flag: '🇵🇰'),
      Country(name: 'Panama', code: 'PA', flag: '🇵🇦'),
      Country(name: 'Palestine', code: 'PS', flag: '🇵🇸'),
      Country(name: 'Papua New Guinea', code: 'PG', flag: '🇵🇬'),
      Country(name: 'Paraguay', code: 'PY', flag: '🇵🇾'),
      Country(name: 'Peru', code: 'PE', flag: '🇵🇪'),
      Country(name: 'Philippines', code: 'PH', flag: '🇵🇭'),
      Country(name: 'Poland', code: 'PL', flag: '🇵🇱'),
      Country(name: 'Portugal', code: 'PT', flag: '🇵🇹'),
      Country(name: 'Qatar', code: 'QA', flag: '🇶🇦'),
      Country(name: 'Romania', code: 'RO', flag: '🇷🇴'),
      Country(name: 'Russia', code: 'RU', flag: '🇷🇺'),
      Country(name: 'Rwanda', code: 'RW', flag: '🇷🇼'),
      Country(name: 'Saudi Arabia', code: 'SA', flag: '🇸🇦'),
      Country(name: 'Senegal', code: 'SN', flag: '🇸🇳'),
      Country(name: 'Serbia', code: 'RS', flag: '🇷🇸'),
      Country(name: 'Singapore', code: 'SG', flag: '🇸🇬'),
      Country(name: 'Slovakia', code: 'SK', flag: '🇸🇰'),
      Country(name: 'Slovenia', code: 'SI', flag: '🇸🇮'),
      Country(name: 'Somalia', code: 'SO', flag: '🇸🇴'),
      Country(name: 'South Africa', code: 'ZA', flag: '🇿🇦'),
      Country(name: 'South Korea', code: 'KR', flag: '🇰🇷'),
      Country(name: 'South Sudan', code: 'SS', flag: '🇸🇸'),
      Country(name: 'Spain', code: 'ES', flag: '🇪🇸'),
      Country(name: 'Sri Lanka', code: 'LK', flag: '🇱🇰'),
      Country(name: 'Sudan', code: 'SD', flag: '🇸🇩'),
      Country(name: 'Sweden', code: 'SE', flag: '🇸🇪'),
      Country(name: 'Switzerland', code: 'CH', flag: '🇨🇭'),
      Country(name: 'Syria', code: 'SY', flag: '🇸🇾'),
      Country(name: 'Taiwan', code: 'TW', flag: '🇹🇼'),
      Country(name: 'Tajikistan', code: 'TJ', flag: '🇹🇯'),
      Country(name: 'Tanzania', code: 'TZ', flag: '🇹🇿'),
      Country(name: 'Thailand', code: 'TH', flag: '🇹🇭'),
      Country(name: 'Togo', code: 'TG', flag: '🇹🇬'),
      Country(name: 'Tunisia', code: 'TN', flag: '🇹🇳'),
      Country(name: 'Turkey', code: 'TR', flag: '🇹🇷'),
      Country(name: 'Turkmenistan', code: 'TM', flag: '🇹🇲'),
      Country(name: 'Uganda', code: 'UG', flag: '🇺🇬'),
      Country(name: 'Ukraine', code: 'UA', flag: '🇺🇦'),
      Country(name: 'United Arab Emirates', code: 'AE', flag: '🇦🇪'),
      Country(name: 'United Kingdom', code: 'GB', flag: '🇬🇧'),
      Country(name: 'United States', code: 'US', flag: '🇺🇸'),
      Country(name: 'Uruguay', code: 'UY', flag: '🇺🇾'),
      Country(name: 'Uzbekistan', code: 'UZ', flag: '🇺🇿'),
      Country(name: 'Venezuela', code: 'VE', flag: '🇻🇪'),
      Country(name: 'Vietnam', code: 'VN', flag: '🇻🇳'),
      Country(name: 'Yemen', code: 'YE', flag: '🇾🇪'),
      Country(name: 'Zambia', code: 'ZM', flag: '🇿🇲'),
      Country(name: 'Zimbabwe', code: 'ZW', flag: '🇿🇼'),
    ];
  }

  void _onSearchChanged() {
    setState(() {
      _currentPage = 0;
      _filterCountries();
    });
  }

  void _filterCountries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = List.from(_allCountries);
      } else {
        _filteredCountries = _allCountries
            .where((country) =>
        country.name.toLowerCase().contains(query) ||
            country.code.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  List<Country> _getCurrentPageCountries() {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, _filteredCountries.length);
    return _filteredCountries.sublist(startIndex, endIndex);
  }

  int _getTotalPages() {
    return (_filteredCountries.length / _itemsPerPage).ceil();
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPageCountries = _getCurrentPageCountries();
    final totalPages = _getTotalPages();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'country'.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'search_country'.tr(),
                prefixIcon: Icon(Icons.search, color: AppColorstatic.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColorstatic.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColorstatic.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColorstatic.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Results info
            Text(
              'showing_results'.tr(
                namedArgs: {'count': _filteredCountries.length.toString()},
              ),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),

            // Countries List
            Expanded(
              child: _filteredCountries.isEmpty
                  ? Center(
                child: Text(
                  'no_countries_found'.tr(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              )
                  : ListView.builder(
                controller: _scrollController,
                itemCount: currentPageCountries.length,
                itemBuilder: (context, index) {
                  final country = currentPageCountries[index];
                  final isSelected = widget.selectedCountry == country.name;

                  return ListTile(
                    leading: Text(
                      country.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      country.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      country.code,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    )
                        : null,
                    onTap: () {
                      widget.onCountrySelected(country);
                    },
                    tileColor: isSelected
                        ? Colors.blue.withOpacity(0.1)
                        : null,
                  );
                },
              ),
            ),

            // Pagination Controls
            if (totalPages > 1) ...[
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _currentPage > 0
                        ? () => _goToPage(_currentPage - 1)
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < totalPages; i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: GestureDetector(
                                onTap: () => _goToPage(i),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: i == _currentPage
                                        ? AppColorstatic.primary
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    (i + 1).toString(),
                                    style: TextStyle(
                                      color: i == _currentPage
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _currentPage < totalPages - 1
                        ? () => _goToPage(_currentPage + 1)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'page_info'.tr(
                  namedArgs: {
                    'current': (_currentPage + 1).toString(),
                    'total': totalPages.toString(),
                  },
                ),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<Country?> showCountryPicker({
  required BuildContext context,
  String? selectedCountry,
}) async {
  final result = await showDialog<Country>(
    context: context,
    builder: (BuildContext dialogContext) => CountryPickerDialog(
      selectedCountry: selectedCountry,
      onCountrySelected: (country) {
        Navigator.of(dialogContext).pop(country);
      },
    ),
  );
  return result;
}