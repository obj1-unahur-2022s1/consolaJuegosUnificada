import wollok.game.*
import snake.*


object juegoSnake {
	
	var property position
	var property image = "snake/headUp.png"
	
	const dificultad = 0.5
	
	method iniciar() {
		puntos.reiniciar()
		
		game.title("Snake Game")
		game.boardGround("fondo.png")
		//game.width(53)
		//game.height(38)
		//game.cellSize(16)
		
		// Visuales
		game.addVisual(snake)
		game.addVisual(new Food(dificultad=dificultad))
		game.addVisual(new Insecto(dificultad=dificultad))
		game.addVisual(new Rayo(dificultad=dificultad))
		game.addVisual(puntos)
		
		// Configurar snake
		snake.start()
		//snake.dificultad(dificultad)
		
		// Colisiones
		game.onCollideDo(snake, {obstacle => obstacle.onCollide()})
	}
	
	method terminar(){
	}
}


object sonido {
	var musicVolume = 0.1
	var sfxVolume = 0.25
	
	const gameplayMusic = self.music("gameplay")
	const gameOverMusic = self.music("gameover")
	
	method music(name) {
		 const sound = game.sound("snake/audio/music/" + name + ".mp3")
		 sound.shouldLoop(true)
		 sound.volume(musicVolume)
		 return sound
	}
	
	method effect(name){
		const sound = game.sound("snake/audio/sfx/" + name + ".mp3")
		sound.volume(sfxVolume)
		return sound
	}
	
	method pop() { self.playSound([self.effect("pop1"), self.effect("pop2")].anyOne()) }
	
	method spider() { self.playSound(self.effect("spider")) }
	
	method playSound(sound){ game.schedule(0, {sound.play()}) }
	
	method setup() {
		game.schedule(500, {gameplayMusic.play()})
	}
	
	
}

object puntos {
	
	var cantidadPuntos = 0
	
	method reiniciar() {
		cantidadPuntos = 0
	}
	
	method position() = game.at(1,game.height()-3)
	
	method cantidadPuntos() = cantidadPuntos
	
	method sumarPuntos(puntos) { cantidadPuntos += puntos }
	
	method text() = self.cantidadPuntos().toString() + " puntos"
	
	method onCollide(){}
	
}
