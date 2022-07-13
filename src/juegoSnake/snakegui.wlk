import wollok.game.*
import snake.*
import snakemain.*
import snakelib.*
import consola.*

object endMenu {

	method iniciar() {
		game.clear()
		game.addVisual(gameOver)
		self.terminarJuego()
	}

	method terminarJuego() {
		keyboard.q().onPressDo({ consola.hacerTerminar(juegoSnake) })
	}
}

object gameOver {
	
	method image() = "snake/youDie.png"
	method position() = game.at(0, 0)
	
}

object fondoMenu {
	
	method image() = "snake/menu.png"
	method position() = game.at(0, 0)
	
}