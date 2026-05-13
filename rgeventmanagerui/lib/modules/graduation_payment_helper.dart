import 'package:rg_event_management_ui/models/Event.dart';
import 'package:rg_event_management_ui/models/Student.dart';

class AdditionalPaymentResult {
  final int persons;
  final double balance;

  AdditionalPaymentResult({required this.persons, required this.balance});
}

class GraduationPaymentHelper {
  static const String ADDITIONAL = 'adicional';

  /// Calculates the number of additional persons and remaining balance
  /// from a payment amount + any existing balance in favor.
  static AdditionalPaymentResult calculateAdditionalPersons({
    required double paymentAmount,
    required double additionalCostPerPerson,
    double existingBalance = 0.0,
  }) {
    if (additionalCostPerPerson <= 0) {
      return AdditionalPaymentResult(persons: 0, balance: 0.0);
    }
    double effectiveAmount = paymentAmount + existingBalance;
    int fullPersons = (effectiveAmount / additionalCostPerPerson).floor();
    double newBalance = effectiveAmount - (fullPersons * additionalCostPerPerson);
    return AdditionalPaymentResult(
      persons: fullPersons,
      balance: double.parse(newBalance.toStringAsFixed(2)),
    );
  }

  /// Calculates the total paid for dish/package payments.
  static double totalPaidForDishOrPackage(List<Payment> payments) {
    var filtered = payments
        .where((e) => e.paymentDetail == 'platillo' || e.paymentDetail == 'paquete')
        .toList();
    if (filtered.isEmpty) return 0.0;
    return filtered.map((e) => e.amount).reduce((a, b) => a + b);
  }

  /// Checks if the student has fully paid their dish/package.
  static bool isDishOrPackageFullyPaid(Student student) {
    return student.totalCost > 0 &&
        student.totalCost - totalPaidForDishOrPackage(student.payments) <= 0;
  }

  /// Checks if the current payment would complete the dish/package payment.
  static bool willCompletePayment(Student student, double paymentAmount) {
    double totalPaid = totalPaidForDishOrPackage(student.payments);
    return student.totalCost <= totalPaid + paymentAmount;
  }

  /// Validates if a dish/package payment exceeds the total cost.
  /// Returns the max allowed amount, or null if the payment is valid.
  static double? validatePaymentExceedsTotalCost(
      Student student, double paymentAmount) {
    double totalPaid = totalPaidForDishOrPackage(student.payments);
    double totalAmount = totalPaid + paymentAmount;
    if (totalAmount > student.totalCost) {
      return paymentAmount - (totalAmount - student.totalCost);
    }
    return null;
  }

  /// Calculates the cost for a given package type.
  static double calculateCost({
    required String packageType,
    required Pricing pricing,
    required int dishCount,
    required bool hasPackages,
  }) {
    if (hasPackages) {
      switch (packageType) {
        case 'paq10ti':
          return pricing.paq10TICost;
        case 'paq10sp':
          return pricing.paq10SPCost;
        case 'paq5ti':
          return pricing.paq5TIPCost;
        case 'paq5sp':
          return pricing.paq5SPCost;
        case 'paq20':
          return pricing.paq10DoubleCost;
        default:
          return 0.0;
      }
    } else {
      return dishCount * pricing.dishCost;
    }
  }

  /// Calculates IVA (16%) for transfer payments.
  static double calculateIva(double amount) {
    return double.parse((amount * 0.16).toStringAsFixed(2));
  }

  /// Calculates total paid for additional payments.
  static double totalPaidForAdditional(List<Payment> payments) {
    var filtered =
        payments.where((e) => e.paymentDetail == ADDITIONAL).toList();
    if (filtered.isEmpty) return 0.0;
    return filtered.map((e) => e.amount).reduce((a, b) => a + b);
  }

  /// Recalculates the additional balance after deleting a payment.
  static double recalculateBalanceAfterDelete({
    required List<Payment> remainingPayments,
    required int remainingAdditionalNumber,
    required double additionalCostPerPerson,
  }) {
    if (additionalCostPerPerson <= 0) return 0.0;
    double totalAdditionalPaid = totalPaidForAdditional(remainingPayments);
    double totalPersonsCost = remainingAdditionalNumber * additionalCostPerPerson;
    double balance = totalAdditionalPaid - totalPersonsCost;
    return balance < 0 ? 0.0 : double.parse(balance.toStringAsFixed(2));
  }

  /// Calculates the remaining amount for additional services.
  static double calculateAdditionalRemaining(Student student) {
    return student.additionalQuantity - totalPaidForAdditional(student.payments);
  }

  /// Returns the remaining amount for additionals display.
  /// If there's a balance in favor, returns 0.
  static double getDisplayRemaining(Student student) {
    if (student.additionalBalance > 0) return 0.0;
    double remaining = calculateAdditionalRemaining(student);
    return remaining < 0 ? 0.0 : remaining;
  }
}
