import wollok.game.*

object selectionSoundEffect {
	method play() {
		game.sound("bman/sonido/seleccion2.mp3").play()
	}
}

object switchSoundEffect {
	method play() {
		game.sound("bman/sonido/seleccion.mp3").play()
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

object bichitoSoundEffect {
	method play() {
		game.sound("bman/sonido/bichito_muere.mp3").play()
	}
}
