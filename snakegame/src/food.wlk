import wollok.game.*
import snake.*
import gameManager.*
import direction.*
import gameObjects.*

class Food inherits GameObjectBase {
	var image =  ""
	var dificultad
	
	method image() = image
	
	method initialize() {
		self.setRandomPosition()
	}
	
	method setRandomPosition() {
		image = "fruta" + [1,2,3].anyOne() + ".png"
		position = game.at(0.randomUpTo(game.width()), 0.randomUpTo(game.height()))
	}
	
	method onCollide() {
		snake.agregarSegmento()
		sonido.pop()
		self.setRandomPosition()
		puntos.sumarPuntos(1)
	}
}

class Insecto inherits Food {
	
	var direction = new Direction2D()
	
	override method image() = "tarantula" + direction.toString() + ".png"
	
	override method initialize(){
		super()
		game.onTick(1000 / dificultad, "spiderLoop", {self.move()})
	}
	
	method move(){
		direction = new Direction2D(randomize=true)
		position = game.at(position.x() + direction.x(), position.y() + direction.y())
		self.validarPosicionSalida()
	}
	
	override method onCollide() {
		sonido.spider()
		self.setRandomPosition()
		snake.agregarSegmento()
		puntos.sumarPuntos(3)
	}
}

class Rayo inherits Food {
	
	override method image() = "velocidad.png"
	
	override method onCollide() {
		snake.establecerTick(100 / dificultad)
		game.schedule(1000 * 4, { snake.establecerTick(100) })
		self.setRandomPosition()
	}
	
}

