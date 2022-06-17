import wollok.game.*
import jugador.*
import direcciones.*

class Enemigo {
	var property position
	const idDeEnemigo
	var frame = 0
	var direccionDondeApunta = oeste
	
	method cortaLaExplosion() = false
	method dibujar() {
		game.addVisual(self)
		game.onTick(500,idDeEnemigo.toString(),{self.moverse()})
	}
	method explotar() {
		game.removeVisual(self)
	}
	method chocarConJugador() {
		jugador.morir()
	}
	method moverse() {
		if (self.puedeAvanzarHacia(direccionDondeApunta)) {
			position = direccionDondeApunta.siguiente(position)
			self.pasarFrame()
		}
		else {
			direccionDondeApunta = self.primeraDireccionPosible()
		}
	}
	method primeraDireccionPosible() {
		const direccionesPosibles = [direccionDondeApunta,direccionDondeApunta.derecha(),direccionDondeApunta.izquierda(),direccionDondeApunta.opuesto()]
		if (direccionesPosibles.any({direccion => self.puedeAvanzarHacia(direccion)})) {
			return direccionesPosibles.find({direccion => self.puedeAvanzarHacia(direccion)})
		}
		else {
			return direccionDondeApunta.opuesto()
		}
	}
	method puedeAvanzarHacia(unaDireccion) {
		return game.getObjectsIn(unaDireccion.siguiente(position)).size() == 0
	}
	method pasarFrame()
}

class Bichito inherits Enemigo {
	override method pasarFrame() {
		frame = (frame + 1) % 4
	}
	method image() = "assets/bichito/bichito_" + direccionDondeApunta.toString() + frame.toString() + ".png"
}

class Globo inherits Enemigo {
	override method pasarFrame() {
		frame = (frame + 1) % 2
	}
	method image() = "assets/globo/globo_" + frame.toString() + ".png"
}