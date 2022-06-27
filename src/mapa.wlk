import bomberman.*
import wollok.game.*

object nivel1 {
	
	method iniciar() {
		game.clear()
		game.addVisualIn(transicionNivelI,game.origin())
		game.schedule(3000,{self.configurar()})
	}
	
	method configurar() {
		game.clear()
		game.addVisualIn(fondoDeNivel,game.origin())
//		// BLOQUES
		self.ponerLimites()
		self.ponerBloques()
		self.ponerBloquesVulnerables()
//		EL PORTAL
		game.addVisualIn(portal,game.at(15,2))
		// BICHITOS
		new Enemigo(position=game.at(1,5),direccion=sur).dibujar()
		new Enemigo(position=game.at(3,7),direccion=oeste).dibujar()
		new Enemigo(position=game.at(10,9),direccion=oeste).dibujar()
		new Enemigo(position=game.at(14,1),direccion=oeste).dibujar()
		// JUGADOR
		game.addVisualIn(jugador_bombas,game.at(5,11))
		game.addVisualIn(jugador_explosion,game.at(10.9,11))
		game.addVisualIn(jugador_puntos,game.at(1,11))
		jugador.iniciar()
	}
	method ponerLimites() {
		const ancho = game.width() - 1
		const largo = game.height() - 2
		const posiciones = []
		
		(1..ancho-1).forEach { i => posiciones.add(new Position(x=i,y=0));posiciones.add(new Position(x=i,y=largo)) }
		(0..largo).forEach { i => posiciones.add(new Position(x=0,y=i));posiciones.add(new Position(x=ancho,y=i)) }
		
		posiciones.forEach { pos => game.addVisual(new Bloque(position=pos))}
	}
	method ponerBloques() {
		const ancho = game.width() - 1
		const largo = game.height() - 1
		const listaFilas = []
		const listaColumnas = []
		
		(2..largo-2).filter {numero => numero.even()}.forEach {numero => listaFilas.add(numero)}
		(2..ancho-2).filter {numero => numero.even()}.forEach {numero => listaColumnas.add(numero)}
		
		listaColumnas.forEach{columna => self.dibujarColumnaDeBloques(listaFilas,columna)}
		self.dibujarColumnaDeBloques([3,9],5)
		game.addVisual(new Bloque(position=game.at(9,3)))
		game.addVisual(new Bloque(position=game.at(11,4)))
		game.addVisual(new Bloque(position=game.at(15,3)))
		game.addVisual(new Bloque(position=game.at(4,1)))
	}
	method ponerBloquesVulnerables() {		
		self.dibujarFilaDeBloquesVulnerables([8,9,14],9)
		self.dibujarFilaDeBloquesVulnerables([3,7,9,11],8)
		self.dibujarFilaDeBloquesVulnerables([1,4,6,8,9,10,11,14,15],7)
		self.dibujarFilaDeBloquesVulnerables([1,3,5,7,11,15],6)
		self.dibujarFilaDeBloquesVulnerables([1,3,9],5)
		self.dibujarFilaDeBloquesVulnerables([5,7,13,15],4)
		self.dibujarFilaDeBloquesVulnerables([2,4,8,11,12,13,14],3)
		self.dibujarFilaDeBloquesVulnerables([13],2)
		self.dibujarFilaDeBloquesVulnerables([6],1)
	}
	method dibujarColumnaDeBloques(filas,columna) {
		filas.forEach{nroFila => game.addVisual(new Bloque(position=game.at(columna,nroFila)))}
	}
	method dibujarFilaDeBloquesVulnerables(columnas,fila) {
		columnas.forEach{nroColumna => game.addVisual(new BloqueVulnerable(position=game.at(nroColumna,fila)))}
	}
}

object fondoDeNivel {
	method image() = "bman/pisoMosaico.png"
}

object jugador_bombas {
	method text() = jugador.bombasDisponibles().toString() 
	method textColor() = "FFFFFFFF"
}

object jugador_explosion {
	method text() = "x" +jugador.rangoDeLaExplosion().toString()
	method textColor() = "FFFFFFFF"
}

object jugador_puntos {
	method text() = "puntos: "+jugador.puntos().toString()
	method textColor() = "FFFFFFFF"	
}

object transicionNivelI {
	method image() = "bman/nivel1.png"
}


object norte {
	method siguiente(posicion) = posicion.up(1)
	method opuesto() = sur
}

object este {
	method siguiente(posicion) = posicion.right(1)
	method opuesto() = oeste
}

object sur {
	method siguiente(posicion) = posicion.down(1)
	method opuesto() = norte
}

object oeste {
	method siguiente(posicion) = posicion.left(1)
	method opuesto() = este
}