# Deploy Firebase - Auto Olinda

## 🚀 Deploy Rápido

### Fazer Deploy
```bash
cd /home/victorleao/Documentos/auto_olinda
flutter build web --release --web-renderer auto --tree-shake-icons
firebase deploy --only hosting
```

### Deploy Completo (com Functions)
```bash
flutter build web --release
firebase deploy
```

---

## 🌐 URLs Atuais

**Produção**: https://autoolinda-5199e.web.app

**Arquivos SEO**:
- https://autoolinda-5199e.web.app/robots.txt
- https://autoolinda-5199e.web.app/sitemap.xml
- https://autoolinda-5199e.web.app/og-image.png

---

## ✅ Checklist Pós-Deploy

1. **Testar rotas limpas (sem #)**
   - Acesse: https://autoolinda-5199e.web.app/sign-in
   - Verifique que a URL não tem `#`

2. **Validar Open Graph**
   - Facebook Debugger: https://developers.facebook.com/tools/debug/
   - Cole: https://autoolinda-5199e.web.app

3. **Testar WhatsApp Preview**
   - Envie o link para você mesmo
   - Verifique preview com imagem

4. **Google Search Console**
   - Submeter: https://autoolinda-5199e.web.app/sitemap.xml

---

## 📝 Configurar Domínio Customizado (Futuro)

Quando quiser usar `autoolinda.com.br`:

1. **Firebase Console**
   - Hosting → Add custom domain
   - Digite: `autoolinda.com.br`

2. **Registrar DNS no Registro.br**
   - Firebase fornecerá os registros

3. **Atualizar URLs no Código**
   - Substituir `autoolinda-5199e.web.app` por `autoolinda.com.br`
   - Arquivos: `web/index.html`, `web/sitemap.xml`, `web/robots.txt`

---

## 📚 Documentação SEO

- [SEO_GUIDE.md](file:///home/victorleao/Documentos/auto_olinda/SEO_GUIDE.md) - Guia completo de SEO
- [docs/SEO_RENDERER_GUIDE.md](file:///home/victorleao/Documentos/auto_olinda/docs/SEO_RENDERER_GUIDE.md) - Como usar seo_renderer
