import wollok.game.*
import consola.*
import juego.*

// NIVELES

class Nivel {
	method configurar() {
		// BLOQUES
		self.ponerLimites()
		self.ponerBloquesAlternados()
		game.addVisualIn(barraDeEstado,game.at(0,11))
	}
	method ponerLimites() {
		const ancho = game.width() - 1
		const largo = game.height() - 2
		const posiciones = []
		
		(1..ancho-1).forEach { i => posiciones.add(new Position(x=i,y=0));posiciones.add(new Position(x=i,y=largo)) }
		(0..largo).forEach { i => posiciones.add(new Position(x=0,y=i));posiciones.add(new Position(x=ancho,y=i)) }
		
		posiciones.forEach { pos => game.addVisualIn(new Bloque(),pos)}
	}
	// Dibuja matriz de bloques fijos alternados
	method ponerBloquesAlternados() {
		const ancho = game.width() - 1
		const largo = game.height() - 1
		const listaFilas = []
		const listaColumnas = []
		
		(2..largo-2).filter {numero => numero.even()}.forEach {numero => listaFilas.add(numero)}
		(2..ancho-2).filter {numero => numero.even()}.forEach {numero => listaColumnas.add(numero)}
		
		listaColumnas.forEach{columna => self.dibujarFilasBloques(listaFilas,columna)}
	}
	method dibujarFilasBloques(listaFilas,nroColumna) {
		listaFilas.forEach{nroFila => game.addVisualIn(new Bloque(),game.at(nroColumna,nroFila))}
	}
}

class Nivel1 inherits Nivel {
	override method configurar() {
		game.addVisualIn(fondoDeNivel,game.origin())
		super()
		self.configurarEscenario()
		// JUGADOR
		jugador.iniciar()
		// BICHITOS
		new Enemigo(position=game.at(5,5),direccion=oeste).dibujar()
		new Enemigo(position=game.at(1,7),direccion=oeste).dibujar()
		// MUSICA
		game.sound("bman/sonido/nivel1.wav").shouldLoop(true)
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
		
		(1..7).forEach{fila => self.dibujarBloquesVulnerables(listaColumnas.get(fila-1),fila)}
	}
	method dibujarBloquesVulnerables(listaPosColumnas,posFila) {
		listaPosColumnas.forEach{posColumna => game.addVisualIn(new BloqueVulnerable(),game.at(posColumna,posFila))}
	}
}

// PERSONAJES

class Personaje {
	var position = null
	var direccion = null
	var frame = 0
	
	method mover(_direccion) {
		direccion = _direccion
		position = direccion.siguiente(position)
		self.animar()
	}
	method animar(){
		self.pasarFrame()
		game.schedule(250,{self.pasarFrame()})
	}
	method pasarFrame() {
		frame = (frame + 1) % 4
	}
	method position() = position
	method image() = direccion.toString() + frame.toString() + ".png"
}

// JUGADOR

object jugador inherits Personaje {
	var bombasDisponibles = 1
	
	method iniciar() {
		position = game.at(1,1)
		direccion = sur
		bombasDisponibles = 1
		frame = 0

		keyboard.up().onPressDo({self.mover(norte)})
		keyboard.right().onPressDo({self.mover(este)})
		keyboard.left().onPressDo({self.mover(oeste)})
		keyboard.down().onPressDo({self.mover(sur)})
		keyboard.d().onPressDo({self.plantarBomba()})
		
		game.addVisual(self)
		game.onCollideDo(self,{elemento => elemento.chocarJugador()})
	}
	
	method retroceder() { 
		position = direccion.opuesto().siguiente(position)
	}
	
	method plantarBomba() {
		if (self.puedePlantarBomba())
			new Bomba(position = position).colocar()
			bombasDisponibles -= 1
	}
	
	method explotar() {
		self.morir()
	}
	
	method morir() {
		game.clear()
		menu.opcionSeleccionada(opcionContinuar)
		menu.fondoDelMenu(fondoGameOver)
		menu.iniciar()
	}

	method puedePlantarBomba() = game.getObjectsIn(position).size() == 1 and bombasDisponibles > 0
	method agregarBombaDisponible() {bombasDisponibles += 1}
	
	method refrescarFrame() {
		game.removeVisual(self)
		game.addVisual(self)
	}
	
	override method image() = "bman/bman_" + super()
}

// ENEMIGOS

class Enemigo inherits Personaje {
	
	method dibujar() {
		game.addVisual(self)
		game.onTick(500,self.identity().toString(),{self.moverse()})
	}
	method explotar() {
		game.removeVisual(self)
		game.removeTickEvent(self.identity().toString().toString())
	}
	method chocarJugador() {
		jugador.morir()
	}
	method moverse() {
		if (self.puedeAvanzarHacia(direccion)) {
			self.mover(direccion)
		}
		else {
			self.cambiarDeDireccion()
		}
	}
	
	method cambiarDeDireccion() {
		const direccionesPosibles = [norte,este,sur,oeste]
		direccionesPosibles.removeAllSuchThat( {direccion => !self.puedeAvanzarHacia(direccion) })
		try {
			direccion = direccionesPosibles.anyOne()
		}
		catch e {
			direccion = direccion.opuesto()
		}
	}

	method puedeAvanzarHacia(unaDireccion) {
		const elementosEnDireccion = game.getObjectsIn(unaDireccion.siguiente(position))
		return elementosEnDireccion.isEmpty() or (elementosEnDireccion.size() == 1 and elementosEnDireccion.contains(jugador))
	}

	override method image() = "bman/bichito_" + super()
	
}

// BLOQUES

class Bloque {
	method image() = "bman/solidBlock.png"
	method explotar() {
		game.colliders(self).forEach { objeto => objeto.remover() }
	}
	method chocarJugador() {jugador.retroceder()}
}

class BloqueVulnerable inherits Bloque {
	override method image() = "bman/explodableBlock.png"
	override method explotar() {
		game.colliders(self).first().remover()
		game.removeVisual(self)
	}
}

// HABILIDAD JUGADOR

class Bomba {
	const property position
	var frame = 0
	var acabaDeSerPlantada = true
	
	method colocar() {
			game.sound("bman/sonido/bomba.mp3").play()
			game.addVisual(self)
			jugador.refrescarFrame()
			game.onTick(800,self.identity().toString(),{self.animar()})
 			game.schedule(3000,{self.explotar()})
	}
 	method explotar() {
 		if(game.hasVisual(self)) {
			game.removeVisual(self)
			game.removeTickEvent(self.identity().toString())
 			jugador.agregarBombaDisponible()
 			game.sound("bman/sonido/explosion.mp3").play()
 			new Flama(position=position).dibujar()
			new Explosion(direccion=norte,position=position).desencadenar()
			new Explosion(direccion=este,position=position).desencadenar()
			new Explosion(direccion=sur,position=position).desencadenar()
			new Explosion(direccion=oeste,position=position).desencadenar()	
		}
 	}
 		
 	method image() = "bman/bomba" + frame.toString() + ".png"
 	method animar() {
 		frame = (frame + 1) % 3
 	}
 	method chocarJugador() {
 		if (acabaDeSerPlantada) {
 			acabaDeSerPlantada = false
 		}
 		else {
 			jugador.retroceder()
 		}
 	}
 }
 
class Explosion {
	const direccion
	var position
	var posicionesAlcanzadas = 0
	var alcance = 2
	method desencadenar() {
		game.addVisual(self)
		game.onTick(100,self.identity().toString(),{self.avanzar()})
	}
	method avanzar() {
		if (posicionesAlcanzadas == alcance) {
			self.remover()
		}
		else {
			position = direccion.siguiente(position)
			posicionesAlcanzadas += 1
			new Flama(position=position).dibujar()
		}
	}
	method remover() {
		game.removeVisual(self)
		game.removeTickEvent(self.identity().toString())
	}
	method explotar() {}
	method position() = position
	method image() = "bman/explosion.png"
}
 
class Flama {
	const property position
	var frame = 0
	method dibujar() {
		game.addVisual(self)
		jugador.refrescarFrame()
		game.onTick(100,self.identity().toString(),{self.animar()})
		game.onCollideDo(self,{elemento => elemento.explotar()})
		game.schedule(2000,{self.remover()})
	}
 	
	method remover() {
		if(game.hasVisual(self)) {
			game.removeVisual(self)
			game.removeTickEvent(self.identity().toString())
			jugador.agregarBombaDisponible()
		}
	}
	
	method explotar() {}
	method chocarJugador() {}

	method animar() { frame = (frame + 1) % 5 }
	method image() = "bman/flama" + frame.toString() + ".png"

}

// DIRECCIONES

object norte {
	method siguiente(posicion) = posicion.up(1)
	method opuesto() = sur
}

object este {
	method siguiente(posicion) = posicion.right(1)
	method opuesto() = oeste
}

object sur {
	method siguiente(posicion) = posicion.down(1)
	method opuesto() = norte
}

object oeste {
	method siguiente(posicion) = posicion.left(1)
	method opuesto() = este
}

// FONDO

object fondoDeNivel {
	method image() = "bman/pisoMosaico.png"
}

object barraDeEstado {
	method image() = "bman/barra-estado.png"
}
// MENU

object menu {
	var property opcionSeleccionada
	var property fondoDelMenu

	method iniciar() {
		keyboard.up().onPressDo{self.cambiarOpcionSeleccionadaA(opcionSeleccionada.opcionSuperior())}
		keyboard.down().onPressDo{self.cambiarOpcionSeleccionadaA(opcionSeleccionada.opcionInferior())}
		keyboard.enter().onPressDo{opcionSeleccionada.seleccionar()}
		flechaMenu.position(opcionSeleccionada.posicion())
		game.addVisual(fondoDelMenu)
		game.addVisual(flechaMenu)
	}
	method cambiarOpcionSeleccionadaA(opcion) {
		opcionSeleccionada = opcion
		flechaMenu.position(opcionSeleccionada.posicion())
	}
}

object opcionComenzarJuego {
	method posicion() = game.at(5,7)

	method seleccionar() {bomberman.jugar()}
	
	method opcionSuperior() = opcionSalir

	method opcionInferior() = opcionControles
}

object opcionControles {
	method posicion() = game.at(4,5)
	
	method seleccionar() {} //En progreso
	
	method opcionSuperior() = opcionComenzarJuego
	
	method opcionInferior() = opcionSalir
}

object opcionSalir {
	method posicion() = game.at(5,3)

	method seleccionar() {consola.iniciar()}

	method opcionSuperior() = opcionControles

	method opcionInferior() = opcionComenzarJuego
}

object opcionContinuar {
	method posicion() = game.at(6,2)

	method seleccionar() {bomberman.jugar()}

	method opcionSuperior() = opcionMenuPrincipal

	method opcionInferior() = self.opcionSuperior()
}

object opcionMenuPrincipal {
	method posicion() = game.at(6,1)

	method seleccionar() {
		game.clear()
		menu.opcionSeleccionada(opcionComenzarJuego)
		menu.fondoDelMenu(fondoMenu)
		menu.iniciar()
	}

	method opcionSuperior() = opcionContinuar

	method opcionInferior() = self.opcionSuperior()
}

object fondoMenu {
	method position() = game.at(0,0)
	method image() = "bman/menuBomberman.png"
}

object fondoGameOver {
	method position() = game.at(0,0)
	method image() = "bman/menuGameOver.png"
}

object flechaMenu {
	var property position
	method image() = "bman/flecha.png"
}