import wollok.game.*
import juego.*
import menu.*

class Nivel {
	var property position = null
	var property titulo
	const indice = 0 // Indice de imagen en consola
	const maximoDeAutos = 15
	const velocidadDeAutos = 300 // Tiempo entre pasos para vehiculos
	const vehiculosPorPunto = 3

	method iniciar(){
		vestimenta.vestimentaActual(titulo) // Establece la vestimenta antes de iniciar
		gameDirector.iniciar(maximoDeAutos, velocidadDeAutos, vehiculosPorPunto)
	}
	
	method terminar(){
		gameDirector.terminar()
	}
	
	method image() = "cuack/items/" + indice.toString() + ".png"
}

object wollocuack{
	var property position
	method image() = "cuack/logo.png"
	method iniciar() {
		game.schedule(80, {menuPrincipal.iniciar()})
	}
	method terminar(){
		gameDirector.terminar()
	}
}