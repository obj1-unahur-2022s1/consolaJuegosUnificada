import wollok.game.*
import consola.*
import juego.*

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
		keyboard.enter().onPressDo{ opcionSeleccionada.seleccionar() game.sound("bman/sonido/seleccion2.mp3").play() }
		flechaMenu.position(opcionSeleccionada.posicion())
		game.addVisual(fondoDelMenu)
		game.addVisual(flechaMenu)
	}
	method cambiarOpcionSeleccionadaA(opcion) {
		opcionSeleccionada = opcion
		flechaMenu.position(opcionSeleccionada.posicion())
		game.sound("bman/sonido/seleccion.mp3").play()
	}
}

object menuControles {
	var property fondoDelMenu

	method iniciar() {
		keyboard.enter().onPressDo{ consola.iniciar() game.sound("bman/sonido/seleccion2.mp3").play() }
		game.addVisual(fondoDelMenu)
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
	
	method seleccionar() {
		game.clear()
		menuControles.fondoDelMenu(fondoControles)
		menuControles.iniciar()
	} //En progreso
	
	method opcionSuperior() = opcionComenzarJuego
	
	method opcionInferior() = opcionSalir
}

object opcionSalir {
	method posicion() = game.at(5,3)

	method seleccionar() {game.schedule(100,{consola.hacerTerminar(bomberman)})}

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

object fondoControles {
	method position() = game.at(0,0)
	method image() = "bman/menuControles.png"
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

object pantallaNivel1 {
	method image() = "bman/nivel1.png"
}
