const fs = require('fs');

let content = fs.readFileSync('/home/ninguem/Documentos/Projects/auto_olinda/lib/src/features/booking/presentation/booking_screen.dart', 'utf-8');

// 1. Remove _ProductsSelectionStep widget block
const startIdx = content.indexOf('class _ProductsSelectionStep extends ConsumerWidget {');
if (startIdx !== -1) {
    let endIdx = content.indexOf('class _DateTimeSelectionStep extends ConsumerStatefulWidget {');
    // Remove the whole block up to _DateTimeSelectionStep
    content = content.substring(0, startIdx) + content.substring(endIdx);
}

// 2. Remove products summary row in review
content = content.replace(/                           \/\/ 3\. PRODUCTS\n                          if \(state\.selectedProducts\.isNotEmpty\) \.\.\.\[[\s\S]*?                          \],/g, '');

// 3. Update displayPrice in review step
content = content.replace(/                    \/\/ If premium, the service is free\. Total is just products\.\n                    final displayPrice = isPremium\n                        \? state\.productsTotalPrice\n                        : state\.totalPrice;/g, 
`                    // If premium, the service is free.
                    final displayPrice = isPremium
                        ? 0.0
                        : state.totalPrice;`);

// 4. Update the bottom bar pricing logic
content = content.replace(/          final productsTotal = bookingState\.productsTotalPrice;[\s\S]*?          \/\/ Premium without products: fully free/g, 
`          // Premium without products: fully free`);

// Write back
fs.writeFileSync('/home/ninguem/Documentos/Projects/auto_olinda/lib/src/features/booking/presentation/booking_screen.dart', content);
console.log('Cleaned up booking_screen.dart');
