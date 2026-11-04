// src/lib/stores/router.svelte.ts

export type Route =
  | 'splash'
  | 'login'
  | 'registro'
  | 'recuperar'
  | 'verificacion'
  | 'home'
  | 'cancion'
  | 'zampona'
  | 'ensayo'
  | 'evento'
  | 'recuerdo'
  | 'admin'
  | 'agregar-evento'
  | 'editar-evento'
  | 'agregar-cancion'
  | 'editar-cancion'
  | 'agregar-recuerdo'
  | 'editar-recuerdo';

type Snapshot = { route: Route; params: Record<string, unknown> };

class Router {
  current = $state<Route>('splash');
  params = $state<Record<string, unknown>>({});
  history = $state<Snapshot[]>([]);

  go(route: Route, params: Record<string, unknown> = {}) {
    if (this.current !== 'splash') {
      this.history = [...this.history, { route: this.current, params: this.params }];
    }
    this.current = route;
    this.params = params;
  }

  replace(route: Route, params: Record<string, unknown> = {}) {
    this.current = route;
    this.params = params;
  }

  back() {
    const prev = this.history[this.history.length - 1];
    if (!prev) return;
    this.history = this.history.slice(0, -1);
    this.current = prev.route;
    this.params = prev.params;
  }

  reset(route: Route) {
    this.history = [];
    this.current = route;
    this.params = {};
  }
}

export const router = new Router();