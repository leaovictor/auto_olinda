# Subscription Module Refactoring Walkthrough

This document outlines the changes made to the Auto Olinda subscription module to enforce vehicle category restrictions, link subscriptions to license plates, and ensure data integrity.

## Changes Overview

### Backend (Cloud Functions)
- **Category Validation**: Implemented logic in `stripe.ts` to prevent SUV/Pickup vehicles from subscribing to Hatch plans.
- **Vehicle Linking**: Updated `createCheckoutSession` and webhook handlers to persist `linkedPlate` and `vehicleId` in the Firestore `subscriptions` document.
- **Anti-Fraud**: Added `updateSubscriptionVehicle` function that enforces a 60-day cool-off period for plate changes.
- **Metadata Injection**: Injected vehicle details into Stripe Session metadata for easier tracking and recovery.

### Frontend (Flutter)
- **Subscription Flow**:
    -   **Vehicle Selection**: Added a vehicle selector to `CustomerPlansScreen`. Users must select a vehicle before viewing/purchasing plans.
    -   **Plan Filtering**: The plans list is automatically filtered based on the selected vehicle's category. Mismatched plans (e.g. Hatch plan for SUV) are filtered out or validated.
- **Checkout**:
    -   Passed `vehicleId` and `linkedPlate` through to the payment intent creation (Card and PIX).
- **Check-in Alert**:
    -   Updated `StaffBookingDetailScreen` to display a **Red Card Alert** ("PLACA DIVERGENTE") if the booking's vehicle plate does not match the subscriber's linked plate.

## Verification Steps

### 1. New Subscription (App)
1.  Navigate to **Menu > Assinar Clube**.
2.  If you have no vehicles, you should be prompted to add one.
3.  Select an **SUV** vehicle from the dropdown.
4.  Verify that **Hatch** specific plans (if any) are not shown or cannot be selected.
5.  Proceed to checkout.
6.  **Success Criteria**: The created subscription in Firestore should have `linkedPlate` matching the selected vehicle.

### 2. Plate Change Lock (Admin/Backend)
1.  Attempt to call `updateSubscriptionVehicle` cloud function for a newly created subscription (less than 60 days).
2.  **Success Criteria**: The function should throw an error regarding the 60-day limit.

### 3. Check-in Alert (Staff App)
1.  As a subscriber with `linkedPlate = "AAA-1111"`.
2.  Create a booking (or have staff create one) for a *different* vehicle `linkedPlate = "BBB-2222"`.
3.  As Staff, open the booking details.
4.  **Success Criteria**: A red alert box "PLACA DIVERGENTE DA ASSINATURA" should appear below the vehicle info.
