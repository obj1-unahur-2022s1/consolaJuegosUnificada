import wollok.game.*
import jugador.*
import elementosDeEntorno.*

class Nivel {
	method configurar() {		
		// BLOQUES
		self.ponerLimites()
		// JUGADOR
		jugador.iniciar()
	}
	method ponerLimites() {
		const ancho = game.width() - 1
		const largo = game.height() - 1
		const posiciones = []
		
		(1..ancho-1).forEach { i => posiciones.add(new Position(x=i,y=0));posiciones.add(new Position(x=i,y=largo)) }
		(0..largo).forEach { i => posiciones.add(new Position(x=0,y=i));posiciones.add(new Position(x=ancho,y=i)) }
		
		posiciones.forEach { pos => new Bloque(position = pos).dibujar() }
	}
}

object nivel1 inherits Nivel {
	
	
}