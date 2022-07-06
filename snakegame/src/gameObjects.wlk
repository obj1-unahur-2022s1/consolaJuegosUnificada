import wollok.game.*

class GameObjectBase {
	var property position = game.center()
	
	method validarPosicionSalidaY(){
		if(position.y() > game.height()-1){
			position = game.at(position.x(),0)
		}
		else if(position.y() < 0){
			position = game.at(position.x(), game.height())
		}
	}
	
	method validarPosicionSalidaX(){
		if(position.x() > game.width()-1){
			position = game.at(0,position.y())
		}
		else if(position.x() < 0){
			position = game.at(game.width(), position.y())
		}
	}
	
	method validarPosicionSalida(){
		self.validarPosicionSalidaX()
		self.validarPosicionSalidaY()
	}
}
