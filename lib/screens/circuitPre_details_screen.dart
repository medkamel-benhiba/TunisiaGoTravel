import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../models/voyage.dart';
import '../../providers/voyage_provider.dart';
import '../theme/color.dart';
import '../widgets/circuits/circuit_infoCard.dart';
import '../widgets/circuits/program_item.dart';
import '../widgets/cultures/DescriptionCard.dart';
import '../widgets/gallery.dart';

class CircuitPreDetailsScreen extends StatefulWidget {
  final String voyageId;

  const CircuitPreDetailsScreen({super.key, required this.voyageId});

  @override
  State<CircuitPreDetailsScreen> createState() =>
      _CircuitPreDetailsScreenState();
}

class _CircuitPreDetailsScreenState extends State<CircuitPreDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<VoyageProvider>(context, listen: false);
      provider.getVoyageById(widget.voyageId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);

    return Consumer<VoyageProvider>(
      builder: (context, provider, child) {
        final voyage = provider.selectedVoyage;

        if (voyage == null) {
          return Scaffold(
            appBar: AppBar(
              titleSpacing: 0,
              title: Text(
                tr("voyage.details"), // 🔑 translation key
                style: const TextStyle(
                  color: AppColorstatic.lightTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: AppColorstatic.primary,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  provider.error ??
                      tr("voyage.no_info"), // 🔑 translation key
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Text(
              voyage.getName(locale), // ✅ multilingual name
              style: const TextStyle(
                color: AppColorstatic.lightTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColorstatic.primary,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (voyage.images.isNotEmpty)
                  ImageGridPreview(images: voyage.images),
                if (voyage.getDescription(locale).isNotEmpty)
                  DescriptionCard(description: voyage.getDescription(locale)),
                if (voyage.getPrograme(locale).isNotEmpty)
                  _buildProgrammeSection(
                      voyage, locale), // ✅ localized programme
                _buildPriceContact(voyage),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorstatic.primary,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      tr("voyage.book_now"), // 🔑 translation key
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgrammeSection(Voyage voyage, Locale locale) {
    List<Program> programs;

    switch (locale.languageCode) {
      case 'ar':
        programs = voyage.programe_ar;
        break;
      case 'en':
        programs = voyage.programe_en;
        break;
      case 'ru':
        programs = voyage.programe_ru;
        break;
      case 'zh':
        programs = voyage.programe_zh;
        break;
      case 'ko':
        programs = voyage.programe_ko;
        break;
      case 'ja':
        programs = voyage.programe_ja;
        break;
      default:
        programs = voyage.programe;
    }

    return CircuitInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr("voyage.program"), // 🔑 translation key
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...programs.map((p) => ProgrammeItem(
            title: p.title,
            description: p.description,
          )),
        ],
      ),
    );
  }

  Widget _buildPriceContact(Voyage voyage) {
    return CircuitInfoCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoPill(
            icon: Icons.attach_money,
            label: tr("voyage.price"), // 🔑 translation key
            value: '\$${voyage.price.isNotEmpty ? voyage.price.first.price : 'N/A'}',
            color: Colors.green,
          ),
          const SizedBox(width: 10),
          _buildInfoPill(
            icon: Icons.phone,
            label: tr("voyage.contact"), // 🔑 translation key
            value: voyage.phone,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
