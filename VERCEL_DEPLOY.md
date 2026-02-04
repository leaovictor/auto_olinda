# Guia de Deploy na Vercel - Auto Olinda

## 📋 Pré-requisitos

1. Conta na Vercel (https://vercel.com)
2. Vercel CLI instalado (opcional, mas recomendado):
```bash
npm install -g vercel
```

---

## 🚀 Deploy via Vercel Dashboard (Método Fácil)

### 1. Conectar Repositório
1. Acesse https://vercel.com/new
2. Importe seu repositório Git (GitHub, GitLab ou Bitbucket)
3. Selecione o projeto `auto_olinda`

### 2. Configurar Projeto
- **Framework Preset**: Other
- **Build Command**: `flutter build web --release --web-renderer canvaskit`
- **Output Directory**: `build/web`
- **Install Command**: (deixe vazio, o Flutter já está instalado)

### 3. Variáveis de Ambiente (se necessário)
Adicione qualquer API key ou configuração no painel Environment Variables.

### 4. Deploy
Clique em **Deploy** e aguarde o build.

---

## 🖥️ Deploy via CLI (Método Avançado)

### 1. Login na Vercel
```bash
vercel login
```

### 2. Build Local
```bash
cd /home/victorleao/Documentos/auto_olinda
flutter build web --release --web-renderer canvaskit
```

### 3. Deploy
```bash
vercel --prod
```

A CLI vai perguntar algumas configurações na primeira vez:
- **Set up and deploy**: Yes
- **Which scope**: Sua conta/organização
- **Link to existing project**: No
- **Project name**: auto-olinda
- **Directory**: `./` (raiz do projeto)
- **Override settings**: No

---

## ⚙️ Como Funciona o vercel.json

### Rewrites (Rotas Amigáveis)
```json
"rewrites": [
  {
    "source": "/(.*)",
    "destination": "/index.html"
  }
]
```
**O que faz**: Todas as rotas (ex: `/servicos`, `/agendamento`) redirecionam para `index.html`, permitindo que o Flutter Router funcione corretamente sem `#`.

### Headers para SEO
- **robots.txt**: Content-Type correto + cache 24h
- **sitemap.xml**: Content-Type XML + cache 24h
- **og-image.png**: Cache longo (30 dias)
- **Arquivos estáticos** (.js, .css): Cache 1 ano com immutable
- **index.html**: Sem cache (para atualizações rápidas)

### Opção trailingSlash
```json
"trailingSlash": false
```
**O que faz**: URLs ficam como `/servicos` ao invés de `/servicos/`

---

## 📁 Estrutura de Arquivos para Vercel

### Antes do Build
```
auto_olinda/
├── lib/              # Código Flutter
├── web/              # Arquivos estáticos (index.html, robots.txt, etc.)
│   ├── index.html    ✅ Com meta tags SEO
│   ├── robots.txt    ✅ Criado
│   ├── sitemap.xml   ✅ Criado
│   ├── og-image.png  ✅ Criado
│   └── favicon.png
├── vercel.json       ✅ Configuração Vercel
└── pubspec.yaml
```

### Depois do Build (o que Vercel lê)
```
build/web/            # Output Directory
├── index.html        # HTML principal com SEO
├── robots.txt        # Copiado automaticamente
├── sitemap.xml       # Copiado automaticamente
├── og-image.png      # Copiado automaticamente
├── main.dart.js      # Código Flutter compilado
├── flutter.js
├── assets/
└── ...
```

**Importante**: O Flutter automaticamente copia tudo de `web/` para `build/web/` durante o build. Por isso, basta colocar `robots.txt`, `sitemap.xml` e `og-image.png` na pasta `web/`.

---

## 🔧 Configuração de Domínio Customizado

### Na Vercel Dashboard

1. Vá em **Settings** > **Domains**
2. Clique em **Add Domain**
3. Digite: `autoolinda.com.br`
4. A Vercel vai fornecer registros DNS para configurar

### No Registro.br (ou outro registrador)

Adicione os registros DNS fornecidos pela Vercel:

**Opção 1: Apex Domain (autoolinda.com.br)**
```
Type: A
Name: @
Value: 76.76.21.21 (IP da Vercel)
```

**Opção 2: Subdomain (www.autoolinda.com.br)**
```
Type: CNAME
Name: www
Value: cname.vercel-dns.com
```

**Aguarde**: Propagação DNS pode levar até 48h (geralmente 1-2h).

---

## ✅ Checklist Pós-Deploy

### 1. Verificar URLs Amigáveis
- [ ] Acesse `https://autoolinda.com.br/sign-in`
- [ ] Verifique que NÃO dá erro 404
- [ ] Verifique que a URL no navegador NÃO tem `#`

### 2. Testar Arquivos SEO
- [ ] `https://autoolinda.com.br/robots.txt` (deve abrir)
- [ ] `https://autoolinda.com.br/sitemap.xml` (deve abrir)
- [ ] `https://autoolinda.com.br/og-image.png` (deve mostrar imagem)

### 3. Validar Open Graph
- [ ] Facebook Debugger: https://developers.facebook.com/tools/debug/
- [ ] Twitter Validator: https://cards-dev.twitter.com/validator
- [ ] Colar URL: `https://autoolinda.com.br`
- [ ] Verificar que mostra imagem, título e descrição

### 4. Testar WhatsApp
- [ ] Enviar `https://autoolinda.com.br` para você mesmo
- [ ] Verificar preview com imagem

### 5. Google Search Console
- [ ] Adicionar propriedade `autoolinda.com.br`
- [ ] Submeter sitemap: `https://autoolinda.com.br/sitemap.xml`
- [ ] Solicitar indexação da home

---

## 🔄 Atualizações Futuras

### Automático (Git Deploy)
Se conectou via Git, a Vercel faz deploy automático a cada push:
```bash
git add .
git commit -m "Atualização do site"
git push origin main
```

### Manual (CLI)
```bash
flutter build web --release --web-renderer canvaskit
vercel --prod
```

---

## 🐛 Troubleshooting

### Erro 404 em Rotas
- **Problema**: `/servicos` dá 404
- **Solução**: Verifique que `vercel.json` está na raiz e tem o rewrite correto

### Sitemap não encontrado
- **Problema**: `/sitemap.xml` não abre
- **Solução**: Verifique que `sitemap.xml` está em `web/` antes do build

### Open Graph não funciona
- **Problema**: Preview não mostra imagem no WhatsApp
- **Solução**: 
  1. Aguarde cache do WhatsApp limpar (pode demorar)
  2. Tente adicionar `?v=1` na URL
  3. Use Facebook Debugger para limpar cache

### Domínio não funciona
- **Problema**: `autoolinda.com.br` não abre
- **Solução**:
  1. Verifique registros DNS no Registro.br
  2. Aguarde propagação (até 48h)
  3. Use ferramenta: https://dnschecker.org

---

## 📊 Monitoramento

### Vercel Analytics (Built-in)
A Vercel já fornece analytics básicos:
- Visitas
- Performance (Core Web Vitals)
- Erros 404

Acesse em: **Dashboard** > **Analytics**

### Google Analytics (Recomendado)
Adicione o GA4 no `web/index.html` para análise detalhada.

---

## 💡 Dicas Extras

### 1. Preview Deployments
Cada branch/PR gera um preview URL:
```
https://auto-olinda-git-feature-xyz-seu-usuario.vercel.app
```

### 2. Deploy Rollback
Se algo der errado, você pode voltar para versão anterior no Dashboard.

### 3. Performance
A Vercel usa CDN global automaticamente - seu app carrega rápido em todo Brasil.

### 4. HTTPS
SSL/HTTPS é automático e gratuito na Vercel.

---

## 🎉 Pronto!

Seu Auto Olinda está configurado para deploy na Vercel com:
- ✅ URLs amigáveis sem `#`
- ✅ SEO completo (robots.txt, sitemap.xml)
- ✅ Open Graph para redes sociais
- ✅ Domínio customizado `autoolinda.com.br`

**Deploy agora**: `vercel --prod` ou faça push no Git! 🚀
