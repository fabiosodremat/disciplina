# Disciplina — instalação e teste pessoal no Android

## Estado atual

O projeto é uma PWA. Para instalar no celular, primeiro precisa estar publicado em um endereço HTTPS e configurado com Supabase. O ZIP não é APK e ainda não existe uma URL pública pronta.

## 1. Criar o projeto Supabase

1. No computador, acesse https://supabase.com/ e crie um projeto chamado `disciplina-pessoal`.
2. Guarde a senha do banco em local seguro.
3. Abra **SQL Editor → New query**.
4. Abra `supabase/schema.sql` neste pacote, copie todo o conteúdo e execute.
5. Abra **Project Settings → API** (ou API Keys) e copie o **Project URL** e a chave pública **anon/publishable**.
6. Edite `static/config.js` e substitua os valores de exemplo. Nunca use a chave `service_role`/secret no frontend.

## 2. Configurar autenticação

1. No Supabase, abra **Authentication → Providers → Email** e mantenha Email habilitado.
2. Para o primeiro teste, mantenha confirmação de e-mail habilitada se puder receber a mensagem; confirme o endereço ao criar a conta.
3. Em **Authentication → URL Configuration**, depois da publicação, informe o domínio HTTPS como Site URL e Redirect URL.
4. Crie sua conta pela tela inicial do Disciplina.
5. Como o uso inicial será pessoal, desative novos cadastros depois de criar a conta, se a opção estiver disponível. Não compartilhe a URL por enquanto.

## 3. Publicar no Netlify sem GitHub (por enquanto)

1. Acesse https://app.netlify.com/ e crie uma conta.
2. Extraia `disciplina_universal_mvp_0_2_documentado.zip` no computador.
3. Confira `static/config.js`: precisa conter a URL e a chave pública corretas do Supabase.
4. No Netlify, escolha deploy manual / Netlify Drop e envie **a pasta `static`**, não a pasta raiz inteira.
5. Aguarde o endereço HTTPS gerado, por exemplo `https://nome-aleatorio.netlify.app`.
6. Abra o endereço no computador e confira se a tela inicial carrega.
7. Volte ao Supabase → Authentication → URL Configuration e defina esse endereço como Site URL e Redirect URL.
8. Salve e teste criar a conta e entrar.

Não publique a pasta antes de substituir os valores de exemplo em `static/config.js`. A chave anon/publishable é pública, mas `service_role` e segredos não podem ser publicados.

## 4. Instalar no Android

1. No celular Android, abra o Google Chrome.
2. Digite o endereço HTTPS fornecido pelo Netlify.
3. Entre com a conta criada no Supabase.
4. Aguarde o carregamento e a primeira sincronização.
5. Abra o menu do Chrome (três pontos).
6. Escolha **Instalar app** ou **Adicionar à tela inicial** (o rótulo varia conforme a versão).
7. Confirme a instalação.
8. Feche o navegador e abra o ícone Disciplina na tela inicial ou gaveta de aplicativos.

Se a opção de instalação não aparecer, confirme HTTPS e tente **Adicionar à tela inicial**. O primeiro acesso deve ser online.

## 5. Primeiro teste

1. Crie uma tarefa para hoje e marque como concluída.
2. Registre uma sessão com duração, resultado e próximo passo.
3. Registre uma ideia.
4. Crie uma meta e preencha o diário.
5. Feche e abra o app; verifique se os dados permanecem.
6. Ative modo avião e crie uma tarefa/ideia.
7. Feche e reabra ainda em modo avião; confira se a aplicação e os dados já carregados aparecem.
8. Desative modo avião, abra o app e aguarde sincronização.
9. Depois, entre com a mesma conta em outro dispositivo e confirme que os registros chegaram.

Offline não funciona antes do primeiro login online no dispositivo. Não limpe os dados do site durante os testes.

## 6. Google Calendar (depois do teste básico)

1. Acesse https://console.cloud.google.com/.
2. Crie um projeto e habilite Google Calendar API.
3. Configure a tela de consentimento OAuth.
4. Crie credencial OAuth do tipo **Web application**.
5. Em Authorized JavaScript origins, inclua exatamente o domínio HTTPS Netlify.
6. Copie o Client ID (não o client secret).
7. No Disciplina → Conta e integrações, cole o Client ID e salve.
8. Conecte o Google Calendar e conceda a permissão.
9. Verifique os eventos importados.

Google Calendar exige internet e pode pedir autorização novamente em outra sessão. Teste primeiro tarefas e sincronização Supabase.

## Problemas comuns

- **Configure Supabase:** `static/config.js` ainda tem valores de exemplo ou credenciais incorretas.
- **Erro de confirmação/login:** confira e-mail e configuração Email no Supabase.
- **Página abre, mas não autentica:** confira Site URL e Redirect URLs.
- **Instalação não aparece:** confirme HTTPS e Chrome atualizado; tente Adicionar à tela inicial.
- **Offline não abre:** abra online ao menos uma vez e aguarde cache do Service Worker.
- **Google não conecta:** confira Client ID, origem autorizada e API habilitada.

## Próxima etapa

Depois de validar no Android, criaremos um repositório GitHub privado e conectaremos o Netlify ao GitHub para publicar atualizações automaticamente. Não é necessário fazer isso antes do primeiro teste.
