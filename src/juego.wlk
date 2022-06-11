import wollok.game.*
import consola.*
import juegoBomberman.*

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
	override method iniciar() {
		game.width(13)
		game.height(9)
		game.title("Bomberman Wollok Edition")
		game.cellSize(64)
		game.ground("assets/piso.png")
	
		nivel1.configurar()
	}
	override method image() = "assets/bman_head.png"
}
