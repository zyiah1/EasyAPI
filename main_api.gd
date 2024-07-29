extends Node2D


var completeurl: String = ""

var API_Response
var RequestOptions = []
signal request_finished



# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	if API_Response:
		if $CanvasLayer/Key.text != "":
			if abs(int($CanvasLayer/Index.text)) == int($CanvasLayer/Index.text): # if positive
				$CanvasLayer/ResponseText.text = str(API_Response[int($CanvasLayer/Index.text)].get_or_add($CanvasLayer/Key.text))
			else:
				$CanvasLayer/ResponseText.text = str(API_Response.get_or_add($CanvasLayer/Key.text))
		else:
			if abs(int($CanvasLayer/Index.text)) == int($CanvasLayer/Index.text): # if positive
				$CanvasLayer/ResponseText.text = str(API_Response[int($CanvasLayer/Index.text)])
			else:
				$CanvasLayer/ResponseText.text = str(API_Response)

func fetch(url:String ="https://www.duckduckgo.com/", headers:Array = [], method = HTTPClient.METHOD_GET,callback:String = "Ducks", body = null):
	if url == null or url == "":
		return null
	var http_request = HTTPRequest.new()
	http_request.download_chunk_size = 165536
	add_child(http_request)
	http_request.connect("request_completed", Callable(self, callback))
	var req
	#request(url: String, custom_headers: PackedStringArray = PackedStringArray(), method: HTTPClient.Method = 0, request_data: String = "")
	if body != null:
		req = http_request.request(url,headers,method,body)
	else:
		req = http_request.request(url,headers,method)
	if req != OK:
		return "error"
		
	

#fetch(url, [], 0, handle_ResponseText)

func handle_Response(result, Response_data, headers, body):
	var Response = JSON.parse_string(body.get_string_from_utf8())
	API_Response = Response
	emit_signal("request_finished")
	
	



func _on_accept_pressed():
	OS.shell_open("https://gamebanana.com/tools/12975")


func _on_decline_pressed():
	$CanvasLayer/patchnotes.hide()


func _on_request_pressed():
	fetch(completeurl, RequestOptions, 0, "handle_Response")
	await self.request_finished
	if $CanvasLayer/OptionButton.selected == 1:
		await get_tree().create_timer(.2).timeout #wait for the text to be updated
		fetch($CanvasLayer/ResponseText.text, [], 0, "handle_Image")



func _on_url_text_changed(new_text):
	completeurl = new_text

func handle_Image(result, Response, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Image couldn't be downloaded. Try a different image.")
	var image = Image.new()
	
	var error = image.load_jpg_from_buffer(body)
	if error != OK:
		error = image.load_png_from_buffer(body)
	if error != OK:
		error = image.load_webp_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image")
	var texture = await ImageTexture.create_from_image(image)
	# Display the image in a TextureRect node.
	if texture != null:
		#$CanvasLayer/ResponseImage/TextureRect.size = texture.get_size()
		$CanvasLayer/ResponseImage/TextureRect.texture = texture


func _on_option_button_item_selected(index):
	match index:
		0:
			$CanvasLayer/ResponseImage.hide()
			$CanvasLayer/ResponseText.show()
		1:
			$CanvasLayer/ResponseImage.show()
			$CanvasLayer/ResponseText.hide()
