import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';

class OrderAddPage extends StatefulWidget {
  const OrderAddPage({super.key});

  @override
  State<OrderAddPage> createState() => _OrderAddPageState();
}

class _OrderAddPageState extends State<OrderAddPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  String _desc = '';
  String _price = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty) {
      _titleController.text = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Pesanan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Nama pesanan'),
                onSaved: (v) =>
                    _titleController.text = v ?? _titleController.text,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Masukkan nama' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                onSaved: (v) => _desc = v ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _price = v ?? '0',
                validator: (v) => (v == null || double.tryParse(v) == null)
                    ? 'Masukkan angka'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    provider.addOrder(
                      title: _titleController.text,
                      description: _desc,
                      price: double.parse(_price),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
