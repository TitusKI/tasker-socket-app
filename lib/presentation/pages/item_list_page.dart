import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/item_entity.dart';
import '../bloc/item_bloc.dart';
import '../widgets/error_display.dart';
import '../widgets/empty_list_indicator.dart';
import '../widgets/loading_indicators.dart';
import 'item_form_page.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  @override
  void initState() {
    super.initState();

    BlocProvider.of<ItemBloc>(context).add(LoadItemsEvent());
  }

  void _navigateToForm(BuildContext context, {ItemEntity? item}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                ItemFormPage(item: item),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
        fullscreenDialog: true,
      ),
    );
  }

  void _deleteItem(BuildContext context, ItemEntity item, ItemBloc bloc) {
    bloc.add(RemoveItemEvent(id: item.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Item "${item.title}" deleted',
                style: GoogleFonts.inter(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemBloc = BlocProvider.of<ItemBloc>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green.shade700,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.eco_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Evergreen Items',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          BlocBuilder<ItemBloc, ItemState>(
            builder: (context, state) {
              if (state is ItemLoaded) {
                return Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade100, Colors.green.shade50],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${state.activeUsersCount} Active',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<ItemBloc, ItemState>(
        builder: (context, state) {
          if (state is ItemInitial ||
              (state is ItemLoading && state is! ItemLoaded)) {
            return const LoadingIndicator(message: 'Loading your items...');
          } else if (state is ItemLoaded) {
            if (state.items.isEmpty) {
              return const EmptyListIndicator(
                message:
                    'No items yet.\nTap the + button to create your first item!',
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                itemBloc.add(LoadItemsEvent());
              },
              color: Colors.green.shade600,
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: 100,
                ),
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Slidable(
                      key: ValueKey(item.id),
                      endActionPane: ActionPane(
                        motion: const StretchMotion(),
                        dismissible: DismissiblePane(
                          onDismissed:
                              () => _deleteItem(context, item, itemBloc),
                        ),
                        children: [
                          SlidableAction(
                            onPressed:
                                (_) => _navigateToForm(context, item: item),
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            icon: Icons.edit_rounded,
                            label: 'Edit',
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                          SlidableAction(
                            onPressed:
                                (_) => _deleteItem(context, item, itemBloc),
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            icon: Icons.delete_rounded,
                            label: 'Delete',
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.shade100.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _navigateToForm(context, item: item),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.green.shade400,
                                          Colors.green.shade600,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.task_alt_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade800,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (item.description != null &&
                                            item.description!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            item.description!,
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                              height: 1.3,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.grey.shade400,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (state is ItemError) {
            return ErrorDisplay(
              message: "No internet connection, please try again.",
              onRetry: () => itemBloc.add(LoadItemsEvent()),
            );
          }
          return const Center(child: Text('Something went wrong.'));
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade600, Colors.green.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade300.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _navigateToForm(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
          label: Text(
            'Add Item',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
