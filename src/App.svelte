<!-- src/App.svelte -->
<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { listen } from '@tauri-apps/api/event';
  import { router } from './lib/stores/router.svelte';
  import { session } from './lib/stores/session.svelte';
  import { initOneSignal, oneSignalLogin, oneSignalLogout } from './lib/services/onesignal';
  import { hayActualizacion, type InfoVersion } from './lib/services/update';

  import SplashScreen from './lib/features/splash/SplashScreen.svelte';
  import LoginScreen from './lib/features/auth/LoginScreen.svelte';
  import RegistroScreen from './lib/features/auth/RegistroScreen.svelte';
  import RecuperarScreen from './lib/features/auth/RecuperarScreen.svelte';
  import VerificacionScreen from './lib/features/auth/VerificacionScreen.svelte';
  import HomeScreen from './lib/features/home/HomeScreen.svelte';
  import CancionDetalle from './lib/features/cancionero/CancionDetalle.svelte';
  import CompartirCancionScreen from './lib/features/cancionero/CompartirCancionScreen.svelte';
  import ModoPresentacionScreen from './lib/features/cancionero/ModoPresentacionScreen.svelte';
  import ZamponaScreen from './lib/features/zampona/ZamponaScreen.svelte';
  import EnsayoScreen from './lib/features/ensayo/EnsayoScreen.svelte';
  import EventoDetalle from './lib/features/eventos/EventoDetalle.svelte';
  import RecuerdoDetalle from './lib/features/recuerdos/RecuerdoDetalle.svelte';
  import AdminScreen from './lib/features/admin/AdminScreen.svelte';
  import AgregarEvento from './lib/features/admin/AgregarEvento.svelte';
  import AgregarCancion from './lib/features/admin/AgregarCancion.svelte';
  import AgregarRecuerdo from './lib/features/admin/AgregarRecuerdo.svelte';
  import GestionUsuarios from './lib/features/admin/GestionUsuarios.svelte';
  import GestionCategorias from './lib/features/admin/GestionCategorias.svelte';
  import ActividadScreen from './lib/features/admin/ActividadScreen.svelte';
  import ExportarRespaldo from './lib/features/admin/ExportarRespaldo.svelte';
  import BusquedaScreen from './lib/features/busqueda/BusquedaScreen.svelte';
  import HistoriaScreen from './lib/features/historia/HistoriaScreen.svelte';
  import EditarHistoriaScreen from './lib/features/historia/EditarHistoriaScreen.svelte';
  import CompartirAppScreen from './lib/features/compartir/CompartirAppScreen.svelte';
  import GestionCache from './lib/features/perfil/GestionCache.svelte';
  import ActualizacionDialog from './lib/features/update/ActualizacionDialog.svelte';
  import { canciones } from './lib/stores/canciones.svelte';

  let unlistenBack: (() => void) | null = null;
  let updateInfo = $state<InfoVersion | null>(null);
  let updateChecked = false;

  onMount(async () => {
    void initOneSignal().catch((error) => {
      // Las notificaciones son una integración opcional: un fallo del SDK
      // no debe generar un rechazo sin gestionar ni bloquear el arranque.
      console.warn('OneSignal no está disponible en esta sesión:', error);
    });
    try {
      unlistenBack = await listen('tauri://back-button', () => {
        if (router.history.length > 0) router.back();
      });
    } catch {}
  });

  onDestroy(() => unlistenBack?.());

  $effect(() => {
    if (session.user) {
      oneSignalLogin(session.user.uid);
      checkUpdate();
    } else {
      oneSignalLogout();
    }
  });

  async function checkUpdate() {
    if (updateChecked) return;
    updateChecked = true;
    updateInfo = await hayActualizacion();
  }

  async function onSplashComplete() {
    await session.restore();
    if (!session.isLogged) router.replace('login');
    else if (session.needsVerification) router.replace('verificacion');
    else router.replace('home');
  }

  function cancionParaCompartir() {
    const id = router.params.id as string;
    return canciones.buscar(id) ?? null;
  }
</script>

{#if router.current === 'splash'}
  <SplashScreen onComplete={onSplashComplete} />
{:else if router.current === 'login'}
  <LoginScreen />
{:else if router.current === 'registro'}
  <RegistroScreen />
{:else if router.current === 'recuperar'}
  <RecuperarScreen />
{:else if router.current === 'verificacion'}
  <VerificacionScreen />
{:else if router.current === 'home'}
  <HomeScreen />
{:else if router.current === 'cancion'}
  <CancionDetalle id={router.params.id as string} />
{:else if router.current === 'compartir-cancion'}
  {#if cancionParaCompartir()}
    <CompartirCancionScreen cancion={cancionParaCompartir()!} />
  {:else}
    <div class="app-background min-h-dvh flex items-center justify-center">
      <p class="text-white/40 text-sm">Canción no encontrada</p>
    </div>
  {/if}
{:else if router.current === 'modo-presentacion'}
  <ModoPresentacionScreen id={router.params.id as string} />
{:else if router.current === 'zampona'}
  <ZamponaScreen />
{:else if router.current === 'ensayo'}
  <EnsayoScreen id={router.params.id as string} />
{:else if router.current === 'evento'}
  <EventoDetalle id={router.params.id as string} />
{:else if router.current === 'recuerdo'}
  <RecuerdoDetalle id={router.params.id as string} />
{:else if router.current === 'admin'}
  <AdminScreen />
{:else if router.current === 'agregar-evento'}
  <AgregarEvento />
{:else if router.current === 'editar-evento'}
  <AgregarEvento id={router.params.id as string} />
{:else if router.current === 'agregar-cancion'}
  <AgregarCancion />
{:else if router.current === 'editar-cancion'}
  <AgregarCancion id={router.params.id as string} />
{:else if router.current === 'agregar-recuerdo'}
  <AgregarRecuerdo />
{:else if router.current === 'editar-recuerdo'}
  <AgregarRecuerdo id={router.params.id as string} />
{:else if router.current === 'buscar'}
  <BusquedaScreen />
{:else if router.current === 'historia'}
  <HistoriaScreen />
{:else if router.current === 'editar-historia'}
  <EditarHistoriaScreen />
{:else if router.current === 'compartir-app'}
  <CompartirAppScreen />
{:else if router.current === 'gestion-usuarios'}
  <GestionUsuarios />
{:else if router.current === 'gestion-categorias'}
  <GestionCategorias />
{:else if router.current === 'actividad'}
  <ActividadScreen />
{:else if router.current === 'exportar-respaldo'}
  <ExportarRespaldo />
{:else if router.current === 'gestion-cache'}
  <GestionCache />
{:else}
  <div class="app-background min-h-dvh flex items-center justify-center">
    <p class="text-white/40 text-sm tracking-wider">404</p>
  </div>
{/if}

{#if updateInfo}
  <ActualizacionDialog info={updateInfo} onCerrar={() => (updateInfo = null)} />
{/if}