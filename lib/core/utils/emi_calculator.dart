import 'dart:math';

class EMICalculator {
  /// Calculates the Equated Monthly Installment (EMI).
  /// P = Principal amount
  /// R = Annual interest rate in percentage
  /// N = Tenure in months
  static double calculateEMI(double p, double annualRate, int n) {
    if (p <= 0 || annualRate <= 0 || n <= 0) return 0;

    // Monthly interest rate
    double r = annualRate / (12 * 100);

    // EMI Formula: [P x R x (1+R)^N] / [(1+R)^N - 1]
    double emi = (p * r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
    
    return double.parse(emi.toStringAsFixed(2));
  }

  /// Calculates monthly interest based on remaining balance.
  static double calculateMonthlyInterest(double balance, double annualRate) {
    return (balance * (annualRate / 100)) / 12;
  }
}
