import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/service_card.dart';
import '../providers/order_provider.dart';
import 'order_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedService;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _location;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController(text: '1');

  Widget _pickButton(BuildContext context, String label, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () async {
        if (label.contains('Tanggal')) {
          final d = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (d != null) setState(() => _selectedDate = d);
        } else if (label.contains('Waktu')) {
          final t = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (t != null) setState(() => _selectedTime = t);
        } else {
          // simple location dialog
          final loc = await showDialog<String>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Lokasi Penjemputan'),
              content: TextFormField(
                decoration: const InputDecoration(hintText: 'Masukkan alamat'),
                onFieldSubmitted: (v) => Navigator.of(ctx).pop(v),
              ),
            ),
          );
          if (loc != null && loc.isNotEmpty) setState(() => _location = loc);
        }
      },
      icon: Icon(icon, color: Colors.blue),
      label: Text(label, style: const TextStyle(color: Colors.black)),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  void _selectService(String label) {
    setState(() {
      _selectedService = label;
      _titleController.text = label;
    });
  }

  void _placeOrder() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Masukkan nama pesanan')));
      return;
    }
    final provider = Provider.of<OrderProvider>(context, listen: false);
    double price = 0;
    if (provider.isAdmin) {
      price = double.tryParse(_priceController.text) ?? 0;
    } else {
      final qty = double.tryParse(_qtyController.text) ?? 1.0;
      price = provider.getComputedPrice(_selectedService, qty) ?? 0;
    }
    final orderId = provider.addOrder(
      title: _titleController.text,
      description: _descController.text,
      price: price,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Pesanan dibuat')));
    // navigate to detail page so user can see status and details
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderDetailPage(orderId: orderId)),
    );
    // clear form
    setState(() {
      _selectedService = null;
      _selectedDate = null;
      _selectedTime = null;
      _location = null;
      _titleController.clear();
      _descController.clear();
      _priceController.clear();
      _qtyController.text = '1';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Logu Laundry',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/profile'),
                    icon: const Icon(Icons.person_outline),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Icon(Icons.location_on, size: 16),
                  SizedBox(width: 6),
                  Expanded(child: Text('Jl. Melati No. 1, Temanggung')),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(33, 150, 243, 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Expanded(
                      child: Text(
                        'Diskon 10% untuk pelanggan baru!',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Icon(Icons.local_offer),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
                children: [
                  ServiceCard(
                    label: 'Cuci Lipat',
                    icon: Icons.local_laundry_service,
                    onTap: () => _selectService('Cuci Lipat'),
                    selected: _selectedService == 'Cuci Lipat',
                  ),
                  ServiceCard(
                    label: 'Setrika',
                    icon: Icons.iron,
                    onTap: () => _selectService('Setrika'),
                    selected: _selectedService == 'Setrika',
                  ),
                  ServiceCard(
                    label: 'Laundry Kiloan',
                    icon: Icons.invert_colors,
                    onTap: () => _selectService('Laundry Kiloan'),
                    selected: _selectedService == 'Laundry Kiloan',
                  ),
                  ServiceCard(
                    label: 'Baby Care Laundry',
                    icon: Icons.child_care,
                    onTap: () => _selectService('Baby Care Laundry'),
                    selected: _selectedService == 'Baby Care Laundry',
                  ),
                  ServiceCard(
                    label: 'Karpet dan Gorden',
                    icon: Icons.chair,
                    onTap: () => _selectService('Karpet dan Gorden'),
                    selected: _selectedService == 'Karpet dan Gorden',
                  ),
                  ServiceCard(
                    label: 'Selimut dan Bed Cover',
                    icon: Icons.bed,
                    onTap: () => _selectService('Selimut dan Bed Cover'),
                    selected: _selectedService == 'Selimut dan Bed Cover',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Pesan Sekarang',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10, width: double.infinity),
              SizedBox(
                width: double.infinity,
                child: _pickButton(
                  context,
                  _selectedDate == null
                      ? 'Pilih Tanggal Penjemputan'
                      : 'Tanggal: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                  Icons.calendar_month,
                ),
              ),
              const SizedBox(height: 8, width: double.infinity),
              SizedBox(
                width: double.infinity,
                child: _pickButton(
                  context,
                  _selectedTime == null
                      ? 'Pilih Waktu Penjemputan'
                      : 'Waktu: ${_selectedTime!.format(context)}',
                  Icons.schedule,
                ),
              ),
              const SizedBox(height: 8, width: double.infinity),
              SizedBox(
                width: double.infinity,
                child: _pickButton(
                  context,
                  _location == null
                      ? 'Masukkan Lokasi Penjemputan'
                      : 'Lokasi: $_location',
                  Icons.place,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Nama pesanan'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
              ),
              const SizedBox(height: 8),
              // Quantity: admin can set/override; users see the default quantity configured by admin and cannot edit
              Consumer<OrderProvider>(
                builder: (context, prov, _) {
                  final unit = prov.getUnitByName(_selectedService) ?? '';
                  final defaultQty =
                      prov.getDefaultQuantity(_selectedService) ?? 1.0;
                  if (prov.isAdmin) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _qtyController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Jumlah',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(unit.isNotEmpty ? unit : '-'),
                        ),
                      ],
                    );
                  }

                  // user view: show default qty as read-only
                  _qtyController.text = defaultQty.toString();
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _qtyController,
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Jumlah',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(unit.isNotEmpty ? unit : '-'),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              // Price: editable only for admin; users see computed price based on qty and unit
              Consumer<OrderProvider>(
                builder: (context, prov, _) {
                  final basePrice = prov.getPriceByName(_selectedService);
                  final unit = prov.getUnitByName(_selectedService) ?? '';
                  final qty = double.tryParse(_qtyController.text) ?? 1.0;
                  final computed = prov.getComputedPrice(_selectedService, qty);
                  if (prov.isAdmin) {
                    return TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Harga'),
                      keyboardType: TextInputType.number,
                    );
                  }
                  return TextFormField(
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Harga',
                      hintText: computed != null
                          ? '${computed.toStringAsFixed(0)} (${basePrice?.toStringAsFixed(0) ?? '-'} per ${unit.isNotEmpty ? unit : 'unit'})'
                          : 'Pilih layanan untuk melihat harga',
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B57D0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Pesan Sekarang',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              const Text(
                'Riwayat Pesanan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Consumer<OrderProvider>(
                builder: (context, prov, _) {
                  final orders = prov.orders.reversed.toList();
                  if (orders.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.04),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Text('Belum ada riwayat pesanan'),
                    );
                  }

                  return Column(
                    children: orders.map((o) {
                      final statusLabel = o.status.toString().split('.').last;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.receipt_long,
                                color: Color(0xFF0B57D0),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pesanan #${o.id}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(statusLabel),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          OrderDetailPage(orderId: o.id),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFFE7F0FF),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Lihat Detail',
                                  style: TextStyle(color: Color(0xFF0B57D0)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
