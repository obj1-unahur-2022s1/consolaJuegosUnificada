import wollok.game.*
import consola.*
import mapa.*
import efectosDeSonido.*
import bomberman.*

class Menu {
	var opcionSeleccionada
	const property image
	const opciones = true

	method iniciar() {
		game.clear()
		game.addVisualIn(self,game.origin())
		if(opciones) {
			keyboard.up().onPressDo{self.cambiarOpcionSeleccionadaA(opcionSeleccionada.opcionSuperior())}
			keyboard.down().onPressDo{self.cambiarOpcionSeleccionadaA(opcionSeleccionada.opcionInferior())}
			flechaMenu.position(opcionSeleccionada.posicion())
			game.addVisual(flechaMenu)
		}
			
		keyboard.enter().onPressDo{ 
									game.schedule(100,
										{
											opcionSeleccionada.seleccionar() 
											selectionSoundEffect.play() 
										}
									)
								  }
	}
	method cambiarOpcionSeleccionadaA(opcion) {
		opcionSeleccionada = opcion
		flechaMenu.position(opcionSeleccionada.posicion())
		cursorSoundEffect.play()
	}
}

class Evento {
	var soundEffect
	var tiempo
	var pantalla
	method iniciar() {
		game.schedule(100,{
			soundEffect.play()
			game.removeVisual(jugador)
			jugador.activo(false)
			game.schedule(tiempo,{pantalla.iniciar()})
		})
	}
}

object menus {
	method menuInicio() = new Menu(image='bman/menuBomberman.png',opcionSeleccionada=opcionComenzarJuego)
	method menuControles() = new Menu(image='bman/menuControles.png',opcionSeleccionada = opcionMenuPrincipal,opciones=false)
	method menuGameOver() = new Menu(image='bman/menuGameOver.png',opcionSeleccionada=opcionContinuar)
	method menuNivelCompletado() = new Menu(image='bman/pantallaFinal.png',opcionSeleccionada=opcionMenuPrincipal,opciones=false)
}

object eventos {
	method gameOver() = new Evento(soundEffect=jugadorSoundEffect,tiempo=2000,pantalla=menus.menuGameOver())
	method nivelCompletado() = new Evento(soundEffect=victoriaSoundEffect,tiempo=3000,pantalla=menus.menuNivelCompletado())
}

object opcionComenzarJuego {
	method posicion() = game.at(5,7)

	method seleccionar() {
		nivel1.iniciar()
	}
	
	method opcionSuperior() = opcionSalir

	method opcionInferior() = opcionControles
}

object opcionControles {
	method posicion() = game.at(3,5)
	
	method seleccionar() {
		menus.menuControles().iniciar()
	}
	
	method opcionSuperior() = opcionComenzarJuego
	
	method opcionInferior() = opcionSalir
}

object opcionSalir {
	method posicion() = game.at(5,3)

	method seleccionar() {
		game.clear()
		consola.iniciar()
	}

	method opcionSuperior() = opcionControles

	method opcionInferior() = opcionComenzarJuego
}

object opcionContinuar {
	method posicion() = game.at(6,2)

	method seleccionar() {
		nivel1.iniciar()
	}

	method opcionSuperior() = opcionMenuPrincipal

	method opcionInferior() = self.opcionSuperior()
}

object opcionMenuPrincipal {
	method posicion() = game.at(6,1)

	method seleccionar() {
		menus.menuInicio().iniciar()
	}

	method opcionSuperior() = opcionContinuar

	method opcionInferior() = self.opcionSuperior()
}

object flechaMenu {
	var property position
	method image() = "bman/flecha.png"
}
