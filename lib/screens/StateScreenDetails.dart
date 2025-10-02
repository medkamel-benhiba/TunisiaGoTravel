import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tunisiagotravel/models/destination.dart';
import 'package:tunisiagotravel/models/restaurant.dart';
import 'package:tunisiagotravel/models/state.dart';
import 'package:tunisiagotravel/providers/destination_provider.dart';
import 'package:tunisiagotravel/providers/global_provider.dart';
import 'package:tunisiagotravel/providers/state_provider.dart';
import 'package:tunisiagotravel/providers/hotel_provider.dart';
import 'package:tunisiagotravel/providers/restaurant_provider.dart';
import 'package:tunisiagotravel/providers/activity_provider.dart';
import 'package:tunisiagotravel/providers/festival_provider.dart';
import 'package:tunisiagotravel/providers/monument_provider.dart';
import 'package:tunisiagotravel/providers/musee_provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:tunisiagotravel/theme/color.dart';
import 'package:tunisiagotravel/widgets/destination/activity_card_dest.dart';
import 'package:tunisiagotravel/widgets/destination/dest_card.dart';
import 'package:tunisiagotravel/widgets/destination/event_card_dest.dart';
import 'package:tunisiagotravel/widgets/destination/festival_card_dest.dart';
import 'package:tunisiagotravel/widgets/destination/hotel_card_dest.dart';
import 'package:tunisiagotravel/widgets/destination/monument_card_dest.dart';
import 'package:tunisiagotravel/widgets/destination/restaurant_card_dest.dart';
import 'package:tunisiagotravel/widgets/destination/musees_card_dest.dart';
import 'package:video_player/video_player.dart';
import 'package:tunisiagotravel/providers/event_provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/hotel.dart';

// Add an enum for location type
enum LocationType { state, destination, auto }

// Create a unified interface for both StateApp and Destination
class UnifiedLocationData {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final String? videoUrl;
  final String? thumbnail;
  final bool isState;
  final StateApp? stateApp;
  final Destination? destination;
  final List<String>? destinationIds;

  UnifiedLocationData._({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    this.videoUrl,
    this.thumbnail,
    required this.isState,
    this.stateApp,
    this.destination,
    this.destinationIds,
  });

  factory UnifiedLocationData.fromState(StateApp state) {
    return UnifiedLocationData._(
      id: state.id,
      name: state.name,
      description: state.description,
      images: state.images,
      videoUrl: state.videoId.isNotEmpty ? state.videoId : null,
      thumbnail: state.cover.isNotEmpty ? state.cover : null,
      isState: true,
      stateApp: state,
      destinationIds: state.destinations,
    );
  }

  factory UnifiedLocationData.fromDestination(Destination destination) {
    List<String> allImages = [];
    if (destination.thumbnail != null && destination.thumbnail!.isNotEmpty) {
      allImages.add(destination.thumbnail!);
    }
    allImages.addAll(destination.gallery);

    return UnifiedLocationData._(
      id: destination.id,
      name: destination.name,
      description: destination.description!,
      images: allImages,
      videoUrl: destination.mobileVideo,
      thumbnail: destination.thumbnail ?? destination.gallery.first,
      isState: false,
      destination: destination,
      destinationIds: null,
    );
  }

  String getName(Locale locale) {
    if (isState) {
      return stateApp!.getName(locale);
    } else {
      return destination!.getName(locale);
    }
  }

  String? getDescription(Locale locale) {
    if (isState) {
      return stateApp!.getDescription(locale);
    } else {
      return destination!.getDescription(locale);
    }
  }
}

class StateScreenDetails extends StatefulWidget {
  final String selectedCityId;
  final LocationType locationType;

  const StateScreenDetails({
    super.key,
    required this.selectedCityId,
    this.locationType = LocationType.auto,
  });

  @override
  _StateScreenDetailsState createState() => _StateScreenDetailsState();
}

class _StateScreenDetailsState extends State<StateScreenDetails> {
  bool _isExpanded = false;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoPlaying = false;
  UnifiedLocationData? _locationData;
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _findLocationData();
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _findLocationData() {
    final stateProvider = Provider.of<StateProvider>(context, listen: false);
    final destinationProvider = Provider.of<DestinationProvider>(context, listen: false);

    StateApp? stateApp;
    Destination? destination;

    switch (widget.locationType) {
      case LocationType.state:
        stateApp = stateProvider.getStateByName(widget.selectedCityId) ??
            stateProvider.getStateById(widget.selectedCityId);
        if (stateApp != null) {
          setState(() {
            _locationData = UnifiedLocationData.fromState(stateApp!);
          });
          _loadDataForState(stateApp);
          _initializeVideo();
          return;
        }
        break;

      case LocationType.destination:
        destination = destinationProvider.getDestinationByName(widget.selectedCityId) ??
            destinationProvider.getDestinationById(widget.selectedCityId);
        if (destination != null) {
          setState(() {
            _locationData = UnifiedLocationData.fromDestination(destination!);
          });
          _loadDataForDestination(destination);
          _initializeVideo();
          return;
        }
        break;

      case LocationType.auto:
        stateApp = stateProvider.getStateByName(widget.selectedCityId) ??
            stateProvider.getStateById(widget.selectedCityId);
        if (stateApp != null) {
          setState(() {
            _locationData = UnifiedLocationData.fromState(stateApp!);
          });
          _loadDataForState(stateApp);
          _initializeVideo();
          return;
        }

        destination = destinationProvider.getDestinationByName(widget.selectedCityId) ??
            destinationProvider.getDestinationById(widget.selectedCityId);
        if (destination != null) {
          setState(() {
            _locationData = UnifiedLocationData.fromDestination(destination!);
          });
          _loadDataForDestination(destination);
          _initializeVideo();
          return;
        }
        break;
    }

    setState(() {
      _locationData = null;
    });
  }

  void _loadDataForState(StateApp state) {
    _loadHotelsForState(state);
    _loadRestaurantsForState(state);
  }

  String _formatStateName(String stateName) {
    String formatted = stateName.toLowerCase();

    if (formatted == "médenine") {
      formatted = "mdenine";
    }
    if (formatted == "kébili") {
      formatted = "kebili";
    }
    if (formatted == "béja") {
      formatted = "beja";
    }
    if (formatted == "gabès") {
      formatted = "gabes";
    }

    formatted = formatted.replaceAll(' ', '-');
    return formatted;
  }

  void _loadHotelsForState(StateApp state) {
    final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
    final formattedStateName = _formatStateName(state.name);
    hotelProvider.fetchHotelsByState(formattedStateName);
  }

  void _loadRestaurantsForState(StateApp state) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
    final formattedStateName = _formatStateName(state.name);
    restaurantProvider.fetchRestaurantsByState(formattedStateName);
  }

  void _loadDataForDestination(Destination destination) {
    _loadHotelsForDestination(destination);
    _loadRestaurantsForDestination(destination);
    _loadActivitiesForDestination(destination);
    _loadFestivalsForDestination(destination);
    _loadMonumentsForDestination(destination);
    _loadMuseesForDestination(destination);
    _loadEventsForDestination(destination);
  }

  void _loadHotelsForDestination(Destination destination) {
    final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
    hotelProvider.setHotelsByDestination(destination.id);
  }

  void _loadRestaurantsForDestination(Destination destination) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
    restaurantProvider.setRestaurantsByDestination(destination.id);
  }

  void _loadEventsForDestination(Destination destination) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    eventProvider.setEventsByDestination(destination.id);
  }

  void _loadActivitiesForDestination(Destination destination) {
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
    final cachedActivities = activityProvider.getActivitiesByDestination(destination.id);
    if (cachedActivities.isNotEmpty) {
      activityProvider.setActivitiesByDestination(destination.id);
    } else {
      activityProvider.fetchAllActivities().then((_) {
        activityProvider.setActivitiesByDestination(destination.id);
      });
    }
  }

  void _loadFestivalsForDestination(Destination destination) {
    final festivalProvider = Provider.of<FestivalProvider>(context, listen: false);
    final cachedFestivals = festivalProvider.getFestivalsByDestination(destination.id);
    if (cachedFestivals.isNotEmpty) {
      festivalProvider.setFestivalsByDestination(destination.id);
    } else {
      festivalProvider.fetchAllFestivals().then((_) {
        festivalProvider.setFestivalsByDestination(destination.id);
      });
    }
  }

  void _loadMonumentsForDestination(Destination destination) {
    final monumentProvider = Provider.of<MonumentProvider>(context, listen: false);
    final cachedMonuments = monumentProvider.getMonumentsByDestination(destination.id);
    if (cachedMonuments.isNotEmpty) {
      monumentProvider.getMonumentsByDestination(destination.id);
    } else {
      monumentProvider.fetchMonuments().then((_) {
        monumentProvider.getMonumentsByDestination(destination.id);
      });
    }
  }

  void _loadMuseesForDestination(Destination destination) {
    final museeProvider = Provider.of<MuseeProvider>(context, listen: false);
    final cachedMusees = museeProvider.getMuseesByDestination(destination.id);
    if (cachedMusees.isNotEmpty) {
      museeProvider.getMuseesByDestination(destination.id);
    } else {
      museeProvider.fetchMusees().then((_) {
        museeProvider.getMuseesByDestination(destination.id);
      });
    }
  }

  void _initializeVideo() {
    if (_locationData?.videoUrl != null && _locationData!.videoUrl!.isNotEmpty) {
      String videoUrl = _locationData!.videoUrl!;
      try {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        _videoController!.initialize().then((_) {
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
            });
          }
        }).catchError((error) {
          print('Video initialization error: $error');
        });
      } catch (e) {
        print('Video controller creation error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF11A2DC), Color(0xFF2B5CA1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          _locationData?.getName(locale) ?? tr('destination'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_locationData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              tr('cityNotFound'),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Location: ${widget.selectedCityId}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    final locale = context.locale;
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMediaCarousel(screenWidth),
          _buildDescription(locale, screenWidth),
          _buildRelatedDestinations(locale, screenWidth),
          _buildHotelsSection(screenWidth),
          _buildRestaurantsSection(screenWidth),
          _buildActivitiesSection(screenWidth),
          _buildFestivalsSection(screenWidth),
          _buildMonumentsSection(screenWidth),
          _buildMuseesSection(screenWidth),
          _buildEventsSection(screenWidth),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMediaCarousel(double screenWidth) {
    final mediaItems = <Widget>[];
    final hasVideo = _locationData!.videoUrl != null && _locationData!.videoUrl!.isNotEmpty;
    final hasImages = _locationData!.images.isNotEmpty;

    if (!hasVideo && !hasImages) {
      return _buildNoMediaPlaceholder(screenWidth);
    }

    // Add video as the first item if available
    if (hasVideo) {
      mediaItems.add(_buildVideoItem(screenWidth));
    }

    // Add images
    mediaItems.addAll(_locationData!.images.asMap().entries.map((entry) {
      final index = entry.key + (hasVideo ? 1 : 0);
      return _buildGalleryImage(context, entry.value, index);
    }).toList());

    return Container(
      padding: EdgeInsets.all(screenWidth < 600 ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('media'),
            style: TextStyle(
              fontSize: screenWidth < 600 ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: screenWidth < 600 ? 200 : 300,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: mediaItems.length > 1,
                  autoPlay: false,
                  enlargeCenterPage: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentCarouselIndex = index;
                      if (_isVideoPlaying && index != 0) {
                        _videoController?.pause();
                        _isVideoPlaying = false;
                      }
                    });
                  },
                ),
                items: mediaItems,
              ),
              if (mediaItems.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: mediaItems.asMap().entries.map((entry) {
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentCarouselIndex == entry.key
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoItem(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _buildDirectVideo(screenWidth),
      ),
    );
  }

  Widget _buildDirectVideo(double screenWidth) {
    if (_videoController == null || !_isVideoInitialized || !_isVideoPlaying) {
      return Container(
        color: Colors.black,
        child: Stack(
          children: [
            if (_locationData!.thumbnail != null && _locationData!.thumbnail!.isNotEmpty)
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: _locationData!.thumbnail!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey.shade300),
                  errorWidget: (context, url, error) => Container(color: Colors.grey.shade300),
                ),
              ),
            Container(
              color: Colors.black.withOpacity(0.5),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_videoController == null || !_isVideoInitialized)
                    Column(
                      children: [
                        Icon(
                          Icons.video_library,
                          size: screenWidth < 600 ? 40 : 60,
                          color: Colors.white70,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Loading video...',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: screenWidth < 600 ? 14 : 16,
                          ),
                        ),
                      ],
                    )
                  else
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _videoController!.play();
                          _isVideoPlaying = true;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: screenWidth < 600 ? 40 : 50,
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

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _videoController!.value.size.width,
              height: _videoController!.value.size.height,
              child: VideoPlayer(_videoController!),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              if (_isVideoPlaying) {
                _videoController!.pause();
                _isVideoPlaying = false;
              } else {
                _videoController!.play();
                _isVideoPlaying = true;
              }
            });
          },
          child: AnimatedOpacity(
            opacity: _isVideoPlaying ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(16),
              child: Icon(
                _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: screenWidth < 600 ? 40 : 50,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryImage(BuildContext context, String imageUrl, int index) {
    return Hero(
      tag: 'gallery_image_$index',
      child: GestureDetector(
        onTap: () => _showImageFullscreen(context, imageUrl, index),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey.shade400,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoMediaPlaceholder(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth < 600 ? 16 : 20),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 40,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                tr('noMediaAvailable'),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: screenWidth < 600 ? 13 : 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(Locale locale, double screenWidth) {
    final description = _locationData!.getDescription(locale);

    if (description == null || description.isEmpty) {
      return _buildNoDescriptionPlaceholder(screenWidth);
    }

    const int previewLength = 321;
    final String previewText = description.length > previewLength
        ? '${description.substring(0, previewLength)}...'
        : description;

    return Container(
      padding: EdgeInsets.fromLTRB(
        screenWidth < 600 ? 16 : 20,
        0,
        screenWidth < 600 ? 16 : 20,
        screenWidth < 600 ? 16 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('description'),
            style: TextStyle(
              fontSize: screenWidth < 600 ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(screenWidth < 600 ? 12 : 16),
            decoration: BoxDecoration(
              color: AppColorstatic.secondary.withOpacity(0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Html(
                  data: _isExpanded ? description : previewText,
                  style: {
                    'body': Style(
                      fontSize: FontSize(screenWidth < 600 ? 14 : 16),
                      color: const Color(0xFF34495E),
                    ),
                  },
                ),
                if (description.length > previewLength)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _isExpanded ? tr('see_less') : tr('see_more'),
                        style: TextStyle(
                          fontSize: screenWidth < 600 ? 12 : 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
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

  Widget _buildNoDescriptionPlaceholder(double screenWidth) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        screenWidth < 600 ? 16 : 20,
        0,
        screenWidth < 600 ? 16 : 20,
        screenWidth < 600 ? 16 : 20,
      ),
      child: Container(
        padding: EdgeInsets.all(screenWidth < 600 ? 12 : 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              Icons.description_outlined,
              color: Colors.grey.shade400,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tr('noDescriptionAvailable'),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: screenWidth < 600 ? 14 : 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedDestinations(Locale locale, double screenWidth) {
    final destinationProvider = Provider.of<DestinationProvider>(context, listen: false);
    List<Destination> relatedDestinations = [];

    if (_locationData!.isState && _locationData!.stateApp != null && _locationData!.destinationIds != null) {
      relatedDestinations = _locationData!.destinationIds!
          .map((id) => destinationProvider.getDestinationById(id))
          .where((dest) => dest != null)
          .cast<Destination>()
          .toList();
    } else if (!_locationData!.isState && _locationData!.destination != null) {
      final destination = _locationData!.destination!;
      relatedDestinations = destinationProvider
          .getDestinationsByState(destination.state)
          .where((dest) => dest.id != destination.id)
          .toList();
    }

    if (relatedDestinations.isEmpty) {
      return const SizedBox.shrink();
    }

    double cardWidth;
    double cardHeight;
    double containerHeight;

    if (screenWidth < 600) {
      cardWidth = 140;
      cardHeight = 120;
      containerHeight = 140;
    } else if (screenWidth < 900) {
      cardWidth = 160;
      cardHeight = 140;
      containerHeight = 160;
    } else if (screenWidth < 1200) {
      cardWidth = 180;
      cardHeight = 160;
      containerHeight = 180;
    } else {
      cardWidth = 200;
      cardHeight = 180;
      containerHeight = 200;
    }

    return Container(
      padding: EdgeInsets.all(screenWidth < 600 ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(_locationData!.isState ? 'destinations_in_state' : 'destination_in_state', args: [_locationData!.getName(locale)]),
            style: TextStyle(
              fontSize: screenWidth < 600 ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: containerHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: relatedDestinations.length,
              itemBuilder: (context, index) {
                final relatedDestination = relatedDestinations[index];
                return Container(
                  width: cardWidth,
                  margin: EdgeInsets.only(
                    right: index < relatedDestinations.length - 1 ? (screenWidth < 600 ? 12 : 16) : 0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StateScreenDetails(
                            selectedCityId: relatedDestination.id,
                            locationType: LocationType.destination,
                          ),
                        ),
                      );
                    },
                    child: DestCard(
                      destination: relatedDestination,
                      locale: locale,
                      cardHeight: cardHeight,
                      screenWidth: screenWidth,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelsSection(double screenWidth) {
    return Consumer<HotelProvider>(
      builder: (context, hotelProvider, child) {
        List<Hotel> hotels;

        if (_locationData!.isState) {
          hotels = hotelProvider.getCurrentStateHotels();
        } else if (_locationData!.destination != null) {
          hotels = hotelProvider.getHotelsByDestination(_locationData!.destination!.id);
        } else {
          return const SizedBox.shrink();
        }

        if (hotels.isEmpty && !hotelProvider.isLoading) {
          return const SizedBox.shrink();
        }

        if (hotelProvider.isLoading) {
          return Container(
            padding: EdgeInsets.all(screenWidth < 600 ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('available_hotels'),
                  style: TextStyle(
                    fontSize: screenWidth < 600 ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        }

        double cardWidth;
        double cardHeight;
        double containerHeight;

        if (screenWidth < 600) {
          cardWidth = 200;
          cardHeight = 220;
          containerHeight = 240;
        } else if (screenWidth < 900) {
          cardWidth = 220;
          cardHeight = 240;
          containerHeight = 260;
        } else if (screenWidth < 1200) {
          cardWidth = 240;
          cardHeight = 260;
          containerHeight = 280;
        } else {
          cardWidth = 260;
          cardHeight = 280;
          containerHeight = 300;
        }

        return Container(
          padding: EdgeInsets.all(screenWidth < 600 ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.hotel,
                        size: screenWidth < 600 ? 24 : 28,
                        color: AppColorstatic.primary2,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tr('available_hotels'),
                        style: TextStyle(
                          fontSize: screenWidth < 600 ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                  if (hotels.length > 3)
                    TextButton(
                      onPressed: () {
                        final globalProvider = Provider.of<GlobalProvider>(context, listen: false);
                        final locale = context.locale;

                        if (_locationData!.isState) {
                          String stateName = _locationData!.getName(locale);
                          print("Navigating to hotels for state: $stateName");
                          globalProvider.setSelectedCityForHotels(stateName);
                          globalProvider.setAvailableHotels(hotels);
                          hotelProvider.fetchHotelsByState(_locationData!.stateApp!.name);
                        } else {
                          String destinationName = _locationData!.destination!.getName(locale);
                          print("Navigating to hotels for destination: $destinationName");
                          globalProvider.setSelectedCityForHotels(destinationName);
                          globalProvider.setAvailableHotels(hotels);
                          hotelProvider.setHotelsByDestination(_locationData!.destination!.id);
                        }

                        globalProvider.setPage(AppPage.hotels);
                        Navigator.pop(context);
                      },
                      child: Text(
                        tr('see_all'),
                        style: TextStyle(
                          fontSize: screenWidth < 600 ? 12 : 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: containerHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: hotels.length,
                  itemBuilder: (context, index) {
                    final hotel = hotels[index];
                    return Container(
                      width: cardWidth,
                      margin: EdgeInsets.only(
                        right: index < hotels.length - 1 ? (screenWidth < 600 ? 12 : 16) : 0,
                      ),
                      child: HotelCardDest(hotel: hotel, cardHeight: cardHeight, screenWidth: screenWidth),
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

  Widget _buildRestaurantsSection(double screenWidth) {
    return Consumer<RestaurantProvider>(
      builder: (context, restaurantProvider, child) {
        List<Restaurant> restaurants;

        if (_locationData!.isState) {
          restaurants = restaurantProvider.getCurrentStateRestaurants();
        } else if (_locationData!.destination != null) {
          restaurants = restaurantProvider.getRestaurantsByDestination(_locationData!.destination!.id);
        } else {
          return const SizedBox.shrink();
        }

        if (restaurants.isEmpty && !restaurantProvider.isLoading) {
          return const SizedBox.shrink();
        }

        if (restaurantProvider.isLoading) {
          return Container(
            padding: EdgeInsets.all(screenWidth < 600 ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('available_restaurants'),
                  style: TextStyle(
                    fontSize: screenWidth < 600 ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        }

        double cardWidth;
        double cardHeight;
        double containerHeight;

        if (screenWidth < 600) {
          cardWidth = 200;
          cardHeight = 220;
          containerHeight = 240;
        } else if (screenWidth < 900) {
          cardWidth = 220;
          cardHeight = 240;
          containerHeight = 260;
        } else if (screenWidth < 1200) {
          cardWidth = 240;
          cardHeight = 260;
          containerHeight = 280;
        } else {
          cardWidth = 260;
          cardHeight = 280;
          containerHeight = 300;
        }

        return Container(
          padding: EdgeInsets.all(screenWidth < 600 ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant,
                        size: screenWidth < 600 ? 24 : 28,
                        color: AppColorstatic.primary2,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tr('available_restaurants'),
                        style: TextStyle(
                          fontSize: screenWidth < 600 ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                  if (restaurants.length > 3)
                    TextButton(
                      onPressed: () {
                        final globalProvider = Provider.of<GlobalProvider>(context, listen: false);

                        if (_locationData!.isState) {
                          restaurantProvider.fetchRestaurantsByState(_locationData!.stateApp!.name);
                        } else {
                          globalProvider.setInitialRestaurantDestinationId(_locationData!.destination!.id);
                        }

                        globalProvider.setPage(AppPage.restaurants);
                        Navigator.pop(context);
                      },
                      child: Text(
                        tr('see_all'),
                        style: TextStyle(
                          fontSize: screenWidth < 600 ? 12 : 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: containerHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = restaurants[index];
                    return Container(
                      width: cardWidth,
                      margin: EdgeInsets.only(
                        right: index < restaurants.length - 1 ? (screenWidth < 600 ? 12 : 16) : 0,
                      ),
                      child: RestaurantCardDest(
                        restaurant: restaurant,
                        cardHeight: cardHeight,
                        screenWidth: screenWidth,
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

  Widget _buildActivitiesSection(double screenWidth) {
    if (_locationData!.isState || _locationData!.destination == null) {
      return const SizedBox.shrink();
    }

    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, child) {
        final activities = activityProvider.getActivitiesByDestination(_locationData!.destination!.id);

        if (activities.isEmpty && !activityProvider.isLoading) {
          return const SizedBox.shrink();
        }

        if (activityProvider.isLoading) {
          return Container(
            padding: EdgeInsets.all(screenWidth < 600 ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('available_activities'),
                  style: TextStyle(
                    fontSize: screenWidth < 600 ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        }

        double cardWidth;
        double cardHeight;
        double containerHeight;

        if (screenWidth < 600) {
          cardWidth = 200;
          cardHeight = 220;
          containerHeight = 240;
        } else if (screenWidth < 900) {
          cardWidth = 220;
          cardHeight = 240;
          containerHeight = 260;
        } else if (screenWidth < 1200) {
          cardWidth = 240;
          cardHeight = 260;
          containerHeight = 280;
        } else {
          cardWidth = 260;
          cardHeight = 280;
          containerHeight = 300;
        }

        return Container(
          padding: EdgeInsets.all(screenWidth < 600 ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_activity,
                        size: screenWidth < 600 ? 24 : 28,
                        color: AppColorstatic.primary2,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tr('available_activities'),
                        style: TextStyle(
                          fontSize: screenWidth < 600 ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: containerHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return Container(
                      width: cardWidth,
                      margin: EdgeInsets.only(
                        right: index < activities.length - 1 ? (screenWidth < 600 ? 12 : 16) : 0,
                      ),
                      child: ActivityCardDest(activity: activity, cardHeight: cardHeight, screenWidth: screenWidth),
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

  Widget _buildFestivalsSection(double screenWidth) {
    if (_locationData!.isState || _locationData!.destination == null) {
      return const SizedBox.shrink();
    }

    return Consumer<FestivalProvider>(
      builder: (context, festivalProvider, child) {
        final festivals = festivalProvider.festivals;

        if (festivals.isEmpty && !festivalProvider.isLoading) {
          return const SizedBox.shrink();
        }

        if (festivalProvider.isLoading) {
          return Container(
            padding: EdgeInsets.all(screenWidth < 600 ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('available_festivals'),
                  style: TextStyle(
                    fontSize: screenWidth < 600 ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        }

        double cardWidth;
        double cardHeight;
        double containerHeight;

        if (screenWidth < 600) {
          cardWidth = 200;
          cardHeight = 220;
          containerHeight = 240;
        } else if (screenWidth < 900) {
          cardWidth = 220;
          cardHeight = 240;
          containerHeight = 260;
        } else if (screenWidth < 1200) {
          cardWidth = 240;
          cardHeight = 260;
          containerHeight = 280;
        } else {
          cardWidth = 260;
          cardHeight = 280;
          containerHeight = 300;
        }

        return Container(
          padding: EdgeInsets.all(screenWidth < 600 ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.festival,
                        size: screenWidth < 600 ? 24 : 28,
                        color: AppColorstatic.primary2,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tr('available_festivals'),
                        style: TextStyle(
                          fontSize: screenWidth < 600 ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: containerHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: festivals.length,
                  itemBuilder: (context, index) {
                    final festival = festivals[index];
                    return Container(
                      width: cardWidth,
                      margin: EdgeInsets.only(
                        right: index < festivals.length - 1 ? (screenWidth < 600 ? 12 : 16) : 0,
                      ),
                      child: FestivalCardDest(festival: festival, cardHeight: cardHeight, screenWidth: screenWidth),
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

  Widget _buildMonumentsSection(double screenWidth) {
    if (_locationData!.isState || _locationData!.destination == null) {
      return const SizedBox.shrink();
    }

    return Consumer<MonumentProvider>(
      builder: (context, monumentProvider, child) {
        final monuments = monumentProvider.getMonumentsByDestination(_locationData!.destination!.id);

        if (monuments.isEmpty && !monumentProvider.isLoading) {
          return const SizedBox.shrink();
        }

        if (monumentProvider.isLoading) {
          return Container(
            padding: EdgeInsets.all(screenWidth < 600 ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('available_monuments'),
                  style: TextStyle(
                    fontSize: screenWidth < 600 ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        }

        double cardWidth;
        double cardHeight;
        double containerHeight;

        if (screenWidth < 600) {
          cardWidth = 200;
          cardHeight = 220;
          containerHeight = 240;
        } else if (screenWidth < 900) {
          cardWidth = 220;
          cardHeight = 240;
          containerHeight = 260;
        } else if (screenWidth < 1200) {
          cardWidth = 240;
          cardHeight = 260;
          containerHeight = 280;
        } else {
          cardWidth = 260;
          cardHeight = 280;
          containerHeight = 300;
        }

        return Container(
          padding: EdgeInsets.all(screenWidth < 600 ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.festival_outlined,
                        size: screenWidth < 600 ? 24 : 28,
                        color: AppColorstatic.primary2,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tr('available_monuments'),
                        style: TextStyle(
                          fontSize: screenWidth < 600 ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: containerHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: monuments.length,
                  itemBuilder: (context, index) {
                    final monument = monuments[index];
                    return Container(
                      width: cardWidth,
                      margin: EdgeInsets.only(
                        right: index < monuments.length - 1 ? (screenWidth < 600 ? 12 : 16) : 0,
                      ),
                      child: MonumentCardDest(monument: monument, cardHeight: cardHeight, screenWidth: screenWidth),
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

  Widget _buildMuseesSection(double screenWidth) {
    if (_locationData!.isState || _locationData!.destination == null) {
      return const SizedBox.shrink();
    }

    return Consumer<MuseeProvider>(
      builder: (context, museeProvider, child) {
        final musees = museeProvider.getMuseesByDestination(_locationData!.destination!.id);

        if (musees.isEmpty && !museeProvider.isLoading) {
          return const SizedBox.shrink();
        }

        if (museeProvider.isLoading) {
          return Container(
            padding: EdgeInsets.all(screenWidth < 600 ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('available_musees'),
                  style: TextStyle(
                    fontSize: screenWidth < 600 ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        }

        double cardWidth;
        double cardHeight;
        double containerHeight;

        if (screenWidth < 600) {
          cardWidth = 200;
          cardHeight = 220;
          containerHeight = 240;
        } else if (screenWidth < 900) {
          cardWidth = 220;
          cardHeight = 240;
          containerHeight = 260;
        } else if (screenWidth < 1200) {
          cardWidth = 240;
          cardHeight = 260;
          containerHeight = 280;
        } else {
          cardWidth = 260;
          cardHeight = 280;
          containerHeight = 300;
        }

        return Container(
          padding: EdgeInsets.all(screenWidth < 600 ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.museum,
                        size: screenWidth < 600 ? 24 : 28,
                        color: AppColorstatic.primary2,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tr('available_musees'),
                        style: TextStyle(
                          fontSize: screenWidth < 600 ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: containerHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: musees.length,
                  itemBuilder: (context, index) {
                    final musee = musees[index];
                    return Container(
                      width: cardWidth,
                      margin: EdgeInsets.only(
                        right: index < musees.length - 1 ? (screenWidth < 600 ? 12 : 16) : 0,
                      ),
                      child: MuseesCardDest(musees: musee, cardHeight: cardHeight, screenWidth: screenWidth),
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

  Widget _buildEventsSection(double screenWidth) {
    if (_locationData!.isState || _locationData!.destination == null) {
      return const SizedBox.shrink();
    }

    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        final events = eventProvider.getEventsByDestination(_locationData!.destination!.id);

        if (events.isEmpty && !eventProvider.isLoading) {
          return const SizedBox.shrink();
        }

        if (eventProvider.isLoading) {
          return Container(
            padding: EdgeInsets.all(screenWidth < 600 ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('available_events'),
                  style: TextStyle(
                    fontSize: screenWidth < 600 ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        }

        double cardWidth;
        double cardHeight;
        double containerHeight;

        if (screenWidth < 600) {
          cardWidth = 200;
          cardHeight = 220;
          containerHeight = 240;
        } else if (screenWidth < 900) {
          cardWidth = 220;
          cardHeight = 240;
          containerHeight = 260;
        } else if (screenWidth < 1200) {
          cardWidth = 240;
          cardHeight = 260;
          containerHeight = 280;
        } else {
          cardWidth = 260;
          cardHeight = 280;
          containerHeight = 300;
        }

        return Container(
          padding: EdgeInsets.all(screenWidth < 600 ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.event,
                        size: screenWidth < 600 ? 24 : 28,
                        color: AppColorstatic.primary2,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tr('available_events'),
                        style: TextStyle(
                          fontSize: screenWidth < 600 ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: containerHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Container(
                      width: cardWidth,
                      margin: EdgeInsets.only(
                        right: index < events.length - 1 ? (screenWidth < 600 ? 12 : 16) : 0,
                      ),
                      child: EventCardDest(event: event, cardHeight: cardHeight, screenWidth: screenWidth),
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

  void _showImageFullscreen(BuildContext context, String imageUrl, int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: ImageFullscreenViewer(
              imageUrl: imageUrl,
              heroTag: 'gallery_image_$index',
            ),
          );
        },
      ),
    );
  }
}

class ImageFullscreenViewer extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const ImageFullscreenViewer({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Hero(
          tag: heroTag,
          child: InteractiveViewer(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              errorWidget: (context, url, error) => const Icon(
                Icons.error,
                color: Colors.white,
                size: 60,
              ),
            ),
          ),
        ),
      ),
    );
  }
}