const fs = require('fs');

let content = fs.readFileSync('/home/ninguem/Documentos/Projects/auto_olinda/lib/src/features/auth/presentation/sign_up_screen.dart', 'utf-8');

// 1. Remove NDA state and refs
content = content.replace(/\/\/ NDA acceptance state[\s\S]*?late String _ndaText;/g, '');
content = content.replace(/_ndaAcceptanceDate = DateTime\.now\(\);[\s\S]*?_ndaText = NdaContent\.generateFullText\(_ndaAcceptanceDate\);/g, '');
content = content.replace(/_ndaText,/g, '');

// 2. Remove hardcoded "Auto Olinda" and replace with dynamic if possible, or just "CleanFlow"
content = content.replaceAll('Auto Olinda', 'CleanFlow');
content = content.replaceAll('Auto Olinda Pro', 'CleanFlow Pro');
content = content.replaceAll('autoolinda_logo.png', 'logo.png'); // placeholder

// 3. Remove multi_step_acceptance_screen import if unused
content = content.replace(/import 'multi_step_acceptance_screen\.dart';/g, '');
content = content.replace(/import '\.\.\/domain\/nda_content\.dart';/g, '');

// 4. Update the tenantId handling explanation
content = content.replace(/\/\/ tenantId may be embedded[\s\S]*?\?tenantId=auto-olinda\)\./g, '// tenantId is automatic from URL');

fs.writeFileSync('/home/ninguem/Documentos/Projects/auto_olinda/lib/src/features/auth/presentation/sign_up_screen.dart', content);
console.log('Cleaned up sign_up_screen.dart');
