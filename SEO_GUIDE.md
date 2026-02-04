# Guia Completo de SEO - Auto Olinda

Este documento explica como o SEO foi configurado no Auto Olinda e como gerenciá-lo.

## 📋 O que foi implementado

### 1. **URLs Limpas (Path-based Routing)**
- ✅ Removido o `#` das URLs usando `usePathUrlStrategy()`
- URLs agora são: `auto-olinda.web.app/servicos` ao invés de `auto-olinda.web.app/#/servicos`
- Melhor para SEO e compartilhamento

### 2. **Meta Tags para SEO**
No `web/index.html`, foram adicionados:
- Meta description otimizada para Olinda/PE
- Keywords relevantes para negócio local
- Meta tags robots para indexação

### 3. **Open Graph & Twitter Cards**
Tags configuradas para compartilhamento social rico:
- **WhatsApp**: Mostra imagem, título e descrição
- **Facebook**: Preview completo da página
- **Instagram**: Compartilhamento otimizado
- **Twitter**: Twitter Card com imagem grande

### 4. **Schema.org Structured Data**
Markup JSON-LD configurado para:
- Tipo de negócio: AutoRepair
- Localização: Olinda/PE
- Horário de funcionamento
- Informações de contato

> [!WARNING]
> **Ação Necessária**: Atualize as informações de contato no `web/index.html`:
> - Telefone (linha com `"telephone"`)
> - Endereço completo (linha com `"streetAddress"`)
> - CEP (linha com `"postalCode"`)
> - Coordenadas GPS reais (latitude/longitude)

### 5. **Sitemap & Robots.txt**
- `web/robots.txt`: Orienta crawlers do Google
- `web/sitemap.xml`: Lista de páginas indexáveis

### 6. **Imagem para Compartilhamento Social**
- Arquivo: `web/og-image.png` (1200x630px)
- Design profissional com logo Auto Olinda
- Otimizada para WhatsApp/Facebook/Instagram

---

## 🤖 O Problema do Crawler

### Por que bots não veem o conteúdo Flutter?

Flutter Web renderiza usando **WebAssembly/JavaScript**, criando a interface dinamicamente. Alguns bots de redes sociais (WhatsApp, Facebook) **não executam JavaScript**, então veem apenas o HTML inicial vazio.

### ✅ Solução Implementada (Parcial)

**Para Redes Sociais** (WhatsApp, Facebook, Instagram):
- Usamos **meta tags Open Graph** no `index.html`
- Esses bots leem as tags antes de executar JS
- **Resultado**: Prévias ricas funcionam ✅

**Para Google Search**:
- Google **executa JavaScript**, então vê o conteúdo
- Adicionamos `seo_renderer` (mas precisa ser configurado nas páginas)
- **Resultado**: Indexação básica funciona, mas pode melhorar

### 🚀 Solução Avançada: Pre-rendering

Para indexação 100% completa, recomendamos um serviço de **pre-rendering**:

#### Opção 1: **Prerender.io** (Recomendado)
- **O que faz**: Gera HTML estático a partir do app Flutter
- **Como funciona**: Detecta bots, serve HTML pré-renderizado
- **Custo**: Plano gratuito até 250 páginas/mês
- **Setup**: https://prerender.io/

#### Opção 2: **Rendertron** (Open Source)
- **O que faz**: Mesma função, mas auto-hospedado
- **Vantagem**: Grátis, sem limites
- **Desvantagem**: Precisa de servidor próprio
- **GitHub**: https://github.com/GoogleChrome/rendertron

#### Como Configurar Pre-rendering

**No Firebase Hosting** (`firebase.json`):
```json
"hosting": {
  "rewrites": [
    {
      "source": "**",
      "destination": "/index.html"
    }
  ],
  "headers": [
    {
      "source": "**/*.@(jpg|jpeg|gif|png|svg|webp)",
      "headers": [{
        "key": "Cache-Control",
        "value": "max-age=7200"
      }]
    }
  ]
}
```

Depois, use **Cloud Functions** para detectar bots e redirecionar para Prerender.io.

---

## 🧪 Como Testar o SEO

### 1. **Testar URLs Limpas**
```bash
cd /home/victorleao/Documentos/auto_olinda
flutter run -d chrome
```
- Navegue para diferentes páginas
- Verifique que a URL **não** tem `#`

### 2. **Testar Open Graph (Facebook)**
1. Faça deploy: `firebase deploy --only hosting`
2. Acesse: https://developers.facebook.com/tools/debug/
3. Cole a URL do seu site
4. Clique em "Scrape Again"
5. **Resultado esperado**: Imagem, título e descrição aparecem

### 3. **Testar WhatsApp Preview**
1. Após deploy, copie a URL do site
2. Envie para você mesmo no WhatsApp
3. **Resultado esperado**: Preview com imagem Auto Olinda

### 4. **Validar Twitter Card**
- Acesse: https://cards-dev.twitter.com/validator
- Cole sua URL
- Verifique preview

### 5. **Verificar Sitemap e Robots**
Após deploy, acesse:
- `https://auto-olinda.web.app/robots.txt`
- `https://auto-olinda.web.app/sitemap.xml`

### 6. **Google Search Console**
1. Acesse: https://search.google.com/search-console
2. Adicione seu site
3. Solicite indexação
4. Use "Inspeção de URL" para ver como Google vê sua página

---

## 📝 Checklist de Deploy para SEO

Antes de fazer deploy em produção:

- [ ] Atualizar telefone no Schema.org (`web/index.html`)
- [ ] Atualizar endereço completo no Schema.org
- [ ] Verificar coordenadas GPS (latitude/longitude)
- [ ] Confirmar que `og-image.png` está em `web/`
- [ ] Atualizar URLs no `sitemap.xml` (trocar `auto-olinda.web.app` pelo domínio final)
- [ ] Atualizar URLs nos meta tags Open Graph no `index.html`
- [ ] Fazer build: `flutter build web --release`
- [ ] Deploy: `firebase deploy --only hosting`
- [ ] Testar preview no WhatsApp
- [ ] Validar com Facebook Debugger
- [ ] Submeter sitemap no Google Search Console

---

## 🔧 Manutenção

### Atualizando o Sitemap
Sempre que adicionar novas páginas públicas, atualize `web/sitemap.xml`:
```xml
<url>
  <loc>https://auto-olinda.web.app/nova-pagina</loc>
  <lastmod>2026-02-XX</lastmod>
  <changefreq>monthly</changefreq>
  <priority>0.7</priority>
</url>
```

### Atualizando Textos de SEO
Para mudar descrição/título de compartilhamento, edite `web/index.html`:
- Linha com `<meta property="og:title">`
- Linha com `<meta property="og:description">`
- Linha com `<meta name="description">`

### Mudando Imagem Social
Substitua `web/og-image.png` por uma nova imagem (1200x630px).

---

## 📊 Monitoramento

### Ferramentas Recomendadas
1. **Google Search Console**: Indexação e performance
2. **Google Analytics**: Tráfego orgânico
3. **Facebook Debugger**: Validar Open Graph
4. **Lighthouse** (Chrome DevTools): Score de SEO

### Métricas Importantes
- Taxa de cliques (CTR) no Google
- Impressões de busca local "olinda"
- Compartilhamentos sociais
- Tempo de carregamento (Core Web Vitals)

---

## ❓ FAQ

**P: Por que ainda vejo `#` nas URLs em desenvolvimento?**  
R: Certifique-se de que fez `flutter pub get` após adicionar `flutter_web_plugins`.

**P: O WhatsApp não mostra a imagem.**  
R: Cache do WhatsApp. Tente mudar a URL (ex: adicionar `?v=2`) ou aguarde algumas horas.

**P: Google não está indexando minhas páginas.**  
R: Pode levar dias/semanas. Use Google Search Console para forçar re-indexação.

**P: Preciso mesmo de pre-rendering?**  
R: Para **redes sociais**: NÃO (Open Graph funciona).  
Para **Google**: Não é obrigatório (Google executa JS), mas melhora a indexação.

---

## 📚 Recursos Adicionais

- [Google SEO Starter Guide](https://developers.google.com/search/docs/beginner/seo-starter-guide)
- [Open Graph Protocol](https://ogp.me/)
- [Twitter Card Docs](https://developer.twitter.com/en/docs/twitter-for-websites/cards/overview/abouts-cards)
- [Schema.org - Local Business](https://schema.org/LocalBusiness)
- [Flutter Web SEO Best Practices](https://docs.flutter.dev/platform-integration/web/faq#search-engine-optimization-seo)
