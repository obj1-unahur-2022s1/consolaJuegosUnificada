import wollok.game.*
import menu.*
import efectosDeSonido.*
import mapa.*

class ObjetoAnimado {
	var frame = 0
	const cantFrames = 4
	const img
	
	method pasarFrame() {
		frame = (frame + 1) % cantFrames
	}
//	method remover() {
//		if(game.hasVisual(self)) {
//			game.removeVisual(self)
//			game.removeTickEvent(self.identity().toString())
//		}
//	}
	method image() = img + frame.toString() + ".png"
}

class Personaje inherits ObjetoAnimado {
	var position = null
	var direccion = null
	
	method mover(_direccion) {
		direccion = _direccion
		position = direccion.siguiente(position)
		self.darPaso()
	}
	method darPaso(){
		self.pasarFrame()
		game.schedule(250,{self.pasarFrame()})
	}
	method position() = position
	override method image() = img + direccion.toString() + frame.toString() + ".png"
}

object jugador inherits Personaje(img="bman/bman_") {
	var bombasColocadas = 0
	var activo = true

	method iniciar() {
		position = game.at(1,9)
		direccion = sur
		frame = 0
		activo = true

		keyboard.up().onPressDo({self.mover(norte)})
		keyboard.right().onPressDo({self.mover(este)})
		keyboard.left().onPressDo({self.mover(oeste)})
		keyboard.down().onPressDo({self.mover(sur)})
		keyboard.d().onPressDo({self.ponerBomba()})
		
		game.addVisual(self)
		game.onCollideDo(self,{elemento => elemento.chocarJugador()})
	}
	
	method retroceder() { 
		position = direccion.opuesto().siguiente(position)
	}
	
	method ponerBomba() {
		if (self.puedePonerBomba()) {
			new Bomba(position = position).colocar()
			bombasColocadas += 1
		}
	}
	
	method explotar() {
		self.morir()
	}
	
	method morir() {
		jugadorSoundEffect.play()
		game.removeVisual(self)
		activo = false
		game.schedule(2000,{pantallaDeGameOver.iniciar()})
	}

	method transportar() {
		victoriaSoundEffect.play()
		game.removeVisual(self)
		activo = false
		game.schedule(3000,{pantallaFinal.iniciar()})
	}
	
	method decBombasColocadas() {bombasColocadas -= 1}

	method puedePonerBomba() = game.getObjectsIn(position).size() == 1 and bombasColocadas < bombas.cantidad() and activo

	method refrescarFrame() {
		if(game.hasVisual(self)) {
			game.removeVisual(self)
			game.addVisual(self)	
		}
	}
}

class Enemigo inherits Personaje(img="bman/bichito_") {
	
	method dibujar() {
		game.addVisual(self)
		game.onTick(500,self.identity().toString(),{self.moverse()})
	}
	method explotar() {
		game.removeVisual(self)
		game.removeTickEvent(self.identity().toString())
		scoreSoundEffect.play()
		puntos.aniadirPunto()
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
		
		if(!direccionesPosibles.isEmpty())
			direccion = direccionesPosibles.anyOne()
		else
			direccion = direccion.opuesto()
	}

	method puedeAvanzarHacia(unaDireccion) {
		const elementosEnDireccion = game.getObjectsIn(unaDireccion.siguiente(position))
		return elementosEnDireccion.isEmpty() or (elementosEnDireccion.size() == 1 and elementosEnDireccion.contains(jugador))
	}
	
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
			game.addVisualIn(new PowerUp(objeto=bombas,image="bman/bombPowerUp.png"),position)
		}
		else if(suerte == 2) {
			game.addVisualIn(new PowerUp(objeto=explosiones,image="bman/flamePowerUp.png"),position)
		}
	}
}

class Bomba inherits ObjetoAnimado(cantFrames = 3,img="bman/bomba") {
	const property position
	var acabaDeSerColocada = true
	
	method colocar() {
			bombaSoundEffect.play()
			game.addVisual(self)
			jugador.refrescarFrame()
			game.onTick(800,self.identity().toString(),{self.pasarFrame()})
 			game.schedule(3000,{self.explotar()})
	}
 	method explotar() {
 		if(game.hasVisual(self)) {
			game.removeVisual(self)
			game.removeTickEvent(self.identity().toString())
 			jugador.decBombasColocadas()
 			explosionSoundEffect.play()
 			new Flama(position=position).dibujar()
 			[norte,este,sur,oeste].forEach { dir => new Explosion(direccion=dir,position=position).desencadenar() }
			jugador.refrescarFrame()
		}
 	}
 	
 	method chocarJugador() {
 		if (acabaDeSerColocada) {
 			acabaDeSerColocada = false
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
		game.onTick(50,self.identity().toString(),{self.avanzar()})
	}
	method avanzar() {
		if (posicionesAlcanzadas == explosiones.alcance()) {
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
		jugador.refrescarFrame()
	}
	method explotar() {}
	method chocarJugador() {}
	method position() = position
}
 
class Flama inherits ObjetoAnimado(cantFrames = 5,img="bman/flama") {
	const property position
	
	method dibujar() {
		game.addVisual(self)
		game.onTick(100,self.identity().toString(),{self.pasarFrame()})
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
}

class PowerUp {
	const objeto
	const property image
	
	method chocarJugador() {
		game.removeVisual(self)
		powerUpSoundEffect.play()
		objeto.powerUp()
	}
	method explotar() {
		game.removeVisual(self)	
	}
}


object portal {
	method image() = "bman/portal.png"
	method chocarJugador() {
		jugador.transportar()
	}
	method explotar() {}
}