class_name RoomManager
extends Node2D

var current_room: ShopRepresentation.ShopRoom = ShopRepresentation.shop_enterance

func switch_to_next(destination_room: ShopRepresentation.ShopRoom):
	current_room = destination_room
