# Disciplina — PWA multiplataforma (MVP 0.2)

**Documentação:** [Arquitetura técnica](ARCHITECTURE.md) · [Instalação no Android](ANDROID_SETUP.md)

Aplicação web instalável, responsiva e **offline-first**. A mesma interface atende Android, iOS, Windows, macOS e Linux. Os dados são mantidos localmente em IndexedDB e sincronizados com Supabase quando houver conexão.

## Arquitetura

- **Frontend/PWA:** HTML, CSS e JavaScript.
- **Offline local:** IndexedDB armazena dados e fila de sincronização; Service Worker mantém o shell da aplicação disponível.
- **Nuvem:** Supabase Auth + PostgreSQL + PostgREST.
- **Segurança:** Row Level Security (RLS) restringe cada linha ao `auth.uid()` do proprietário.
- **Calendário:** Google Identity Services + Google Calendar API. O token Google fica somente em memória; ao reabrir o app pode ser necessário autorizar novamente.
- **Hospedagem:** qualquer hospedagem estática HTTPS (Netlify, Vercel, Cloudflare Pages ou servidor próprio).

Não existe dependência do computador do usuário como servidor. Cada dispositivo acessa a mesma URL pública e sincroniza com o banco central.

## 1. Criar o projeto Supabase

1. Crie um projeto em https://supabase.com/.
2. Abra **SQL Editor** e execute todo o arquivo `supabase/schema.sql`.
3. Em **Project Settings → API**, copie o Project URL e a chave pública `anon`/`publishable`.
4. Edite `static/config.js` e substitua os valores de exemplo:

```js
window.DISCIPLINA_CONFIG = {
  SUPABASE_URL: 'https://SEU-PROJETO.supabase.co',
  SUPABASE_ANON_KEY: 'SUA_CHAVE_PUBLICA'
};
```

A chave `service_role` nunca deve ser colocada no frontend. O isolamento é garantido pelas políticas RLS criadas pelo SQL.

5. Em **Authentication → Providers → Email**, configure a confirmação de e-mail conforme sua preferência. Para testes pessoais, pode desativá-la temporariamente. Como o primeiro uso será pessoal, crie sua conta e depois desative novos cadastros em Authentication → Settings (Enable Signups), mantendo a estrutura pronta para reativá-los quando decidir abrir o produto.
6. Em **Authentication → URL Configuration**, inclua o domínio HTTPS onde o PWA será publicado em Site URL e Redirect URLs.

## 2. Publicar na internet

### Netlify (caminho simples)

1. Envie a pasta do projeto para um repositório Git privado.
2. Crie um site no Netlify conectado ao repositório.
3. Defina o diretório de publicação como `static` (já indicado em `netlify.toml`).
4. Publique e use o endereço HTTPS gerado.
5. Confirme que `static/config.js` contém as credenciais públicas do Supabase antes da publicação.

Também é possível publicar a pasta `static` em Vercel, Cloudflare Pages ou hospedagem própria. O site precisa usar HTTPS para instalação e Service Worker fora de `localhost`.

## 3. Instalar no Android, iOS e computadores

- **Android (Chrome):** abra a URL HTTPS → menu → Instalar aplicativo / Adicionar à tela inicial.
- **iOS/iPadOS (Safari):** abra a URL → Compartilhar → Adicionar à Tela de Início. Algumas funções PWA e notificações têm limitações próprias do iOS.
- **Windows/macOS/Linux:** abra no navegador compatível e escolha Instalar aplicativo quando disponível; também pode usar a URL normalmente.

O app não é uma APK/IPA nativa nesta etapa. É uma PWA compartilhada, instalável e atualizada centralmente. Capacitor/Tauri poderão empacotar a mesma base futuramente.

## 4. Google Calendar

1. No Google Cloud Console, crie um projeto e ative **Google Calendar API**.
2. Configure a tela de consentimento OAuth.
3. Crie um OAuth Client ID do tipo **Web application**.
4. Em **Authorized JavaScript origins**, adicione o domínio HTTPS publicado (e `http://localhost:...` para desenvolvimento).
5. Use o Client ID no menu Conta e integrações do Disciplina.
6. Clique em Conectar / sincronizar e autorize o escopo `calendar.events`.

A sincronização importa eventos dos últimos 30 dias e dos próximos 120 dias. Eventos importados podem ter título, descrição e horário editados no app; quando autorizado e online, a edição é enviada ao Google Calendar. Se estiver offline, a alteração fica marcada como pendente e será enviada ao reconectar o calendário.

O Google Identity Services fornece um access token temporário. O usuário poderá precisar autorizar novamente em outra sessão. Não armazenamos refresh token Google no navegador.

## 5. Funcionamento offline e sincronização

- Depois do primeiro login online, os dados ficam em IndexedDB neste dispositivo.
- Cadastro e edição de tarefas, sessões, ideias, metas e diário funcionam offline.
- As alterações entram em uma fila local e são enviadas quando a conexão volta.
- Na sincronização, a fila é enviada ao Supabase e os dados remotos são atualizados no cache local.
- O critério atual para conciliar edições concorrentes é `updated_at` (última gravação prevalece). Para o MVP pessoal é suficiente; versões com uso simultâneo intensivo devem evoluir para resolução explícita de conflitos.
- A sessão de autenticação é guardada no IndexedDB do dispositivo. Sair remove a sessão local, não os dados da conta na nuvem.

**Importante:** offline completo exige que o usuário tenha entrado pelo menos uma vez naquele dispositivo e que o navegador não tenha apagado os dados do site. Para proteger dados importantes, mantenha a sincronização ativa e faça backups periódicos do projeto Supabase.

## Módulos incluídos

- Dashboard com execução programada e tarefas extras em indicadores separados.
- Agenda diária, cadastro de atividades e estados de execução.
- Produção/sessões com duração, resultado e próximo passo.
- Banco de ideias.
- Metas semanais e mensais.
- Diário de bordo.
- Google Calendar: importação e atualização de eventos importados.
- PWA responsiva com navegação móvel inferior e layout desktop.

## Estrutura

```text
static/
  index.html
  style.css
  app.js
  sw.js
  manifest.webmanifest
  config.js
  config.example.js
  icons/icon.svg
supabase/
  schema.sql
netlify.toml
README.md
```

## Limitações conhecidas do MVP 0.2

- A integração Google Calendar é executada no dispositivo e exige nova autorização quando o token temporário expira.
- A sincronização de eventos recorrentes usa as instâncias retornadas pela API; exceções complexas e exclusões remotas serão refinadas.
- O dashboard calcula os indicadores a partir das atividades e registros existentes; não infere automaticamente se uma atividade sem status foi cumprida.
- O cache local é específico de cada navegador/dispositivo; o Supabase é a fonte compartilhada entre dispositivos.
- Antes de abrir cadastro público, revise políticas de e-mail, limites, logs, recuperação de senha, backup e monitoramento.
