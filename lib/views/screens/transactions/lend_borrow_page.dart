import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:borrow_manager/viewmodels/client_viewmodel.dart';
import 'package:borrow_manager/data/models/client.dart';

class LendBorrowPage extends StatefulWidget {
  const LendBorrowPage({super.key});

  @override
  State<LendBorrowPage> createState() => _LendBorrowPageState();
}

class _LendBorrowPageState extends State<LendBorrowPage> {

  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _remarkController = TextEditingController();


  Client? _selectedClient;

  bool _showClientDetails = false;
  bool _isGave = true;

  DateTime _entryDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientViewModel>().fetchClients();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF4F4F4),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF009688),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),

        title: const Text(
          "Lend/Borrow",
          style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w500,
          ),
        ),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(18),

        child: Form(
          key: _formKey,

          child: Column(
            children: [

              /// CLIENT SECTION

              Container(

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),

                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),

                child: Column(
                  children: [

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        /// IMAGE

                        Column(
                          children: [

                            Container(
                              padding: const EdgeInsets.all(3),

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade500,
                                  width: 2,
                                ),
                              ),

                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,

                                backgroundImage:
                                _selectedClient?.imagePath != null
                                    ? FileImage(
                                  File(_selectedClient!.imagePath!),
                                )
                                    : null,

                                child:
                                _selectedClient?.imagePath == null
                                    ? Icon(
                                  Icons.person_outline,
                                  size: 60,
                                  color: Colors.grey.shade600,
                                )
                                    : null,
                              ),
                            ),
                            const SizedBox(width:30,height: 10),

                            const Text(
                              "Add Photo",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 20),

                        /// RIGHT SIDE

                        Expanded(
                          child: Column(
                            children: [

                              /// CLIENT NAME

                              Row(
                                children: [

                                  Expanded(
                                    child: Autocomplete<Client>(

                                      displayStringForOption: (Client option) => option.name,

                                      optionsBuilder: (TextEditingValue textValue) {

                                        if (textValue.text.isEmpty) {
                                          return const Iterable<Client>.empty();
                                        }

                                        return context
                                            .read<ClientViewModel>()
                                            .clients
                                            .where(
                                              (client) => client.name
                                              .toLowerCase()
                                              .contains(
                                            textValue.text.toLowerCase(),
                                          ),
                                        );
                                      },

                                      onSelected: (Client selectedClient) {

                                        setState(() {
                                          _selectedClient = selectedClient;
                                        });
                                      },

                                      fieldViewBuilder:
                                          (
                                          context,
                                          controller,
                                          focusNode,
                                          onEditingComplete,
                                          ) {

                                        return TextFormField(

                                          controller: controller,
                                          focusNode: focusNode,
                                          

                                          style: const TextStyle(
                                            fontSize: 20,
                                          ),

                                          decoration: const InputDecoration(

                                            labelText: "Client Name *",

                                            labelStyle: TextStyle(
                                              fontSize: 20,
                                              color: Colors.grey,
                                            ),

                                            border: InputBorder.none,

                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.search,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 26),

                              /// MOBILE

                              TextFormField(

                                initialValue:
                                _selectedClient?.mobile ?? "",

                                style: const TextStyle(
                                  fontSize: 22,
                                ),

                                decoration: const InputDecoration(

                                  hintText: "Mobile *",

                                  hintStyle: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey,
                                  ),

                                  border: InputBorder.none,

                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),

                    /// EXPANDABLE SECTION

                    if (_showClientDetails) ...[

                      const SizedBox(height: 10),

                      const Align(
                        alignment: Alignment.centerLeft,


                        child: Padding(
                          padding: const EdgeInsets.only(left: 95),

                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    Align(
                      alignment: Alignment.bottomRight,

                      child: GestureDetector(

                        onTap: () {
                          setState(() {
                            _showClientDetails =
                            !_showClientDetails;
                          });
                        },

                        child: Icon(
                          _showClientDetails
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 36,
                          color: Colors.grey,


                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              /// TRANSACTION SECTION

              Container(

                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),

                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),

                child: Column(
                  children: [

                    /// AMOUNT

                    TextFormField(
                      controller: _amountController,

                      keyboardType: TextInputType.number,

                      style: const TextStyle(
                        fontSize: 22,
                      ),

                      decoration: const InputDecoration(
                        hintText: "Amount *",

                        hintStyle: TextStyle(
                          fontSize: 22,
                          color: Colors.grey,
                        ),

                        border: InputBorder.none,

                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// REMARK

                    TextFormField(
                      controller: _remarkController,

                      style: const TextStyle(
                        fontSize: 22,
                      ),

                      decoration: const InputDecoration(
                        hintText: "Remark",

                        hintStyle: TextStyle(
                          fontSize: 22,
                          color: Colors.grey,
                        ),

                        border: InputBorder.none,

                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// DATES

                    Row(
                      children: [

                        const Expanded(
                          flex: 3,

                          child: Text(
                            "Entry Date:",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 5,

                          child: Text(
                            DateFormat(
                              'dd-MM-yyyy',
                            ).format(_entryDate),

                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black54,
                            ),
                          ),
                        ),

                        const Icon(
                          Icons.edit_calendar_outlined,
                          color: Color(0xFF0097A7),
                          size: 38,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [

                        const Expanded(
                          child: Text(
                            "           Due:",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ),

                        const Icon(
                          Icons.calendar_month_outlined,
                          color: Color(0xFF0097A7),
                          size: 38,
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [

                        const Expanded(
                          child: Text(
                            " Reminder",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ),

                        const Icon(
                          Icons.add_alert_outlined,
                          color: Color(0xFF0097A7),
                          size: 38,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              /// GAVE / RECEIVED

              Container(

                height: 70,
                width: 300,

                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF009688),
                    width: 1,
                  ),

                  borderRadius: BorderRadius.circular(12),
                ),


                child: Row(
                  children: [

                    Expanded(
                      child: GestureDetector(

                        onTap: () {
                          setState(() {
                            _isGave = true;
                          });
                        },

                        child: Container(

                          color:
                          _isGave
                              ? const Color(0xFF17A89B)
                              : Colors.white,

                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,

                            children: [

                              Icon(
                                Icons.arrow_upward,
                                color:
                                _isGave
                                    ? Colors.red
                                    : Colors.green,
                                size: 42,
                              ),

                              const SizedBox(width: 10),

                              Text(
                                "Gave",
                                style: TextStyle(
                                  fontSize: 20,
                                  color:
                                  _isGave
                                      ? Colors.black
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: GestureDetector(

                        onTap: () {
                          setState(() {
                            _isGave = false;
                          });
                        },

                        child: Container(
                          color:
                          !_isGave
                              ? const Color(0xFF17A89B)
                              : Colors.white,

                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,

                            children: [

                              Icon(
                                Icons.arrow_downward,
                                color: Colors.green,
                                size: 42,
                              ),

                              const SizedBox(width: 10),

                              Text(
                                "Received",
                                style: TextStyle(
                                  fontSize: 20,
                                  color:
                                  !_isGave
                                      ? Colors.black
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              /// PAYMENT TYPE

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(12),

                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),

                child: DropdownButtonFormField<String>(

                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),

                  value: "-",


                  items: const [
                    DropdownMenuItem(
                      value: "-",
                      child: Text("Payment Type"),
                    ),

                  ],

                  onChanged: (val) {},
                ),
              ),

              const SizedBox(height: 15),

              /// SAVE BUTTON

              SizedBox(
                width: double.infinity,
                height: 60,

                child: ElevatedButton(

                  onPressed: () {},

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009688),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),

                  child: const Text(
                    "SAVE",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}