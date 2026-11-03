// src/lib/stores/player.svelte.ts

export interface Track {
  id: string;
  titulo: string;
  autor: string;
  imagenUrl: string;
}

class Player {
  current = $state<Track | null>(null);
  playing = $state(false);
  loading = $state(false);

  get isActive() {
    return this.current !== null;
  }

  async play(track: Track) {
    if (this.current?.id === track.id) {
      this.playing = !this.playing;
      return;
    }
    this.loading = true;
    // TODO: llamar a Rust para audio real (fase posterior)
    await new Promise((r) => setTimeout(r, 200));
    this.current = track;
    this.playing = true;
    this.loading = false;
  }

  toggle() {
    if (!this.current) return;
    this.playing = !this.playing;
  }

  stop() {
    this.current = null;
    this.playing = false;
    this.loading = false;
  }
}

export const player = new Player();