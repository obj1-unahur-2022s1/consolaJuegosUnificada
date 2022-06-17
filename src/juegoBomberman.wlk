import wollok.game.*
import jugador.*
import elementosDeEntorno.*
import enemigos.*

object background {
	method position() = game.at(0,0)
	method explotar() {}
	method chocarConJugador() {}
	method cortaLaExplosion() = false
	method image() = "assets/pisoMosaico.png"
	method establecer() {
		game.addVisual(self)
	}
}

class Nivel {
	const ancho = game.width() - 1
	const alto = game.height() - 1
	method configurar() {
		// BLOQUES
		self.dibujarBloquesFijos([2,4,6],[2,4,6,8,10])
		self.ponerLimites()
		// JUGADOR
		jugador.iniciar()
	}
	method ponerLimites() {
		const posiciones = []
		
		(1..ancho-1).forEach { i => posiciones.add(new Position(x=i,y=0));posiciones.add(new Position(x=i,y=alto)) }
		(0..alto).forEach { i => posiciones.add(new Position(x=0,y=i));posiciones.add(new Position(x=ancho,y=i)) }
		
		posiciones.forEach { pos => new Bloque(position = pos).dibujar() }
	}
	// Dibuja matriz de bloques fijos
	method dibujarBloquesFijos(listaFilas,listaColumnas) {
		listaColumnas.forEach{columna => self.dibujarFilasBloques(listaFilas,columna)}
	}
	method dibujarFilasBloques(listaFilas,nroColumna) {
		listaFilas.forEach{nroFila => new Bloque(position = game.at(nroColumna,nroFila)).dibujar()}
	}
}

object nivel1 inherits Nivel {
	override method configurar() {
		background.establecer()
		self.configurarEscenario()
		super()
	}
	method configurarEscenario() {
		const fila1 = [3,4,5,6,7] 		// Columnas	
		const fila2 = [3,5,11]			// bloques fijos en 2,4,6,8,10
		const fila3 = [2,3,4,5,6]
		const fila4 = [1,3,5,7,11]		// bloques fijos en 2,4,6,8,10
		const fila5 = [2,3,9]
		const fila6 = [1,3,5,7]			// bloques fijos en 2,4,6,8,10
		const fila7 = [3,7]
		const listaColumnas = [fila1,fila2,fila3,fila4,fila5,fila6,fila7]
		
		(1..7).forEach{fila => self.dibujarBloquesVulnerables(listaColumnas.get(fila-1),fila)}//new BloqueVulnerable(position = game.at(posColumna,fila)).dibujar()}
				
		new Bichito(idDeEnemigo=1,position=game.at(5,5)).dibujar()
		new Bichito(idDeEnemigo=2,position=game.at(1,7)).dibujar()
		new Globo(idDeEnemigo=3,position=game.at(9,1)).dibujar()
		new Globo(idDeEnemigo=4,position=game.at(11,5)).dibujar()
	}
	method dibujarBloquesVulnerables(listaPosColumnas,posFila) {
		listaPosColumnas.forEach{posColumna => new BloqueVulnerable(position = game.at(posColumna,posFila)).dibujar()}
	}
}