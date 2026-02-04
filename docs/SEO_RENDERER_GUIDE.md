# Como Usar seo_renderer no Auto Olinda

## Exemplo de Implementação

O pacote `seo_renderer` permite que você adicione tags HTML semânticas (h1, p, etc.) que o Google pode indexar, mesmo em um app Flutter Web.

### Exemplo: Tela de Login com SEO

```dart
import 'package:flutter/material.dart';
import 'package:seo_renderer/seo_renderer.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Tags H1 e P para SEO (invisíveis ao usuário, visíveis ao Google)
          TextRenderer(
            text: 'Auto Olinda - Login',
            style: TextRendererStyle.header1,
          ),
          TextRenderer(
            text: 'Entre na sua conta para agendar lavagem premium em Olinda/PE',
            style: TextRendererStyle.paragraph,
          ),
          
          // Seus widgets Flutter normais
          Text(
            'Login',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          
          // Formulário de login...
        ],
      ),
    );
  }
}
```

### Exemplo: Home Screen com SEO

```dart
import 'package:flutter/material.dart';
import 'package:seo_renderer/seo_renderer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // SEO: Título principal da página
          TextRenderer(
            text: 'Auto Olinda - Estética Automotiva Premium em Olinda/PE',
            style: TextRendererStyle.header1,
          ),
          
          // SEO: Descrição dos serviços
          TextRenderer(
            text: 'Lavagem premium, polimento, higienização interna e detailing profissional. '
                  'Agende seu horário agora e transforme seu carro!',
            style: TextRendererStyle.paragraph,
          ),
          
          // SEO: Subtítulo de serviços
          TextRenderer(
            text: 'Nossos Serviços',
            style: TextRendererStyle.header2,
          ),
          
          TextRenderer(
            text: 'Lavagem Premium: Limpeza completa externa e interna',
            style: TextRendererStyle.paragraph,
          ),
          
          TextRenderer(
            text: 'Polimento Profissional: Restaure o brilho original',
            style: TextRendererStyle.paragraph,
          ),
          
          // Seus widgets Flutter visuais normais...
          Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Bem-vindo ao Auto Olinda',
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
          // ... resto da UI
        ],
      ),
    );
  }
}
```

## Estilos Disponíveis

- `TextRendererStyle.header1` - Tag `<h1>` (use 1x por página)
- `TextRendererStyle.header2` - Tag `<h2>`
- `TextRendererStyle.header3` - Tag `<h3>`
- `TextRendererStyle.header4` - Tag `<h4>`
- `TextRendererStyle.header5` - Tag `<h5>`
- `TextRendererStyle.header6` - Tag `<h6>`
- `TextRendererStyle.paragraph` - Tag `<p>`

## Renderização de Links

Para links internos que o Google pode indexar:

```dart
LinkRenderer(
  text: 'Agendar Lavagem',
  href: '/agendamento',
  anchorText: 'Agende seu horário',
),
```

## Renderização de Imagens

Para imagens com atributo `alt` (importante para SEO):

```dart
ImageRenderer(
  src: 'https://auto-olinda.web.app/assets/images/lavagem.jpg',
  alt: 'Lavagem premium de carro em Olinda',
  width: 600,
  height: 400,
),
```

## ⚠️ Observações Importantes

1. **TextRenderer é invisível**: Os widgets `TextRenderer` não aparecem visualmente na tela. Eles apenas adicionam tags HTML para o Google.

2. **Use junto com widgets visuais**: Você precisa dos widgets Flutter normais (Text, Image, etc.) para o usuário ver. O TextRenderer é APENAS para SEO.

3. **Um H1 por página**: Use apenas um `TextRendererStyle.header1` por tela/página.

4. **Ordem importa**: Coloque os TextRenderer no início da árvore de widgets, mas a ordem visual não importa (são invisíveis).

## 🎯 Onde Usar

### Prioridade Alta (usar TextRenderer)
- ✅ Home / Landing Page
- ✅ Página de Serviços
- ✅ Página de Login/Sign Up
- ✅ Sobre Nós / FAQ

### Prioridade Média
- ⚠️ Páginas de agendamento (se quiser que apareça em busca)
- ⚠️ Páginas de contato

### Não precisa
- ❌ Dashboard interno (área autenticada)
- ❌ Telas de admin
- ❌ Configurações

## 🧪 Como Testar

1. Faça build para web:
```bash
flutter build web --release
```

2. Abra `build/web/index.html` em um navegador

3. Inspecione o código-fonte (View Page Source)

4. Procure por tags `<h1>`, `<h2>`, `<p>` com seu conteúdo

5. Use Google Search Console > Inspeção de URL para ver como o Google vê

## 📚 Documentação Oficial

https://pub.dev/packages/seo_renderer

## ⚡ Próximos Passos

1. Identifique suas principais telas públicas
2. Adicione TextRenderer com conteúdo de venda otimizado
3. Faça build e teste
4. Deploy e use Google Search Console para verificar indexação
