import wollok.game.*
import consola.*
import mapa.*
import efectosDeSonido.*

class Menu {
	var opcionSeleccionada = null

	method iniciar() {
		game.clear()
		keyboard.up().onPressDo{self.cambiarOpcionSeleccionadaA(opcionSeleccionada.opcionSuperior())}
		keyboard.down().onPressDo{self.cambiarOpcionSeleccionadaA(opcionSeleccionada.opcionInferior())}
		keyboard.enter().onPressDo{ opcionSeleccionada.seleccionar() }
		flechaMenu.position(opcionSeleccionada.posicion())
		game.addVisualIn(self,game.origin())
		game.addVisual(flechaMenu)
	}
	method cambiarOpcionSeleccionadaA(opcion) {
		opcionSeleccionada = opcion
		flechaMenu.position(opcionSeleccionada.posicion())
		cursorSoundEffect.play()
	}
}

object pantallaDeInicio inherits Menu {
	method image() = "bman/menuBomberman.png"
	override method iniciar() {
		opcionSeleccionada = opcionComenzarJuego
		super()
	}
}

object pantallaDeGameOver inherits Menu {
	method image() = "bman/menuGameOver.png"
	override method iniciar() {
		opcionSeleccionada = opcionContinuar
		super()
	}
}

object pantallaDeControles {
	method iniciar() {
		game.clear()
		keyboard.enter().onPressDo{
			game.schedule(100,{pantallaDeInicio.iniciar()})
		 }
		game.addVisualIn(self,game.origin())
	}
	method image() = "bman/menuControles.png"
}

object pantallaFinal {
	method image() = "bman/pantallaFinal.png"
	method iniciar() {
		game.clear()
		keyboard.enter().onPressDo{
			game.schedule(100,{pantallaDeInicio.iniciar()})
		 }
		game.addVisualIn(self,game.origin())
	}
}

object opcionComenzarJuego {
	method posicion() = game.at(5,7)

	method seleccionar() {
		selectionSoundEffect.play()
		nivel1.iniciar()
	}
	
	method opcionSuperior() = opcionSalir

	method opcionInferior() = opcionControles
}

object opcionControles {
	method posicion() = game.at(4,5)
	
	method seleccionar() {
		selectionSoundEffect.play()
		game.schedule(100,{pantallaDeControles.iniciar()})
	}
	
	method opcionSuperior() = opcionComenzarJuego
	
	method opcionInferior() = opcionSalir
}

object opcionSalir {
	method posicion() = game.at(5,3)

	method seleccionar() {
		game.schedule(100,
		{
			game.clear()
			consola.iniciar()
		}
	)}

	method opcionSuperior() = opcionControles

	method opcionInferior() = opcionComenzarJuego
}

object opcionContinuar {
	method posicion() = game.at(6,2)

	method seleccionar() {
		selectionSoundEffect.play()
		nivel1.iniciar()
	}

	method opcionSuperior() = opcionMenuPrincipal

	method opcionInferior() = self.opcionSuperior()
}

object opcionMenuPrincipal {
	method posicion() = game.at(6,1)

	method seleccionar() {
		selectionSoundEffect.play()
		pantallaDeInicio.iniciar()
	}

	method opcionSuperior() = opcionContinuar

	method opcionInferior() = self.opcionSuperior()
}

object flechaMenu {
	var property position
	method image() = "bman/flecha.png"
}
