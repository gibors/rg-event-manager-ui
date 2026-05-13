import 'package:flutter_test/flutter_test.dart';
import 'package:rg_event_management_ui/models/Event.dart';
import 'package:rg_event_management_ui/models/Student.dart';
import 'package:rg_event_management_ui/modules/graduation_payment_helper.dart';

// ── Helpers to build test objects ──

Payment _makePayment({
  double amount = 0.0,
  String paymentDetail = 'platillo',
  String paymentMethod = 'Efectivo',
  int quantity = 0,
}) {
  return Payment(
    id: -1,
    amount: amount,
    paymentMethod: paymentMethod,
    paymentDate: DateTime.now(),
    studentId: 1,
    eventId: 1,
    addedBy: '',
    paymentDetail: paymentDetail,
    iva: 0,
    quantity: quantity,
  );
}

Student _makeStudent({
  double totalCost = 5000.0,
  List<Payment>? payments,
  String folio = '',
  String packageType = '',
  double additionalQuantity = 0.0,
  int additionalNumber = 0,
  double additionalBalance = 0.0,
  bool paid = false,
  bool cancelled = false,
  bool hasPreParty = false,
  bool hasSouvenir = false,
  bool hasBracelet = false,
}) {
  return Student(
    id: 1,
    name: 'Test',
    lastName: 'Student',
    age: 20,
    email: 'test@test.com',
    phone: '1234567890',
    packageType: packageType,
    additionalQuantity: additionalQuantity,
    totalCost: totalCost,
    eventId: 1,
    comments: '',
    payments: payments ?? [],
    folio: folio,
    dishCount: 0,
    additionalNumber: additionalNumber,
    hasPreParty: hasPreParty,
    hasSouvenir: hasSouvenir,
    hasBracelet: hasBracelet,
    paid: paid,
    cancelled: cancelled,
    additionalBalance: additionalBalance,
  );
}

Pricing _makePricing({
  double dishCost = 200.0,
  double additionalCost = 200.0,
  double paq10TICost = 5000.0,
  double paq10SPCost = 4500.0,
  double paq5TIPCost = 3000.0,
  double paq5SPCost = 2500.0,
  double paq10DoubleCost = 9000.0,
  double prePartyCost = 150.0,
  double braceletCost = 50.0,
  double souvenirCost = 100.0,
}) {
  return Pricing(
    id: 1,
    dishCost: dishCost,
    additionalCost: additionalCost,
    paq10TICost: paq10TICost,
    paq10SPCost: paq10SPCost,
    paq5TIPCost: paq5TIPCost,
    paq5SPCost: paq5SPCost,
    paq10DoubleCost: paq10DoubleCost,
    prePartyCost: prePartyCost,
    braceletCost: braceletCost,
    childrenCost: 0,
    youngCost: 0,
    souvenirCost: souvenirCost,
  );
}

// ══════════════════════════════════════════════════════════════════════
//  Tests
// ══════════════════════════════════════════════════════════════════════

void main() {
  // ─── calculateAdditionalPersons ───────────────────────────────────

  group('calculateAdditionalPersons', () {
    test('exact amount for 3 persons, no balance', () {
      final result = GraduationPaymentHelper.calculateAdditionalPersons(
        paymentAmount: 600,
        additionalCostPerPerson: 200,
      );
      expect(result.persons, 3);
      expect(result.balance, 0.0);
    });

    test('amount with remainder leaves balance in favor', () {
      final result = GraduationPaymentHelper.calculateAdditionalPersons(
        paymentAmount: 500,
        additionalCostPerPerson: 200,
      );
      expect(result.persons, 2);
      expect(result.balance, 100.0);
    });

    test('existing balance combines with payment', () {
      // 550 payment + 50 existing balance = 600 => 3 persons, 0 balance
      final result = GraduationPaymentHelper.calculateAdditionalPersons(
        paymentAmount: 550,
        additionalCostPerPerson: 200,
        existingBalance: 50,
      );
      expect(result.persons, 3);
      expect(result.balance, 0.0);
    });

    test('existing balance combines with payment leaving remainder', () {
      // 400 payment + 50 balance = 450 => 2 persons, 50 balance
      final result = GraduationPaymentHelper.calculateAdditionalPersons(
        paymentAmount: 400,
        additionalCostPerPerson: 200,
        existingBalance: 50,
      );
      expect(result.persons, 2);
      expect(result.balance, 50.0);
    });

    test('payment less than one person cost keeps full balance', () {
      final result = GraduationPaymentHelper.calculateAdditionalPersons(
        paymentAmount: 100,
        additionalCostPerPerson: 200,
      );
      expect(result.persons, 0);
      expect(result.balance, 100.0);
    });

    test('small payment with existing balance reaches one person', () {
      // 50 payment + 150 balance = 200 => 1 person, 0 balance
      final result = GraduationPaymentHelper.calculateAdditionalPersons(
        paymentAmount: 50,
        additionalCostPerPerson: 200,
        existingBalance: 150,
      );
      expect(result.persons, 1);
      expect(result.balance, 0.0);
    });

    test('zero payment with balance works correctly', () {
      final result = GraduationPaymentHelper.calculateAdditionalPersons(
        paymentAmount: 0,
        additionalCostPerPerson: 200,
        existingBalance: 100,
      );
      expect(result.persons, 0);
      expect(result.balance, 100.0);
    });

    test('zero cost per person returns 0 persons and 0 balance', () {
      final result = GraduationPaymentHelper.calculateAdditionalPersons(
        paymentAmount: 500,
        additionalCostPerPerson: 0,
      );
      expect(result.persons, 0);
      expect(result.balance, 0.0);
    });

    test('negative cost per person returns 0 persons and 0 balance', () {
      final result = GraduationPaymentHelper.calculateAdditionalPersons(
        paymentAmount: 500,
        additionalCostPerPerson: -100,
      );
      expect(result.persons, 0);
      expect(result.balance, 0.0);
    });

    test('large payment calculates many persons correctly', () {
      final result = GraduationPaymentHelper.calculateAdditionalPersons(
        paymentAmount: 10050,
        additionalCostPerPerson: 200,
      );
      expect(result.persons, 50);
      expect(result.balance, 50.0);
    });

    test('balance precision is maintained to 2 decimals', () {
      // 100 / 30 = 3.333... => 3 persons, 100 - 90 = 10.0
      final result = GraduationPaymentHelper.calculateAdditionalPersons(
        paymentAmount: 100,
        additionalCostPerPerson: 30,
      );
      expect(result.persons, 3);
      expect(result.balance, 10.0);
    });

    test('fractional cost per person with remainder', () {
      // 250 / 75.50 = 3.31.. => 3 persons, 250 - 226.50 = 23.50
      final result = GraduationPaymentHelper.calculateAdditionalPersons(
        paymentAmount: 250,
        additionalCostPerPerson: 75.50,
      );
      expect(result.persons, 3);
      expect(result.balance, 23.5);
    });
  });

  // ─── totalPaidForDishOrPackage ────────────────────────────────────

  group('totalPaidForDishOrPackage', () {
    test('no payments returns 0', () {
      expect(GraduationPaymentHelper.totalPaidForDishOrPackage([]), 0.0);
    });

    test('sums only platillo payments', () {
      final payments = [
        _makePayment(amount: 1000, paymentDetail: 'platillo'),
        _makePayment(amount: 500, paymentDetail: 'platillo'),
        _makePayment(amount: 200, paymentDetail: 'adicional'),
      ];
      expect(GraduationPaymentHelper.totalPaidForDishOrPackage(payments), 1500.0);
    });

    test('sums only paquete payments', () {
      final payments = [
        _makePayment(amount: 2000, paymentDetail: 'paquete'),
        _makePayment(amount: 1000, paymentDetail: 'paquete'),
      ];
      expect(GraduationPaymentHelper.totalPaidForDishOrPackage(payments), 3000.0);
    });

    test('sums both platillo and paquete', () {
      final payments = [
        _makePayment(amount: 1000, paymentDetail: 'platillo'),
        _makePayment(amount: 2000, paymentDetail: 'paquete'),
      ];
      expect(GraduationPaymentHelper.totalPaidForDishOrPackage(payments), 3000.0);
    });

    test('ignores non-dish/package payments', () {
      final payments = [
        _makePayment(amount: 500, paymentDetail: 'adicional'),
        _makePayment(amount: 300, paymentDetail: 'souvenir'),
        _makePayment(amount: 150, paymentDetail: 'pre-fiesta'),
      ];
      expect(GraduationPaymentHelper.totalPaidForDishOrPackage(payments), 0.0);
    });
  });

  // ─── isDishOrPackageFullyPaid ─────────────────────────────────────

  group('isDishOrPackageFullyPaid', () {
    test('fully paid returns true', () {
      final student = _makeStudent(
        totalCost: 5000,
        payments: [_makePayment(amount: 5000, paymentDetail: 'paquete')],
      );
      expect(GraduationPaymentHelper.isDishOrPackageFullyPaid(student), true);
    });

    test('overpaid returns true', () {
      final student = _makeStudent(
        totalCost: 5000,
        payments: [
          _makePayment(amount: 3000, paymentDetail: 'paquete'),
          _makePayment(amount: 2500, paymentDetail: 'paquete'),
        ],
      );
      expect(GraduationPaymentHelper.isDishOrPackageFullyPaid(student), true);
    });

    test('partially paid returns false', () {
      final student = _makeStudent(
        totalCost: 5000,
        payments: [_makePayment(amount: 3000, paymentDetail: 'paquete')],
      );
      expect(GraduationPaymentHelper.isDishOrPackageFullyPaid(student), false);
    });

    test('no payments returns false', () {
      final student = _makeStudent(totalCost: 5000);
      expect(GraduationPaymentHelper.isDishOrPackageFullyPaid(student), false);
    });

    test('zero total cost returns false', () {
      final student = _makeStudent(totalCost: 0);
      expect(GraduationPaymentHelper.isDishOrPackageFullyPaid(student), false);
    });

    test('additional payments do not count toward dish/package', () {
      final student = _makeStudent(
        totalCost: 5000,
        payments: [_makePayment(amount: 5000, paymentDetail: 'adicional')],
      );
      expect(GraduationPaymentHelper.isDishOrPackageFullyPaid(student), false);
    });
  });

  // ─── willCompletePayment ──────────────────────────────────────────

  group('willCompletePayment', () {
    test('exact remaining amount completes payment', () {
      final student = _makeStudent(
        totalCost: 5000,
        payments: [_makePayment(amount: 3000, paymentDetail: 'platillo')],
      );
      expect(GraduationPaymentHelper.willCompletePayment(student, 2000), true);
    });

    test('more than remaining completes payment', () {
      final student = _makeStudent(
        totalCost: 5000,
        payments: [_makePayment(amount: 3000, paymentDetail: 'platillo')],
      );
      expect(GraduationPaymentHelper.willCompletePayment(student, 3000), true);
    });

    test('less than remaining does not complete', () {
      final student = _makeStudent(
        totalCost: 5000,
        payments: [_makePayment(amount: 3000, paymentDetail: 'platillo')],
      );
      expect(GraduationPaymentHelper.willCompletePayment(student, 1000), false);
    });

    test('no prior payments, full amount completes', () {
      final student = _makeStudent(totalCost: 5000);
      expect(GraduationPaymentHelper.willCompletePayment(student, 5000), true);
    });

    test('no prior payments, partial amount does not complete', () {
      final student = _makeStudent(totalCost: 5000);
      expect(GraduationPaymentHelper.willCompletePayment(student, 4999), false);
    });
  });

  // ─── validatePaymentExceedsTotalCost ──────────────────────────────

  group('validatePaymentExceedsTotalCost', () {
    test('valid payment returns null', () {
      final student = _makeStudent(
        totalCost: 5000,
        payments: [_makePayment(amount: 3000, paymentDetail: 'platillo')],
      );
      expect(
        GraduationPaymentHelper.validatePaymentExceedsTotalCost(student, 2000),
        isNull,
      );
    });

    test('exact remaining returns null', () {
      final student = _makeStudent(
        totalCost: 5000,
        payments: [_makePayment(amount: 3000, paymentDetail: 'platillo')],
      );
      expect(
        GraduationPaymentHelper.validatePaymentExceedsTotalCost(student, 2000),
        isNull,
      );
    });

    test('exceeding payment returns max allowed', () {
      final student = _makeStudent(
        totalCost: 5000,
        payments: [_makePayment(amount: 3000, paymentDetail: 'platillo')],
      );
      // Trying to pay 3000, but only 2000 remaining => max 2000
      expect(
        GraduationPaymentHelper.validatePaymentExceedsTotalCost(student, 3000),
        2000.0,
      );
    });

    test('no prior payments, exceeding returns max allowed', () {
      final student = _makeStudent(totalCost: 5000);
      expect(
        GraduationPaymentHelper.validatePaymentExceedsTotalCost(student, 6000),
        5000.0,
      );
    });

    test('already fully paid, any payment exceeds', () {
      final student = _makeStudent(
        totalCost: 5000,
        payments: [_makePayment(amount: 5000, paymentDetail: 'paquete')],
      );
      expect(
        GraduationPaymentHelper.validatePaymentExceedsTotalCost(student, 100),
        closeTo(-100 + 100, 0.01), // 100 - (5100 - 5000) = 0
      );
    });
  });

  // ─── calculateCost ────────────────────────────────────────────────

  group('calculateCost', () {
    final pricing = _makePricing();

    test('paq10ti returns correct cost', () {
      expect(
        GraduationPaymentHelper.calculateCost(
          packageType: 'paq10ti',
          pricing: pricing,
          dishCount: 0,
          hasPackages: true,
        ),
        5000.0,
      );
    });

    test('paq10sp returns correct cost', () {
      expect(
        GraduationPaymentHelper.calculateCost(
          packageType: 'paq10sp',
          pricing: pricing,
          dishCount: 0,
          hasPackages: true,
        ),
        4500.0,
      );
    });

    test('paq5ti returns correct cost', () {
      expect(
        GraduationPaymentHelper.calculateCost(
          packageType: 'paq5ti',
          pricing: pricing,
          dishCount: 0,
          hasPackages: true,
        ),
        3000.0,
      );
    });

    test('paq5sp returns correct cost', () {
      expect(
        GraduationPaymentHelper.calculateCost(
          packageType: 'paq5sp',
          pricing: pricing,
          dishCount: 0,
          hasPackages: true,
        ),
        2500.0,
      );
    });

    test('paq20 returns correct cost', () {
      expect(
        GraduationPaymentHelper.calculateCost(
          packageType: 'paq20',
          pricing: pricing,
          dishCount: 0,
          hasPackages: true,
        ),
        9000.0,
      );
    });

    test('unknown package type returns 0', () {
      expect(
        GraduationPaymentHelper.calculateCost(
          packageType: 'unknown',
          pricing: pricing,
          dishCount: 0,
          hasPackages: true,
        ),
        0.0,
      );
    });

    test('dish count multiplied by dish cost when no packages', () {
      expect(
        GraduationPaymentHelper.calculateCost(
          packageType: '',
          pricing: pricing,
          dishCount: 5,
          hasPackages: false,
        ),
        1000.0, // 5 * 200
      );
    });

    test('zero dish count returns 0', () {
      expect(
        GraduationPaymentHelper.calculateCost(
          packageType: '',
          pricing: pricing,
          dishCount: 0,
          hasPackages: false,
        ),
        0.0,
      );
    });

    test('dish cost with large count', () {
      expect(
        GraduationPaymentHelper.calculateCost(
          packageType: '',
          pricing: _makePricing(dishCost: 350),
          dishCount: 10,
          hasPackages: false,
        ),
        3500.0,
      );
    });
  });

  // ─── calculateIva ─────────────────────────────────────────────────

  group('calculateIva', () {
    test('calculates 16% correctly', () {
      expect(GraduationPaymentHelper.calculateIva(1000), 160.0);
    });

    test('rounds to 2 decimal places', () {
      expect(GraduationPaymentHelper.calculateIva(333.33), 53.33);
    });

    test('zero amount returns 0', () {
      expect(GraduationPaymentHelper.calculateIva(0), 0.0);
    });

    test('small amount precision', () {
      expect(GraduationPaymentHelper.calculateIva(100), 16.0);
    });
  });

  // ─── totalPaidForAdditional ───────────────────────────────────────

  group('totalPaidForAdditional', () {
    test('no payments returns 0', () {
      expect(GraduationPaymentHelper.totalPaidForAdditional([]), 0.0);
    });

    test('sums only additional payments', () {
      final payments = [
        _makePayment(amount: 400, paymentDetail: 'adicional'),
        _makePayment(amount: 200, paymentDetail: 'adicional'),
        _makePayment(amount: 5000, paymentDetail: 'paquete'),
      ];
      expect(GraduationPaymentHelper.totalPaidForAdditional(payments), 600.0);
    });

    test('no additional payments returns 0', () {
      final payments = [
        _makePayment(amount: 5000, paymentDetail: 'paquete'),
        _makePayment(amount: 150, paymentDetail: 'pre-fiesta'),
      ];
      expect(GraduationPaymentHelper.totalPaidForAdditional(payments), 0.0);
    });
  });

  // ─── recalculateBalanceAfterDelete ────────────────────────────────

  group('recalculateBalanceAfterDelete', () {
    test('no remaining payments returns 0', () {
      expect(
        GraduationPaymentHelper.recalculateBalanceAfterDelete(
          remainingPayments: [],
          remainingAdditionalNumber: 0,
          additionalCostPerPerson: 200,
        ),
        0.0,
      );
    });

    test('remaining payments with balance returns correct balance', () {
      // Paid 500 for 2 persons (400 cost) => balance 100
      final payments = [
        _makePayment(amount: 500, paymentDetail: 'adicional'),
      ];
      expect(
        GraduationPaymentHelper.recalculateBalanceAfterDelete(
          remainingPayments: payments,
          remainingAdditionalNumber: 2,
          additionalCostPerPerson: 200,
        ),
        100.0,
      );
    });

    test('remaining payments exactly cover persons returns 0', () {
      final payments = [
        _makePayment(amount: 400, paymentDetail: 'adicional'),
      ];
      expect(
        GraduationPaymentHelper.recalculateBalanceAfterDelete(
          remainingPayments: payments,
          remainingAdditionalNumber: 2,
          additionalCostPerPerson: 200,
        ),
        0.0,
      );
    });

    test('negative balance clamped to 0', () {
      // Paid 200, but 2 persons cost 400 => would be negative
      final payments = [
        _makePayment(amount: 200, paymentDetail: 'adicional'),
      ];
      expect(
        GraduationPaymentHelper.recalculateBalanceAfterDelete(
          remainingPayments: payments,
          remainingAdditionalNumber: 2,
          additionalCostPerPerson: 200,
        ),
        0.0,
      );
    });

    test('zero cost per person returns 0', () {
      final payments = [
        _makePayment(amount: 500, paymentDetail: 'adicional'),
      ];
      expect(
        GraduationPaymentHelper.recalculateBalanceAfterDelete(
          remainingPayments: payments,
          remainingAdditionalNumber: 2,
          additionalCostPerPerson: 0,
        ),
        0.0,
      );
    });

    test('multiple remaining payments summed correctly', () {
      // Paid 300 + 350 = 650, 3 persons cost 600 => balance 50
      final payments = [
        _makePayment(amount: 300, paymentDetail: 'adicional'),
        _makePayment(amount: 350, paymentDetail: 'adicional'),
      ];
      expect(
        GraduationPaymentHelper.recalculateBalanceAfterDelete(
          remainingPayments: payments,
          remainingAdditionalNumber: 3,
          additionalCostPerPerson: 200,
        ),
        50.0,
      );
    });
  });

  // ─── getDisplayRemaining ──────────────────────────────────────────

  group('getDisplayRemaining', () {
    test('balance in favor returns 0', () {
      final student = _makeStudent(
        additionalQuantity: 600,
        additionalBalance: 50,
        payments: [_makePayment(amount: 650, paymentDetail: 'adicional')],
      );
      expect(GraduationPaymentHelper.getDisplayRemaining(student), 0.0);
    });

    test('no balance with remaining returns remaining', () {
      final student = _makeStudent(
        additionalQuantity: 600,
        additionalBalance: 0,
        payments: [_makePayment(amount: 400, paymentDetail: 'adicional')],
      );
      expect(GraduationPaymentHelper.getDisplayRemaining(student), 200.0);
    });

    test('fully paid returns 0', () {
      final student = _makeStudent(
        additionalQuantity: 600,
        additionalBalance: 0,
        payments: [_makePayment(amount: 600, paymentDetail: 'adicional')],
      );
      expect(GraduationPaymentHelper.getDisplayRemaining(student), 0.0);
    });

    test('no additional payments returns full quantity', () {
      final student = _makeStudent(
        additionalQuantity: 600,
        additionalBalance: 0,
      );
      expect(GraduationPaymentHelper.getDisplayRemaining(student), 600.0);
    });

    test('zero additional quantity returns 0', () {
      final student = _makeStudent(additionalQuantity: 0, additionalBalance: 0);
      expect(GraduationPaymentHelper.getDisplayRemaining(student), 0.0);
    });
  });

  // ─── Student model serialization ──────────────────────────────────

  group('Student model', () {
    test('toJson includes additionalBalance', () {
      final student = _makeStudent(additionalBalance: 75.50);
      final json = student.toJson();
      expect(json['additionalBalance'], 75.50);
    });

    test('fromJson parses additionalBalance', () {
      final json = {
        'id': 1,
        'name': 'Test',
        'lastName': 'Student',
        'age': 20,
        'email': 'test@test.com',
        'phone': '1234567890',
        'packageType': '',
        'additionalQuantity': 0.0,
        'totalCost': 5000.0,
        'eventId': 1,
        'comments': '',
        'payments': [],
        'folio': '',
        'dishCount': 0,
        'additionalNumber': 0,
        'hasPreParty': false,
        'hasSouvenir': false,
        'hasBracelet': false,
        'paid': false,
        'cancelled': false,
        'additionalBalance': 125.75,
      };
      final student = Student.fromJson(json);
      expect(student.additionalBalance, 125.75);
    });

    test('fromJson defaults additionalBalance to 0 when missing', () {
      final json = {
        'id': 1,
        'name': 'Test',
        'lastName': 'Student',
        'age': 20,
        'email': 'test@test.com',
        'phone': '1234567890',
        'packageType': '',
        'additionalQuantity': 0.0,
        'totalCost': 5000.0,
        'eventId': 1,
        'comments': '',
        'payments': [],
        'folio': '',
        'dishCount': 0,
        'additionalNumber': 0,
        'hasPreParty': false,
        'hasSouvenir': false,
        'hasBracelet': false,
        'paid': false,
        'cancelled': false,
      };
      final student = Student.fromJson(json);
      expect(student.additionalBalance, 0.0);
    });

    test('toJson and fromJson roundtrip preserves all fields', () {
      final original = _makeStudent(
        totalCost: 3000,
        additionalBalance: 99.99,
        additionalNumber: 5,
        additionalQuantity: 1200,
        paid: true,
        folio: 'ABC-123',
      );
      final json = original.toJson();
      final restored = Student.fromJson(json);
      expect(restored.totalCost, original.totalCost);
      expect(restored.additionalBalance, original.additionalBalance);
      expect(restored.additionalNumber, original.additionalNumber);
      expect(restored.additionalQuantity, original.additionalQuantity);
      expect(restored.paid, original.paid);
      expect(restored.folio, original.folio);
    });
  });

  // ─── Payment model serialization ──────────────────────────────────

  group('Payment model', () {
    test('toJson and fromJson roundtrip', () {
      final original = _makePayment(
        amount: 500,
        paymentDetail: 'adicional',
        paymentMethod: 'Transferencia',
        quantity: 2,
      );
      final json = original.toJson();
      final restored = Payment.fromJson(json);
      expect(restored.amount, original.amount);
      expect(restored.paymentDetail, original.paymentDetail);
      expect(restored.paymentMethod, original.paymentMethod);
      expect(restored.quantity, original.quantity);
    });
  });

  // ─── Edge case: full workflow simulation ──────────────────────────

  group('Full additional payment workflow', () {
    test('multiple payments accumulate persons and balance correctly', () {
      final pricing = _makePricing(additionalCost: 200);

      // Payment 1: $500 => 2 persons + $100 balance
      var result = GraduationPaymentHelper.calculateAdditionalPersons(
        paymentAmount: 500,
        additionalCostPerPerson: pricing.additionalCost,
        existingBalance: 0,
      );
      expect(result.persons, 2);
      expect(result.balance, 100.0);
      int totalPersons = result.persons;
      double currentBalance = result.balance;

      // Payment 2: $250 => $250 + $100 balance = $350 => 1 person + $150
      result = GraduationPaymentHelper.calculateAdditionalPersons(
        paymentAmount: 250,
        additionalCostPerPerson: pricing.additionalCost,
        existingBalance: currentBalance,
      );
      expect(result.persons, 1);
      expect(result.balance, 150.0);
      totalPersons += result.persons;
      currentBalance = result.balance;

      // Payment 3: $50 => $50 + $150 balance = $200 => 1 person + $0
      result = GraduationPaymentHelper.calculateAdditionalPersons(
        paymentAmount: 50,
        additionalCostPerPerson: pricing.additionalCost,
        existingBalance: currentBalance,
      );
      expect(result.persons, 1);
      expect(result.balance, 0.0);
      totalPersons += result.persons;

      expect(totalPersons, 4); // 2 + 1 + 1
    });

    test('delete payment recalculates balance correctly', () {
      // Student has 3 payments: 500 + 250 + 50 = 800 total
      // 4 persons at 200 = 800 cost, 0 balance
      // Delete the 250 payment => remaining: 500 + 50 = 550
      // 3 persons remained, 550 - 600 = negative => clamped to 0
      final remainingPayments = [
        _makePayment(amount: 500, paymentDetail: 'adicional', quantity: 2),
        _makePayment(amount: 50, paymentDetail: 'adicional', quantity: 1),
      ];
      // After deleting, persons should be recalculated: 3 remained
      final balance = GraduationPaymentHelper.recalculateBalanceAfterDelete(
        remainingPayments: remainingPayments,
        remainingAdditionalNumber: 3,
        additionalCostPerPerson: 200,
      );
      // 550 paid - 600 (3*200) = -50, clamped to 0
      expect(balance, 0.0);
    });

    test('delete last payment resets to 0 balance', () {
      final balance = GraduationPaymentHelper.recalculateBalanceAfterDelete(
        remainingPayments: [],
        remainingAdditionalNumber: 0,
        additionalCostPerPerson: 200,
      );
      expect(balance, 0.0);
    });
  });
}
