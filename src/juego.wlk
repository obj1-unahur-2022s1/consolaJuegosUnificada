import wollok.game.*
import consola.*
import bomberman.*
import menu.*

class Juego {
	var property position = null
	var property color = null
	
	method iniciar(){
        game.addVisual(object{method position()= game.center() method text() = "Juego "+color + " - <q> para salir"})		
	}
	
	method terminar(){}
	
	method image() = "juego" + color + ".png"

}

object bomberman {
	var property position
	method image() = "bman_head.png"
	method iniciar() {
		menus.menuInicio().iniciar()
	}
}
