const fs = require('fs');
const path = require('path');

const files = [
  '/home/ninguem/Documentos/Projects/auto_olinda/lib/src/features/auth/presentation/sign_in_screen.dart',
  '/home/ninguem/Documentos/Projects/auto_olinda/lib/src/features/auth/presentation/sign_up_screen.dart',
  '/home/ninguem/Documentos/Projects/auto_olinda/lib/src/features/auth/presentation/forgot_password_screen.dart',
  '/home/ninguem/Documentos/Projects/auto_olinda/lib/src/routing/app_router.dart'
];

files.forEach(file => {
  if (fs.existsSync(file)) {
    let content = fs.readFileSync(file, 'utf-8');
    content = content.replaceAll('Auto Olinda', 'CleanFlow');
    content = content.replaceAll('AquaClean', 'CleanFlow');
    content = content.replaceAll('autoolinda_logo.png', 'logo.png');
    content = content.replaceAll('aquaclean_logo.svg', 'logo.svg');
    fs.writeFileSync(file, content);
    console.log(`Updated ${file}`);
  }
});
