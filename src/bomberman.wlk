import wollok.game.*
import menu.*
import efectosDeSonido.*
import mapa.*


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
	var vivo = true

	method iniciar() {
		position = game.at(1,1)
		direccion = sur
		bombasDisponibles = 1
		rangoDeLaExplosion = 1
		frame = 0
		vivo = true

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
			bombasDisponibles -= 1	
		}
	}
	
	method explotar() {
		self.morir()
	}
	
	method morir() {
		jugadorSoundEffect.play()
		game.removeVisual(self)
		vivo = false
		game.schedule(2000,{pantallaDeGameOver.iniciar()})
	}

	method puedePonerBomba() = game.getObjectsIn(position).size() == 1 and bombasDisponibles > 0 and vivo
	method powerUpBomba() {bombasDisponibles += 1}
	method powerUpExplosion() {rangoDeLaExplosion += 1}
	
	method refrescarFrame() {
		if(game.hasVisual(self)) {
			game.removeVisual(self)
			game.addVisual(self)	
		}
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
		bichitoSoundEffect.play()
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
		game.addVisualIn(portal,position)
	}
}

class Bomba {
	const property position
	var frame = 0
	var acabaDeSerColocada = true
	
	method colocar() {
			bombaSoundEffect.play()
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
 			explosionSoundEffect.play()
 			new Flama(position=position).dibujar()
			new Explosion(direccion=norte,position=position).desencadenar()
			new Explosion(direccion=este,position=position).desencadenar()
			new Explosion(direccion=sur,position=position).desencadenar()
			new Explosion(direccion=oeste,position=position).desencadenar()
			jugador.refrescarFrame()
		}
 	}
 		
 	method image() = "bman/bomba" + frame.toString() + ".png"
 	method animar() {
 		frame = (frame + 1) % 3
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
		jugador.refrescarFrame()
	}
	method explotar() {}
	method chocarJugador() {}
	method position() = position
}
 
class Flama {
	const property position
	var frame = 0
	method dibujar() {
		game.addVisual(self)
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
	method explotar() {
		game.removeVisual(self)	
	}
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

object portal {
	method image() = "bman/portal.png"
	method chocarJugador() {
		
	}
	method explotar() {}
}