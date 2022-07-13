import wollok.game.*
import menu.*
import efectosDeSonido.*
import mapa.*

object bomber {
	var property position
	method image() = "bman_head.png"
	method iniciar() {
		menus.menuInicio().iniciar()
	}
}

object jugador inherits Personaje(img="bman/bman_") {
	var bombasColocadas = 0
	var property activo = true

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
	
	method explotar() {}
	
	method decBombasColocadas() {bombasColocadas -= 1}

	method puedePonerBomba() = game.getObjectsIn(position).size() == 1 and bombasColocadas < bombas.cantidad() and activo
}

class Enemigo inherits Personaje(img="bman/bichito_") {
	
	method dibujar() {
		juegoBomb.dibujarElementoConEvento(self,500,{self.moverse()})
	}
	method explotar() {
		juegoBomb.removerElementoConEvento(self)
		scoreSoundEffect.play()
		puntos.aniadirPunto()
	}
	method chocarJugador() {
		eventos.gameOver().iniciar()
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
			game.addVisual(new PowerUp(objeto=bombas,image="bman/bombPowerUp.png",position =  position))
		}
		else if(suerte == 2) {
			game.addVisual(new PowerUp(objeto=explosiones,image="bman/flamePowerUp.png",position = position))
		}
	}
}

class Bomba inherits Sprite(cantFrames = 3,img="bman/bomba") {
	const property position
	var acabaDeSerColocada = true
	
	method colocar() {
			bombaSoundEffect.play()
			juegoBomb.dibujarElementoConEvento(self,800,{self.pasarFrame()})
			jugador.refrescarSprite()
 			game.schedule(3000,{self.explotar()})
	}
 	method explotar() {
 		if(game.hasVisual(self)) {
			juegoBomb.removerElementoConEvento(self)
 			jugador.decBombasColocadas()
 			explosionSoundEffect.play()
 			new Flama(position=position).dibujar()
 			[norte,este,sur,oeste].forEach { dir => new Explosion(direccion=dir,position=position).desencadenar() }
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
		juegoBomb.dibujarElementoConEvento(self,50,{self.avanzar()})
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
		juegoBomb.removerElementoConEvento(self)
		jugador.refrescarSprite()
	}
	method explotar() {}
	method chocarJugador() {}
	method position() = position
}
 
class Flama inherits Sprite(cantFrames = 5,img="bman/flama") {
	const property position
	
	method dibujar() {
		game.addVisual(self)
		game.onTick(100,self.identity().toString(),{self.pasarFrame()})
		game.onCollideDo(self,{elemento => elemento.explotar()})
		game.schedule(2000,{self.remover()})
	}
	method remover() {
		if(game.hasVisual(self)) {
			juegoBomb.removerElementoConEvento(self)
		}
	}
	method explotar() {}
	method chocarJugador() {eventos.gameOver().iniciar()}
}

class PowerUp {
	const objeto
	const property image
	const property position
	
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
		eventos.nivelCompletado().iniciar()
	}
	method explotar() {}
}

object juegoBomb  {
	method dibujarElementoConEvento(elemento,tiempo,closure) {
		game.addVisual(elemento)
		game.onTick(tiempo,elemento.identity().toString(),closure)
	}
	method removerElementoConEvento(elemento) {
		game.removeVisual(elemento)
		game.removeTickEvent(elemento.identity().toString())
	}
}

class Sprite {
	var frame = 0
	const cantFrames = 4
	const img
	
	method pasarFrame() {
		frame = (frame + 1) % cantFrames
	}
	method refrescarSprite() {
		if(game.hasVisual(self)) {
			game.removeVisual(self)
			game.addVisual(self)	
		}
	}
	method image() = img + frame.toString() + ".png"
}

class Personaje inherits Sprite {
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