export class Point {
  constructor(
    public readonly latitude: number,
    public readonly longitude: number,
  ) {}

  toPostgres(): string {
    return `(${this.longitude},${this.latitude})`;
  }

  toJSON() {
    return { latitude: this.latitude, longitude: this.longitude };
  }
}
