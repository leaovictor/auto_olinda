const fs = require('fs');
const path = require('path');

function walk(dir) {
    let results = [];
    const list = fs.readdirSync(dir);
    list.forEach(file => {
        file = path.join(dir, file);
        const stat = fs.statSync(file);
        if (stat && stat.isDirectory()) {
            results = results.concat(walk(file));
        } else {
            if (file.endsWith('.dart')) results.push(file);
        }
    });
    return results;
}

const files = walk('/home/ninguem/Documentos/Projects/auto_olinda/lib/src');

files.forEach(file => {
    let content = fs.readFileSync(file, 'utf-8');
    if (content.includes('Auto Olinda') || content.includes('autoolinda_logo.png')) {
        content = content.replaceAll('Auto Olinda', 'CleanFlow');
        content = content.replaceAll('autoolinda_logo.png', 'logo.png');
        fs.writeFileSync(file, content);
        console.log(`Updated ${file}`);
    }
});
