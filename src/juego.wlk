import wollok.game.*
import consola.*
import bomberman.*

class Juego {
	var property position = null
	var property color = null
	
	method iniciar(){
        game.addVisual(object{method position()= game.center() method text() = "Juego "+color + " - <q> para salir"})		
	}
	
	method terminar(){

	}
	method image() = "juego" + color + ".png"
	

}

object bomberman inherits Juego {
	override method image() = "bman_head.png"
	override method iniciar() {
		var nivel = new Nivel1()
		nivel.configurar()
	}
	method avanzarNivel() {
		
	}
}