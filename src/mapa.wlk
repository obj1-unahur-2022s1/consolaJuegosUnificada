import bomberman.*
import wollok.game.*

object nivel1 {
	
	method iniciar() {
		game.clear()
		game.addVisualIn(transicionNivelI,game.origin())
		puntos.puntos(0)
		bombas.cantidad(1)
		explosiones.alcance(1)
		game.schedule(3000,{self.configurar()})
	}
	
	method configurar() {
		game.clear()
		game.addVisualIn(fondoDeNivel,game.origin())
//		// BLOQUES
		self.ponerLimites()
		self.ponerBloquesAlternados()
		self.ponerBloquesVulnerables()
//		EL PORTAL
		game.addVisualIn(portal,game.at(15,5))
		// BICHITOS
		new Enemigo(position=game.at(6,5),direccion=oeste).dibujar()
		new Enemigo(position=game.at(13,7),direccion=sur).dibujar()
		// JUGADOR
		game.addVisualIn(bombas,game.at(5,11))
		game.addVisualIn(explosiones,game.at(10.9,11))
		game.addVisualIn(puntos,game.at(1,11))
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
	method ponerBloquesAlternados() {
		const ancho = game.width() - 1
		const largo = game.height() - 1
		const listaFilas = []
		const listaColumnas = []
		
		(2..largo-2).filter {numero => numero.even()}.forEach {numero => listaFilas.add(numero)}
		(2..ancho-2).filter {numero => numero.even()}.forEach {numero => listaColumnas.add(numero)}
		
		listaColumnas.forEach{columna => self.dibujarColumnaDeBloques(listaFilas,columna)}
	}
	method ponerBloquesVulnerables() {		
		self.dibujarFilaDeBloquesVulnerables([5,7,8,10,11,12,13,14,15],9)
		self.dibujarFilaDeBloquesVulnerables([7,9,11,13,15],8)
		self.dibujarFilaDeBloquesVulnerables([1,3,4,5,7,10,11,12,14,15],7)
		self.dibujarFilaDeBloquesVulnerables([3,5,15],6)
		self.dibujarFilaDeBloquesVulnerables([3,7,8,9,14],5)
		self.dibujarFilaDeBloquesVulnerables([5,7,13],4)
		self.dibujarFilaDeBloquesVulnerables([1,2,6,7,8,9,10,11,12,13,14,15],3)
		self.dibujarFilaDeBloquesVulnerables([1,3,5,11,13],2)
		self.dibujarFilaDeBloquesVulnerables([1,2,3,4,5,6,7,8,10,11,14,15],1)
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

object bombas {
	var property cantidad = 1
	method powerUp(){
		cantidad += 1
	}
	method text() = cantidad.toString()
	method textColor() = "FFFFFFFF"
}

object explosiones {
	var property alcance = 1
	method powerUp(){
		alcance += 1
	}
	method text() = "x" + alcance.toString()
	method textColor() = "FFFFFFFF"
}

object puntos {
	var property puntos = 0
	method aniadirPunto() {
		puntos += 1
	}
	method text() = "puntos: " + puntos.toString()
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