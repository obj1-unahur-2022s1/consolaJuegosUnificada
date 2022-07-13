import wollok.game.*
import snakelib.*
import snakegui.*
import snakemain.*

object snake inherits GameObjectBase {
	var dificultad = 1
	
	var direction = new Direction2D(randomize=true)
	
	var property anterior = null
	var property ultimaPosicion = position
	var ultimoSegmento = null
	var tick = 250 * dificultad
	
	method image() = "snake/head" + direction.toString() + ".png"
	
	method start() {
		// Para la rejugabilidad
		anterior = null
		ultimaPosicion = position
		ultimoSegmento = null
		
		keyboard.up().onPressDo({direction.setUp()})
		keyboard.down().onPressDo({direction.setDown()})
		keyboard.left().onPressDo({direction.setLeft()})
		keyboard.right().onPressDo({direction.setRight()})
		game.onTick(tick, "snakeLoop", { self.mover() })
	}
	
	method dificultad() = dificultad
	method dificultad(nuevaDificultad) {
		self.establecerTick(250 * dificultad)
	} 
	
	method agregarSegmento(){
		const segmento = new SnakeBodypart(position=ultimaPosicion) 
		
		if(anterior == null) anterior = segmento 
		
		
		if(ultimoSegmento != null) ultimoSegmento.anterior(segmento)
		ultimoSegmento = segmento
		game.addVisual(segmento)
	}
	
	method establecerTick(nuevoTick){
		game.removeTickEvent("snakeLoop")
		tick = nuevoTick
		game.onTick(tick, "snakeLoop", { self.mover() })
	}
	
	// Mueve la serpiente en la dirección horizontal establecida
	method moveHorizontal() { position = position.right(direction.x()) }
	
	// Mueve la serpiente en la dirección vertical establecida.
	method moveVertical() { position = position.up(direction.y()) }
	
	method moverAcordeADireccion() {
		self.moveHorizontal()
		self.moveVertical()
	}
	
	// Mueve la serpiente en la dirección establecida.
	method mover() {
		
		ultimaPosicion = position
		self.moverAcordeADireccion()
		self.validarPosicionSalida()
		if(anterior != null) anterior.mover(ultimaPosicion)
	}
}

class SnakeBodypart {
	var property anterior = null
	var property ultimaPosicion = position
	var property position
	method image() = "snake/snakeBody.png"
	
	method mover(nuevaPosicion) {
		ultimaPosicion = position
		position = nuevaPosicion
		if(anterior != null) anterior.mover(ultimaPosicion)
	}
	
	method onCollide() {
		game.say(snake, "Perdiste!")
		endMenu.iniciar()
	}
}

/* CONSUMIBLES */

class Food inherits GameObjectBase {
	var image =  ""
	var dificultad
	
	method image() = image
	
	method initialize() {
		self.setRandomPosition()
	}
	
	method setRandomPosition() {
		image = "snake/fruta" + [1,2,3].anyOne() + ".png"
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
	
	override method image() = "snake/tarantula" + direction.toString() + ".png"
	
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
	
	override method image() = "snake/velocidad.png"
	
	override method onCollide() {
		snake.establecerTick(100 / dificultad)
		game.schedule(1000 * 4, { snake.establecerTick(100) })
		self.setRandomPosition()
	}
	
}