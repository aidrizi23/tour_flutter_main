import 'package:flutter/material.dart';
import '../../../models/photo_models.dart';
import '../../../services/photo_service.dart';
import '../../../widgets/modern_widgets.dart';

class HomeInspirationSection extends StatefulWidget {
  const HomeInspirationSection({super.key});

  @override
  State<HomeInspirationSection> createState() => _HomeInspirationSectionState();
}

class _HomeInspirationSectionState extends State<HomeInspirationSection> {
  final PhotoService _photoService = PhotoService();
  late Future<List<InspirationPhoto>> _photosFuture;

  @override
  void initState() {
    super.initState();
    _photosFuture = _photoService.fetchInspirationPhotos(limit: 5);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: FutureBuilder<List<InspirationPhoto>>(
        future: _photosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 260,
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return ModernErrorState(
              title: 'Oops',
              message: 'Failed to load inspiration.',
              actionText: 'Retry',
              onRetry: () => setState(() {
                _photosFuture = _photoService.fetchInspirationPhotos(limit: 5);
              }),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const SizedBox.shrink();
          }

          final photos = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Get Inspired',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 250,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.8),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(photo.downloadUrl, fit: BoxFit.cover),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.black45,
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  photo.author,
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
