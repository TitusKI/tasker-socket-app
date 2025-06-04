import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/item_entity.dart';
import '../bloc/item_bloc.dart';

class ItemFormPage extends StatefulWidget {
  final ItemEntity? item;

  const ItemFormPage({super.key, this.item});

  @override
  State<ItemFormPage> createState() => _ItemFormPageState();
}

class _ItemFormPageState extends State<ItemFormPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isSubmitting = false;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.item?.description ?? '',
    );
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && !_isSubmitting) {
      setState(() => _isSubmitting = true);

      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();

      if (_isEditing) {
        context.read<ItemBloc>().add(
          EditItemEvent(
            id: widget.item!.id,
            title: title,
            description: description.isNotEmpty ? description : null,
          ),
        );

        await Future.delayed(const Duration(seconds: 2));
        context.read<ItemBloc>().add(LoadItemsEvent());
        Navigator.of(context).pop();
      } else {
        context.read<ItemBloc>().add(
          AddItemEvent(
            title: title,
            description: description.isNotEmpty ? description : null,
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        context.read<ItemBloc>().add(LoadItemsEvent());
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green.shade700,

        title: Text(
          _isEditing ? 'Edit Item' : 'Create New Item',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.check_rounded, color: Colors.white, size: 20),
              ),
              onPressed: _isSubmitting ? null : _submitForm,
              tooltip: 'Save Item',
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.shade100.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        style: GoogleFonts.inter(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.green.shade600,
                          ),
                          hintText: 'Enter a descriptive title',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.title_rounded,
                              color: Colors.green.shade600,
                              size: 20,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.green.shade400,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red.shade400),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Title is required';
                          }
                          if (value.trim().length < 3) {
                            return 'Title must be at least 3 characters';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _descriptionController,
                        style: GoogleFonts.inter(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Description (Optional)',
                          labelStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.green.shade600,
                          ),
                          hintText: 'Add more details about this item',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.description_outlined,
                              color: Colors.green.shade600,
                              size: 20,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.green.shade400,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                        minLines: 2,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submitForm(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32.0),
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade600, Colors.green.shade500],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.shade300.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon:
                        _isSubmitting
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Icon(
                              _isEditing
                                  ? Icons.edit_note_rounded
                                  : Icons.add_circle_outline_rounded,
                              color: Colors.white,
                            ),
                    label: Text(
                      _isSubmitting
                          ? 'Saving...'
                          : (_isEditing ? 'Save Changes' : 'Create Item'),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _submitForm,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
