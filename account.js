(() => {
  const openButton = document.getElementById('accountOpen');
  const backdrop = document.getElementById('accountBackdrop');
  const form = document.getElementById('accountForm');
  const emailInput = document.getElementById('accountEmail');
  const passwordInput = document.getElementById('accountPassword');
  const submitButton = document.getElementById('accountSubmit');
  const modeButton = document.getElementById('accountModeToggle');
  const forgotButton = document.getElementById('accountForgot');
  const logoutButton = document.getElementById('accountLogout');
  const status = document.getElementById('accountStatus');
  const accountLabel = document.getElementById('accountLabel');
  const syncLabel = document.getElementById('accountSyncLabel');
  const keys = ['herzenssache_tasks', 'herzenssache_events', 'herzenssache_selfcare_checkin'];
  const config = window.HERZENSSACHE_SUPABASE || {};
  const configured = Boolean(config.url && config.publishableKey);
  let client = null;
  let activeUser = null;
  let mode = 'signin';
  let syncTimer = null;
  let hydrating = false;

  function tell(message, kind = 'info') {
    status.textContent = message;
    status.dataset.kind = kind;
  }
  function setMode(next) {
    mode = next;
    const needsPassword = mode !== 'reset';
    passwordInput.hidden = !needsPassword;
    passwordInput.required = needsPassword;
    passwordInput.autocomplete = mode === 'signup' || mode === 'newpassword' ? 'new-password' : 'current-password';
    passwordInput.placeholder = mode === 'newpassword' ? 'Neues Passwort (mind. 8 Zeichen)' : 'Passwort';
    passwordInput.minLength = mode === 'newpassword' || mode === 'signup' ? 8 : 1;
    submitButton.textContent = ({signin:'Anmelden', signup:'Konto erstellen', reset:'Link zum Zurücksetzen senden', newpassword:'Neues Passwort speichern'})[mode];
    modeButton.hidden = mode === 'reset' || mode === 'newpassword';
    forgotButton.hidden = mode !== 'signin';
    logoutButton.hidden = !activeUser;
    document.getElementById('accountTitle').textContent = mode === 'signup' ? 'Dein Konto erstellen' : mode === 'newpassword' ? 'Neues Passwort festlegen' : mode === 'reset' ? 'Passwort zurücksetzen' : 'Willkommen zurück';
    if (modeButton) modeButton.textContent = mode === 'signup' ? 'Ich habe schon ein Konto' : 'Neues Konto erstellen';
  }
  function openModal() {
    backdrop.hidden = false;
    setMode(activeUser ? 'signin' : mode);
    if (!configured) tell('Die Konto-Oberfläche ist bereit. Zum Aktivieren müssen noch Supabase-Projekt-URL und Publishable key eingetragen werden.');
    else if (!client) tell('Der Anmeldedienst konnte nicht geladen werden. Bitte prüfe deine Internetverbindung und lade die Seite neu.', 'error');
    else if (activeUser) tell(`Angemeldet als ${activeUser.email || 'dein Konto'}.`);
    emailInput.focus();
  }
  function closeModal() { backdrop.hidden = true; }
  function localSnapshot() {
    return Object.fromEntries(keys.map(key => {
      try { return [key, JSON.parse(localStorage.getItem(key) || 'null')]; }
      catch { return [key, null]; }
    }));
  }
  function applySnapshot(payload) {
    hydrating = true;
    for (const key of keys) {
      if (Object.prototype.hasOwnProperty.call(payload || {}, key) && payload[key] !== null) {
        localStorage.setItem(key, JSON.stringify(payload[key]));
      } else {
        localStorage.removeItem(key);
      }
    }
    hydrating = false;
    window.location.reload();
  }
  async function syncNow() {
    if (!client || !activeUser || hydrating) return false;
    try {
      const {error} = await client.from('herzenssache_state').upsert({
        user_id: activeUser.id,
        payload: localSnapshot(),
        updated_at: new Date().toISOString()
      }, {onConflict:'user_id'});
      if (error) throw error;
    } catch (error) {
      syncLabel.textContent = 'Synchronisierung pausiert – lokal gespeichert';
      syncLabel.title = 'Die Änderungen bleiben auf diesem Gerät gespeichert und werden bei einer späteren Verbindung erneut synchronisiert.';
      return false;
    }
    syncLabel.textContent = 'Mit deinem Konto synchronisiert';
    return true;
  }
  function scheduleSync() {
    if (!activeUser || hydrating) return;
    syncLabel.textContent = 'Synchronisiere …';
    clearTimeout(syncTimer);
    syncTimer = setTimeout(syncNow, 700);
  }
  async function loadUserState(user) {
    if (!client || !user) return;
    const {data, error} = await client.from('herzenssache_state').select('payload').eq('user_id', user.id).maybeSingle();
    if (error) {
      tell('Konto ist angemeldet, aber persönliche Daten konnten nicht geladen werden. Prüfe bitte die Datenbank-Einrichtung.', 'error');
      return;
    }
    if (data?.payload) applySnapshot(data.payload);
    else {
      await syncNow();
      syncLabel.textContent = 'Deine persönlichen Daten sind mit deinem Konto verbunden';
    }
  }
  function setUser(user) {
    activeUser = user || null;
    accountLabel.textContent = activeUser ? (activeUser.email || 'Angemeldet') : (configured ? 'Mein Konto' : 'Konto einrichten');
    logoutButton.hidden = !activeUser;
    syncLabel.textContent = activeUser ? 'Konto verbunden' : '';
  }

  openButton.addEventListener('click', openModal);
  document.getElementById('accountClose').addEventListener('click', closeModal);
  backdrop.addEventListener('click', event => { if (event.target === backdrop) closeModal(); });
  document.addEventListener('keydown', event => { if (event.key === 'Escape') closeModal(); });
  modeButton.addEventListener('click', () => { setMode(mode === 'signup' ? 'signin' : 'signup'); tell(''); });
  forgotButton.addEventListener('click', async () => {
    if (!client) return tell('Zum Zurücksetzen muss zuerst Supabase verbunden werden.');
    if (!emailInput.value.trim()) return tell('Gib zuerst deine E-Mail-Adresse ein.');
    const {error} = await client.auth.resetPasswordForEmail(emailInput.value.trim(), {redirectTo:location.origin + location.pathname});
    tell(error ? error.message : 'Wenn ein Konto zu dieser Adresse besteht, erhältst du eine E-Mail mit einem Link.');
  });
  logoutButton.addEventListener('click', async () => {
    if (!client || !activeUser) return;
    if (!await syncNow()) return tell('Abmelden pausiert: Die aktuellen Änderungen konnten nicht synchronisiert werden. Bitte versuche es erneut, sobald du wieder online bist.', 'error');
    const {error} = await client.auth.signOut();
    if (error) return tell('Abmelden ging gerade nicht. Bitte versuche es erneut.', 'error');
    keys.forEach(key => localStorage.removeItem(key));
    window.location.reload();
  });
  form.addEventListener('submit', async event => {
    event.preventDefault();
    if (!configured) return tell('Noch nicht verbunden: In supabase-config.js müssen zuerst Projekt-URL und Publishable key eingetragen und die Datenbank eingerichtet werden.');
    if (!client) return tell('Der Supabase-Anmeldedienst ist nicht verfügbar. Bitte lade die Seite mit Internetverbindung neu.', 'error');
    const email = emailInput.value.trim();
    const password = passwordInput.value;
    submitButton.disabled = true;
    try {
      if (mode === 'signup') {
        const {data, error} = await client.auth.signUp({email, password, options:{emailRedirectTo:location.origin + location.pathname}});
        if (error) throw error;
        if (data.session) {
          setUser(data.user);
          await loadUserState(data.user);
          tell('Dein Konto ist erstellt und angemeldet.');
        } else {
          tell('Fast geschafft: Öffne den Bestätigungslink, den Supabase an deine E-Mail-Adresse sendet. Danach kannst du dich hier anmelden.');
        }
      } else if (mode === 'signin') {
        const {data, error} = await client.auth.signInWithPassword({email, password});
        if (error) throw error;
        setUser(data.user);
        await loadUserState(data.user);
        tell('Du bist angemeldet.');
      } else if (mode === 'newpassword') {
        const {error} = await client.auth.updateUser({password});
        if (error) throw error;
        setMode('signin');
        tell('Dein Passwort wurde aktualisiert. Du kannst dich jetzt anmelden.');
      } else {
        const {error} = await client.auth.resetPasswordForEmail(email, {redirectTo:location.origin + location.pathname});
        if (error) throw error;
        tell('Wenn ein Konto zu dieser Adresse besteht, erhältst du eine E-Mail mit einem Link.');
      }
    } catch (error) {
      tell(error.message || 'Das hat nicht geklappt. Bitte prüfe deine Angaben und versuche es erneut.', 'error');
    } finally {
      submitButton.disabled = false;
    }
  });

  const nativeSetItem = Storage.prototype.setItem;
  Storage.prototype.setItem = function(key, value) {
    nativeSetItem.call(this, key, value);
    if (this === localStorage && keys.includes(key)) scheduleSync();
  };
  window.addEventListener('online', scheduleSync);
  document.addEventListener('visibilitychange', () => { if (document.visibilityState === 'visible') scheduleSync(); });

  if (configured && window.supabase?.createClient) {
    client = window.supabase.createClient(config.url, config.publishableKey);
    client.auth.getSession().then(({data, error}) => {
      if (error) return tell('Der Anmeldestatus konnte nicht geprüft werden.', 'error');
      if (data.session?.user) {
        setUser(data.session.user);
        const recovery = new URLSearchParams(location.hash.slice(1)).get('type') === 'recovery';
        if (recovery) {
          setMode('newpassword');
          history.replaceState(null, '', location.pathname + location.search);
          backdrop.hidden = false;
          tell('Lege jetzt ein neues Passwort fest.');
        } else loadUserState(data.session.user);
      }
    });
    client.auth.onAuthStateChange((event, session) => {
      setUser(session?.user || null);
      if (event === 'PASSWORD_RECOVERY') {
        setMode('newpassword');
        backdrop.hidden = false;
        tell('Lege jetzt ein neues Passwort fest.');
      }
      if (event === 'SIGNED_IN' && session?.user) setTimeout(() => loadUserState(session.user), 0);
    });
  }
  setUser(null);
  setMode('signin');
})();

