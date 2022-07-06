import wollok.game.*
import direction.*
import gameManager.*
import gameObjects.*
import menu.*

object snake inherits GameObjectBase {
	var dificultad = 1
	
	var direction = new Direction2D(randomize=true)
	
	var property anterior = null
	var property ultimaPosicion = position
	var ultimoSegmento = null
	var tick = 250 * dificultad
	
	method image() = "head" + direction.toString() + ".png"
	
	method start() {
		// Para la rejugabilidad
		anterior = null
		ultimaPosicion = position
		ultimoSegmento = null
		
		keyboard.w().onPressDo({direction.setUp()})
		keyboard.s().onPressDo({direction.setDown()})
		keyboard.a().onPressDo({direction.setLeft()})
		keyboard.d().onPressDo({direction.setRight()})
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
	method image() = "snakeBody.png"
	
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