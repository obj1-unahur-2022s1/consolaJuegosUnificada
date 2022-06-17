import wollok.game.*

object norte {
	method siguiente(posicion) = posicion.up(1)
	method opuesto() = sur
	method derecha() = oeste
	method izquierda() = este
}

object este {
	method siguiente(posicion) = posicion.right(1)
	method opuesto() = oeste
	method derecha() = norte
	method izquierda() = sur
}

object sur {
	method siguiente(posicion) = posicion.down(1)
	method opuesto() = norte
	method derecha() = este
	method izquierda() = oeste
}

object oeste {
	method siguiente(posicion) = posicion.left(1)
	method opuesto() = este
	method derecha() = sur
	method izquierda() = norte
}