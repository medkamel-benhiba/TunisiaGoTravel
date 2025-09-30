/*import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/conversation.dart';
import '../services/conversation_history_service.dart';
import '../theme/color.dart';
import '../widgets/screen_title.dart';
import 'chatbot_screen.dart';

class ConversationHistoryScreen extends StatefulWidget {
  @override
  State<ConversationHistoryScreen> createState() => _ConversationHistoryScreenState();
}

class _ConversationHistoryScreenState extends State<ConversationHistoryScreen> {
  List<Conversation> conversations = [];
  List<Conversation> filteredConversations = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String sortBy = 'date';
  bool isAscending = false;
  String selectedCategory = 'Tous';

  @override
  void initState() {
    super.initState();
    _loadConversations();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = searchController.text;
      _filterAndSortConversations();
    });
  }

  Future<void> _loadConversations() async {
    setState(() => isLoading = true);
    try {
      final loadedConversations = await ConversationHistoryService.getConversations();
      setState(() {
        conversations = loadedConversations;
        _filterAndSortConversations();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading conversations: $e');
    }
  }

  void _filterAndSortConversations() {
    filteredConversations = conversations.where((conv) {
      bool matchesSearch = searchQuery.isEmpty ||
          conv.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          conv.messages.any((msg) =>
          msg['content']?.toString().toLowerCase().contains(searchQuery.toLowerCase()) ?? false);

      bool matchesCategory = selectedCategory == 'Tous' || conv.category == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    filteredConversations.sort((a, b) {
      int comparison = 0;
      switch (sortBy) {
        case 'date':
          comparison = a.lastUpdated.compareTo(b.lastUpdated);
          break;
        case 'title':
          comparison = a.title.compareTo(b.title);
          break;
        case 'messages':
          comparison = a.messageCount.compareTo(b.messageCount);
          break;
      }
      return isAscending ? comparison : -comparison;
    });
  }

  Future<void> _deleteConversation(String conversationId) async {
    await ConversationHistoryService.deleteConversation(conversationId);
    _loadConversations();
  }

  Future<void> _toggleFavorite(Conversation conversation) async {
    await ConversationHistoryService.toggleFavorite(conversation.id);
    _loadConversations();
  }

  void _openConversation(Conversation conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatBotScreen(
          existingConversation: conversation,
          apiResponse: {},
        ),
      ),
    ).then((_) => _loadConversations());
  }

  void _startNewConversation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatBotScreen(apiResponse: {}),
      ),
    ).then((_) => _loadConversations());
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'maintenant';
    }
  }

  Icon _getCategoryIcon(String category) {
    switch (category) {
      case 'Voyage':
        return Icon(Icons.flight_takeoff, color: AppColorstatic.primary);
      case 'Restaurants':
        return Icon(Icons.restaurant, color: Colors.orange);
      case 'Activités':
        return Icon(Icons.local_activity, color: Colors.purple);
      case 'Hébergement':
        return Icon(Icons.hotel, color: Colors.blue);
      case 'Transport':
        return Icon(Icons.directions_bus, color: Colors.green);
      case 'Culture':
        return Icon(Icons.museum, color: Colors.brown);
      case 'Sport':
        return Icon(Icons.sports_soccer, color: Colors.red);
      default:
        return Icon(Icons.chat_bubble_outline, color: AppColorstatic.primary);
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trier par',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text('Date'),
              trailing: sortBy == 'date' ? Icon(Icons.check, color: AppColorstatic.primary) : null,
              onTap: () {
                setState(() {
                  sortBy = 'date';
                  _filterAndSortConversations();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.title),
              title: Text('Titre'),
              trailing: sortBy == 'title' ? Icon(Icons.check, color: AppColorstatic.primary) : null,
              onTap: () {
                setState(() {
                  sortBy = 'title';
                  _filterAndSortConversations();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Nombre de messages'),
              trailing: sortBy == 'messages' ? Icon(Icons.check, color: AppColorstatic.primary) : null,
              onTap: () {
                setState(() {
                  sortBy = 'messages';
                  _filterAndSortConversations();
                });
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward),
              title: Text(isAscending ? 'Croissant' : 'Décroissant'),
              onTap: () {
                setState(() {
                  isAscending = !isAscending;
                  _filterAndSortConversations();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilter() {
    final categories = ['Tous', ...ConversationHistoryService.defaultCategories];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filtrer par catégorie'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: categories.map((category) => ListTile(
            leading: category == 'Tous'
                ? Icon(Icons.all_inclusive)
                : _getCategoryIcon(category),
            title: Text(category),
            trailing: selectedCategory == category
                ? Icon(Icons.check, color: AppColorstatic.primary)
                : null,
            onTap: () {
              setState(() {
                selectedCategory = category;
                _filterAndSortConversations();
              });
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showStatistics() async {
    final stats = await ConversationHistoryService.getStatistics();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Statistiques'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Total conversations:', stats['totalConversations'].toString()),
            _buildStatRow('Total messages:', stats['totalMessages'].toString()),
            _buildStatRow('Messages favoris:', stats['favoriteCount'].toString()),
            _buildStatRow('Moyenne par conversation:', stats['averageMessages'].toString()),
            if (stats['oldestConversation'] != null)
              _buildStatRow(
                'Première conversation:',
                DateFormat('dd/MM/yyyy').format(stats['oldestConversation']),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ScreenTitle(
          title: 'Historique des conversations',
          icon: Icons.history,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher dans les conversations...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => searchController.clear(),
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilterChip(
                    label: Text(selectedCategory),
                    onSelected: (_) => _showCategoryFilter(),
                    avatar: Icon(Icons.category, size: 16),
                  ),
                  FilterChip(
                    label: Text('Trier'),
                    onSelected: (_) => _showSortOptions(),
                    avatar: Icon(Icons.sort, size: 16),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.analytics),
            onPressed: _showStatistics,
            tooltip: 'Statistiques',
          ),
          if (conversations.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'clear') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Confirmer la suppression'),
                      content: Text('Voulez-vous vraiment supprimer tout l\'historique ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Supprimer', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await ConversationHistoryService.clearAllConversations();
                    _loadConversations();
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Tout supprimer'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : filteredConversations.isEmpty
          ? _buildEmptyState()
          : _buildConversationsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewConversation,
        backgroundColor: AppColorstatic.primary,
        child: Icon(Icons.add),
        tooltip: 'Nouvelle conversation',
      ),
    );
  }

  Widget _buildEmptyState() {
    if (searchQuery.isNotEmpty || selectedCategory != 'Tous') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Aucun résultat trouvé',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Essayez des filtres différents',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  searchController.clear();
                  selectedCategory = 'Tous';
                  _filterAndSortConversations();
                });
              },
              child: Text('Réinitialiser les filtres'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Aucune conversation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'Commencez une nouvelle conversation',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _startNewConversation,
            icon: Icon(Icons.add),
            label: Text('Nouvelle conversation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorstatic.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList() {
    return Column(
      children: [
        if (searchQuery.isNotEmpty || selectedCategory != 'Tous')
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            child: Text(
              '${filteredConversations.length} résultat(s) trouvé(s)',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),

        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: filteredConversations.length,
            itemBuilder: (context, index) {
              final conversation = filteredConversations[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: AppColorstatic.primary.withOpacity(0.1),
                    child: _getCategoryIcon(conversation.category),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.title,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.isFavorite)
                        Icon(Icons.favorite, color: Colors.red, size: 16),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColorstatic.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              conversation.category,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColorstatic.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${conversation.messageCount} messages',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          SizedBox(width: 8),
                          Text(
                            _getTimeAgo(conversation.lastUpdated),
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(conversation.lastUpdated),
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      switch (value) {
                        case 'favorite':
                          await _toggleFavorite(conversation);
                          break;
                        case 'delete':
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Supprimer la conversation'),
                              content: Text('Cette action est irréversible.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text('Annuler'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Supprimer', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            _deleteConversation(conversation.id);
                          }
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'favorite',
                        child: Row(
                          children: [
                            Icon(
                              conversation.isFavorite ? Icons.favorite_border : Icons.favorite,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text(conversation.isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Supprimer'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _openConversation(conversation),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}*/