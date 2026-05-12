import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:borrow_manager/views/screens/clients/add_client_page.dart';
import 'package:borrow_manager/views/screens/clients/clients_list_page.dart';
import 'package:borrow_manager/views/screens/transactions/lend_borrow_page.dart';
import 'package:borrow_manager/views/screens/reminders/reminder_list_page.dart';
import 'package:borrow_manager/viewmodels/transaction_viewmodel.dart';
import 'package:borrow_manager/viewmodels/client_viewmodel.dart';
import 'package:borrow_manager/data/models/client.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const HomePage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF4F1F2),

      // ---------------- APP BAR ----------------
      appBar: AppBar(

        backgroundColor: const Color(0xFF009688),

        elevation: 0,

        title: const Text(
          "Borrow Manager",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),

        actions: [

          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
          ),
        ],
      ),

      // ---------------- BODY ----------------
      body: SingleChildScrollView(

        child: Padding(

          padding: const EdgeInsets.all(14),

          child: Column(

            children: [

              // ---------------- BALANCE CARD ----------------
              Container(

                width: double.infinity,

                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius: BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    // BALANCE
                    Row(

                      children: [

                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 32,
                          color: Colors.grey.shade500,
                        ),

                        const SizedBox(width: 10),

                        Column(

                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            Text(
                              "Balance",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade900,
                              ),
                            ),

                            const SizedBox(height: 0),

                            Text(
                              "₹0.0",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 0),

                    // GAVE + RECEIVED
                    Row(

                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                      children: [

                        // GAVE
                        Expanded(

                          child: Row(

                            children: [

                              const Icon(
                                Icons.arrow_upward,
                                color: Colors.redAccent,
                                size: 35,
                              ),

                              const SizedBox(width: 0),

                              Column(

                                crossAxisAlignment:
                                CrossAxisAlignment.start,

                                children: const [

                                  Text(
                                    "Gave",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),

                                  SizedBox(height: 0),

                                  Text(
                                    "₹0.0",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Container(
                          width: 1,
                          height: 80,
                          color: Colors.grey.shade300,
                        ),

                        // RECEIVED
                        Expanded(

                          child: Row(

                            mainAxisAlignment:
                            MainAxisAlignment.end,

                            children: [

                              const Icon(
                                Icons.arrow_downward,
                                color: Colors.green,
                                size: 35,
                              ),

                              const SizedBox(width: 0),

                              Column(

                                crossAxisAlignment:
                                CrossAxisAlignment.start,

                                children: const [

                                  Text(
                                    "Received",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),

                                  SizedBox(height: 0),

                                  Text(
                                    "₹0.0",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // ---------------- BOTTOM ACTION BUTTONS ----------------
              Container(

                padding: const EdgeInsets.symmetric(vertical: 10),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Row(

                  mainAxisAlignment:
                  MainAxisAlignment.spaceAround,

                  children: [

                    _footerButton(

                      icon: Icons.person_add_alt_1,

                      title: "Add Client",

                      onTap: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(
                            builder: (context) => const AddClientPage(),
                          ),
                        );
                      },
                    ),

                    _footerButton(

                      icon: Icons.assignment_outlined,

                      title: "Clients List",

                      onTap: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(
                            builder: (context) => const ClientsListPage(),
                          ),
                        );
                      },
                    ),
                    _footerButton(

                      icon: Icons.currency_exchange,

                      title: "Lend/Borrow",

                      onTap: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(
                            builder: (context) => const LendBorrowPage(),
                          ),
                        );
                      },
                    ),
                    _footerButton(

                      icon: Icons.event_note_outlined,

                      title: "Reminder List",

                      onTap: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(
                            builder: (context) => const ReminderListPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- FOOTER BUTTON ----------------
  Widget _footerButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {

    return InkWell(

      borderRadius: BorderRadius.circular(15),

      onTap: onTap,

      child: Column(

        mainAxisSize: MainAxisSize.min,

        children: [

          Container(

            width: 75,
            height: 75,

            decoration: BoxDecoration(

              border: Border.all(
                color: Colors.grey.shade300,
              ),

              borderRadius: BorderRadius.circular(15),
            ),

            child: Icon(
              icon,
              size: 35,
              color: const Color(0xFF00B3A4),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(

            width: 80,

            child: Text(
              title,
              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}