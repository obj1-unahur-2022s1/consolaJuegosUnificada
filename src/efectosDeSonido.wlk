import wollok.game.*

object selectionSoundEffect {
	method play() {
		game.sound("bman/sonido/seleccion.mp3").play()
	}
}

object cursorSoundEffect {
	method play() {
		game.sound("bman/sonido/cursor.mp3").play()
	}
}

object scoreSoundEffect {
	method play() {
		game.sound("bman/sonido/punto.mp3").play()
	}
}

object bombaSoundEffect {
	method play() {
		game.sound("bman/sonido/bomba.mp3").play()
	}
}

object explosionSoundEffect {
	method play() {
		game.sound("bman/sonido/explosion.mp3").play()
	}
}

object jugadorSoundEffect {
	method play() {
		game.sound("bman/sonido/jugador_muere.mp3").play() 	
	}
}

object victoriaSoundEffect {
	method play() {
		game.sound("bman/sonido/Stage Clear.mp3").play()
	}
}

object powerUpSoundEffect {
	method play() {
		game.sound("bman/sonido/powerUp.mp3").play()
	}
}
