import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/models/transaction_model.dart';
import 'package:my_app/utils/app_api.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({
    super.key,
    this.transaction,
  });

  final TransactionModel? transaction;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState
    extends State<TransactionFormScreen> {
  final _form = GlobalKey<FormState>();

  late final TextEditingController _amount;
  late final TextEditingController _description;

  late DateTime _date;
  late String _type;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final item = widget.transaction;

    _amount = TextEditingController(
      text: item?.amount.toStringAsFixed(2) ?? '',
    );

    _description = TextEditingController(
      text: item?.description ?? '',
    );

    _date = item?.transactionDate ?? DateTime.now();
    _type = item?.type ?? 'deposit';
  }

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    setState(() => _saving = true);

    final item = TransactionModel(
      id: widget.transaction?.id ?? 0,
      type: _type,
      amount: double.parse(_amount.text),
      transactionDate: _date,
      description: _description.text.trim(),
    );

    try {
      if (widget.transaction == null) {
        await AppApi.post(
          '/transactions',
          item.toPayload(),
          auth: true,
        );
      } else {
        await AppApi.put(
          '/transactions/${widget.transaction!.id}',
          item.toPayload(),
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } on ApiException catch (e) {
      _message(e.message);
    } catch (_) {
      _message('Unable to save the transaction.');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _message(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null
              ? 'Add transaction'
              : 'Edit transaction',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Transaction type',
                style: Theme.of(context).textTheme.titleSmall,
              ),

              const SizedBox(height: 8),

              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'deposit',
                    label: Text('Deposit'),
                    icon: Icon(Icons.south_west),
                  ),
                  ButtonSegment(
                    value: 'withdraw',
                    label: Text('Withdrawal'),
                    icon: Icon(Icons.north_east),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (value) {
                  setState(() => _type = value.first);
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '฿ ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    double.tryParse(value ?? '') == null ||
                            double.parse(value!) <= 0
                        ? 'Amount must be greater than zero.'
                        : null,
              ),

              const SizedBox(height: 16),

              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(
                    color: Colors.grey,
                  ),
                ),
                leading: const Icon(Icons.calendar_today),
                title: const Text('Transaction date'),
                subtitle: Text(
                  DateFormat.yMMMd().format(_date),
                ),
                onTap: _pickDate,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _description,
                maxLength: 255,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Description is required.'
                        : null,
              ),

              const SizedBox(height: 20),

              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.transaction == null
                            ? 'Save transaction'
                            : 'Save changes',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}