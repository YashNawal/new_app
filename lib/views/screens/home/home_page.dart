import 'package:flutter/material.dart';

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
                      Icons.person_add_alt_1,
                      "Add Client",
                    ),

                    _footerButton(
                      Icons.assignment_outlined,
                      "Clients List",
                    ),

                    _footerButton(
                      Icons.currency_exchange,
                      "Lend/Borrow",
                    ),

                    _footerButton(
                      Icons.event_note_outlined,
                      "Reminder List",
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
  Widget _footerButton(IconData icon, String title) {

    return Column(

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
    );
  }
}