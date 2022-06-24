import wollok.game.*
import menu.*
// NIVELES

class Nivel1 {
	
	method initialize() {
		game.addVisualIn(pantallaNivel1,game.origin())
		game.schedule(3000,
			{
				game.clear()
				self.configurar()
			})
	}
	
	method configurar() {
		game.addVisualIn(fondoDeNivel,game.origin())
		// BLOQUES
		self.ponerLimites()
		self.ponerBloquesAlternados()
		self.ponerBloquesVulnerables()
		// EL BLOQUE CON EL PORTAL
		game.addVisual(new BloqueConPortal(position=game.at(7,7)))
		// BICHITOS
		new Enemigo(position=game.at(5,5),direccion=oeste).dibujar()
		new Enemigo(position=game.at(1,7),direccion=oeste).dibujar()
		// JUGADOR
		game.addVisualIn(estado_jugador,game.at(2,11))
		jugador.iniciar()
	}
	method ponerLimites() {
		const ancho = game.width() - 1
		const largo = game.height() - 2
		const posiciones = []
		
		(1..ancho-1).forEach { i => posiciones.add(new Position(x=i,y=0));posiciones.add(new Position(x=i,y=largo)) }
		(0..largo).forEach { i => posiciones.add(new Position(x=0,y=i));posiciones.add(new Position(x=ancho,y=i)) }
		
		posiciones.forEach { pos => game.addVisual(new Bloque(position=pos))}
	}
	method ponerBloquesAlternados() {
		const ancho = game.width() - 1
		const largo = game.height() - 1
		const listaFilas = []
		const listaColumnas = []
		
		(2..largo-2).filter {numero => numero.even()}.forEach {numero => listaFilas.add(numero)}
		(2..ancho-2).filter {numero => numero.even()}.forEach {numero => listaColumnas.add(numero)}
		
		listaColumnas.forEach{columna => self.dibujarColumnaDeBloques(listaFilas,columna)}
	}
	method ponerBloquesVulnerables() {		
		self.dibujarFilaDeBloquesVulnerables([3,4,5,6,7],1)
		self.dibujarFilaDeBloquesVulnerables([3,5,11],2)
		self.dibujarFilaDeBloquesVulnerables([2,3,4,5,6],3)
		self.dibujarFilaDeBloquesVulnerables([1,3,5,7,11],4)
		self.dibujarFilaDeBloquesVulnerables([2,3,9],5)
		self.dibujarFilaDeBloquesVulnerables([1,3,5,7],6)
		self.dibujarFilaDeBloquesVulnerables([3],7)
	}
	method dibujarColumnaDeBloques(filas,columna) {
		filas.forEach{nroFila => game.addVisual(new Bloque(position=game.at(columna,nroFila)))}
	}
	method dibujarFilaDeBloquesVulnerables(columnas,fila) {
		columnas.forEach{nroColumna => game.addVisual(new BloqueVulnerable(position=game.at(nroColumna,fila)))}
	}
}

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

object jugador inherits Personaje {
	var property bombasDisponibles = 1
	var property rangoDeLaExplosion = 1
	
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
		if (self.puedePlantarBomba()) {
			new Bomba(position = position).colocar()
			bombasDisponibles -= 1	
		}
	}
	
	method explotar() {
		self.morir()
	}
	
	method morir() {
		game.sound("bman/sonido/jugador_muere.mp3").play()
		position = game.at(-1,-1)
		game.schedule(2000,
			{
				game.clear()
				menu.opcionSeleccionada(opcionContinuar)
				menu.fondoDelMenu(fondoGameOver)
				menu.iniciar()
				
			}
		)
	}

	method puedePlantarBomba() = game.getObjectsIn(position).size() == 1 and bombasDisponibles > 0
	method powerUpBomba() {bombasDisponibles += 1}
	method powerUpExplosion() {rangoDeLaExplosion += 1}
	
	method refrescarFrame() {
		game.removeVisual(self)
		game.addVisual(self)
	}
	
	override method image() = "bman/bman_" + super()
}

class Enemigo inherits Personaje {
	
	method dibujar() {
		game.addVisual(self)
		game.onTick(500,self.identity().toString(),{self.moverse()})
	}
	method explotar() {
		game.removeVisual(self)
		game.removeTickEvent(self.identity().toString().toString())
		game.sound("bman/sonido/bichito_muere.mp3").play()
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

class Bloque {
	const property position
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
		self.soltarPowerUp()
	}
	method soltarPowerUp() {
		const suerte = (1..10).anyOne()
		if(suerte == 1) {
			game.addVisualIn(new PowerUpBomba(),position)
		}
		else if(suerte == 2) {
			game.addVisualIn(new PowerUpExplosion(),position)
		}
	}
}

class BloqueConPortal inherits BloqueVulnerable {
	override method explotar() {
		game.colliders(self).first().remover()
		game.removeVisual(self)
		game.addVisualIn(new Portal(),position)
	}
}

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
 			jugador.powerUpBomba()
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

	method desencadenar() {
		game.addVisual(self)
		game.onTick(100,self.identity().toString(),{self.avanzar()})
	}
	method avanzar() {
		if (posicionesAlcanzadas == jugador.rangoDeLaExplosion()) {
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
		}
	}
	
	method explotar() {}
	method chocarJugador() {}

	method animar() { frame = (frame + 1) % 5 }
	method image() = "bman/flama" + frame.toString() + ".png"

}

class PowerUp {
	method chocarJugador() {
		game.removeVisual(self)
		game.sound("bman/sonido/powerUp.mp3").play()
	}
	method explotar() {}
}
class PowerUpBomba inherits PowerUp {
	method image() = "bman/bombPowerUp.png"
	override method chocarJugador() {
		super()
		jugador.powerUpBomba()
	}
}

class PowerUpExplosion inherits PowerUp{
	method image() = "bman/flamePowerUp.png"
	override method chocarJugador() {
		super()
		jugador.powerUpExplosion()
	}

}

class Portal {
	method image() = "bman/portal.png"
	method chocarJugador() {

	}
	method explotar() {}
}



object estado_jugador {
	method text() = "bombas = "+jugador.bombasDisponibles().toString()+" | explosión = x"+jugador.rangoDeLaExplosion().toString()
	method textColor() = "FFFFFFFF"
}

object fondoDeNivel {
	method image() = "bman/pisoMosaico.png"
}

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