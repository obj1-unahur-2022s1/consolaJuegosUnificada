import wollok.game.*
import wollocuack.*
import juego.*
import consola.*

object menuPrincipal { 
	const niveles = [
		new Nivel(indice = 1, titulo = "desiertoNevado"),
		new Nivel(indice = 2, titulo = "Bosque", velocidadDeAutos = 200),
		new Nivel(indice = 3, titulo = "Ciudad", velocidadDeAutos = 200, vehiculosPorPunto = 4),
		new Nivel(indice = 4, titulo = "desiertoNevado", maximoDeAutos = 20, velocidadDeAutos = 150, vehiculosPorPunto = 4),
		new Nivel(indice = 5, titulo = "Bosque", maximoDeAutos = 20, velocidadDeAutos = 150, vehiculosPorPunto = 6),
		new Nivel(indice = 6, titulo = "Ciudad", maximoDeAutos = 25, velocidadDeAutos = 110, vehiculosPorPunto = 8)
	] 
	var menu 
	const sonido = game.sound("Musica.mp3")
	
	method initialize(){
		// TODO
		//game.title("Wollocuack") 
		//game.boardGround("scene.png")  
	}
	method reproducirMusica(){ 
		if (not sonido.played()){
			sonido.volume(0.5) 
			sonido.shouldLoop(true)
			sonido.play()
		}
	}
	method reiniciarNivel(nivel) {
        nivel.terminar()
        self.hacerIniciar(nivel) 
    }
	method iniciar(){ 
		menu = new MenuIconos(posicionInicial = game.at(6,4)) 	
		game.addVisual(menu)
		niveles.forEach{nivel=>menu.agregarItem(nivel)}
		menu.dibujar()
		keyboard.enter().onPressDo{self.hacerIniciar(menu.itemSeleccionado())}
		game.schedule(1,{self.reproducirMusica()})
	}
	
	method hacerIniciar(nivel){	
		game.clear()
		keyboard.r().onPressDo{self.reiniciarNivel(nivel)}
		keyboard.q().onPressDo{self.hacerTerminar(nivel)}
		nivel.iniciar()
	}
	method hacerTerminar(nivel){
		nivel.terminar()
		game.clear()
		self.iniciar()
		game.schedule(80, {keyboard.q().onPressDo{self.terminarJuego()}})
	}
	method terminarJuego(){
		game.clear()
		consola.iniciar()
	}
}