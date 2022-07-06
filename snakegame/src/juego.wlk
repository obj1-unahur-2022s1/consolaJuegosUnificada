import wollok.game.*
import consola.*
import gameManager.*

class Juego {
	var property position = null
	var property color 
	const juego
	
	method iniciar(){
        juego.iniciar()
	}
	
	method terminar(){

	}
	method image() = "juego" + color + ".png"
	
}

object snakeStarts 
{
	const snaker = new Juego(color = "Verde", juego = new JuegoSnake(dificultad=2))
	var property position
	method image() = "headUp.png"
	method iniciar() 
	{
		snaker.iniciar()
	}
}